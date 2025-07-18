subsurfaceMode = 2;

#ifdef GBUFFERS_TERRAIN
    materialMask = OSIEBCA * 253.0; 

    #ifdef COATED_TEXTURES
        doTileRandomisation = false;
    #endif
#endif

#ifdef IPBR
    float factor = min1(pow2(color.g - 0.15 * (color.r + color.b)) * 2.5);
    smoothnessG = factor * 0.4;
    highlightMult = factor * 4.0 + 2.0;
    float fresnel = clamp(1.0 + dot(normalM, normalize(viewPos)), 0.0, 1.0);
    highlightMult *= 1.0 - pow2(pow2(fresnel));
#endif

#ifdef SNOWY_WORLD
    snowMinNdotU = min(pow2(pow2(color.g)), 0.1);
    color.rgb = color.rgb * 0.5 + 0.5 * (color.rgb / glColor.rgb);
#endif

#if SHADOW_QUALITY > -1 && SHADOW_QUALITY < 3 && defined OVERWORLD
    shadowMult = vec3(sqrt1(max0(max(lmCoordM.y, min1(lmCoordM.x * 2.0)) - 0.95) * 20.0));
#endif