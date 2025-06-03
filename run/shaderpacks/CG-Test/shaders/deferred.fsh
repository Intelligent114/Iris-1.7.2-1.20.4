#version 150

#include "/lib/buffers.glsl"
#include "/lib/raytracing/lighting.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:012 */
layout(location = 0) out vec4 outColor;      // colortex0
layout(location = 1) out vec4 outNormalDepth; // colortex1
layout(location = 2) out vec4 outMaterialProps; // colortex2

void main() {
    // 从G-buffer读取颜色、法线和深度
    vec4 color = texture(colortex0, texCoord);
    vec4 normalDepth = texture(colortex1, texCoord);
    
    // 如果没有有效深度值，直接输出
    if (normalDepth.a == 1.0) {
        outColor = color;
        outNormalDepth = normalDepth;
        outMaterialProps = texture(colortex2, texCoord);
        return;
    }
    
    // 解码法线
    vec3 normal = normalDepth.rgb * 2.0 - 1.0;
    float depth = normalDepth.a;
    
    // 重建世界空间位置
    vec3 viewPos = screenToView(vec3(texCoord, depth));
    vec3 worldPos = viewToWorld(viewPos);
    
    // 读取材质属性
    vec4 materialProps = texture(colortex2, texCoord);
    float roughness = materialProps.r;
    float metallic = materialProps.g;
    float emission = materialProps.b;
    
    // 设置主光源（根据时间切换太阳/月亮）
    DirectionalLight mainLight;
    bool isDay = (worldTime < 12000 || worldTime > 23000);
    
    if (isDay) {
        mainLight.direction = normalize(sunPosition);
        mainLight.color = vec3(1.0, 0.9, 0.7);
        mainLight.intensity = 2.0;
    } else {
        mainLight.direction = normalize(moonPosition);
        mainLight.color = vec3(0.2, 0.2, 0.3);
        mainLight.intensity = 0.5;
    }
    
    // 计算直接光照
    vec3 directLight = calculateDirectLight(mainLight, worldPos, normal, roughness);
    
    // 环境光和阴影
    float ao = ambientOcclusion(worldPos, normal, 4);
    vec3 ambient = vec3(0.1, 0.12, 0.15) * ao;
    
    // 添加光照到颜色
    vec3 albedo = color.rgb;
    vec3 litColor = albedo * (ambient + directLight) + albedo * emission;
    
    // 输出最终颜色和不变的G-buffer数据
    outColor = vec4(litColor, color.a);
    outNormalDepth = normalDepth;
    outMaterialProps = materialProps;
}