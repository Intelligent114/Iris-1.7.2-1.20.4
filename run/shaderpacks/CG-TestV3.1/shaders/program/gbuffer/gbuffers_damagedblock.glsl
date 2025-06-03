#include "/lib/common.glsl"
#ifdef FRAGMENT_SHADER

in vec2 texCoord;

flat in vec4 glColor;

#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/others/colorCodedPrograms.glsl"
#endif


void main() {
    vec4 color = texture2D(tex, texCoord);
    color.rgb *= glColor.rgb;

    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);
    #endif

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}

#endif

#ifdef VERTEX_SHADER

out vec2 texCoord;

flat out vec4 glColor;

void main() {
    gl_Position = ftransform();
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glColor = gl_Color;
}

#endif
