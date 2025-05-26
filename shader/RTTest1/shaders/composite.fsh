#version 150 core
uniform sampler2D colortex0;  // 累积图
in vec2 v_texCoord; // Input from vertex shader
out vec4 fragColor;

void main() {
    vec3 c = texture(colortex0, v_texCoord).rgb;
    fragColor = vec4(pow(c, vec3(1.0/2.2)), 1.0); // linear→sRGB
}
