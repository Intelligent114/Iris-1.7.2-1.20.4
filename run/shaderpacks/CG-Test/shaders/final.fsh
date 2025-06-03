#version 120

#if defined IRIS_FEATURE_ENTITY_TRANSLUCENT && !defined IS_IRIS
#define OLD
#include "/lib/iris_required.glsl"
#elif !defined IS_IRIS
#include "/lib/iris_required.glsl"
#else
uniform sampler2D texture;

// 添加其他G-Buffer纹理

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex4; // 最终光追结果

varying vec4 color;
varying vec2 coord0;

void main()
{
    // 正常渲染（使用光追结果）
    gl_FragData[0] = texture2D(colortex4, coord0);
    
    // 调试用：可以注释上面一行，并取消注释以下某一行来查看特定缓冲区
    
    // 查看原始颜色
    // gl_FragData[0] = texture2D(colortex0, coord0);
    
    // 查看法线
    // vec3 normal = texture2D(colortex1, coord0).rgb * 2.0 - 1.0;
    // gl_FragData[0] = vec4(normal * 0.5 + 0.5, 1.0);
    
    // 查看深度
    // float depth = texture2D(colortex1, coord0).a;
    // gl_FragData[0] = vec4(depth, depth, depth, 1.0);
    
    // 查看材质属性
    // gl_FragData[0] = texture2D(colortex2, coord0);
}
#endif