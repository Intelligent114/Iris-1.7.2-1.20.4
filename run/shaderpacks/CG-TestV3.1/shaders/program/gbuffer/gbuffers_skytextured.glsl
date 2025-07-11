#include "/lib/common.glsl"
#ifdef FRAGMENT_SHADER

in vec2 texCoord;

flat in vec4 glColor;

#ifdef OVERWORLD
    flat in vec3 upVec, sunVec;
#endif

#ifdef OVERWORLD
    float SdotU = dot(sunVec, upVec);
    float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
    float sunVisibility2 = sunVisibility * sunVisibility;
#endif

#include "/lib/colors/lightAndAmbientColors.glsl"

#ifdef CAVE_FOG
    #include "/lib/atmos/caveFactor.glsl"
#endif

#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/others/colorCodedPrograms.glsl"
#endif

void main() {
    #ifdef OVERWORLD
        vec2 tSize = textureSize(tex, 0);
        vec4 color = texture2D(tex, texCoord);
        color.rgb *= glColor.rgb;

        vec4 screenPos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z, 1.0);
        vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
        viewPos /= viewPos.w;
        vec3 nViewPos = normalize(viewPos.xyz);

        float VdotS = dot(nViewPos, sunVec);
        float VdotU = dot(nViewPos, upVec);

        #ifdef IS_IRIS
            bool isSun = renderStage == MC_RENDER_STAGE_SUN;
            bool isMoon = renderStage == MC_RENDER_STAGE_MOON;
        #else
            bool tSizeCheck = abs(tSize.y - 264.0) < 248.5;
            bool sunSideCheck = VdotS > 0.0;
            bool isSun = tSizeCheck && sunSideCheck;
            bool isMoon = tSizeCheck && !sunSideCheck;
        #endif

        if (isSun || isMoon) {
            #if SUN_MOON_STYLE >= 2
                discard;
            #endif

            if (isSun) {
                color.rgb *= dot(color.rgb, color.rgb) * normalize(lightColor) * 3.2;
                color.rgb *= 0.25 + (0.75 - 0.25 * rainFactor) * sunVisibility2;
            }

            if (isMoon) {
                color.rgb *= smoothstep1(min1(length(color.rgb))) * 1.3;
            }

            color.rgb *= GetHorizonFactor(VdotU);

            #ifdef CAVE_FOG
                color.rgb *= 1.0 - 0.75 * GetCaveFactor();
            #endif
        } else {
            #if MC_VERSION >= 11300
                color.rgb *= color.rgb * smoothstep1(sqrt1(max0(VdotU)));
            #else
                discard;

            #endif
        }

        if (isEyeInWater == 1) color.rgb *= 0.25;

        #ifdef SUN_MOON_DURING_RAIN
            color.a *= 1.0 - 0.8 * rainFactor;
        #else
            color.a *= 1.0 - rainFactor;
        #endif
    #endif

    #ifdef NETHER
        vec4 color = vec4(0.0);
    #endif

    #ifdef END
        vec4 color = vec4(endSkyColor, 1.0);
    #endif

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

#ifdef OVERWORLD
    flat out vec3 upVec, sunVec;
#endif

void main() {
    gl_Position = ftransform();
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    glColor = gl_Color;

    #ifdef OVERWORLD
        upVec = normalize(gbufferModelView[1].xyz);
        sunVec = GetSunVector();
    #endif
}

#endif
