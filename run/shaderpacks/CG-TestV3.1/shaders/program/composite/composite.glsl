#include "/lib/common.glsl"

#ifdef FRAGMENT_SHADER

noperspective in vec2 texCoord;

flat in vec3 upVec, sunVec;

#ifdef LIGHTSHAFTS_ACTIVE
    flat in float vlFactor;
#endif

float SdotU = dot(sunVec, upVec);
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;

vec2 view = vec2(viewWidth, viewHeight);

#ifdef OVERWORLD
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    vec3 lightVec = sunVec;
#endif

#ifdef LIGHTSHAFTS_ACTIVE
    float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
    float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
    float shadowTime = shadowTimeVar2 * shadowTimeVar2;
    float vlTime = min(abs(SdotU) - 0.05, 0.15) / 0.15;
#endif

#include "/lib/atmos/waterFog.glsl"
#include "/lib/atmos/caveFactor.glsl"

#ifdef BLOOM_FOG_COMPOSITE
    #include "/lib/atmos/bloomFog.glsl"
#endif

#ifdef LIGHTSHAFTS_ACTIVE
    #ifdef END
        #include "/lib/atmos/enderBeams.glsl"
    #endif
    #include "/lib/atmos/volumetricLight.glsl"
#endif

#if WATER_MAT_QUALITY >= 3 || defined NETHER_STORM || defined COLORED_LIGHT_FOG
    #include "/lib/util/spaceConversion.glsl"
#endif

#if WATER_MAT_QUALITY >= 3
    #include "/lib/materials/refraction.glsl"
#endif

#ifdef NETHER_STORM
    #include "/lib/atmos/netherStorm.glsl"
#endif

#ifdef ATM_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif
#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/colors/moonPhaseInfluence.glsl"
#endif

#if RAINBOWS > 0 && defined OVERWORLD
    #include "/lib/atmos/rainbow.glsl"
#endif

#ifdef COLORED_LIGHT_FOG
    #include "/lib/others/voxelization.glsl"
    #include "/lib/atmos/coloredLightFog.glsl"
#endif

vec3 lensEffects(vec3 color_input, vec2 coord) {
    vec3 result_color = color_input;

    float distToCenter = length(coord - 0.5) * 2.0;

    float vignette = 1.0 - smoothstep(0.7, 1.4, distToCenter);
    result_color *= mix(1.0, vignette, 0.3);

    if (distToCenter > 0.5) {
        float caStrength = 0.015 * smoothstep(0.5, 1.0, distToCenter);
        vec2 caOffset = normalize(coord - 0.5) * caStrength;

        vec3 caSampledColor;
        caSampledColor.r = texture(colortex0, coord + caOffset).r;
        caSampledColor.g = texture(colortex0, coord).g;
        caSampledColor.b = texture(colortex0, coord - caOffset).b;

        result_color = mix(result_color, caSampledColor, smoothstep(0.5, 1.0, distToCenter) * 0.5);
    }

    return result_color;
}


void main() {
    vec3 color = texelFetch(colortex0, texelCoord, 0).rgb;
    float z0 = texelFetch(depthtex0, texelCoord, 0).r;
    float z1 = texelFetch(depthtex1, texelCoord, 0).r;

    vec4 screenPos = vec4(texCoord, z0, 1.0);
    vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
    viewPos /= viewPos.w;
    float lViewPos = length(viewPos.xyz);

    #if defined DISTANT_HORIZONS && !defined OVERWORLD
        float z0DH = texelFetch(dhDepthTex, texelCoord, 0).r;
        vec4 screenPosDH = vec4(texCoord, z0DH, 1.0);
        vec4 viewPosDH = dhProjectionInverse * (screenPosDH * 2.0 - 1.0);
        viewPosDH /= viewPosDH.w;
        lViewPos = min(lViewPos, length(viewPosDH.xyz));
    #endif

    float dither = texture2D(noisetex, texCoord * view / 128.0).b;
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif

    vec3 translucentMult = 1.0 - texelFetch(colortex3, texelCoord, 0).rgb;
    vec4 volumetricEffect = vec4(0.0);

    #if WATER_MAT_QUALITY >= 3
        DoRefraction(color, z0, z1, viewPos.xyz, lViewPos);
    #endif

    vec4 screenPos1 = vec4(texCoord, z1, 1.0);
    vec4 viewPos1 = gbufferProjectionInverse * (screenPos1 * 2.0 - 1.0);
    viewPos1 /= viewPos1.w;
    float lViewPos1 = length(viewPos1.xyz);

    #if defined DISTANT_HORIZONS && !defined OVERWORLD
        float z1DH = texelFetch(dhDepthTex1, texelCoord, 0).r;
        vec4 screenPos1DH = vec4(texCoord, z1DH, 1.0);
        vec4 viewPos1DH = dhProjectionInverse * (screenPos1DH * 2.0 - 1.0);
        viewPos1DH /= viewPos1DH.w;
        lViewPos1 = min(lViewPos1, length(viewPos1DH.xyz));
    #endif

    #if defined LIGHTSHAFTS_ACTIVE || RAINBOWS > 0 && defined OVERWORLD
        vec3 nViewPos = normalize(viewPos1.xyz);
        float VdotL = dot(nViewPos, lightVec);
    #endif

    #if defined NETHER_STORM || defined COLORED_LIGHT_FOG
        vec3 playerPos = ViewToPlayer(viewPos1.xyz);
        vec3 nPlayerPos = normalize(playerPos);
    #endif

    #if RAINBOWS > 0 && defined OVERWORLD
        if (isEyeInWater == 0) color += GetRainbow(translucentMult, z0, z1, lViewPos, lViewPos1, VdotL, dither);
    #endif

    #ifdef LIGHTSHAFTS_ACTIVE
        float vlFactorM = vlFactor;
        float VdotU = dot(nViewPos, upVec);

        volumetricEffect = GetVolumetricLight(color, vlFactorM, translucentMult, lViewPos, lViewPos1, nViewPos, VdotL, VdotU, texCoord, z0, z1, dither);
    #endif

    #ifdef NETHER_STORM
        volumetricEffect = GetNetherStorm(color, translucentMult, nPlayerPos, playerPos, lViewPos, lViewPos1, dither);
    #endif

    #ifdef ATM_COLOR_MULTS
        volumetricEffect.rgb *= GetAtmColorMult();
    #endif
    #ifdef MOON_PHASE_INF_ATMOSPHERE
        volumetricEffect.rgb *= moonPhaseInfluence;
    #endif

    #ifdef NETHER_STORM
        color = mix(color, volumetricEffect.rgb, volumetricEffect.a);
    #endif

    #ifdef COLORED_LIGHT_FOG
        vec3 lightFog = GetColoredLightFog(nPlayerPos, translucentMult, lViewPos, lViewPos1, dither);
        float lightFogMult = COLORED_LIGHT_FOG_I;


        #ifdef OVERWORLD
            lightFogMult *= 0.2 + 0.6 * mix(1.0, 1.0 - sunFactor * invRainFactor, eyeBrightnessM);
        #endif
    #endif

    if (isEyeInWater == 1) {
        if (z0 == 1.0) color.rgb = waterFogColor;

        vec3 underwaterMult = vec3(0.80, 0.87, 0.97);
        color.rgb *= underwaterMult * 0.85;
        volumetricEffect.rgb *= pow2(underwaterMult * 0.71);

        #ifdef COLORED_LIGHT_FOG
            lightFog *= underwaterMult;
        #endif
    } else if (isEyeInWater == 2) {
        if (z1 == 1.0) color.rgb = fogColor * 5.0;

        volumetricEffect.rgb *= 0.0;
        #ifdef COLORED_LIGHT_FOG
            lightFog *= 0.0;
        #endif
    }

    #ifdef COLORED_LIGHT_FOG
        color /= 1.0 + pow2(GetLuminance(lightFog)) * lightFogMult * 2.0;
        color += lightFog * lightFogMult * 0.5;
    #endif

    color = lensEffects(color, texCoord);
    
    color = pow(color, vec3(2.2));

    #ifdef LIGHTSHAFTS_ACTIVE
        #ifdef END
            volumetricEffect.rgb *= volumetricEffect.rgb;
        #endif

        color += volumetricEffect.rgb;
    #endif

    #ifdef BLOOM_FOG_COMPOSITE
        color *= GetBloomFog(lViewPos);
    #endif

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);

    #if LIGHTSHAFT_QUALI_DEFINE > 0 && LIGHTSHAFT_BEHAVIOUR == 1 && SHADOW_QUALITY >= 1 && defined OVERWORLD || defined END
        #if LENSFLARE_MODE > 0 || defined ENTITY_TAA_NOISY_CLOUD_FIX
            if (viewWidth + viewHeight - gl_FragCoord.x - gl_FragCoord.y > 1.5)
                vlFactorM = texelFetch(colortex4, texelCoord, 0).r;
        #endif

        /* DRAWBUFFERS:04 */
        gl_FragData[1] = vec4(vlFactorM, 0.0, 0.0, 1.0);
    #endif
}

#endif


#ifdef VERTEX_SHADER

noperspective out vec2 texCoord;

flat out vec3 upVec, sunVec;

#ifdef LIGHTSHAFTS_ACTIVE
    flat out float vlFactor;
#endif










void main() {
    gl_Position = ftransform();

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    upVec = normalize(gbufferModelView[1].xyz);
    sunVec = GetSunVector();

    #ifdef LIGHTSHAFTS_ACTIVE
        #if LIGHTSHAFT_BEHAVIOUR == 1 && SHADOW_QUALITY >= 1 || defined END
            vlFactor = texelFetch(colortex4, ivec2(viewWidth-1, viewHeight-1), 0).r;
        #else
            #if LIGHTSHAFT_BEHAVIOUR == 2
                vlFactor = 0.0;
            #elif LIGHTSHAFT_BEHAVIOUR == 3
                vlFactor = 1.0;
            #endif
        #endif
    #endif
}

#endif
