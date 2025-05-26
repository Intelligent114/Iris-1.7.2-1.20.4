#version 150 core

#extension GL_ARB_shader_image_load_store : require
#extension GL_ARB_shading_language_420pack : require
#extension GL_ARB_shader_storage_image_extended_formats : enable

#include "/include/octa_normal.glsl"
#include "/include/gbuffer_images.glsl"

in vec3 wPos;
in vec3 wNorm;
in vec2 uv;

uniform sampler2D gAtlas;   // 实体贴图（Iris 会自动绑定）
uniform vec3      colorMul; // 部分生物自带色（羊毛、羊驼等）

void main() {
    vec3 albedo = pow(texture(gAtlas, uv).rgb * colorMul, vec3(2.2));

    /* 写入扩展 G-Buffer */
    imageStore(colortex2, ivec2(gl_FragCoord.xy), vec4(wPos, -gl_FragCoord.z));
    imageStore(colortex3, ivec2(gl_FragCoord.xy), vec4(encodeOcta(normalize(wNorm)), 0, 0));
    imageStore(colortex4, ivec2(gl_FragCoord.xy), vec4(albedo, 1));

    /* 先直接按原版方式输出到主颜色缓冲 */
    gl_FragColor = vec4(albedo, 1);
}
