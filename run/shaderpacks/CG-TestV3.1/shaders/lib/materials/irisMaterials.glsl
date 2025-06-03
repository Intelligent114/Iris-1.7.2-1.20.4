int mat = currentRenderedItemId;

#ifdef GBUFFERS_HAND
    float lViewPos = 0.0;
#endif

int subsurfaceMode;
bool centerShadowBias;
float noPuddles;

if (currentRenderedItemId < 45000) {
    #include "/lib/materials/terrainMaterials.glsl"
} else {
    switch(currentRenderedItemId) {
        case 45000: {
            smoothnessG = 0.5;
            highlightMult = 2.0;
            smoothnessD = 0.5;
            #ifdef GLOWING_ARMOR_TRIM
                emission = 1.0;
            #endif
            break;
        }

        case 45004: {
            #include "/lib/materials/sprucePlanks.glsl"
            smoothnessG = min(smoothnessG, 0.4);
            smoothnessD = smoothnessG;
            break;
        }

        case 45008: {
            if (CheckForStick(color.rgb)) {
                #include "/lib/materials/sprucePlanks.glsl"
            } else {
                #include "/lib/materials/stone.glsl"
            }
            break;
        }

        case 45012: {
            if (CheckForStick(color.rgb)) {
                #include "/lib/materials/sprucePlanks.glsl"
            } else {
                #include "/lib/materials/ironBlock.glsl"
            }
            break;
        }

        case 45016: {
            if (CheckForStick(color.rgb)) {
                #include "/lib/materials/sprucePlanks.glsl"
            } else {
                #include "/lib/materials/goldBlock.glsl"
            }
            break;
        }

        case 45020: {
            if (CheckForStick(color.rgb)) {
                #include "/lib/materials/sprucePlanks.glsl"
            } else {
                #include "/lib/materials/diamondBlock.glsl"
            }
            break;
        }

        case 45024: {
            materialMask = OSIEBCA;
            smoothnessG = color.r * 1.5;
            smoothnessG = min1(smoothnessG);
            highlightMult = smoothnessG * 2.0;
            smoothnessD = smoothnessG * smoothnessG * 0.5;
            #ifdef COATED_TEXTURES
                noiseFactor = 0.33;
            #endif
            break;
        }

        case 45028: {
            #include "/lib/materials/trident.glsl"
            break;
        }

        case 45032: {
            if (color.r + color.g > color.b * 2.0) {
                emission = color.r + color.g - color.b * 1.5;
                emission *= 1.8;
                color.rg += color.b * vec2(0.4, 0.15);
                color.b *= 0.8;
            } else {
                #include "/lib/materials/ironBlock.glsl"
            }
            break;
        }

        case 45036: {
            if (GetMaxColorDif(color.rgb) < 0.01) {
                #include "/lib/materials/ironBlock.glsl"
            } else {
                float factor = color.b;
                smoothnessG = factor;
                highlightMult = factor * 2.0;
                smoothnessD = factor;
            }
            break;
        }

        case 45040: {
            noSmoothLighting = false;
            lmCoordM.x = 0.85;
            emission = color.g;
            color.rgb = sqrt1(color.rgb);
            break;
        }

        case 45044: {
            emission = color.b * 2.0;
            break;
        }

        case 45048: {
            emission = max0(color.r + color.g - color.b * 0.5);
            break;
        }

        case 45052: {
            emission = max0(color.b * 2.0 - color.r) * 1.5;
            break;
        }

        case 45056: {
            materialMask = OSIEBCA;
            float factor = pow2(color.r);
            smoothnessG = 0.8 - factor * 0.3;
            highlightMult = factor * 3.0;
            smoothnessD = factor;
            break;
        }

        case 45060: {
            float factor = min(color.r * color.g * color.b * 4.0, 0.7) * 0.7;
            smoothnessG = factor;
            highlightMult = factor * 3.0;
            smoothnessD = factor;
            break;
        }

        case 45064: {
            float factor = color.g * 0.7;
            smoothnessG = factor;
            highlightMult = factor * 3.0;
            smoothnessD = factor;
            break;
        }

        case 45068: {
            smoothnessG = 1.0;
            highlightMult = 2.0;
            smoothnessD = 1.0;
            break;
        }

        case 45072: {
            smoothnessG = 1.0;
            highlightMult = 2.0;
            smoothnessD = 1.0;
            emission = max0(color.g - color.b * 0.25);
            color.rgb = pow(color.rgb, vec3(1.0 - 0.75 * emission));
            break;
        }

        case 45076: {
            if (
                CheckForColor(color.rgb, vec3(255, 255, 0)) ||
                CheckForColor(color.rgb, vec3(204, 204, 0)) ||
                CheckForColor(color.rgb, vec3(73, 104, 216)) ||
                CheckForColor(color.rgb, vec3(58, 83, 172)) ||
                CheckForColor(color.rgb, vec3(108, 108, 137)) ||
                CheckForColor(color.rgb, vec3(86, 86, 109))
            ) {
                emission = 1.0;
                color.rgb += vec3(0.1);
            }
            #include "/lib/materials/goldBlock.glsl"
            break;
        }

        case 45080: {
            if (color.r - 0.1 > color.b + color.g) {
                emission = color.r * 1.5;
            }
            #include "/lib/materials/ironBlock.glsl"
            break;
        }

        case 45084: {
            emission = max0(color.b + color.g - color.r * 2.0);
            #include "/lib/materials/ironBlock.glsl"
            break;
        }

        case 45088: {
            emission = pow2(color.r + color.g) * 0.5;
            break;
        }

        case 45092: {
            if (color.g < color.r) {
                emission = 3.0;
                color.r *= 1.1;
            }
            break;
        }

        case 45096: {
            break;
        }

        case 45100: {
            emission = dot(color.rgb, color.rgb) * 0.5 + 1.0;
            break;
        }

        case 45104: {
            emission = pow1_5(color.r) * 2.5 + 0.2;
            break;
        }

        case 45108: {
            #include "/lib/materials/goldBlock.glsl"
            break;
        }

        case 45112: {
            emission = abs(color.r - color.b) * 3.0;
            color.rgb = pow(color.rgb, vec3(1.0 + 0.5 * sqrt(emission)));
            break;
        }


        case 45116: case 45120: case 45124:
            break;
    }
}
