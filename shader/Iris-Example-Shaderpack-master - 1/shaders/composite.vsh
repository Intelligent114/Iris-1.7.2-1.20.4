#version 150

// 输入顶点数据
in vec4 Position;

// 输出到片段着色器的数据
out vec2 texCoord;

uniform mat4 projectionMatrix;
uniform vec2 viewSize;
uniform int frameCounter;

void main() {
    // 直接传递顶点位置（全屏四边形）
    gl_Position = Position;
    
    // 计算纹理坐标（从NDC坐标转换到0-1范围）
    texCoord = Position.xy * 0.5 + 0.5;
    
    // 可以添加抖动偏移以实现时间抗锯齿
    // 基于frameCounter生成低差异序列偏移
    // Halton序列(2,3)
    float x = 0.0;
    float y = 0.0;
    
    // TAA 抖动（可选，如果需要更高质量）
    /*
    int i = frameCounter % 8;
    float invBase = 1.0 / 2.0;
    float radical = invBase;
    
    while (i > 0) {
        x += radical * float(i % 2);
        i = i / 2;
        radical *= invBase;
    }
    
    i = frameCounter % 8;
    invBase = 1.0 / 3.0;
    radical = invBase;
    
    while (i > 0) {
        y += radical * float(i % 3);
        i = i / 3;
        radical *= invBase;
    }
    
    // 应用抖动（像素大小）
    texCoord += (vec2(x, y) - 0.5) / viewSize;
    */
}