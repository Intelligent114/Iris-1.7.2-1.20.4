#version 120

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

varying vec4 color;
// 新增变量
varying vec3 viewNormal;
varying float viewDepth;

void main()
{
    // 计算世界空间位置
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (gbufferModelViewInverse * vec4(pos,1)).xyz;

    // 输出位置和雾效
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos,1);
    gl_FogFragCoord = length(pos);

    // 计算视图空间法线
    viewNormal = gl_NormalMatrix * gl_Normal;
    
    // 输出颜色
    color = gl_Color;
    
    // 记录视图空间深度
    viewDepth = (gl_ModelViewMatrix * gl_Vertex).z;
}