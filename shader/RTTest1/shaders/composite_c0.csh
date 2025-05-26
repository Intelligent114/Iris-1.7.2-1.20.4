#version 450 core
layout(local_size_x=8, local_size_y=8) in;

layout(binding=0, rgba16f) uniform readonly  image2D accumImg;
layout(binding=1, rgba16f) uniform writeonly image2D pingImg;   // colortex1
layout(binding=2, rgba16f) uniform readonly  image2D gPos;      // colortex2
layout(binding=3, rg16f)   uniform readonly  image2D gNorm;     // colortex3
layout(binding=4, rgba8)   uniform readonly  image2D gAlb;      // colortex4

uniform int  frameCounter;
uniform vec2 viewSize;
uniform vec3 cameraPos; // 可用于更高级的效果，但当前未直接使用

// Iris 会自动提供这些矩阵
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;
uniform mat4 gbufferModelViewInverse;  // 可能未来有用
uniform mat4 gbufferProjectionInverse; // 可能未来有用

#include "/include/hashing.glsl"
#include "/include/sampling.glsl"
#include "/include/octa_normal.glsl"

/* 简易工具 */
vec3  worldPos(ivec2 p){ return imageLoad(gPos, p).xyz; }
float depthEye(ivec2 p){ return imageLoad(gPos, p).w; }         // 负值，视图空间Z
vec3  normalP (ivec2 p){ return decodeOcta(imageLoad(gNorm,p).xy); }
vec3  albedoP (ivec2 p){ return pow(imageLoad(gAlb, p).rgb, vec3(2.2)); } // 从 sRGB 校正到线性

/* 将世界坐标点 P 转换到裁剪空间坐标 */
vec4 clipFromWorld(vec3 worldP) {
    vec4 viewPos = gbufferModelView * vec4(worldP, 1.0);
    return gbufferProjection * viewPos;
}

/* 检查像素是否有有效的几何体数据 */
bool hasValidGeometry(ivec2 p) {
    // 检查像素是否在屏幕范围内
    if (any(lessThan(p, ivec2(0))) || any(greaterThanEqual(p, ivec2(viewSize)))) {
        return false;
    }
    // 检查世界位置是否接近零向量 (通常表示天空或无效数据)
    // GBuffer 中的深度通常存储为 -z_eye，所以 w 分量不为零表示有几何体
    return abs(imageLoad(gPos, p).w) > 0.001;
}

vec3 sampleGI(ivec2 pix, inout uint seed){
    // 如果当前像素没有有效的几何体 (例如天空像素)，直接返回天空颜色
    if (!hasValidGeometry(pix)) {
        return vec3(0.04); // 天空背景色
    }

    vec3 P = worldPos(pix);
    vec3 N = normalP(pix);

    // 稍微偏移光线起点，防止自相交
    P += N * 0.01; // 偏移量可以根据场景尺度调整

    vec3 dir = cosineHemisphere(N, seed); // 在法线方向的半球内采样一个随机方向

    const float tMax  = 16.0; // 光线追踪的最大距离，可以调整
    const int   steps = 64;   // 光线步进的次数，可以调整
    float dt = tMax / float(steps);

    for(int i = 1; i <= steps; ++i){
        vec3 Q = P + dir * dt * float(i); // 当前光线步进到的点
        vec4 clip = clipFromWorld(Q);     // 将该点转换到裁剪空间

        // 如果 w <= 0，点在视锥体后面或非常远，无效
        if (clip.w <= 0.001) continue;

        // 转换到归一化设备坐标 (NDC)，再到屏幕纹理坐标 (UV)
        vec2 uv = clip.xy / clip.w * 0.5 + 0.5;

        // 如果 UV 超出 [0,1] 范围，说明光线射出屏幕
        if(any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0)))) break;

        ivec2 qp = ivec2(uv * viewSize); // 将 UV 转换回像素坐标

        // 检查光线碰撞到的像素是否有有效几何体
        if (!hasValidGeometry(qp)) continue;

        /* 深度比较：判断光线是否被场景中的几何体截断 */
        // eyeHit 是光线当前点 Q 在视图空间中的 -Z 值 (即到近裁剪面的距离)
        float eyeHit = -clip.w;
        // surfaceDepth 是 GBuffer 中 qp 像素处存储的视图空间 -Z 值
        float surfaceDepth = depthEye(qp);

        // 如果光线点 Q 比 GBuffer 中的表面更近 (eyeHit 更小，因为是负Z值比较，所以 eyeHit > surfaceDepth)
        // 并且两者足够接近 (在 0.1 的阈值内)，则认为发生碰撞
        // 注意：depthEye 返回的是负值。eyeHit 也是负的 clip.w。
        // 我们希望 eyeHit (光线上的点) "接近于" surfaceDepth (GBuffer上的点)
        // 并且 eyeHit "在" surfaceDepth "之前或之上" (即 -clip.w > depthEye(qp) 或 -clip.w ≈ depthEye(qp))
        // eyeHit - surfaceDepth < threshold  => -clip.w - depthEye(qp) < threshold
        if (eyeHit > surfaceDepth - 0.1 && eyeHit < surfaceDepth + 0.1) { // 更鲁棒的比较
        // 或者使用一个小的正阈值来检查是否足够接近表面:
        // if (abs(eyeHit - surfaceDepth) < 0.1 && eyeHit >= surfaceDepth - 0.01) { // 确保光线点不穿透太深
            return albedoP(qp) * max(0.0, dot(dir, normalP(qp))); // 返回击中点的颜色贡献
        }
    }
    return vec3(0.04); // 如果没有击中任何物体，返回天空背景色
}

void main(){
    ivec2 pix = ivec2(gl_GlobalInvocationID.xy);
    if(any(greaterThanEqual(pix, ivec2(viewSize)))) return;

    // 如果当前像素本身就是天空，则直接写入天空色并混合
    if (!hasValidGeometry(pix)) {
        vec3 prev = imageLoad(accumImg, pix).rgb;
        float alpha = (frameCounter == 0) ? 1.0 : 1.0 / float(frameCounter + 1); // 防止 frameCounter 为 0
        if (frameCounter > 64) alpha = 0.02; // 稳定后减小混合率
        vec3 mixC = mix(prev, vec3(0.04), alpha);
        imageStore(pingImg, pix, vec4(mixC, 1.0));
        return;
    }

    uint seed = uint(pix.x + pix.y * int(viewSize.x)) ^ uint(frameCounter); // 更稳健的种子生成
    seed = wangHash(seed); // 初始化种子

    vec3 gi = sampleGI(pix, seed);

    vec3 prev = imageLoad(accumImg, pix).rgb;
    // 改进累积混合的 alpha 值
    float alpha = (frameCounter == 0) ? 1.0 : 1.0 / float(frameCounter + 1); // 防止 frameCounter 为 0
    if (frameCounter > 64) alpha = 0.02; // 稳定后减小混合率

    vec3 mixC = mix(prev, gi, alpha);

    imageStore(pingImg, pix, vec4(mixC,1.0));
}