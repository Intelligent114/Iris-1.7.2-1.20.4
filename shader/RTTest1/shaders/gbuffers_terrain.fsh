#version 150 core
#include "/include/octa_normal.glsl"

in vec3 worldPos;
in vec3 worldNormal;
in vec2 texCoord;

uniform sampler2D terrain;      // Minecraft 默认地形图集

layout(location = 0) out vec4 finalColor;
layout(location = 2) out vec4 out_colortex2; // For gPos + EyeDepth
layout(location = 3) out vec4 out_colortex3; // For gNormal
layout(location = 4) out vec4 out_colortex4; // For gAlbedo + roughness

void main() {
    vec3 albedo = pow(texture(terrain, texCoord).rgb, vec3(2.2));

    /* 写扩展 G-Buffer */
    out_colortex2 = vec4(worldPos, -gl_FragCoord.z);
    out_colortex3 = vec4(encodeOcta(worldNormal),0,0);
    out_colortex4 = vec4(albedo, 1.0); // Assuming roughness is 1.0 for terrain

    /* 依旧输出原版颜色管线（照明可后续替换） */
    finalColor = vec4(albedo, 1);
}
