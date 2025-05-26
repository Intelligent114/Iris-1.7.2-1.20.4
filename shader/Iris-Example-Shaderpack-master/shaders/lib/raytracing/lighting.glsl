#ifndef LIGHTING_GLSL
#define LIGHTING_GLSL

#include "/lib/buffers.glsl"
#include "/lib/raytracing/intersect.glsl"
#include "/lib/raytracing/raygen.glsl"

// 阴影测试
float shadowTest(vec3 position, vec3 lightDir, float maxDistance) {
    Ray shadowRay;
    shadowRay.origin = position;
    shadowRay.direction = lightDir;
    shadowRay.tMin = 0.001;
    shadowRay.tMax = maxDistance;
    
    HitInfo hitInfo = traceRay(shadowRay);
    return hitInfo.hit ? 0.0 : 1.0;
}

// 环境光遮蔽
float ambientOcclusion(vec3 position, vec3 normal, int samples) {
    float ao = 0.0;
    float radius = 1.0;
    
    for (int i = 0; i < samples; i++) {
        // 生成随机方向，使用位置和样本索引作为随机种子
        vec2 seed = position.xz + vec2(i * 0.13, i * 0.37);
        vec3 randomDir = generateRandomDirection(normal, seed);
        
        // 创建光线
        Ray aoRay;
        aoRay.origin = position;
        aoRay.direction = randomDir;
        aoRay.tMin = 0.001;
        aoRay.tMax = radius;
        
        // 检测碰撞
        HitInfo hitInfo = traceRay(aoRay);
        
        // 如果没有碰撞，增加AO值
        if (!hitInfo.hit) {
            ao += 1.0;
        }
    }
    
    // 归一化结果
    return ao / float(samples);
}

// 简单方向光源
struct DirectionalLight {
    vec3 direction;
    vec3 color;
    float intensity;
};

// 计算直接光照
vec3 calculateDirectLight(DirectionalLight light, vec3 position, vec3 normal, float roughness) {
    float NdotL = max(dot(normal, light.direction), 0.0);
    
    // 阴影测试
    float shadow = shadowTest(position, light.direction, 100.0);
    
    // 结合粗糙度的漫反射光照
    float diffuse = NdotL * (1.0 - roughness * 0.5);
    
    return light.color * light.intensity * diffuse * shadow;
}

// 简单点光源
struct PointLight {
    vec3 position;
    vec3 color;
    float intensity;
    float radius;
};

// 计算点光源照明
vec3 calculatePointLight(PointLight light, vec3 position, vec3 normal, float roughness) {
    vec3 lightDir = normalize(light.position - position);
    float distance = length(light.position - position);
    
    if (distance > light.radius)
        return vec3(0.0);
        
    float NdotL = max(dot(normal, lightDir), 0.0);
    
    // 距离衰减
    float attenuation = 1.0 / (1.0 + distance * distance / (light.radius * light.radius));
    
    // 阴影测试
    float shadow = shadowTest(position, lightDir, distance);
    
    // 结合粗糙度的漫反射光照
    float diffuse = NdotL * (1.0 - roughness * 0.5);
    
    return light.color * light.intensity * diffuse * attenuation * shadow;
}

#endif // LIGHTING_GLSL