#version 150

// 输入顶点数据
in vec4 Position;

// 输出到片段着色器的数据
out vec2 texCoord;

void main() {
    // 直接传递顶点位置（全屏四边形）
    gl_Position = Position;
    
    // 计算纹理坐标（从NDC坐标转换到0-1范围）
    texCoord = Position.xy * 0.5 + 0.5;
}