#define RAINBOW_DIAMETER 1.00 
#define RAINBOW_STYLE 1 

vec3 GetRainbow(vec3 translucentMult, float z0, float z1, float lViewPos, float lViewPos1, float VdotL, float dither) {
    vec3 rainbow = vec3(0.0);

    float rainbowTime = min1(max0(SdotU - 0.1) / 0.15);
    rainbowTime = clamp(rainbowTime - pow2(pow2(pow2(noonFactor))) * 8.0, 0.0, 0.85);
    #if RAINBOWS == 1 
        rainbowTime *= sqrt2(max0(wetness - 0.333) * 1.5) * invRainFactor * inRainy;
    #endif

    if (rainbowTime > 0.001) {
        float cloudLinearDepth = texelFetch(colortex4, texelCoord, 0).r;
        float cloudDistance = pow2(cloudLinearDepth + OSIEBCA * dither) * far;
        if (cloudDistance < lViewPos1) lViewPos = cloudDistance;

        float rainbowLength = max(far, 128.0) * 0.9;

        float rainbowCoord = clamp01(1.0 - (VdotL + 0.75) / (0.0625 * RAINBOW_DIAMETER));
        float rainbowFactor = rainbowCoord * (1.0 - rainbowCoord);
              rainbowFactor = pow2(pow2(rainbowFactor * 3.7));
              rainbowFactor *= pow2(min1(lViewPos / rainbowLength));
              rainbowFactor *= rainbowTime;
              rainbowFactor *= 1.0 - GetCaveFactor();

        if (rainbowFactor > 0.0) {
            #if RAINBOW_STYLE == 1
                float rainbowCoordM = pow(rainbowCoord, 1.4 + max(rainbowCoord - 0.5, 0.0) * 1.6);
                rainbowCoordM = smoothstep(0.0, 1.0, rainbowCoordM) * 0.85;
                rainbowCoordM += (dither - 0.5) * 0.1;
                    rainbow += clamp(abs(mod(rainbowCoordM * 6.0 + vec3(-0.55,4.3,2.2) ,6.0)-3.0)-1.0, 0.0, 1.0);
                    rainbowCoordM += 0.1;
                    rainbow += clamp(abs(mod(rainbowCoordM * 6.0 + vec3(-0.55,4.3,2.2) ,6.0)-3.0)-1.0, 0.0, 1.0);
                    rainbowCoordM -= 0.2;
                    rainbow += clamp(abs(mod(rainbowCoordM * 6.0 + vec3(-0.55,4.3,2.2) ,6.0)-3.0)-1.0, 0.0, 1.0);
                    rainbow /= 3.0;
                rainbow.r += pow2(max(rainbowCoord - 0.5, 0.0)) * (max(1.0 - rainbowCoord, 0.0)) * 26.0;
                rainbow = pow(rainbow, vec3(2.2)) * vec3(0.25, 0.075, 0.25) * 3.0;
            #else
                float rainbowCoordM = pow(rainbowCoord, 1.35);
                rainbowCoordM = smoothstep(0.0, 1.0, rainbowCoordM);
                rainbow += clamp(abs(mod(rainbowCoordM * 6.0 + vec3(0.0,4.0,2.0) ,6.0)-3.0)-1.0, 0.0, 1.0);
                rainbow *= rainbow * (3.0 - 2.0 * rainbow);
                rainbow = pow(rainbow, vec3(2.2)) * vec3(0.25, 0.075, 0.25) * 3.0;
            #endif

            if (z1 > z0 && lViewPos < rainbowLength)
            rainbow *= mix(translucentMult, vec3(1.0), lViewPos / rainbowLength);

            rainbow *= rainbowFactor;
        }
    }

    return rainbow;
}