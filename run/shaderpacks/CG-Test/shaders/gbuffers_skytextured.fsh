#version 120

uniform sampler2D texture;
uniform float blindness;
uniform int isEyeInWater;

varying vec4 color;
varying vec2 coord0;
// 新增变量
varying vec3 viewDir;

// 天空的特殊材质属性
const float SKY_ROUGHNESS = 0.0;
const float SKY_METALLIC = 0.0;
const float SKY_EMISSION = 0.3;  // 天空有微弱自发光

void main()
{
    // 可见度
    vec3 light = vec3(1.-blindness);
    // 采样纹理
    vec4 col = color * vec4(light,1) * texture2D(texture,coord0);

    // 1. 输出颜色 (colortex0)
    gl_FragData[0] = col;

    // 2. 输出天空的法线和最大深度 (colortex1)
    // 对于天空，使用视图方向的反方向作为法线（指向相机）
    vec3 skyNormal = normalize(-viewDir) * 0.5 + 0.5;
    gl_FragData[1] = vec4(skyNormal, 1.0);  // 深度设为最大值1.0表示天空

    // 3. 输出天空的材质属性 (colortex2)
    gl_FragData[2] = vec4(SKY_ROUGHNESS, SKY_METALLIC, SKY_EMISSION, 1.0);
}