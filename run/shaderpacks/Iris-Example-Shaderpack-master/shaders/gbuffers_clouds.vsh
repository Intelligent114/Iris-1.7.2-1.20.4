#version 120

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

varying vec4 color;
varying vec2 coord0;
// 新增变量
varying float viewDepth;
varying vec3 viewNormal;

void main()
{
    // 计算世界空间位置
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (gbufferModelViewInverse * vec4(pos,1)).xyz;

    // 输出位置和雾效
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos,1);
    gl_FogFragCoord = length(pos);
    
    // 云通常是平坦的，使用向上的法线
    viewNormal = (gl_NormalMatrix * vec3(0.0, 1.0, 0.0));
    
    // 视图空间深度
    viewDepth = (gl_ModelViewMatrix * gl_Vertex).z;

    // 输出颜色
    color = gl_Color;
    // 输出纹理坐标
    coord0 = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}