#version 150 core
in vec3 vaPosition;
in vec3 vaNormal;
in vec2 vaTexCoord0;

uniform mat4 modelViewMat;
uniform mat4 modelMat;
uniform mat4 projMat;

out vec3 worldPos;
out vec3 worldNormal;
out vec2 texCoord;

void main() {
    vec4 posWorld = modelMat * vec4(vaPosition,1.0);
    gl_Position   = projMat * modelViewMat * vec4(vaPosition,1.0);

    worldPos    = posWorld.xyz;
    worldNormal = normalize(mat3(modelMat) * vaNormal);
    texCoord    = vaTexCoord0;
}
