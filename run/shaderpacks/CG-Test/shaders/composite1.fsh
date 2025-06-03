#version 150

#include "/lib/buffers.glsl"
#include "/lib/raytracing/raygen.glsl" 
// 添加此行以获取screenToView函数

in vec2 texCoord;

/* DRAWBUFFERS:4 */
layout(location = 0) out vec4 outColor; // colortex4

// 双边滤波参数
const float SPATIAL_SIGMA = 2.0;
const float COLOR_SIGMA = 0.1;
const int FILTER_RADIUS = 3;

// 光照与色调映射参数
uniform float sunPathRotation; // 太阳路径旋转角度
uniform float exposure = 0.9;  // 曝光度
uniform float saturation = 1.3; // 饱和度
uniform float contrast = 1.0;   // 对比度

// 用于运动检测
uniform float frameTimeCounter;
// cameraPosition 已在buffers.glsl中定义
uniform vec3 previousCameraPosition;

// 应用双边滤波降噪
vec3 bilateralFilter() {
    vec4 center = texture(colortex3, texCoord);
    vec3 result = vec3(0.0);
    float totalWeight = 0.0;
    
    // 获取中心像素的深度和法线
    vec4 normalDepth = texture(colortex1, texCoord);
    float centerDepth = normalDepth.a;
    vec3 centerNormal = normalDepth.rgb * 2.0 - 1.0;
    
    // 如果是天空或没有有效深度，跳过滤波
    if (centerDepth >= 1.0) {
        return center.rgb;
    }
    
    // 重建世界空间位置
    vec3 centerViewPos = screenToView(vec3(texCoord, centerDepth));
    
    for (int x = -FILTER_RADIUS; x <= FILTER_RADIUS; x++) {
        for (int y = -FILTER_RADIUS; y <= FILTER_RADIUS; y++) {
            vec2 offset = vec2(x, y) / vec2(viewWidth, viewHeight);
            vec2 sampleCoord = texCoord + offset;
            
            // 获取样本像素
            vec4 sampleValue = texture(colortex3, sampleCoord);  // 修改为sampleValue
            vec4 sampleNormalDepth = texture(colortex1, sampleCoord);
            float sampleDepth = sampleNormalDepth.a;
            vec3 sampleNormal = sampleNormalDepth.rgb * 2.0 - 1.0;
            
            // 跳过无效深度
            if (sampleDepth >= 1.0) continue;
            
            // 重建样本位置
            vec3 sampleViewPos = screenToView(vec3(sampleCoord, sampleDepth));
            
            // 计算空间权重
            float spatialDist = length(vec2(x, y));
            float spatialWeight = exp(-spatialDist * spatialDist / (2.0 * SPATIAL_SIGMA * SPATIAL_SIGMA));
            
            // 计算颜色权重
            float colorDistance = distance(center.rgb, sampleValue.rgb);  // 定义变量
            float colorWeight = exp(-colorDistance * colorDistance / (2.0 * COLOR_SIGMA * COLOR_SIGMA));
            
            // 计算法线权重
            float normalWeight = max(0.0, dot(centerNormal, sampleNormal));
            normalWeight = pow(normalWeight, 8.0);
            
            // 计算深度权重（基于视图空间距离）
            float depthDiff = distance(centerViewPos, sampleViewPos);
            float depthWeight = exp(-depthDiff * depthDiff * 10.0);
            
            // 组合权重
            float weight = spatialWeight * colorWeight * normalWeight * depthWeight;
            
            result += sampleValue.rgb * weight;
            totalWeight += weight;
        }
    }
    
    // 归一化结果
    if (totalWeight > 0.0001) {
        return result / totalWeight;
    } else {
        return center.rgb;
    }
}

// 色调映射函数 - ACES电影风格
vec3 ACESToneMapping(vec3 color) {
    color *= exposure;
    
    // ACES参数
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    
    return clamp((color * (a * color + b)) / (color * (c * color + d) + e), 0.0, 1.0);
}

// 调整饱和度
vec3 adjustSaturation(vec3 color, float sat) {
    float grey = dot(color, vec3(0.2126, 0.7152, 0.0722));
    return mix(vec3(grey), color, sat);
}

// 调整对比度
vec3 adjustContrast(vec3 color, float cont) {
    return mix(vec3(0.5), color, cont);
}

// 镜头特效：颜色校正、色差、渐晕
vec3 lensEffects(vec3 color, vec2 coord) {
    // 计算到中心的距离（用于渐晕效果）
    float distToCenter = length(coord - 0.5) * 2.0;
    
    // 渐晕效果（边缘变暗）
    float vignette = 1.0 - smoothstep(0.7, 1.4, distToCenter);
    color *= mix(1.0, vignette, 0.3);
    
    // 色差效果（RGB通道轻微偏移）
    if (distToCenter > 0.5) {
        float caStrength = 0.015 * smoothstep(0.5, 1.0, distToCenter);
        vec2 caOffset = normalize(coord - 0.5) * caStrength;
        
        vec3 caColor;
        caColor.r = texture(colortex4, coord + caOffset).r;
        caColor.g = texture(colortex4, coord).g;
        caColor.b = texture(colortex4, coord - caOffset).b;
        
        color = mix(color, caColor, smoothstep(0.5, 1.0, distToCenter) * 0.5);
    }
    
    return color;
}

void main() {
    // 降噪处理
    vec3 filteredColor = bilateralFilter();
    
    // 色调映射
    vec3 tonemappedColor = ACESToneMapping(filteredColor);
    
    // 颜色调整
    tonemappedColor = adjustContrast(tonemappedColor, contrast);
    tonemappedColor = adjustSaturation(tonemappedColor, saturation);
    
    // 应用镜头效果
    tonemappedColor = lensEffects(tonemappedColor, texCoord);
    
    // 伽马校正
    vec3 gammaCorrected = pow(tonemappedColor, vec3(1.0 / 2.2));
    
    // 输出最终颜色
    outColor = vec4(gammaCorrected, 1.0);
}