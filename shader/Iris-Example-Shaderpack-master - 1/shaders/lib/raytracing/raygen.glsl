#ifndef RAYGEN_GLSL
#define RAYGEN_GLSL

#include "/lib/buffers.glsl"
#include "/lib/raytracing/intersect.glsl"

// 从屏幕空间坐标和深度重建世界空间坐标
vec3 screenToView(vec3 screenPos) {
    vec4 pos = gbufferProjectionInverse * vec4(screenPos * 2.0 - 1.0, 1.0);
    return pos.xyz / pos.w;
}

// 从视图空间转换到世界空间
vec3 viewToWorld(vec3 viewPos) {
    return (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz + cameraPosition;
}

// 从世界空间转换到视图空间
vec3 worldToView(vec3 worldPos) {
    return (gbufferModelView * vec4(worldPos - cameraPosition, 1.0)).xyz;
}

// 生成一个符合余弦加权分布的随机方向
vec3 generateRandomDirection(vec3 normal, vec2 seed) {
    // 生成随机角度
    float phi = 2.0 * 3.14159265 * random(seed);
    float cosTheta = sqrt(random(seed * vec2(1.71, 0.66)));
    float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
    
    // 创建一个与normal正交的坐标系
    vec3 tangent, bitangent;
    createOrthonormalBasis(normal, tangent, bitangent);
    
    // 返回在半球范围内的随机方向
    return normalize(tangent * (cos(phi) * sinTheta) + 
                    bitangent * (sin(phi) * sinTheta) + 
                    normal * cosTheta);
}

// 生成光线
Ray generateRay(vec2 texCoord, float depth, vec3 normal, vec2 pixelOffset) {
    Ray ray;
    
    // 获取视图空间位置（可选择添加像素偏移）
    vec2 jitteredCoord = texCoord + pixelOffset / vec2(viewWidth, viewHeight);
    vec3 viewPos = screenToView(vec3(jitteredCoord, depth));
    
    // 转换到世界空间
    vec3 worldPos = viewToWorld(viewPos);
    vec3 worldNormal = mat3(gbufferModelViewInverse) * normal;
    
    // 设置光线起点（稍微偏移以避免自相交）
    ray.origin = worldPos + worldNormal * 0.001;
    
    // 使用pixelOffset作为随机种子生成半球随机方向
    ray.direction = generateRandomDirection(worldNormal, texCoord + pixelOffset);
    
    ray.tMin = 0.001;
    ray.tMax = RT_MAX_DISTANCE;
    
    return ray;
}

#endif // RAYGEN_GLSL