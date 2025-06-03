#version 120

uniform sampler2D texture;
uniform sampler2D lightmap;

uniform vec4 entityColor;
uniform float blindness;
uniform int isEyeInWater;

// 原有变量
varying vec4 color;
varying vec2 coord0;
varying vec2 coord1;

// 新增变量
varying vec3 viewNormal;
varying vec3 worldNormal;
varying float viewDepth;

// 材质属性默认值
const float DEFAULT_ROUGHNESS = 0.8;
const float DEFAULT_METALLIC = 0.0;
const float DEFAULT_EMISSION = 0.0;

void main()
{
    // 原有的光照计算
    vec3 light = (1.-blindness) * texture2D(lightmap,coord1).rgb;
    
    // 纹理采样和颜色计算
    vec4 col = color * vec4(light,1) * texture2D(texture,coord0);
    col.rgb = mix(col.rgb, entityColor.rgb, entityColor.a);

    // 雾效计算
    float fog = (isEyeInWater>0) ? 1.-exp(-gl_FogFragCoord * gl_Fog.density):
    clamp((gl_FogFragCoord-gl_Fog.start) * gl_Fog.scale, 0., 1.);

    // 应用雾效
    col.rgb = mix(col.rgb, gl_Fog.color.rgb, fog);

    // 1. 原始颜色输出 (colortex0) - 保持不变
    gl_FragData[0] = col;

    // 2. 输出法线和深度 (colortex1)
    // 将法线从[-1,1]范围编码到[0,1]范围
    vec3 encodedNormal = normalize(viewNormal) * 0.5 + 0.5;
    float encodedDepth = gl_FragCoord.z; // 使用非线性深度
    gl_FragData[1] = vec4(encodedNormal, encodedDepth);

    // 3. 输出材质属性 (colortex2)
    // 可以根据方块ID或纹理样式设置不同的材质属性
    float roughness = DEFAULT_ROUGHNESS;
    float metallic = DEFAULT_METALLIC;
    float emission = length(light) > 1.3 ? 0.5 : DEFAULT_EMISSION; // 基于光照图检测发光方块
    
    gl_FragData[2] = vec4(roughness, metallic, emission, 1.0);
}