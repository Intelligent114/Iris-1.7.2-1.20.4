#include "/lib/common.glsl"
#ifdef FRAGMENT_SHADER

in vec2 texCoord;

in vec4 glColor;

#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/others/colorCodedPrograms.glsl"
#endif

void main() {
    vec4 color = texture2D(tex, texCoord) * glColor;

    #ifdef IPBR
        if (CheckForColor(color.rgb, vec3(224, 121, 250))) {
            color.rgb = vec3(0.8, 0.25, 0.8);
        }
    #endif

    color.rgb *= 1.0 - 0.6 * pow2(pow2(min1(GetLuminance(color.rgb) * 1.2)));

    color.rgb = pow1_5(color.rgb);
    color.rgb *= pow2(1.0 + color.b + 0.5 * color.g) * 1.5;

    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);
    #endif

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}
#endif

#ifdef VERTEX_SHADER

out vec2 texCoord;

out vec4 glColor;

void main() {
    gl_Position = ftransform();

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    glColor = gl_Color;
}
#endif
