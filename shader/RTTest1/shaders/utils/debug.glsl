/******************************************************
 *  debug.glsl  —  可视化 G-Buffer 的工具函数
 *  用法：
 *      #include "/include/debug.glsl"
 *      if (debugMode != 0) { fragColor = vec4(debugView(pix), 1); return; }
 *****************************************************/
#include "../include/octa_normal.glsl"

layout(binding = 2) uniform readonly image2D gPos;   // colortex2
layout(binding = 3) uniform readonly image2D gNorm;  // colortex3
layout(binding = 4) uniform readonly image2D gAlb;   // colortex4

// 约定由 Java / Iris Custom Uniform 注入
uniform int debugMode;   // 0-关闭, 1-Pos, 2-Normal, 3-Albedo

vec3 debugView(ivec2 p) {
    if (debugMode == 1) {                     // World-Pos → 0-10 m 映射到彩虹
        vec3 w = imageLoad(gPos, p).xyz * 0.1;
        return fract(w);
    }
    if (debugMode == 2) {                     // Normal → 重映射 0-1
        return decodeOcta(imageLoad(gNorm, p).xy) * 0.5 + 0.5;
    }
    if (debugMode == 3) {                     // Albedo
        return pow(imageLoad(gAlb, p).rgb, vec3(1.0/2.2));
    }
    return vec3(0);                           // 默认黑
}
