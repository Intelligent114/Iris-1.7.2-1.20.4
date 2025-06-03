#version 150

// 输入顶点数据
in vec4 Position;

// 输出到片段着色器的数据
out vec2 texCoord;

void main() {
    // 直接传递顶点位置（全屏四边形）
    gl_Position = vec4(Position.x * 2.0 - 1.0, Position.y * 2.0 - 1.0, Position.z, Position.w);
    texCoord = Position.xy;
}