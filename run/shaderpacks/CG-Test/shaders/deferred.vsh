#version 150

in vec4 Position;

out vec2 texCoord;

void main() {
    // 直接传递顶点位置（全屏四边形）
    gl_Position = vec4(Position.x * 2.0 - 1.0, Position.y * 2.0 - 1.0, Position.z, Position.w);
    
    texCoord = Position.xy;
}