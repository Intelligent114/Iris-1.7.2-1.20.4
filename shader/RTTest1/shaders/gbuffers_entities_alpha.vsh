#version 150 core
in vec3 vaPosition;
in vec3 vaNormal;
in vec2 vaTexCoord0;

uniform mat4 modelViewMat;
uniform mat4 modelMat;
uniform mat4 projMat;

out vec3 wPos;
out vec3 wNorm;
out vec2 uv;

void main() {
    vec4 posW   = modelMat * vec4(vaPosition, 1);
    gl_Position = projMat * modelViewMat * vec4(vaPosition, 1);

    wPos  = posW.xyz;
    wNorm = normalize(mat3(modelMat) * vaNormal);
    uv    = vaTexCoord0;
}
