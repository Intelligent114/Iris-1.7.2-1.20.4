#ifndef BUFFERS_GLSL
#define BUFFERS_GLSL

uniform sampler2D colortex0; // 颜色
uniform sampler2D colortex1; // 法线和深度
uniform sampler2D colortex2; // 材质属性
uniform sampler2D colortex3; // 光线追踪累计结果
uniform sampler2D colortex4; // 最终合成颜色

// 投影相关矩阵
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

// 相机相关
uniform vec3 cameraPosition;
uniform float near;
uniform float far;

// 视图大小
uniform float viewWidth;
uniform float viewHeight;

// 光线追踪设置
#ifndef RT_SAMPLES
    #define RT_SAMPLES 1     // 每像素光线样本数
#endif

#ifndef RT_BOUNCES
    #define RT_BOUNCES 3     // 最大弹射次数
#endif

#ifndef RT_MAX_DISTANCE
    #define RT_MAX_DISTANCE 128.0  // 最大追踪距离
#endif

// 添加太阳/月亮位置和世界时间
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform int worldTime;

// 随机数生成
uniform int frameCounter;

// 随机数函数
float random(vec2 co) {
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt = dot(co.xy, vec2(a, b));
    float sn = mod(dt, 3.14);
    return fract(sin(sn) * c);
}

// 为generateRandomDirection函数创建正交基
void createOrthonormalBasis(vec3 normal, out vec3 tangent, out vec3 bitangent) {
    if (abs(normal.x) > abs(normal.z)) {
        tangent = vec3(-normal.y, normal.x, 0.0);
    } else {
        tangent = vec3(0.0, -normal.z, normal.y);
    }
    tangent = normalize(tangent);
    bitangent = cross(normal, tangent);
}

#endif // BUFFERS_GLSL