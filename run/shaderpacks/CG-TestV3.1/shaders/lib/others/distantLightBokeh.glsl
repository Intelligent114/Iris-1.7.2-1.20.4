float GetDistantLightBokehMix(float lViewPos) {
    
    return clamp01(0.005 * (lViewPos - 60.0));
}

#ifdef GBUFFERS_TERRAIN
    float GetDistantLightBokehMixMipmapped(float lViewPos) {
        float dlbMix = GetDistantLightBokehMix(lViewPos);
        return dlbMix * min1(miplevel * 0.4);
    }

    void DoDistantLightBokehMaterial(inout vec4 color, vec4 distantColor, inout float emission, float distantEmission, float lViewPos) {
        float dlbMix = GetDistantLightBokehMixMipmapped(lViewPos);
        color = mix(color, distantColor, dlbMix);
        emission = mix(emission, distantEmission, dlbMix);
    }
    void DoDistantLightBokehMaterial(inout float emission, float distantEmission, float lViewPos) {
        float dlbMix = GetDistantLightBokehMixMipmapped(lViewPos);
        emission = mix(emission, distantEmission, dlbMix);
    }
#endif