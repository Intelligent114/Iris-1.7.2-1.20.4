#version 150 core
//
// 把 colortex0 直接输出
//

uniform sampler2D colortex0;   // Iris 自动绑定

out vec4 fragColor;

void main() {
    // 使用 gl_FragCoord 求像素坐标，再除以分辨率得到 UV
    vec2 resolution = textureSize(colortex0, 0);
    vec2 uv = gl_FragCoord.xy / resolution;

    fragColor = texture(colortex0, uv);
}

