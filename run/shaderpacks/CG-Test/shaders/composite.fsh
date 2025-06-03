#version 150

#include "/lib/buffers.glsl"
#include "/lib/raytracing/raygen.glsl"
#include "/lib/raytracing/intersect.glsl"
#include "/lib/raytracing/materials.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:34 */
layout(location = 0) out vec4 outColor;  // colortex3 - 累积光追结果
layout(location = 1) out vec4 outFinal;  // colortex4 - 当前帧结果

// 配置参数 - 使用宏定义防止重复定义
#ifndef RT_SAMPLES
    #define RT_SAMPLES 3     // 每像素光线样本数
#endif
#ifndef RT_BOUNCES
    #define RT_BOUNCES 5     // 最大光线弹射次数
#endif
#ifndef RT_MAX_DISTANCE
    #define RT_MAX_DISTANCE 128.0  // 最大光线追踪距离
#endif

// 相机运动检测参数
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform vec3 previousCameraPosition;
uniform float frameTimeCounter;

// frameCounter已在buffers.glsl中定义，不再重复声明

// 获取表面信息
struct SurfaceInfo {
    vec3 albedo;
    vec3 normal;
    float roughness;
    float metallic;
    float emission;
    float specular;
    float depth;
};

// 检查相机是否移动（用于重置时间累积）
bool cameraHasMoved() {
    vec3 cameraMovement = cameraPosition - previousCameraPosition;
    return length(cameraMovement) > 0.001;
}

// 随机数生成（基于哈希函数和帧计数器）
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233)) + float(frameCounter) * 0.11) * 43758.5453);
}

// 获取表面信息
SurfaceInfo getSurfaceInfo() {
    SurfaceInfo surface;
    
    // 从G-Buffer中提取信息
    vec4 colorSample = texture(colortex0, texCoord);
    vec4 normalDepth = texture(colortex1, texCoord);
    vec4 materialProps = texture(colortex2, texCoord);
    
    surface.albedo = colorSample.rgb;
    surface.normal = normalDepth.rgb * 2.0 - 1.0;
    surface.depth = normalDepth.a;
    surface.roughness = materialProps.r;
    surface.metallic = materialProps.g;
    surface.emission = materialProps.b;
    surface.specular = materialProps.a;
    
    return surface;
}

// 光线追踪着色函数
vec3 traceAndShade() {
    // 获取表面信息
    SurfaceInfo surface = getSurfaceInfo();
    
    // 如果是天空或无效深度，直接返回原始颜色
    if (surface.depth >= 1.0) {
        return surface.albedo;
    }
    
    // 重建世界空间位置
    vec3 viewPos = screenToView(vec3(texCoord, surface.depth));
    vec3 worldPos = viewToWorld(viewPos);
    
    // 累积多个样本的结果
    vec3 totalRadiance = vec3(0.0);
    
    // 添加直接来自材质的发光
    totalRadiance += surface.albedo * surface.emission;
    
    // 多次采样以减少噪声
    for (int sampleIndex = 0; sampleIndex < RT_SAMPLES; sampleIndex++) {
        // 为每个样本生成不同的随机种子
        vec2 pixelOffset = vec2(
            rand(texCoord + vec2(0.1, 0.3) * float(sampleIndex)),
            rand(texCoord + vec2(0.5, 0.7) * float(sampleIndex))
        );
        
        // 生成光线（添加随机性以获得更好的采样分布）
        Ray ray = generateRay(texCoord, surface.depth, surface.normal, pixelOffset);
        
        // 追踪光线
        vec3 radiance = vec3(0.0);
        vec3 throughput = vec3(1.0);
        
        // 俄罗斯轮盘赌参数
        float survivalProbability = 1.0;
        
        for (int bounce = 0; bounce < RT_BOUNCES; bounce++) {
            // 如果光线能量过低，应用俄罗斯轮盘赌决定是否继续
            if (bounce > 1) {
                survivalProbability = min(max(max(throughput.r, throughput.g), throughput.b) * 1.5, 0.95);
                if (rand(texCoord + vec2(float(bounce) * 0.1, frameTimeCounter * 0.01)) > survivalProbability) {
                    break;
                }
                // 补偿光线提前终止导致的能量损失
                throughput /= survivalProbability;
            }
            
            // 追踪光线与场景的交点
            HitInfo hitInfo = traceRay(ray);
            
            if (hitInfo.hit) {
                // 获取材质和发光信息
                vec3 materialColor = getMaterialColor(hitInfo.materialId);
                vec3 emissive = getMaterialEmission(hitInfo.materialId);
                float materialRoughness = getMaterialRoughness(hitInfo.materialId);
                float materialMetallic = getMaterialMetallic(hitInfo.materialId);
                
                // 累积发光贡献
                radiance += throughput * emissive;
                
                // 计算下一次弹射方向
                float selectBRDF = rand(texCoord + vec2(float(bounce) * 0.7, frameTimeCounter * 0.03));
                
                if (selectBRDF < materialMetallic) {
                    // 金属反射（镜面反射方向加上基于粗糙度的随机偏差）
                    vec3 reflectDir = reflect(ray.direction, hitInfo.normal);
                    vec3 randomDir = generateRandomDirection(hitInfo.normal, texCoord + pixelOffset);
                    ray.direction = normalize(mix(reflectDir, randomDir, materialRoughness * materialRoughness));
                } else {
                    // 漫反射
                    ray.direction = generateRandomDirection(hitInfo.normal, texCoord + pixelOffset);
                }
                
                // 更新光线起点和能量
                ray.origin = hitInfo.position + hitInfo.normal * 0.001;
                throughput *= materialColor;
            } else {
                // 光线击中天空
                radiance += throughput * getSkyColor(ray.direction);
                break;
            }
        }
        
        totalRadiance += radiance / float(RT_SAMPLES);
    }
    
    return totalRadiance;
}

void main() {
    // 提取上一帧的累积结果
    vec4 previousResult = texture(colortex3, texCoord);
    
    // 计算本帧的光线追踪结果
    vec3 currentResult = traceAndShade();
    
    // 判断是否需要重置累积（相机移动或场景变化）
    bool resetAccumulation = cameraHasMoved() || (frameCounter % 512 == 0);
    
    // 累积多帧结果以进行降噪
    float accumFrames = resetAccumulation ? 1.0 : previousResult.a + 1.0;
    float frameWeight = 1.0 / accumFrames;
    
    vec3 accumulatedColor;
    if (resetAccumulation) {
        accumulatedColor = currentResult;
    } else {
        accumulatedColor = mix(previousResult.rgb, currentResult, frameWeight);
    }
    
    // 防止NaN和Inf值
    accumulatedColor = clamp(accumulatedColor, vec3(0.0), vec3(30.0));
    
    // 输出累积结果与帧计数
    outColor = vec4(accumulatedColor, accumFrames);
    
    // 输出当前帧结果（用于调试）
    outFinal = vec4(accumulatedColor, 1.0);
}