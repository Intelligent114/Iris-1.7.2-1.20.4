#version 120

uniform sampler2D texture;
uniform float blindness;
uniform int isEyeInWater;

varying vec4 color;
varying vec2 coord0;
// 新增变量
varying float viewDepth;
varying vec3 viewNormal;

// 云的材质属性
const float CLOUD_ROUGHNESS = 0.9;
const float CLOUD_METALLIC = 0.0;
const float CLOUD_EMISSION = 0.0;

void main()
{
    // 可见度
    vec3 light = vec3(1.-blindness);
    // 采样纹理
    vec4 col = color * vec4(light,1) * texture2D(texture,coord0);

    // 雾效计算
    float fog = (isEyeInWater>0) ? 1.-exp(-gl_FogFragCoord * gl_Fog.density):
    clamp((gl_FogFragCoord-gl_Fog.start) * gl_Fog.scale, 0., 1.);

    // 应用雾效
    col.rgb = mix(col.rgb, gl_Fog.color.rgb, fog);

    // 1. 输出颜色 (colortex0)
    gl_FragData[0] = col;

    // 2. 输出法线和深度 (colortex1)
    vec3 encodedNormal = normalize(viewNormal) * 0.5 + 0.5;
    gl_FragData[1] = vec4(encodedNormal, gl_FragCoord.z);

    // 3. 输出云的材质属性 (colortex2)
    gl_FragData[2] = vec4(CLOUD_ROUGHNESS, CLOUD_METALLIC, CLOUD_EMISSION, col.a); // 使用alpha进行半透明判断
}