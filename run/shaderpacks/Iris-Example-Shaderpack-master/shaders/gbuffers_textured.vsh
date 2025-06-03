#version 120

attribute float mc_Entity;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

// 原有变量
varying vec4 color;
varying vec2 coord0;
varying vec2 coord1;

// 新增变量，用于光线追踪
varying vec3 viewNormal;     // 视图空间法线
varying vec3 worldNormal;    // 世界空间法线
varying float viewDepth;     // 视图空间深度

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
    
    // 对于平坦方块使用向上的法线，否则使用世界空间法线
    worldNormal = (mc_Entity==1.) ? vec3(0,1,0) : (gbufferModelViewInverse * vec4(viewNormal,0)).xyz;
    
    // 计算简单的光照
    float light = min(worldNormal.x * worldNormal.x * 0.6f + worldNormal.y * worldNormal.y * 0.25f * (3.0f + worldNormal.y) + worldNormal.z * worldNormal.z * 0.8f, 1.0f);

    // 输出带光照的颜色
    color = vec4(gl_Color.rgb * light, gl_Color.a);
    
    // 输出纹理坐标
    coord0 = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    coord1 = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    
    // 记录视图空间Z坐标（用于深度）
    viewDepth = (gl_ModelViewMatrix * gl_Vertex).z;
}