
if (mat < 32008) {


    switch (mat) {
        case 30000:
            break;
        case 30004:
            break;
        case 30008: {
            #ifdef CONNECTED_GLASS_EFFECT
                uint voxelID = uint(254);
                bool isPane = false;
                DoConnectedGlass(colorP, color, noGeneratedNormals, playerPos, worldGeoNormal, voxelID, isPane);
            #endif
            color.a = pow(color.a, 1.0 - fresnel * 0.65);
            reflectMult = 0.75;
            break;
        }
        case 30012: {
            translucentMultCalculated = true;
            reflectMult = 0.7;
            translucentMult.rgb = pow2(color.rgb) * 0.2;
            smoothnessG = color.g * 0.7;
            highlightMult = 2.5;
            break;
        }
        case 30016: {
            translucentMultCalculated = true;
            reflectMult = 1.0;
            translucentMult.rgb = pow2(color.rgb) * 0.2;
            smoothnessG = color.r * 0.7;
            highlightMult = 2.5;
            break;
        }
        case 30020: {
            #ifdef SPECIAL_PORTAL_EFFECTS
                #include "/lib/materials/netherPortal.glsl"
            #endif
            break;
        }

        case 32000: {
            #include "/lib/materials/water.glsl"
            break;
        }
        case 32004: {
            smoothnessG = pow2(color.g) * color.g;
            highlightMult = pow2(min1(pow2(color.g) * 1.5)) * 3.5;
            reflectMult = 0.7;
            break;
        }
        default: {
            if (mat >= 31000 && mat < 32000) {
                #ifdef CONNECTED_GLASS_EFFECT
                    uint voxelID = uint(200 + (mat - 31000) / 2);
                    bool isPane = (mat % 2 != 0);
                    DoConnectedGlass(colorP, color, noGeneratedNormals, playerPos, worldGeoNormal, voxelID, isPane);
                #endif
                #include "/lib/materials/stainedGlass.glsl"
                if (mat % 2 != 0) {
                    noSmoothLighting = true;
                }
            }

            break;
        }
    }
} else {
    switch (mat) {
        case 32008: {
            #ifdef CONNECTED_GLASS_EFFECT
                uint voxelID = uint(217);
                bool isPane = false;
                DoConnectedGlass(colorP, color, noGeneratedNormals, playerPos, worldGeoNormal, voxelID, isPane);
            #endif
            #include "/lib/materials/glass.glsl"
            break;
        }
        case 32012: {
            #ifdef CONNECTED_GLASS_EFFECT
                uint voxelID = uint(218);
                bool isPane = true;
                DoConnectedGlass(colorP, color, noGeneratedNormals, playerPos, worldGeoNormal, voxelID, isPane);
            #endif
            if (color.a < 0.001 && abs(NdotU) > 0.95) discard;
            #include "/lib/materials/glass.glsl"
            noSmoothLighting = true;
            break;
        }
        case 32016: {
            lmCoordM.x = 0.88;
            translucentMultCalculated = true;
            translucentMult = vec4(0.0, 0.0, 0.0, 1.0);

            if (color.b > 0.5) {
                if (color.g - color.b < 0.01 && color.g < 0.99) {
                    #include "/lib/materials/glass.glsl"
                } else {
                    lmCoordM = vec2(0.0);
                    noDirectionalShading = true;
                    float lColor = length(color.rgb);
                    vec3 baseColor = vec3(0.1, 1.0, 0.92);
                    if (lColor > 1.5)       color.rgb = baseColor + 0.22;
                    else if (lColor > 1.3)  color.rgb = baseColor + 0.15;
                    else if (lColor > 1.15) color.rgb = baseColor + 0.09;
                    else                    color.rgb = baseColor + 0.05;
                    emission = 4.0;
                }
            } else {
                float factor = color.r * 1.5;
                smoothnessG = factor;
                highlightMult = 2.0 + min1(smoothnessG * 2.0) * 1.5;
                smoothnessG = min1(smoothnessG);
            }
            break;
        }
        case 32020:
            break;
        case 32024:
            break;
        case 32028:
            break;
        case 32032:
            break;
        case 32036:
            break;
        default:

            break;
    }
}
// ...existing code...
