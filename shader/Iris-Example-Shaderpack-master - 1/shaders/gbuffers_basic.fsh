#version 120

uniform float blindness;
uniform int isEyeInWater;

varying vec4 color;
// 新增变量
varying vec3 viewNormal;
varying float viewDepth;

// 材质默认值
const float DEFAULT_ROUGHNESS = 0.8;
const float DEFAULT_METALLIC = 0.0;
const float DEFAULT_EMISSION = 0.0;

void main()
{
    vec4 col = color;

    // 雾效计算
    float fog = (isEyeInWater>0) ? 1.-exp(-gl_FogFragCoord * gl_Fog.density):
    clamp((gl_FogFragCoord-gl_Fog.start) * gl_Fog.scale, 0., 1.);

    // 应用雾效
    col.rgb = mix(col.rgb, gl_Fog.color.rgb, fog);

    // 1. 输出颜色 (colortex0)
    gl_FragData[0] = col * vec4(vec3(1.-blindness),1);

    // 2. 输出法线和深度 (colortex1)
    vec3 encodedNormal = normalize(viewNormal) * 0.5 + 0.5;
    float encodedDepth = gl_FragCoord.z;
    gl_FragData[1] = vec4(encodedNormal, encodedDepth);

    // 3. 输出材质属性 (colortex2)
    gl_FragData[2] = vec4(DEFAULT_ROUGHNESS, DEFAULT_METALLIC, DEFAULT_EMISSION, 1.0);
}