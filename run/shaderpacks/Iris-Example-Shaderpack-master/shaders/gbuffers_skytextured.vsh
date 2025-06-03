#version 120

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

varying vec4 color;
varying vec2 coord0;
// 新增变量
varying vec3 viewDir;

void main()
{
    // 计算世界空间位置
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (gbufferModelViewInverse * vec4(pos,1)).xyz;

    // 输出位置
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos,1);
    
    // 计算视图方向（用于天空的法线）
    viewDir = normalize(pos);

    // 输出颜色
    color = vec4(gl_Color.rgb, gl_Color.a);
    // 输出纹理坐标
    coord0 = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}