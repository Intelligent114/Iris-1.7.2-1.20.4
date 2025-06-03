#include "/lib/common.glsl"
#ifdef FRAGMENT_SHADER

noperspective in vec2 texCoord;

float GetLinearDepth(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

#if FXAA_DEFINE == 1
    #include "/lib/aa/fxaa.glsl"
#endif

void main() {
    vec3 color = texelFetch(colortex3, texelCoord, 0).rgb;

    #if FXAA_DEFINE == 1
        FXAA311(color);
    #endif

    /* DRAWBUFFERS:3 */
    gl_FragData[0] = vec4(color, 1.0);
}
#endif

#ifdef VERTEX_SHADER

noperspective out vec2 texCoord;
void main() {
    gl_Position = ftransform();

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
