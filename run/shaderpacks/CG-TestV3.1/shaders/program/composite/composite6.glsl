#include "/lib/common.glsl"

#ifdef FRAGMENT_SHADER

noperspective in vec2 texCoord;

#include "/lib/pipelineSettings.glsl"

const bool colortex3MipmapEnabled = true;

vec2 view = vec2(viewWidth, viewHeight);

float GetLinearDepth(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

#ifdef TAA
    #include "/lib/aa/taa.glsl"
#endif

void main() {
    vec3 color = texelFetch(colortex3, texelCoord, 0).rgb;

    vec3 temp = vec3(0.0);
    float z1 = 0.0;

    #if defined TAA || defined TEMPORAL_FILTER
        z1 = texelFetch(depthtex1, texelCoord, 0).r;
    #endif

    #ifdef TAA
        DoTAA(color, temp, z1);
    #endif

    /* DRAWBUFFERS:32 */
    gl_FragData[0] = vec4(color, 1.0);
    gl_FragData[1] = vec4(temp, 1.0);


    #if BLOCK_REFLECT_QUALITY >= 3 && RP_MODE >= 1
        /* DRAWBUFFERS:321 */
        gl_FragData[2] = vec4(z1, 1.0, 1.0, 1.0);
    #endif
}
#endif

#ifdef VERTEX_SHADER

noperspective out vec2 texCoord;

void main() {
    gl_Position = ftransform();

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
