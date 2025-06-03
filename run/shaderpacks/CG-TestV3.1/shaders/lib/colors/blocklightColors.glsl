vec3 blocklightCol = vec3(0.1775, 0.108, 0.0775) * vec3(XLIGHT_R, XLIGHT_G, XLIGHT_B);

void AddSpecialLightDetail(inout vec3 light, vec3 albedo, float emission) {
	vec3 lightM = max(light, vec3(0.0));
	lightM /= (0.2 + 0.8 * GetLuminance(lightM));
	lightM *= (1.0 / (1.0 + emission)) * 0.22;
	light *= 0.9;
	light += pow2(lightM / (albedo + 0.1));
}

vec3 fireSpecialLightColor = vec3(2.05, 0.83, 0.27) * 3.8;
vec3 lavaSpecialLightColor = vec3(3.0, 0.9, 0.2) * 4.0;
vec3 netherPortalSpecialLightColor = vec3(1.8, 0.4, 2.2) * 0.8;
vec3 redstoneSpecialLightColor = vec3(4.0, 0.1, 0.1);
vec4 soulFireSpecialColor = vec4(vec3(0.3, 2.0, 2.2) * 1.0, 0.3);
float candleColorMult = 2.0;
float candleExtraLight = 0.004;
vec4 GetSpecialBlocklightColor(int mat) {
    switch (mat) {
        case 2: return vec4(fireSpecialLightColor, 0.0);
        case 3:
            #ifndef END
                return vec4(vec3(1.0, 1.0, 1.0) * 4.0, 0.0);
            #else
                return vec4(vec3(1.25, 0.5, 1.25) * 4.0, 0.0);
            #endif
        case 4: return vec4(vec3(0.7, 1.5, 2.0) * 3.0, 0.0);
        case 5: return vec4(fireSpecialLightColor, 0.0);
        case 6: return vec4(vec3(0.7, 1.5, 1.5) * 1.7, 0.0);
        case 7: return vec4(vec3(1.1, 0.85, 0.35) * 5.0, 0.0);
        case 8: return vec4(vec3(0.6, 1.3, 0.6) * 4.5, 0.0);
        case 9: return vec4(vec3(1.1, 0.5, 0.9) * 4.5, 0.0);
        case 10: return vec4(vec3(1.7, 0.9, 0.4) * 4.0, 0.0);
        case 11: return vec4(fireSpecialLightColor, 0.0);
        case 12: return vec4(fireSpecialLightColor, 0.0);
        case 13: return vec4(lavaSpecialLightColor, 0.8);
        case 14: return vec4(lavaSpecialLightColor, 0.0);
        case 15: return vec4(fireSpecialLightColor, 0.0);
        case 16: return vec4(vec3(1.7, 0.9, 0.4) * 4.0, 0.0);
        case 17: return vec4(vec3(1.7, 0.9, 0.4) * 2.0, 0.0);
        case 18: return vec4(vec3(1.0, 1.25, 1.5) * 3.4, 0.0);
        case 19: return vec4(vec3(3.0, 0.9, 0.2) * 3.0, 0.0);
        case 20: return vec4(vec3(2.3, 0.9, 0.2) * 3.4, 0.0);
        case 21: return vec4(fireSpecialLightColor * 0.7, 0.0);
        case 22: return vec4(fireSpecialLightColor * 0.7, 0.0);
        case 23: return vec4(fireSpecialLightColor * 0.7, 0.0);
        case 24: return vec4(fireSpecialLightColor * 0.25 * candleColorMult, candleExtraLight);
        case 25: return vec4(netherPortalSpecialLightColor * 2.0, 0.4);
        case 26: return vec4(netherPortalSpecialLightColor, 0.0);
        case 27: return soulFireSpecialColor;
        case 28: return soulFireSpecialColor;
        case 29: return soulFireSpecialColor;
        case 30: return soulFireSpecialColor;
        case 31: return vec4(redstoneSpecialLightColor * 0.5, 0.1);
        case 32: return vec4(redstoneSpecialLightColor * 0.3, 0.1);
        case 33: return vec4(vec3(1.4, 1.1, 0.5), 0.0);
        case 34:
            #if GLOWING_LICHEN > 0
                return vec4(vec3(0.8, 1.1, 1.1), 0.05);
            #else
                return vec4(vec3(0.4, 0.55, 0.55), 0.0);
            #endif
        case 35: return vec4(redstoneSpecialLightColor * 0.25, 0.0);
        case 36: return vec4(vec3(0.325, 0.15, 0.425) * 2.0, 0.05);
        case 37: return vec4(lavaSpecialLightColor * 0.1, 0.1);
        case 38: return vec4(vec3(2.0, 0.5, 1.5) * 0.3, 0.1);
        case 39: return vec4(vec3(2.0, 1.0, 1.5) * 0.25, 0.1);
        case 40: return vec4(vec3(2.5, 1.2, 0.4) * 0.1, 0.1);
        case 41: return vec4(redstoneSpecialLightColor * 0.4, 0.15);
        case 42: return vec4(vec3(0.75, 0.75, 3.0) * 0.277, 0.15);
        case 43: return vec4(vec3(1.7, 0.9, 0.4) * 0.45, 0.05);
        case 44: return vec4(vec3(1.7, 1.1, 0.2) * 0.45, 0.1);
        case 45: return vec4(vec3(1.7, 0.8, 0.4) * 0.45, 0.05);
        case 46: return vec4(vec3(0.75, 0.75, 3.0) * 0.2, 0.1);
        case 47: return vec4(vec3(0.5, 3.5, 0.5) * 0.3, 0.1);
        case 48: return vec4(vec3(0.5, 2.0, 2.0) * 0.4, 0.15);
        case 49: return vec4(vec3(1.5, 1.5, 1.5) * 0.3, 0.05);
        case 50: return vec4(vec3(1.7, 1.1, 0.2) * 0.45, 0.05);
        case 51: return vec4(vec3(1.7, 1.1, 0.2) * 0.45, 0.05);
        case 52: return vec4(vec3(1.8, 0.8, 0.4) * 0.6, 0.15);
        case 53: return vec4(vec3(1.4, 0.2, 1.4) * 0.3, 0.05);
        case 54: return vec4(vec3(3.1, 1.1, 0.3) * 1.0, 0.1);
        case 55: return vec4(vec3(1.7, 0.9, 0.4) * 4.0, 0.0);
        case 56: return vec4(vec3(1.7, 0.9, 0.4) * 2.0, 0.0);
        case 57: return vec4(vec3(0.1, 0.3, 0.4) * 0.5, 0.0005);
        case 58: return vec4(vec3(0.0, 1.4, 1.4) * 4.0, 0.15);
        case 59: return vec4(0.0);
        case 60: return vec4(vec3(3.1, 1.1, 0.3) * 0.125, 0.0125);
        case 61: return vec4(vec3(3.0, 0.9, 0.2) * 0.125, 0.0125);
        case 62: return vec4(vec3(3.5, 0.6, 0.4) * 0.3, 0.05);
        case 63: return vec4(vec3(0.3, 1.9, 1.5) * 0.3, 0.05);
        case 64: return vec4(vec3(1.0, 1.0, 1.0) * 0.45, 0.1);
        case 65: return vec4(vec3(3.0, 0.9, 0.2) * 0.125, 0.0125);
        case 66: return vec4(redstoneSpecialLightColor * 0.05, 0.002);
        case 67: return vec4(redstoneSpecialLightColor * 0.125, 0.0125);
        case 68: return vec4(vec3(0.75), 0.0);
        case 69: return vec4(vec3(1.3, 1.6, 1.6) * 1.0, 0.1);
        case 70: return vec4(vec3(1.0, 0.1, 0.1) * candleColorMult, candleExtraLight);
        case 71: return vec4(vec3(1.0, 0.4, 0.1) * candleColorMult, candleExtraLight);
        case 72: return vec4(vec3(1.0, 1.0, 0.1) * candleColorMult, candleExtraLight);
        case 73: return vec4(vec3(0.1, 1.0, 0.1) * candleColorMult, candleExtraLight);
        case 74: return vec4(vec3(0.3, 1.0, 0.3) * candleColorMult, candleExtraLight);
        case 75: return vec4(vec3(0.3, 0.8, 1.0) * candleColorMult, candleExtraLight);
        case 76: return vec4(vec3(0.5, 0.65, 1.0) * candleColorMult, candleExtraLight);
        case 77: return vec4(vec3(0.1, 0.15, 1.0) * candleColorMult, candleExtraLight);
        case 78: return vec4(vec3(0.7, 0.3, 1.0) * candleColorMult, candleExtraLight);
        case 79: return vec4(vec3(1.0, 0.1, 1.0) * candleColorMult, candleExtraLight);
        case 80: return vec4(vec3(1.0, 0.4, 1.0) * candleColorMult, candleExtraLight);
        case 81: return vec4(vec3(2.8, 1.1, 0.2) * 0.125, 0.0125);
        case 82: return vec4(vec3(2.8, 1.1, 0.2) * 0.3, 0.05);
        case 83: return vec4(vec3(1.6, 1.6, 0.7) * 0.3, 0.05);
        case 84: return vec4(0.0);
        case 85: return vec4(0.0);
        case 86: return vec4(0.0);
        case 87: return vec4(0.0);
        case 88: return vec4(0.0);
        case 89: return vec4(0.0);
        case 90: return vec4(0.0);
        case 91: return vec4(0.0);
        case 92: return vec4(0.0);
        case 93: return vec4(0.0);
        case 94: return vec4(0.0);
        case 95: return vec4(0.0);
        case 96: return vec4(0.0);
        case 97: return vec4(0.0);
        default: return vec4(blocklightCol * 20.0, 0.0);
    }
}

vec3[] specialTintColor = vec3[](
	vec3(1.0),
	vec3(1.0, 0.3, 0.1),
	vec3(1.0, 0.1, 1.0),
	vec3(0.5, 0.65, 1.0),
	vec3(1.0, 1.0, 0.1),
	vec3(0.1, 1.0, 0.1),
	vec3(1.0, 0.4, 1.0),
	vec3(1.0),
	vec3(1.0),
	vec3(0.3, 0.8, 1.0),
	vec3(0.7, 0.3, 1.0),
	vec3(0.1, 0.15, 1.0),
	vec3(1.0, 0.75, 0.5),
	vec3(0.3, 1.0, 0.3),
	vec3(1.0, 0.1, 0.1),
	vec3(1.0),
	vec3(0.5, 0.65, 1.0),
	vec3(1.0),
	vec3(1.0),
	vec3(0.0)
);