switch (blockEntityId) {
    case 5000:

        break;
    case 5004:
        noSmoothLighting = true;
        if (glColor.r + glColor.g + glColor.b <= 2.99 || lmCoord.x > 0.999) {
            #include "/lib/materials/signText.glsl"
        }
        #ifdef COATED_TEXTURES
            noiseFactor = 0.66;
        #endif
        break;
    case 5008:
        noSmoothLighting = true;
        smoothnessG = pow2(color.g);
        #ifdef COATED_TEXTURES
            noiseFactor = 0.66;
        #endif
        break;
    case 5012:
        noSmoothLighting = true;
        float factor = min(pow2(color.g), 0.25);
        smoothnessG = factor * 2.0;
        if (color.g > color.r || color.b > color.g)
            emission = pow2(factor) * 20.0;
        emission += 0.35;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.66;
        #endif
        break;
    case 5016:
        noSmoothLighting = true;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.2;
        #endif
        break;
    case 5020:
        noSmoothLighting = true;
        lmCoordM.x = 0.9;
        if (color.b > color.r) {
            emission = color.r * 16.0;
        } else if (color.r > color.b * 2.5) {
            emission = 20.0;
            color.rgb *= vec3(1.0, 0.25, 0.1);
        }
        break;
    case 5024:
        #ifdef SPECIAL_PORTAL_EFFECTS
            #include "/lib/materials/endPortalEffect.glsl"
        #endif
        break;
    case 5028:
        if (color.r + color.g > color.b + 0.5) {
            #include "/lib/materials/goldBlock.glsl"
        } else {
            #include "/lib/materials/stone.glsl"
        }
        break;
    case 5032:

        break;
    case 5036:

        break;
    case 5040:

        break;
    case 5044:

        break;
    case 5048:

        break;
    case 5052:

        break;
    case 10548:
        smoothnessG = pow2(color.g) * 0.35;
        if (color.b < 0.0001 && color.r > color.g) {
            emission = color.g * 4.0;
        }
        break;


}
