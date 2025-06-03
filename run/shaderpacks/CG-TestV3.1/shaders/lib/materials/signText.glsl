normalM = upVec;

highlightMult = 0.0;
shadowMult = vec3(0.0);

#if MC_VERSION >= 11700
    if (lmCoord.x > 0.99) { 
        lmCoordM = vec2(0.0);

        emission = 1.0;

        color.rgb *= length(color.rgb) + 0.5;
    } else 
#endif
color.rgb *= 5.0;