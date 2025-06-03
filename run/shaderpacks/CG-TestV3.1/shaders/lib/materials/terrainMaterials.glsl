if (mat >= 10000) {
    if (mat < 10004) {
        noDirectionalShading = true;
    } else if (mat < 10008) {
        subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;
        #ifdef GBUFFERS_TERRAIN
            DoFoliageColorTweaks(color.rgb, shadowMult, snowMinNdotU, viewPos, nViewPos, lViewPos, dither);
            #ifdef COATED_TEXTURES
                doTileRandomisation = false;
            #endif
        #endif
        #if SHADOW_QUALITY == -1
            shadowMult *= 1.0 - 0.3 * (signMidCoordPos.y + 1.0) * (1.0 - abs(signMidCoordPos.x))
                    + 0.5 * (1.0 - signMidCoordPos.y) * invNoonFactor;
        #endif
    } else if (mat < 10012) {
        #include "/lib/materials/leaves.glsl"
    } else if (mat < 10016) {
        subsurfaceMode = 3, centerShadowBias = true;
        noSmoothLighting = true;
        #if defined COATED_TEXTURES && defined GBUFFERS_TERRAIN
            doTileRandomisation = false;
        #endif
        float factor = color.g;
        smoothnessG = factor * 0.5;
        highlightMult = factor * 4.0 + 2.0;
        float fresnel = clamp(1.0 + dot(normalM, normalize(viewPos)), 0.0, 1.0);
        highlightMult *= 1.0 - pow2(pow2(fresnel));
    } else if (mat < 10020) {
        subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;
    } else if (mat < 10024) {
        subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;
        #ifdef GBUFFERS_TERRAIN
            DoFoliageColorTweaks(color.rgb, shadowMult, snowMinNdotU, viewPos, nViewPos, lViewPos, dither);
            #ifdef COATED_TEXTURES
                doTileRandomisation = false;
            #endif
        #endif
        #if SHADOW_QUALITY == -1
            shadowMult *= 1.0 + invNoonFactor;
        #endif
    } else if (mat < 10028) {
        #ifdef GLOWING_ORE_MODDED
            float epsilon = 0.00001;
            vec2 absMidCoordPosM = absMidCoordPos - epsilon;
            vec3 avgBorderColor = vec3(0.0);
            avgBorderColor += texture2D(tex, midCoord + vec2( absMidCoordPosM.x, absMidCoordPosM.y)).rgb;
            avgBorderColor += texture2D(tex, midCoord + vec2(-absMidCoordPosM.x, absMidCoordPosM.y)).rgb;
            avgBorderColor += texture2D(tex, midCoord + vec2( absMidCoordPosM.x,-absMidCoordPosM.y)).rgb;
            avgBorderColor += texture2D(tex, midCoord + vec2(-absMidCoordPosM.x,-absMidCoordPosM.y)).rgb;
            avgBorderColor += texture2D(tex, midCoord + vec2(epsilon, absMidCoordPosM.y)).rgb;
            avgBorderColor += texture2D(tex, midCoord + vec2(epsilon,-absMidCoordPosM.y)).rgb;
            avgBorderColor += texture2D(tex, midCoord + vec2( absMidCoordPosM.x, epsilon)).rgb;
            avgBorderColor += texture2D(tex, midCoord + vec2(-absMidCoordPosM.x, epsilon)).rgb;
            avgBorderColor *= 0.125;
            vec3 colorDif = abs(avgBorderColor - color.rgb);
            emission = max(colorDif.r, max(colorDif.g, colorDif.b));
            emission = pow2(emission * 2.5 - 0.15);
            emission *= GLOWING_ORE_MULT;
        #endif
    } else if (mat < 10032) {
        noSmoothLighting = true;
        noDirectionalShading = true;
        emission = GetLuminance(color.rgb) * 2.5;
    } else if (mat < 10036) {
        #include "/lib/materials/stone.glsl"
        #ifdef COATED_TEXTURES
            noiseFactor = 0.66;
        #endif
    } else if (mat < 10040) {
        #include "/lib/materials/anvil.glsl"
    } else if (mat < 10044) {
        #if ANISOTROPIC_FILTER == 0
            color = texture2DLod(tex, texCoord, 0);
        #endif
        noSmoothLighting = true;
        if (color.r > 0.1 && color.g + color.b < 0.1) {
            noSmoothLighting = true;
            noDirectionalShading = true;
            lmCoordM.x = min(lmCoordM.x * 0.9, 0.77);
            if (color.r > 0.5) {
                color.rgb *= color.rgb;
                emission = 8.0 * color.r;
            } else if (color.r > color.g * 2.0) {
                materialMask = OSIEBCA * 5.0;
                float factor = pow2(color.r);
                smoothnessG = 0.4;
                highlightMult = factor + 0.4;
                smoothnessD = factor * 0.7 + 0.3;
            }
        } else if (abs(color.r - color.b) < 0.15) {
            #include "/lib/materials/ironBlock.glsl"
        } else if (color.g > color.b * 2.0) {
            #include "/lib/materials/goldBlock.glsl"
        } else {
            #include "/lib/materials/oakPlanks.glsl"
        }
    } else if (mat < 10048) {
        noSmoothLighting = true;
        lmCoordM.x = min(lmCoordM.x, 0.9333);
        #include "/lib/materials/anvil.glsl"
    } else if (mat < 10052) {
        noSmoothLighting = true;
        lmCoordM.x = min(lmCoordM.x, 0.9333);
        vec3 worldPos = playerPos + cameraPosition;
        vec3 fractPos = fract(worldPos.xyz);
        vec2 coordM = abs(fractPos.xz - 0.5);
        if (max(coordM.x, coordM.y) < 0.375 && fractPos.y > 0.3 && NdotU > 0.9) {
            #if WATER_STYLE < 3
                vec3 colorP = color.rgb / glColor.rgb;
                smoothnessG = min(pow2(pow2(dot(colorP.rgb, colorP.rgb) * 0.4)), 1.0);
                highlightMult = 3.25;
                smoothnessD = 0.8;
            #else
                smoothnessG = 0.3;
                smoothnessD = 1.0;
            #endif
            #include "/lib/materials/water.glsl"
            #ifdef COATED_TEXTURES
                noiseFactor = 0.0;
            #endif
        } else {
            #include "/lib/materials/anvil.glsl"
        }
    } else if (mat < 10056) {
        noSmoothLighting = true;
        lmCoordM.x = min(lmCoordM.x, 0.9333);
        vec3 worldPos = playerPos + cameraPosition;
        vec3 fractPos = fract(worldPos.xyz);
        vec2 coordM = abs(fractPos.xz - 0.5);
        if (max(coordM.x, coordM.y) < 0.375 &&
            fractPos.y > 0.3 &&
            NdotU > 0.9) {
            #include "/lib/materials/snow.glsl"
        } else {
            #include "/lib/materials/anvil.glsl"
        }
    } else if (mat < 10060) {
        noSmoothLighting = true;
        lmCoordM.x = min(lmCoordM.x, 0.9333);
        vec3 worldPos = playerPos + cameraPosition;
        vec3 fractPos = fract(worldPos.xyz);
        vec2 coordM = abs(fractPos.xz - 0.5);
        if (max(coordM.x, coordM.y) < 0.375 &&
            fractPos.y > 0.3 &&
            NdotU > 0.9) {
            #include "/lib/materials/lava.glsl"
        } else {
            #include "/lib/materials/anvil.glsl"
        }
    } else if (mat < 10064) {
        if (color.r > color.g + color.b) {
            color.rgb *= color.rgb;
            emission = 4.0;
        } else {
            #include "/lib/materials/cobblestone.glsl"
        }
    } else if (mat < 10068) {
        #include "/lib/materials/oakPlanks.glsl"
    } else if (mat < 10072) {
        #include "/lib/materials/lava.glsl"
        #if defined COATED_TEXTURES && defined GBUFFERS_TERRAIN
            doTileRandomisation = false;
        #endif
        #ifdef DISTANT_LIGHT_BOKEH
            DoDistantLightBokehMaterial(emission, 4.5, lViewPos);
        #endif
    } else if (mat < 10076) {
        noSmoothLighting = true, noDirectionalShading = true;
        emission = 2.35;
        color.rgb *= sqrt1(GetLuminance(color.rgb));
    } else if (mat < 10080) {
        noSmoothLighting = true, noDirectionalShading = true;
        emission = 1.5;
        color.rgb = pow1_5(color.rgb);
    } else if (mat < 10084) {
        #include "/lib/materials/stone.glsl"
    } else if (mat < 10088) {
        smoothnessG = pow2(pow2(color.r)) * 0.75;
        smoothnessD = smoothnessG;
    } else if (mat < 10092) {
        smoothnessG = pow2(pow2(color.g)) * 0.5;
        smoothnessD = smoothnessG;
        #ifdef GBUFFERS_TERRAIN
            DoBrightBlockTweaks(color.rgb, 0.75, shadowMult, highlightMult);
        #endif
    } else if (mat < 10096) {
        smoothnessG = pow2(pow2(color.g)) * 1.3;
        smoothnessG = min1(smoothnessG);
        smoothnessD = smoothnessG;
    } else if (mat < 10100) {
        smoothnessG = 0.1 + color.r * 0.4;
        smoothnessD = smoothnessG;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.77;
        #endif
    } else if (mat < 10104) {
        smoothnessG = pow2(color.g) * 0.7;
        smoothnessD = smoothnessG;
        #ifdef GBUFFERS_TERRAIN
            DoBrightBlockTweaks(color.rgb, 0.75, shadowMult, highlightMult);
        #endif
        #ifdef COATED_TEXTURES
            noiseFactor = 0.77;
        #endif
    } else if (mat < 10108) {
        smoothnessG = pow2(color.g);
        smoothnessD = smoothnessG;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.77;
        #endif
    } else if (mat < 10112) {
        #include "/lib/materials/deepslate.glsl"
    } else if (mat < 10116) {
        #include "/lib/materials/deepslate.glsl"
        #ifdef COATED_TEXTURES
            noiseFactor = 0.77;
        #endif
    } else if (mat < 10120) {
        highlightMult = pow2(color.g) + 1.0;
        smoothnessG = 1.0 - color.g * 0.5;
        smoothnessD = smoothnessG;
        #ifdef GBUFFERS_TERRAIN
            DoBrightBlockTweaks(color.rgb, 0.75, shadowMult, highlightMult);
        #endif
    } else if (mat < 10124) {
        smoothnessG = color.r * 0.35 + 0.2;
        smoothnessD = smoothnessG;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.66;
        #endif
    } else if (mat < 10128) {
        float dotColor = dot(color.rgb, color.rgb);
        if (dotColor > 1.5) {
            #include "/lib/materials/snow.glsl"
        } else {
            #include "/lib/materials/dirt.glsl"
        }
    } else if (mat < 10132) {
        #include "/lib/materials/dirt.glsl"
    } else if (mat < 10136) {
        if (glColor.b < 0.999) {
            smoothnessG = pow2(color.g);
            #ifdef SNOWY_WORLD
                snowMinNdotU = min(pow2(pow2(color.g)) * 1.9, 0.1);
                color.rgb = color.rgb * 0.5 + 0.5 * (color.rgb / glColor.rgb);
            #endif
        } else {
            #include "/lib/materials/dirt.glsl"
        }
    } else if (mat < 10140) {
        if (NdotU > 0.99) {
            #if MC_VERSION >= 11300
                smoothnessG = clamp(pow2(pow2(1.0 - color.r)) * 2.5, 0.5, 1.0);
                highlightMult = 0.5 + smoothnessG * smoothnessG * 2.0;
                smoothnessD = smoothnessG * 0.75;
            #else
                smoothnessG = 0.5 * (1.0 + abs(color.r - color.b) + color.b);
                smoothnessD = smoothnessG * 0.5;
            #endif
        } else {
            #include "/lib/materials/dirt.glsl"
        }
    } else if (mat < 10144) {
        #include "/lib/materials/netherrack.glsl"
    } else if (mat < 10148) {
        if (color.g == color.b && color.g > 0.0001) {
            #include "/lib/materials/netherrack.glsl"
        } else {
            smoothnessG = color.g * 0.5;
            smoothnessD = smoothnessG;
            #ifdef COATED_TEXTURES
                noiseFactor = 0.77;
            #endif
        }
    } else if (mat < 10152) {
        if (color.g == color.b && color.g > 0.0001 && color.r < 0.522) {
            #include "/lib/materials/netherrack.glsl"
        } else {
            smoothnessG = color.r * 0.5;
            smoothnessD = smoothnessG;
            #ifdef COATED_TEXTURES
                noiseFactor = 0.77;
            #endif
        }
    } else if (mat < 10156) {
        #include "/lib/materials/cobblestone.glsl"
    } else if (mat < 10160) {
        #include "/lib/materials/oakPlanks.glsl"
    } else if (mat < 10164) {
        if (color.g > 0.48 ||
            CheckForColor(color.rgb, vec3(126, 98, 55)) ||
            CheckForColor(color.rgb, vec3(150, 116, 65))) {
            #include "/lib/materials/oakPlanks.glsl"
        } else {
            #include "/lib/materials/oakWood.glsl"
        }
    } else if (mat < 10168) {
        #include "/lib/materials/sprucePlanks.glsl"
    } else if (mat < 10172) {
        if (color.g > 0.25) {
            #include "/lib/materials/sprucePlanks.glsl"
        } else {
            smoothnessG = pow2(color.g) * 2.5;
            smoothnessG = min1(smoothnessG);
            smoothnessD = smoothnessG;
        }
    } else if (mat < 10176) {
        #include "/lib/materials/birchPlanks.glsl"
    } else if (mat < 10180) {
        if (color.r - color.b > 0.15) {
            #include "/lib/materials/birchPlanks.glsl"
        } else {
            smoothnessG = pow2(color.g) * 0.25;
            smoothnessD = smoothnessG;
            #ifdef COATED_TEXTURES
                noiseFactor = 1.25;
            #endif
        }
    } else if (mat < 10184) {
        #include "/lib/materials/junglePlanks.glsl"
    } else if (mat < 10188) {
        if (color.g > 0.405) {
            #include "/lib/materials/junglePlanks.glsl"
        } else {
            smoothnessG = pow2(pow2(color.g)) * 5.0;
            smoothnessG = min1(smoothnessG);
            smoothnessD = smoothnessG;
            #ifdef COATED_TEXTURES
                noiseFactor = 0.77;
            #endif
        }
    } else if (mat < 10192) {
        #include "/lib/materials/acaciaPlanks.glsl"
    } else if (mat < 10196) {
        if (color.r - color.b > 0.2) {
            #include "/lib/materials/acaciaPlanks.glsl"
        } else {
            smoothnessG = pow2(color.b) * 1.3;
            smoothnessG = min1(smoothnessG);
            smoothnessD = smoothnessG;
            #ifdef COATED_TEXTURES
                noiseFactor = 0.66;
            #endif
        }
    } else if (mat < 10200) {
        #include "/lib/materials/darkOakPlanks.glsl"
    } else if (mat < 10204) {
        if (color.r - color.g > 0.08 ||
            CheckForColor(color.rgb, vec3(48, 30, 14))) {
            #include "/lib/materials/darkOakPlanks.glsl"
        } else {
            smoothnessG = color.r * 0.4;
            smoothnessD = smoothnessG;
        }
    } else if (mat < 10208) {
        #include "/lib/materials/mangrovePlanks.glsl"
    } else if (mat < 10212) {
        if (color.r - color.g > 0.2) {
            #include "/lib/materials/mangrovePlanks.glsl"
        } else {
            smoothnessG = pow2(color.r) * 0.6;
            smoothnessD = smoothnessG;
        }
    } else if (mat < 10216) {
        #include "/lib/materials/crimsonPlanks.glsl"
    } else if (mat < 10220) {
        if (color.r / color.b > 2.5) {
            emission = pow2(color.r) * 6.5;
            color.gb *= 0.5;
        } else {
            #include "/lib/materials/crimsonPlanks.glsl"
        }
    } else if (mat < 10224) {
        #include "/lib/materials/warpedPlanks.glsl"
    } else if (mat < 10228) {
        if (color.r < 0.37 * color.b || color.r + color.g * 3.0 < 3.4 * color.b) {
            emission = pow2(color.g + 0.2 * color.b) * 4.5 + 0.15;
        } else {
            #include "/lib/materials/warpedPlanks.glsl"
        }
    } else if (mat < 10232) {
        smoothnessG = color.b * 0.2 + 0.1;
        smoothnessD = smoothnessG;
        #ifdef COATED_TEXTURES
            noiseFactor = 1.5;
        #endif
    } else if (mat < 10236) {
        smoothnessG = pow(color.g, 16.0) * 2.0;
        smoothnessG = min1(smoothnessG);
        smoothnessD = smoothnessG;
        highlightMult = 2.0;
        #ifdef GBUFFERS_TERRAIN
            DoBrightBlockTweaks(color.rgb, 0.5, shadowMult, highlightMult);
            DoOceanBlockTweaks(smoothnessD);
        #endif
        #if RAIN_PUDDLES >= 1
            noPuddles = 1.0;
        #endif
    } else if (mat < 10240) {
        smoothnessG = pow(color.r * 1.08, 16.0) * 2.0;
        smoothnessG = min1(smoothnessG);
        smoothnessD = smoothnessG;
        highlightMult = 2.0;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.77;
        #endif
        #if RAIN_PUDDLES >= 1
            noPuddles = 1.0;
        #endif
    } else if (mat < 10244) {
        highlightMult = 2.0;
        smoothnessG = pow2(pow2(color.g)) * 0.5;
        smoothnessG = min1(smoothnessG);
        smoothnessD = smoothnessG;
        #ifdef GBUFFERS_TERRAIN
            DoBrightBlockTweaks(color.rgb, 0.5, shadowMult, highlightMult);
        #endif
        #ifdef COATED_TEXTURES
            noiseFactor = 0.77;
        #endif
    } else if (mat < 10248) {
        highlightMult = 2.0;
        smoothnessG = pow2(pow2(color.r * 1.08)) * 0.5;
        smoothnessG = min1(smoothnessG);
        smoothnessD = smoothnessG;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.5;
        #endif
    } else if (mat < 10252) {
        #include "/lib/materials/netheriteBlock.glsl"
    } else if (mat < 10256) {
        smoothnessG = pow2(color.r);
        smoothnessG = min1(smoothnessG);
        smoothnessD = smoothnessG;
        #ifdef COATED_TEXTURES
            noiseFactor = 1.5;
        #endif
        #ifdef GLOWING_ORE_ANCIENTDEBRIS
            emission = min(pow2(color.g * 6.0), 8.0);
            color.rgb *= pow(color.rgb, vec3(min1(GLOWING_ORE_MULT)));
            emission *= GLOWING_ORE_MULT;
        #endif
    } else if (mat < 10260) {
        noSmoothLighting = true;
        #include "/lib/materials/ironBlock.glsl"
    } else if (mat < 10264) {

    } else if (mat < 10268) {
        #include "/lib/materials/ironBlock.glsl"
        color.rgb *= max(color.r, 0.85) * 0.9;
    } else if (mat < 10272) {
        #include "/lib/materials/rawIronBlock.glsl"
    } else if (mat < 10276) {
        if (color.r != color.g) {
            #include "/lib/materials/rawIronBlock.glsl"
            #ifdef GLOWING_ORE_IRON
                if (color.r - color.b > 0.15) {
                    emission = pow1_5(color.r) * 1.5;
                    color.rgb *= pow(color.rgb, vec3(0.5 * min1(GLOWING_ORE_MULT)));
                    emission *= GLOWING_ORE_MULT;
                }
            #endif
        } else {
            #include "/lib/materials/stone.glsl"
        }
    } else if (mat < 10280) {
        if (color.r != color.g) {
            #include "/lib/materials/rawIronBlock.glsl"
            #ifdef GLOWING_ORE_IRON
                if (color.r - color.b > 0.15) {
                    emission = pow1_5(color.r) * 1.5;
                    color.rgb *= pow(color.rgb, vec3(0.5 * min1(GLOWING_ORE_MULT)));
                    emission *= GLOWING_ORE_MULT;
                }
            #endif
        } else {
            #include "/lib/materials/deepslate.glsl"
        }
    } else if (mat < 10284) {
        #include "/lib/materials/rawCopperBlock.glsl"
    } else if (mat < 10288) {
        if (color.r != color.g) {
            #include "/lib/materials/rawCopperBlock.glsl"
            #ifdef GLOWING_ORE_COPPER
                if (max(color.r * 0.5, color.g) - color.b > 0.05) {
                    emission = color.r * 2.0 + 0.7;
                    color.rgb *= pow(color.rgb, vec3(min1(GLOWING_ORE_MULT)));
                    emission *= GLOWING_ORE_MULT;
                }
            #endif
        } else {
            #include "/lib/materials/stone.glsl"
        }
    } else if (mat < 10292) {
        if (color.r != color.g) {
            #include "/lib/materials/rawCopperBlock.glsl"
            #ifdef GLOWING_ORE_COPPER
                if (max(color.r * 0.5, color.g) - color.b > 0.05) {
                    emission = color.r * 2.0 + 0.7;
                    color.rgb *= pow(color.rgb, vec3(min1(GLOWING_ORE_MULT)));
                    emission *= GLOWING_ORE_MULT;
                }
            #endif
        } else {
            #include "/lib/materials/deepslate.glsl"
        }
    } else if (mat < 10296) {
        #include "/lib/materials/copperBlock.glsl"
    } else if (mat < 10300) {
        #include "/lib/materials/rawGoldBlock.glsl"
    } else if (mat < 10304) {
        if (color.r != color.g || color.r > 0.99) {
            #include "/lib/materials/rawGoldBlock.glsl"
            #ifdef GLOWING_ORE_GOLD
                if (color.g - color.b > 0.15 ||
                    color.r > 0.99) {
                    emission = color.r + 1.0;
                    color.rgb *= pow(color.rgb, vec3(min1(GLOWING_ORE_MULT)));
                    emission *= GLOWING_ORE_MULT;
                }
            #endif
        } else {
            #include "/lib/materials/stone.glsl"
        }
    } else if (mat < 10308) {
        if (color.r != color.g || color.r > 0.99) {
            #include "/lib/materials/rawGoldBlock.glsl"
            #ifdef GLOWING_ORE_GOLD
                if (color.g - color.b > 0.15 || color.r > 0.99) {
                    emission = color.r + 1.0;
                    color.rgb *= pow(color.rgb, vec3(min1(GLOWING_ORE_MULT)));
                    emission *= GLOWING_ORE_MULT;
                }
            #endif
        } else {
            #include "/lib/materials/deepslate.glsl"
        }
    } else if (mat < 10312) {
        if (color.g != color.b) {
            #include "/lib/materials/rawGoldBlock.glsl"
            #ifdef GLOWING_ORE_NETHERGOLD
                emission = color.g * 1.5;
                emission *= GLOWING_ORE_MULT;
            #endif
        } else {
            #include "/lib/materials/netherrack.glsl"
        }
    } else if (mat < 10316) {
        #include "/lib/materials/goldBlock.glsl"
    } else if (mat < 10320) {
        #include "/lib/materials/diamondBlock.glsl"
    } else if (mat < 10324) {
        if (color.b / color.r > 1.5 ||
            color.b > 0.8) {
            #include "/lib/materials/diamondBlock.glsl"
            #ifdef GLOWING_ORE_DIAMOND
                emission = color.g + 1.5;
                color.rgb *= pow(color.rgb, vec3(min1(GLOWING_ORE_MULT)));
                emission *= GLOWING_ORE_MULT;
            #endif
        } else {
            #include "/lib/materials/stone.glsl"
        }
    } else if (mat < 10328) {
        if (color.b / color.r > 1.5 || color.b > 0.8) {
            #include "/lib/materials/diamondBlock.glsl"
            #ifdef GLOWING_ORE_DIAMOND
                emission = color.g + 1.5;
                color.rgb *= pow(color.rgb, vec3(min1(GLOWING_ORE_MULT)));
                emission *= GLOWING_ORE_MULT;
            #endif
        } else {
            #include "/lib/materials/deepslate.glsl"
        }
    } else if (mat < 10332) {
        materialMask = OSIEBCA;
        float factor = pow2(color.r);
        smoothnessG = 0.8 - factor * 0.3;
        highlightMult = factor * 3.0;
        smoothnessD = factor;
        #if GLOWING_AMETHYST >= 2
            emission = dot(color.rgb, color.rgb) * 0.3;
        #endif
        color.rgb *= 0.7 + 0.3 * GetLuminance(color.rgb);
        #ifdef COATED_TEXTURES
            noiseFactor = 0.66;
        #endif
    } else if (mat < 10336) {
        materialMask = OSIEBCA;
        float factor = pow2(color.r);
        smoothnessG = 0.8 - factor * 0.3;
        highlightMult = factor * 3.0;
        smoothnessD = factor;
        noSmoothLighting = true;
        lmCoordM.x *= 0.85;
        #if GLOWING_AMETHYST >= 1
            #if defined GBUFFERS_TERRAIN && !defined IPBR_COMPATIBILITY_MODE
                vec3 worldPos = playerPos.xyz + cameraPosition.xyz;
                vec3 blockPos = abs(fract(worldPos) - vec3(0.5));
                float maxBlockPos = max(blockPos.x, max(blockPos.y, blockPos.z));
                emission = pow2(max0(1.0 - maxBlockPos * 1.85) * color.g) * 7.0;
                if (CheckForColor(color.rgb, vec3(254, 203, 230)))
                    emission = pow(emission, max0(1.0 - 0.2 * max0(emission - 1.0)));
                color.g *= 1.0 - emission * 0.07;
                emission *= 1.3;
            #else
                emission = pow2(color.g + color.b) * 0.4;
            #endif
        #endif
        #ifdef COATED_TEXTURES
            noiseFactor = 0.66;
        #endif
    } else if (mat < 10340) {
        #include "/lib/materials/emeraldBlock.glsl"
    } else if (mat < 10344) {
        float dif = GetMaxColorDif(color.rgb);
        if (dif > 0.4 || color.b > 0.85) {
            #include "/lib/materials/emeraldBlock.glsl"
            #ifdef GLOWING_ORE_EMERALD
                emission = 2.0;
                color.rgb *= pow(color.rgb, vec3(min1(GLOWING_ORE_MULT)));
                emission *= GLOWING_ORE_MULT;
            #endif
        } else {
            #include "/lib/materials/stone.glsl"
        }
    } else if (mat < 10348) {
        float dif = GetMaxColorDif(color.rgb);
        if (dif > 0.4 || color.b > 0.85) {
            #include "/lib/materials/emeraldBlock.glsl"
            #ifdef GLOWING_ORE_EMERALD
                emission = 2.0;
                color.rgb *= pow(color.rgb, vec3(min1(GLOWING_ORE_MULT)));
                emission *= GLOWING_ORE_MULT;
            #endif
        } else {
            #include "/lib/materials/deepslate.glsl"
        }
    } else if (mat < 10352) {
        #include "/lib/materials/cobblestone.glsl"
    } else if (mat < 10356) {
        #include "/lib/materials/lapisBlock.glsl"
        #ifdef EMISSIVE_LAPIS_BLOCK
            emission = pow2(dot(color.rgb, color.rgb)) * 10.0;
        #endif
    } else if (mat < 10360) {
        if (color.r != color.g) {
            #include "/lib/materials/lapisBlock.glsl"
            smoothnessG *= 0.5;
            smoothnessD *= 0.5;
            #ifdef GLOWING_ORE_LAPIS
                if (color.b - color.r > 0.2) {
                    emission = 2.0;
                    color.rgb *= pow(color.rgb, vec3(min1(GLOWING_ORE_MULT)));
                    emission *= GLOWING_ORE_MULT;
                }
            #endif
        } else {
            #include "/lib/materials/stone.glsl"
        }
    } else if (mat < 10364) {
        if (color.r != color.g) {
            #include "/lib/materials/lapisBlock.glsl"
            smoothnessG *= 0.5;
            smoothnessD *= 0.5;
            #ifdef GLOWING_ORE_LAPIS
                if (color.b - color.r > 0.2) {
                    emission = 2.0;
                    color.rgb *= pow(color.rgb, vec3(min1(GLOWING_ORE_MULT)));
                    emission *= GLOWING_ORE_MULT;
                }
            #endif
        } else {
            #include "/lib/materials/deepslate.glsl"
        }
    } else if (mat < 10368) {
        #include "/lib/materials/quartzBlock.glsl"
    } else if (mat < 10372) {
        if (color.g != color.b) {
            #include "/lib/materials/quartzBlock.glsl"
            #ifdef GLOWING_ORE_NETHERQUARTZ
                emission = pow2(color.b * 1.6);
                emission *= GLOWING_ORE_MULT;
            #endif
        } else {
            #include "/lib/materials/netherrack.glsl"
        }
    } else if (mat < 10376) {
        #include "/lib/materials/obsidian.glsl"
    } else if (mat < 10380) {
        highlightMult = 2.0;
        smoothnessG = pow2(color.r) * 0.6;
        smoothnessG = min1(smoothnessG);
        smoothnessD = smoothnessG;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.5;
        #endif
    } else if (mat < 10384) {
        #include "/lib/materials/snow.glsl"
    } else if (mat < 10388) {
        materialMask = OSIEBCA;
        float factor = pow2(color.g);
        float factor2 = pow2(factor);
        smoothnessG = 1.0 - 0.5 * factor;
        highlightMult = factor2 * 3.5;
        smoothnessD = factor;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.33;
        #endif
    } else if (mat < 10392) {
        materialMask = OSIEBCA;
        float factor = min1(pow2(color.g) * 1.38);
        float factor2 = pow2(factor);
        smoothnessG = 1.0 - 0.5 * factor;
        highlightMult = factor2 * 3.5;
        smoothnessD = pow1_5(color.g);
        #ifdef COATED_TEXTURES
            noiseFactor = 0.33;
        #endif
    } else if (mat < 10396) {
        #include "/lib/materials/pumpkin.glsl"
    } else if (mat < 10400) {
        #include "/lib/materials/pumpkin.glsl"
        noSmoothLighting = true, noDirectionalShading = true;
        lmCoordM.y = 0.0;
        lmCoordM.x = 1.0;
        #if MC_VERSION >= 11300
            if (color.b > 0.28 && color.r > 0.9) {
                float factor = pow2(color.g);
                emission = pow2(factor) * factor * 5.0;
            }
        #else
            if (color.b < 0.4)
                emission = clamp01(color.g * 1.3 - color.r) * 5.0;
        #endif
    } else if (mat < 10404) {
        noSmoothLighting = true;
    } else if (mat < 10408) {
        noSmoothLighting = true;
        if (color.b > 0.5) {
            #ifdef GBUFFERS_TERRAIN
                color.g *= 1.1;
                emission = 5.0;
            #endif
        }
    } else if (mat < 10412) {
        smoothnessG = color.r * 0.45;
        smoothnessD = smoothnessG;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.77;
        #endif
    } else if (mat < 10416) {
        noSmoothLighting = true; noDirectionalShading = true;
        lmCoordM = vec2(0.9, 0.0);
        emission = max0(color.g - 0.3) * 4.6;
        color.rg += emission * vec2(0.15, 0.05);
        #ifdef DISTANT_LIGHT_BOKEH
            DoDistantLightBokehMaterial(emission, 2.0, lViewPos);
        #endif
    } else if (mat < 10420) {
        float factor = smoothstep1(min1(color.r * 1.5));
        factor = factor > 0.12 ? factor : factor * 0.5;
        smoothnessG = factor;
        smoothnessD = factor;
    } else if (mat < 10424) {
        float factor = color.r * 0.9;
        factor = color.r > 0.215 ? factor : factor * 0.25;
        smoothnessG = factor;
        smoothnessD = factor;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.77;
        #endif
    } else if (mat < 10428) {
        smoothnessG = color.r * 0.75;
        smoothnessD = color.r * 0.5;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.66;
        #endif
    } else if (mat < 10432) {
        #include "/lib/materials/endStone.glsl"
    } else if (mat < 10436) {
        smoothnessG = 0.25;
        highlightMult = 1.5;
        smoothnessD = 0.17;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.33;
        #endif
    } else if (mat < 10440) {
        smoothnessG = 0.75;
        smoothnessD = 0.35;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.5;
        #endif
    } else if (mat < 10444) {
        smoothnessG = pow2(color.g) * 0.8;
        highlightMult = 1.5;
        smoothnessD = smoothnessG;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.66;
        #endif
    } else if (mat < 10448) {
        smoothnessG = min1(pow2(color.g) * 2.0);
        highlightMult = 1.5;
        smoothnessD = smoothnessG;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.77;
        #endif
    } else if (mat < 10452) {
        noSmoothLighting = true;
        noDirectionalShading = true;
        lmCoordM.x = 0.85;
        smoothnessD = min1(max0(0.5 - color.r) * 2.0);
        smoothnessG = color.g;
        #ifndef IPBR_COMPATIBILITY_MODE
            float blockRes = absMidCoordPos.x * atlasSize.x;
            vec2 signMidCoordPosM = (floor((signMidCoordPos + 1.0) * blockRes) + 0.5) / blockRes - 1.0;
            float dotsignMidCoordPos = dot(signMidCoordPosM, signMidCoordPosM);
            float factor = pow2(max0(1.0 - 1.7 * pow2(pow2(dotsignMidCoordPos))));
        #else
            float factor = pow2(pow2(min(dot(color.rgb, color.rgb), 2.5) / 2.5));
        #endif
        emission = pow2(color.b) * 1.6 + 2.2 * factor;
        emission *= 0.4 + max0(0.6 - 0.006 * lViewPos);
        color.rb *= vec2(1.13, 1.1);
        #ifdef DISTANT_LIGHT_BOKEH
            DoDistantLightBokehMaterial(emission, 2.0, lViewPos);
        #endif
        #ifdef COATED_TEXTURES
            noiseFactor = 0.5;
        #endif
    } else if (mat < 10456) {
        noSmoothLighting = true; noDirectionalShading = true;
        lmCoordM = vec2(0.75, 0.0);
        if (color.g > 0.22) {
            emission = pow2(pow2(color.r)) * 4.0;
            #if RAIN_PUDDLES >= 1
                noPuddles = color.g * 4.0;
            #endif
            color.gb *= max(2.0 - 11.0 * pow2(color.g), 0.5);
            maRecolor = vec3(emission * 0.075);
        } else {
            #include "/lib/materials/netherrack.glsl"
            emission = 0.2;
        }
    } else if (mat < 10460) {
        color = texture2DLod(tex, texCoord, 0);
        vec2 coord = signMidCoordPos;
        float blockRes = absMidCoordPos.x * atlasSize.x;
        vec2 absCoord = abs(coord);
        float maxCoord = max(absCoord.x, absCoord.y);
        float dif = GetMaxColorDif(color.rgb);
        if (
            dif > 0.1 && maxCoord < 0.375 &&
            !CheckForColor(color.rgb, vec3(111, 73, 43)) &&
            !CheckForColor(color.rgb, vec3(207, 166, 139)) &&
            !CheckForColor(color.rgb, vec3(155, 139, 207)) &&
            !CheckForColor(color.rgb, vec3(161, 195, 180)) &&
            !CheckForColor(color.rgb, vec3(201, 143, 107)) &&
            !CheckForColor(color.rgb, vec3(135, 121, 181)) &&
            !CheckForColor(color.rgb, vec3(131, 181, 145))
        ) {
            emission = 6.0;
            color.rgb *= color.rgb;
            highlightMult = 2.0;
            maRecolor = vec3(0.5);
        } else {
            smoothnessG = dot(color.rgb, color.rgb) * 0.33;
            smoothnessD = smoothnessG;
        }
    } else if (mat < 10464) {
        smoothnessG = 0.4;
        highlightMult = 1.5;
        smoothnessD = 0.3;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.2;
        #endif
    } else if (mat < 10468) {
        smoothnessG = 0.2;
        smoothnessD = 0.1;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.5;
        #endif
    } else if (mat < 10472) {
        #include "/lib/materials/coral.glsl"
    } else if (mat < 10476) {
        noSmoothLighting = true;
        #include "/lib/materials/coral.glsl"
    } else if (mat < 10480) {
        #include "/lib/materials/cryingObsidian.glsl"
        #ifdef SNOWY_WORLD
            snowFactor = 0.0;
        #endif
    } else if (mat < 10484) {
        #include "/lib/materials/blackstone.glsl"
    } else if (mat < 10488) {
        if (color.r > color.b * 3.0) {
            #include "/lib/materials/rawGoldBlock.glsl"
            #ifdef GLOWING_ORE_GILDEDBLACKSTONE
                emission = color.g * 1.5;
                emission *= GLOWING_ORE_MULT;
            #endif
        } else {
            #include "/lib/materials/blackstone.glsl"
        }
    } else if (mat < 10492) {
        noSmoothLighting = true;
        subsurfaceMode = 2;
        #if defined COATED_TEXTURES && defined GBUFFERS_TERRAIN
            doTileRandomisation = false;
        #endif
        #ifdef IPBR
            float factor = min1(color.g * 2.0);
            smoothnessG = factor * 0.5;
            highlightMult = factor;
        #endif
    } else if (mat < 10496) {
        #include "/lib/materials/dirt.glsl"
        #ifdef GBUFFERS_TERRAIN
            glColor.a = sqrt(glColor.a);
        #endif
    } else if (mat < 10500) {
        noDirectionalShading = true;
        if (color.r > 0.95) {
            noSmoothLighting = true;
            lmCoordM.x = 1.0;
            emission = GetLuminance(color.rgb) * 4.1;
            #ifndef GBUFFERS_TERRAIN
                emission *= 0.65;
            #endif
            color.r *= 1.4;
            color.b *= 0.5;
        }
        #ifdef GBUFFERS_TERRAIN
            else if (abs(NdotU) < 0.5) {
                #ifndef IPBR_COMPATIBILITY_MODE
                    #if MC_VERSION >= 12102
                        lmCoordM.x = min1(0.7 + 0.3 * smoothstep1(max0(0.4 - signMidCoordPos.y)));
                    #else
                        lmCoordM.x = min1(0.7 + 0.3 * pow2(1.0 - signMidCoordPos.y));
                    #endif
                #else
                    lmCoordM.x = 0.82;
                #endif
            }
        #else
            else {
                color.rgb *= 1.5;
            }
        #endif
        #ifdef DISTANT_LIGHT_BOKEH
            DoDistantLightBokehMaterial(color, vec4(1.0, 0.6, 0.2, 1.0), emission, 5.0, lViewPos);
        #endif
        emission += 0.0001;
    } else if (mat < 10504) {
        noDirectionalShading = true;
        #ifdef GBUFFERS_TERRAIN
            noSmoothLighting = true;
            lmCoordM.x = 0.92;
        #else
            lmCoordM.x = 0.9;
        #endif
        float dotColor = dot(color.rgb, color.rgb);
        if (dotColor > 2.0) {
            emission = 3.3;
            emission *= 0.4 + max0(0.6 - 0.006 * lViewPos);
            color.rgb = pow2(color.rgb);
            color.g *= 0.95;
        }
        #ifdef GBUFFERS_TERRAIN
            else {
                vec3 fractPos = abs(fract(playerPos + cameraPosition) - 0.5);
                float maxCoord = max(fractPos.x, max(fractPos.y, fractPos.z));
                if (maxCoord < 0.4376) {
                    lmCoordM.x = 1.0;
                    color.rgb *= 1.8;
                }
            }
        #endif
        #ifdef DISTANT_LIGHT_BOKEH
            DoDistantLightBokehMaterial(emission, 4.0, lViewPos);
        #endif
    } else if (mat < 10508) {

    } else if (mat < 10512) {
        float dotColor = dot(color.rgb, color.rgb);
        if (dotColor > 1.0)
            emission = pow2(pow2(pow2(dotColor * 0.33))) + 0.2 * dotColor;
    } else if (mat < 10516) {
        vec3 checkColor = texture2DLod(tex, texCoord, 0).rgb;
        if (CheckForColor(checkColor, vec3(164, 157, 126)) ||
            CheckForColor(checkColor, vec3(201, 197, 176)) ||
            CheckForColor(checkColor, vec3(226, 221, 188)) ||
            CheckForColor(checkColor, vec3(153, 142, 95))
        ) {
            emission = min(GetLuminance(color.rgb), 0.75) / 0.75;
            emission = pow2(pow2(emission)) * 6.5;
            color.gb *= 0.85;
        } else emission = max0(GetLuminance(color.rgb) - 0.5) * 3.0;
    } else if (mat < 10520) {
        lmCoordM.x *= 0.95;
        #include "/lib/materials/cobblestone.glsl"
        float dotColor = dot(color.rgb, color.rgb);
        emission = 2.5 * dotColor * max0(pow2(pow2(pow2(color.r))) - color.b) + pow(dotColor * 0.35, 32.0);
        color.r *= 1.0 + 0.1 * emission;
    } else if (mat < 10524) {
        float factor = sqrt1(color.r);
        smoothnessG = factor * 0.5;
        highlightMult = factor;
    } else if (mat < 10528) {
        float factor = color.r * 0.5;
        smoothnessG = factor;
        smoothnessD = factor;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.66;
        #endif
    } else if (mat < 10532) {
        noSmoothLighting = true;
        noDirectionalShading = true;
        lmCoordM.x = min(lmCoordM.x * 0.9, 0.77);
        if (color.b > 0.6) {
            emission = 2.7;
            color.rgb = pow1_5(color.rgb);
            color.r = min1(color.r + 0.1);
        }
        emission += 0.0001;
        #ifdef DISTANT_LIGHT_BOKEH
            DoDistantLightBokehMaterial(color, vec4(0.5, 1.0, 1.0, 1.0), emission, 3.0, lViewPos);
        #endif
        #ifdef SNOWY_WORLD
            snowFactor = 0.0;
        #endif
    } else if (mat < 10536) {
        if (color.r > color.g && color.g > color.b && color.b > 0.37) {
            #include "/lib/materials/cobblestone.glsl"
        } else {
            float factor = pow2(color.r) * color.r * 0.8;
            highlightMult = 1.5;
            smoothnessG = factor;
            smoothnessD = factor * 0.9;
            #ifdef COATED_TEXTURES
                noiseFactor = 0.33;
            #endif
        }
    } else if (mat < 10540) {
        if (color.r > color.g && color.g > color.b && color.b > 0.37) {
            #include "/lib/materials/cobblestone.glsl"
        } else {
            float factor = min1(pow2(color.g) + 0.25);
            highlightMult = 1.5;
            smoothnessG = factor;
            smoothnessD = factor * 0.7;
            #ifdef COATED_TEXTURES
                noiseFactor = 0.33;
            #endif
        }
    } else if (mat < 10544) {
        if (color.r > color.g && color.g > color.b && color.b < 0.6) {
            #include "/lib/materials/cobblestone.glsl"
        } else {
            float factor = pow2(pow2(color.g));
            highlightMult = 1.5;
            smoothnessG = factor;
            smoothnessD = factor * 0.5;
            #ifdef COATED_TEXTURES
                noiseFactor = 0.33;
            #endif
        }
    } else if (mat < 10548) {
        noSmoothLighting = true;
        #if GLOWING_LICHEN > 0
            float dotColor = dot(color.rgb, color.rgb);
            emission = min(pow2(pow2(dotColor) * dotColor) * 1.4 + dotColor * 0.9, 6.0);
            emission = mix(emission, dotColor * 1.5, min1(lViewPos / 96.0));
            #if GLOWING_LICHEN == 1
                float skyLightFactor = pow2(1.0 - min1(lmCoord.y * 2.9));
                emission *= skyLightFactor;
                color.r *= 1.0 + 0.15 * skyLightFactor;
            #else
                color.r *= 1.15;
            #endif
        #endif
    } else if (mat < 10552) {
        float dotColor = dot(color.rgb, color.rgb);
        if (dotColor < 0.19 && color.r < color.b) {
            #include "/lib/materials/obsidian.glsl"
        } else if (color.g >= color.r) {
            #include "/lib/materials/diamondBlock.glsl"
        } else {
            smoothnessG = color.r * 0.3 + 0.1;
        }
        #ifdef SNOWY_WORLD
            snowFactor = 0.0;
        #endif
    } else if (mat < 10556) {
        noSmoothLighting = true;
        if (abs(color.r - color.g - 0.05) < 0.10) {
            #include "/lib/materials/endStone.glsl"
        } else {
            #include "/lib/materials/endPortalFrame.glsl"
        }
        #ifdef SNOWY_WORLD
            snowFactor = 0.0;
        #endif
    } else if (mat < 10560) {
        noSmoothLighting = true;
        if (abs(color.r - color.g - 0.05) < 0.10) {
            #include "/lib/materials/endStone.glsl"
        } else {
            #include "/lib/materials/endPortalFrame.glsl"
            vec2 absCoord = abs(fract(playerPos.xz + cameraPosition.xz) - 0.5);
            float maxCoord = max(absCoord.x, absCoord.y);
            if (maxCoord < 0.2505) {
                smoothnessG = 0.5;
                smoothnessD = 0.5;
                emission = pow2(min(color.g, 0.25)) * 170.0 * (0.28 - maxCoord);
            } else {
                float minCoord = min(absCoord.x, absCoord.y);
                if (CheckForColor(color.rgb, vec3(153, 198, 147))
                && minCoord > 0.25) {
                    emission = 1.4;
                    color.rgb = vec3(0.45, 1.0, 0.6);
                }
            }
        }
        #ifdef SNOWY_WORLD
            snowFactor = 0.0;
        #endif
    } else if (mat < 10564) {
        noSmoothLighting = true;
        lmCoordM.x = 0.77;
        #include "/lib/materials/lanternMetal.glsl"
        emission = 4.3 * max0(color.r - color.b);
        emission += min(pow2(pow2(0.75 * dot(color.rgb, color.rgb))), 5.0);
        color.gb *= pow(vec2(0.8, 0.7), vec2(sqrt(emission) * 0.5));
        #ifdef DISTANT_LIGHT_BOKEH
            DoDistantLightBokehMaterial(color, vec4(1.0, 0.6, 0.2, 1.0), emission, 5.0, lViewPos);
        #endif
        #ifdef SNOWY_WORLD
            snowFactor = 0.0;
        #endif
    } else if (mat < 10568) {
        noSmoothLighting = true;
        lmCoordM.x = min(lmCoordM.x, 0.77);
        #include "/lib/materials/lanternMetal.glsl"
        emission = 1.45 * max0(color.g - color.r * 2.0);
        emission += 1.17 * min(pow2(pow2(0.55 * dot(color.rgb, color.rgb))), 3.5);
        #ifdef DISTANT_LIGHT_BOKEH
            DoDistantLightBokehMaterial(color, vec4(0.5, 1.0, 1.0, 1.0), emission, 3.0, lViewPos);
        #endif
        #ifdef SNOWY_WORLD
            snowFactor = 0.0;
        #endif
    } else if (mat < 10572) {
        smoothnessG = (color.r + color.g) * 0.35;
        smoothnessD = (color.r + color.g) * 0.25;
    } else if (mat < 10576) {
        emission = float(color.b > 0.1) * 10.0 + 1.25;
    } else if (mat < 10580) {
        lmCoordM.x *= 0.95;
        float dotColor = dot(color.rgb, color.rgb);
        if (color.r > color.b * 2.0 && dotColor > 0.7) {
            emission = 2.5 * dotColor;
            color.r *= 1.5;
        } else {
            #include "/lib/materials/cobblestone.glsl"
        }
    } else if (mat < 10584) {
        lmCoordM.x *= 0.95;
        float dotColor = dot(color.rgb, color.rgb);
        if (color.r > color.b * 2.0 && dotColor > 0.7) {
            emission = pow2(color.g) * (20.0 - 13.7 * float(color.b > 0.25));
            color.r *= 1.5;
        } else {
            #include "/lib/materials/cobblestone.glsl"
        }
    } else if (mat < 10588) {
        smoothnessG = dot(color.rgb, vec3(0.5));
        smoothnessG = min1(smoothnessG);
        smoothnessD = smoothnessG;
    } else if (mat < 10592) {
        noSmoothLighting = true;
        #include "/lib/materials/cryingObsidian.glsl"
        emission += 0.2;
        #ifdef SNOWY_WORLD
            snowFactor = 0.0;
        #endif
    } else if (mat < 10596) {
        noSmoothLighting = true;
        #include "/lib/materials/cryingObsidian.glsl"
        vec2 absCoord = abs(signMidCoordPos);
        if (NdotU > 0.9 && max(absCoord.x, absCoord.y) < 0.754) {
            highlightMult = 0.0;
            smoothnessD = 0.0;
            emission = pow2(color.r) * color.r * 16.0;
            maRecolor = vec3(0.0);
        } else if (color.r + color.g > 1.3) {
            emission = 4.5 * sqrt3(max0(color.r + color.g - 1.3));
        }
        emission += 0.3;
        #ifdef SNOWY_WORLD
            snowFactor = 0.0;
        #endif
    } else if (mat < 10600) {
        #include "/lib/materials/redstoneBlock.glsl"
        #if COLORED_LIGHTING_INTERNAL == 0
            emission = pow2(min(color.r, 0.9)) * 4.0;
        #else
            vec3 colorP = color.rgb / glColor.rgb;
            emission = pow2((colorP.r + color.r) * 0.5) * 3.5;
        #endif
        color.gb *= 0.25;
    } else if (mat < 10604) {
        #include "/lib/materials/redstoneBlock.glsl"
    } else if (mat < 10608) {
        noSmoothLighting = true; noDirectionalShading = true;
        lmCoordM.x = min(lmCoordM.x * 0.9, 0.77);
        #include "/lib/materials/redstoneTorch.glsl"
        emission += 0.0001;
        #ifdef DISTANT_LIGHT_BOKEH
            DoDistantLightBokehMaterial(color, vec4(1.0, 0.0, 0.0, 1.0), emission, 5.0, lViewPos);
        #endif
    } else if (mat < 10612) {
        #include "/lib/materials/redstoneBlock.glsl"
        #ifdef EMISSIVE_REDSTONE_BLOCK
            emission = 0.75 + 3.0 * pow2(pow2(color.r));
            color.gb *= 0.65;
            #ifdef SNOWY_WORLD
                snowFactor = 0.0;
            #endif
        #endif
    } else if (mat < 10616) {
        if (color.r - color.g > 0.2) {
            #include "/lib/materials/redstoneBlock.glsl"
            #ifdef GLOWING_ORE_REDSTONE
                emission = color.r * pow1_5(color.r) * 4.0;
                color.gb *= 1.0 - 0.9 * min1(GLOWING_ORE_MULT);
                emission *= GLOWING_ORE_MULT;
            #endif
        } else {
            #include "/lib/materials/stone.glsl"
        }
    } else if (mat < 10620) {
        if (color.r - color.g > 0.2) {
            #include "/lib/materials/redstoneBlock.glsl"
            emission = pow2(color.r) * color.r * 5.5;
            color.gb *= 0.1;
        } else {
            #include "/lib/materials/stone.glsl"
        }
        noSmoothLighting = true;
    } else if (mat < 10624) {
        if (color.r - color.g > 0.2) {
            #include "/lib/materials/redstoneBlock.glsl"
            #ifdef GLOWING_ORE_REDSTONE
                emission = color.r * pow1_5(color.r) * 4.0;
                color.gb *= 1.0 - 0.9 * min1(GLOWING_ORE_MULT);
                emission *= GLOWING_ORE_MULT;
            #endif
        } else {
            #include "/lib/materials/deepslate.glsl"
        }
    } else if (mat < 10628) {
        if (color.r - color.g > 0.2) {
            #include "/lib/materials/redstoneBlock.glsl"
            emission = pow2(color.r) * color.r * 6.0;
            color.gb *= 0.05;
        } else {
            #include "/lib/materials/deepslate.glsl"
        }
        noSmoothLighting = true;
    } else if (mat < 10632) {
        subsurfaceMode = 1;
        lmCoordM.x *= 0.875;
    } else if (mat < 10636) {
        subsurfaceMode = 1;
        lmCoordM.x *= 0.875;
        if (color.r > 0.64) {
            emission = color.r < 0.75 ? 2.5 : 8.0;
            color.rgb = color.rgb * vec3(1.0, 0.8, 0.6);
        }
    } else if (mat < 10640) {
        materialMask = OSIEBCA;
        smoothnessG = color.r * 0.5 + 0.2;
        float factor = pow2(smoothnessG);
        highlightMult = factor * 2.0 + 1.0;
        smoothnessD = min1(factor * 2.0);
    } else if (mat < 10644) {
        noDirectionalShading = true;
        lmCoordM.x = 0.84;
        materialMask = OSIEBCA;
        smoothnessG = color.r * 0.35 + 0.2;
        float factor = pow2(smoothnessG);
        highlightMult = factor * 2.0 + 1.0;
        smoothnessD = min1(factor * 2.0);
        if (color.b > 0.1) {
            float dotColor = dot(color.rgb, color.rgb);
            #if MC_VERSION >= 11300
                emission = pow2(dotColor) * 1.0;
            #else
                emission = dotColor * 1.2;
            #endif
            color.rgb = pow1_5(color.rgb);
            maRecolor = vec3(emission * 0.2);
        }
        #ifdef DISTANT_LIGHT_BOKEH
            DoDistantLightBokehMaterial(emission, 5.0, lViewPos);
        #endif
    } else if (mat < 10648) {
        noSmoothLighting = true;
        #if ANISOTROPIC_FILTER > 0
            color = texture2D(tex, texCoord);
            color.rgb *= glColor.rgb;
        #endif
        vec3 absDif = abs(vec3(color.r - color.g, color.g - color.b, color.r - color.b));
        float maxDif = max(absDif.r, max(absDif.g, absDif.b));
        if (maxDif > 0.125 || color.b > 0.99) {
            if (color.r < 0.999 && color.b > 0.4) color.gb *= 0.5;
            #include "/lib/materials/redstoneTorch.glsl"
        } else {
            float factor = pow2(color.g) * 0.6;
            smoothnessG = factor;
            highlightMult = 1.0 + 2.5 * factor;
            smoothnessD = factor;
        }
    } else if (mat < 10652) {
        noSmoothLighting = true;
        noDirectionalShading = true;
        lmCoordM = vec2(1.0, 0.0);
        float dotColor = dot(color.rgb, color.rgb);
        emission = min(pow2(pow2(pow2(dotColor * 0.6))), 6.0) * 0.8 + 0.5;
        #ifdef DISTANT_LIGHT_BOKEH
            DoDistantLightBokehMaterial(emission, 2.5, lViewPos);
        #endif
    } else if (mat < 10656) {
        #ifdef GBUFFERS_TERRAIN
            vec3 fractPos = fract(playerPos + cameraPosition) - 0.5;
            lmCoordM.x = pow2(pow2(smoothstep1(1.0 - 0.4 * dot(fractPos.xz, fractPos.xz))));
        #endif
        float dotColor = dot(color.rgb, color.rgb);
        if (color.r > color.b && color.r - color.g < 0.15 && dotColor < 1.4) {
            #include "/lib/materials/oakWood.glsl"
        } else if (color.r > color.b || dotColor > 2.9) {
            noDirectionalShading = true;
            emission = 3.5;
            color.rgb *= sqrt1(GetLuminance(color.rgb));
        }
    } else if (mat < 10660) {
        #if COLORED_LIGHTING_INTERNAL == 0
            noSmoothLighting = true;
        #else
            #ifdef GBUFFERS_TERRAIN
                vec3 fractPos = fract(playerPos + cameraPosition) - 0.5;
                lmCoordM.x = pow2(pow2(smoothstep1(1.0 - 0.4 * dot(fractPos.xz, fractPos.xz))));
                lmCoordM.x *= 0.95;
            #endif
        #endif
        float dotColor = dot(color.rgb, color.rgb);
        if (color.r > color.b) {
            #include "/lib/materials/oakWood.glsl"
        } else if (color.g - color.r > 0.1 || dotColor > 2.9) {
            noDirectionalShading = true;
            emission = 2.1;
            color.rgb *= sqrt1(GetLuminance(color.rgb));
        }
        #ifdef SNOWY_WORLD
            snowFactor = 0.0;
        #endif
    } else if (mat < 10664) {
        noSmoothLighting = true;
        if (color.r > color.b) {
            #include "/lib/materials/oakWood.glsl"
        }
    } else if (mat < 10668) {
        if (color.r > 0.1 && color.g + color.b < 0.1) {
            #include "/lib/materials/redstoneTorch.glsl"
        } else {
            #include "/lib/materials/cobblestone.glsl"
        }
    } else if (mat < 10672) {
        #ifdef COATED_TEXTURES
            noiseFactor = 0.77;
        #endif
    } else if (mat < 10676) {
        smoothnessG = color.r * 0.2;
        smoothnessD = smoothnessG;
        #ifdef GBUFFERS_TERRAIN
            DoBrightBlockTweaks(color.rgb, 0.5, shadowMult, highlightMult);
        #endif
        #ifdef COATED_TEXTURES
            noiseFactor = 0.33;
        #endif
    } else if (mat < 10680) {
        #include "/lib/materials/cobblestone.glsl"
        #ifdef COATED_TEXTURES
            noiseFactor = 0.66;
        #endif
    } else if (mat < 10684) {
        float frogPow = 8.0;
        #include "/lib/materials/froglights.glsl"
    } else if (mat < 10688) {
        float frogPow = 16.0;
        #include "/lib/materials/froglights.glsl"
    } else if (mat < 10692) {
        float frogPow = 24.0;
        #include "/lib/materials/froglights.glsl"
    } else if (mat < 10696) {
        if (abs(color.r - color.g) < 0.01) {
            #include "/lib/materials/deepslate.glsl"
        } else {
            float boneFactor = max0(color.r * 1.25 - color.b);
            if (boneFactor < 0.0001) emission = 0.15;
            smoothnessG = min1(boneFactor * 1.7);
            smoothnessD = smoothnessG;
        }
    } else if (mat < 10700) {
        float boneFactor = max0(color.r * 1.25 - color.b);
        if (boneFactor < 0.0001) {
            emission = pow2(max0(color.g - color.r)) * 1.7;
            #ifdef GBUFFERS_TERRAIN
                vec2 bpos = floor(playerPos.xz + cameraPosition.xz + 0.501)
                    + floor(playerPos.y + cameraPosition.y + 0.501);
                bpos = bpos * 0.01 + 0.003 * frameTimeCounter;
                emission *= pow2(texture2D(noisetex, bpos).r * pow1_5(texture2D(noisetex, bpos * 0.5).r));
                emission *= 6.0;
            #endif
        }
        smoothnessG = min1(boneFactor * 1.7);
        smoothnessD = smoothnessG;
        #ifdef SNOWY_WORLD
            snowFactor = 0.0;
        #endif
    } else if (mat < 10704) {
        float boneFactor = max0(color.r * 1.25 - color.b);
        if (boneFactor < 0.0001) {
            emission = pow2(max0(color.g - color.r)) * 2.0;
            #ifdef GBUFFERS_TERRAIN
                vec2 coordFactor = abs(fract(playerPos.xz + cameraPosition.xz) - 0.5);
                float coordFactorM = max(coordFactor.x, coordFactor.y);
                if (coordFactorM < 0.43) emission += color.g * 7.0;
            #endif
        }
        smoothnessG = min1(boneFactor * 1.7);
        smoothnessD = smoothnessG;
        #ifdef SNOWY_WORLD
            snowFactor = 0.0;
        #endif
    } else if (mat < 10708) {
        lmCoordM = vec2(0.0, 0.0);
        emission = pow2(max0(color.g - color.r)) * 7.0 + 0.7;
    } else if (mat < 10712) {
        smoothnessG = color.b + 0.2;
        smoothnessD = smoothnessG;
        emission = 7.0 * float(CheckForColor(color.rgb, vec3(110, 4, 83)));
    } else if (mat < 10716) {
        smoothnessG = color.r * 0.4;
        smoothnessD = smoothnessG;
    } else if (mat < 10720) {
        highlightMult = 2.0;
        smoothnessG = pow2(pow2(color.g)) * 0.5;
        smoothnessG = min1(smoothnessG);
        smoothnessD = smoothnessG * 0.7;
        #ifdef GBUFFERS_TERRAIN
            DoOceanBlockTweaks(smoothnessD);
        #endif
        #ifdef COATED_TEXTURES
            noiseFactor = 0.77;
        #endif
    } else if (mat < 10724) {
        noSmoothLighting = true;
    } else if (mat < 10728) {
        #include "/lib/materials/stone.glsl"
        #ifdef GBUFFERS_TERRAIN
            DoOceanBlockTweaks(smoothnessD);
        #endif
        #ifdef COATED_TEXTURES
            noiseFactor = 1.25;
        #endif
    } else if (mat < 10732) {
        noSmoothLighting = true;
    } else if (mat < 10736) {
        noSmoothLighting = true;
        float NdotE = dot(normalM, eastVec);
        if (abs(abs(NdotE) - 0.5) < 0.4) {
            subsurfaceMode = 1, noDirectionalShading = true;
        }
    } else if (mat < 10740) {
        float blockRes = absMidCoordPos.x * atlasSize.x;
        vec2 signMidCoordPosM = (floor((signMidCoordPos + 1.0) * blockRes) + 0.5) / blockRes - 1.0;
        float dotsignMidCoordPos = dot(signMidCoordPosM, signMidCoordPosM);
        float lBlockPosM = pow2(max0(1.0 - 1.125 * pow2(dotsignMidCoordPos)));
        emission = 2.5 * lBlockPosM + 1.0;
        color.rgb = mix(color.rgb, pow2(color.rgb), 0.5);
    } else if (mat < 10744) {
        noSmoothLighting = true;
        lmCoordM.x = min(lmCoordM.x, 0.77);
        #include "/lib/materials/lanternMetal.glsl"
    } else if (mat < 10748) {
        smoothnessG = color.r * 0.4;
        smoothnessD = color.r * 0.25;
    } else if (mat < 10752) {
        smoothnessG = pow2(color.b) * 0.8;
        smoothnessD = smoothnessG;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.5;
        #endif
    } else if (mat < 10756) {
        if (absMidCoordPos.x > 0.005)
            subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;
    } else if (mat < 10760) {
        #include "/lib/materials/bambooPlanks.glsl"
    } else if (mat < 10764) {
        #include "/lib/materials/cherryPlanks.glsl"
    } else if (mat < 10768) {
        if (color.g > 0.33) {
            #include "/lib/materials/cherryPlanks.glsl"
        } else {
            smoothnessG = pow2(color.r);
            smoothnessD = smoothnessG;
        }
    } else if (mat < 10772) {
        #include "/lib/materials/torchflower.glsl"
    } else if (mat < 10776) {
        noSmoothLighting = true;
        float NdotE = dot(normalM, eastVec);
        if (abs(abs(NdotE) - 0.5) < 0.4) {
            #include "/lib/materials/torchflower.glsl"
        }
    } else if (mat < 10780) {
        noSmoothLighting = true;
        if (color.r > 0.91) {
            emission = 3.0 * color.g;
            color.r *= 1.2;
            maRecolor = vec3(0.1);
        }
    } else if (mat < 10784) {
        noSmoothLighting = true;
        float NdotE = dot(normalM, eastVec);
        if (abs(abs(NdotE) - 0.5) < 0.4) {
            if (color.r > 0.91) {
                emission = 3.0 * color.g;
                color.r *= 1.2;
                maRecolor = vec3(0.1);
            }
        }
    } else if (mat < 10788) {
        #if ANISOTROPIC_FILTER == 0
            vec4 checkColor = color;
        #else
            vec4 checkColor = texture2D(tex, texCoord);
        #endif
        if (checkColor.r + checkColor.b > checkColor.g * 2.2 || checkColor.r > 0.99) {
            #if GLOWING_AMETHYST >= 1
                #if defined GBUFFERS_TERRAIN && !defined IPBR_COMPATIBILITY_MODE
                    vec2 absCoord = abs(signMidCoordPos);
                    float maxBlockPos = max(absCoord.x, absCoord.y);
                    emission = pow2(max0(1.0 - maxBlockPos) * color.g) * 5.4 + 1.2 * color.g;
                    color.g *= 1.0 - emission * 0.07;
                    color.rgb *= color.g;
                #else
                    emission = pow2(color.g + color.b) * 0.32;
                #endif
            #endif
            #ifdef COATED_TEXTURES
                noiseFactor = 0.66;
            #endif
        } else {
            float boneFactor = max0(color.r * 1.25 - color.b);
            if (boneFactor < 0.0001) emission = pow2(max0(color.g - color.r));
            smoothnessG = min1(boneFactor * 1.7);
            smoothnessD = smoothnessG;
        }
        #ifdef SNOWY_WORLD
            snowFactor = 0.0;
        #endif
    } else if (mat < 10792) {
        lmCoordM = vec2(0.0, 0.0);
        #if ANISOTROPIC_FILTER == 0
            vec4 checkColor = color;
        #else
            vec4 checkColor = texture2D(tex, texCoord);
        #endif
        if (checkColor.r + checkColor.b > checkColor.g * 2.2 || checkColor.r > 0.99) {
            lmCoordM.x = 1.0;
            #if GLOWING_AMETHYST >= 1
                #if defined GBUFFERS_TERRAIN && !defined IPBR_COMPATIBILITY_MODE
                    vec2 absCoord = abs(signMidCoordPos);
                    float maxBlockPos = max(absCoord.x, absCoord.y);
                    emission = pow2(max0(1.0 - maxBlockPos) * color.g) * 5.4 + 1.2 * color.g;
                    color.g *= 1.0 - emission * 0.07;
                    color.rgb *= color.g;
                #else
                    emission = pow2(color.g + color.b) * 0.32;
                #endif
            #endif
            #ifdef COATED_TEXTURES
                noiseFactor = 0.66;
            #endif
        } else {
            emission = pow2(max0(color.g - color.r)) * 7.0 + 0.7;
        }
    } else if (mat < 10796) {
        noSmoothLighting = true;
        #include "/lib/materials/oakPlanks.glsl"
    } else if (mat < 10800) {
        noSmoothLighting = true;
        #include "/lib/materials/sprucePlanks.glsl"
    } else if (mat < 10804) {
        noSmoothLighting = true;
        #include "/lib/materials/birchPlanks.glsl"
    } else if (mat < 10808) {
        noSmoothLighting = true;
        #include "/lib/materials/junglePlanks.glsl"
    } else if (mat < 10812) {
        noSmoothLighting = true;
        #include "/lib/materials/acaciaPlanks.glsl"
    } else if (mat < 10816) {
        noSmoothLighting = true;
        #include "/lib/materials/darkOakPlanks.glsl"
    } else if (mat < 10820) {
        noSmoothLighting = true;
        #include "/lib/materials/mangrovePlanks.glsl"
    } else if (mat < 10824) {
        noSmoothLighting = true;
        #include "/lib/materials/crimsonPlanks.glsl"
    } else if (mat < 10828) {
        noSmoothLighting = true;
        #include "/lib/materials/warpedPlanks.glsl"
    } else if (mat < 10832) {
        noSmoothLighting = true;
        #include "/lib/materials/bambooPlanks.glsl"
    } else if (mat < 10836) {
        noSmoothLighting = true;
        #include "/lib/materials/cherryPlanks.glsl"
    } else if (mat < 10840) {
        #ifdef GBUFFERS_TERRAIN
            vec3 worldPos = playerPos + cameraPosition;
            vec3 fractPos = fract(worldPos.xyz);
            vec3 coordM = abs(fractPos.xyz - 0.5);
            float cLength = dot(coordM, coordM) * 1.3333333;
            cLength = pow2(1.0 - cLength);
            if (color.r + color.g > color.b * 3.0 && max(coordM.x, coordM.z) < 0.07) {
                emission = 2.5 * pow1_5(cLength);
            } else {
                lmCoordM.x = max(lmCoordM.x * 0.9, cLength);
                #include "/lib/materials/cobblestone.glsl"
            }
        #else
            emission = max0(color.r + color.g - color.b * 1.8 - 0.3) * 2.2;
        #endif
    } else if (mat < 10844) {
        smoothnessG = 0.4;
        highlightMult = 1.5;
        smoothnessD = 0.3;
        #ifdef COATED_TEXTURES
            noiseFactor = 0.2;
        #endif
        #ifdef GREEN_SCREEN_LIME
            materialMask = OSIEBCA * 240.0;
        #endif
    } else if (mat < 10848) {
        #ifdef COATED_TEXTURES
            noiseFactor = 0.77;
        #endif
        #ifdef GREEN_SCREEN_LIME
            materialMask = OSIEBCA * 240.0;
        #endif
    } else if (mat < 10852) {
        smoothnessG = pow2(color.b);
        smoothnessD = max(smoothnessG, 0.2);
        if (color.r > 2.5 * (color.g + color.b)) {
            emission = 4.0;
            color.rgb *= color.rgb;
        }
    } else if (mat < 10856) {
        #include "/lib/materials/copperBulb.glsl"
    } else if (mat < 10860) {
        #include "/lib/materials/copperBulb.glsl"
        emission *= 0.85;
    } else if (mat < 10864) {
        noSmoothLighting = true;
        #include "/lib/materials/copperBlock.glsl"
    } else if (mat < 10868) {
        #include "/lib/materials/copperBlock.glsl"
    } else if (mat < 10872) {
        smoothnessG = max0(color.b - color.r * 0.5);
        smoothnessD = smoothnessG;
        emission = max0(color.r - color.b) * 3.0;
        color.rgb = pow(color.rgb, vec3(1.0 + 0.5 * sqrt(emission)));
    } else if (mat < 10876) {
        smoothnessG = max0(color.b - color.r * 0.5);
        smoothnessD = smoothnessG;
    } else if (mat < 10880) {
        float maxComponent = max(max(color.r, color.g), color.b);
        float minComponent = min(min(color.r, color.g), color.b);
        float saturation = (maxComponent - minComponent) / (1.0 - abs(maxComponent + minComponent - 1.0));
        smoothnessG = max0(color.b - pow2(saturation) * 0.5) * 0.5 + 0.1;
        smoothnessD = smoothnessG;
        emission = saturation > 0.5 ? 4.0 : 0.0;
        color.rgb = pow(color.rgb, vec3(1.0 + (0.3 + 0.5 * color.r) * emission));
    } else if (mat < 10884) {

    } else if (mat < 10888) {
        noSmoothLighting = true;
        #if defined COATED_TEXTURES && defined GBUFFERS_TERRAIN
            doTileRandomisation = false;
        #endif
        if (color.r > 0.91) {
            emission = 3.0 * color.g;
            color.r *= 1.2;
            maRecolor = vec3(0.1);
        }
    } else if (mat < 10892) {
        smoothnessG = pow2(color.r) * 0.5;
        highlightMult *= 1.5;
        smoothnessD = float(color.r > color.g * 2.0) * 0.3;
    } else if (mat < 10896) {
        noSmoothLighting = true;
        #include "/lib/materials/ironBlock.glsl"
        color.rgb *= 0.9;
    } else if (mat < 10900) {
        #include "/lib/materials/ironBlock.glsl"
        color.rgb *= 0.9;
    } else if (mat < 10924) {
        #include "/lib/materials/candle.glsl"
    } else if (mat < 10928) {

    } else if (mat < 10932) {
        #include "/lib/materials/paleOakPlanks.glsl"
    } else if (mat < 10936) {
        if (color.g > 0.45) {
            #include "/lib/materials/paleOakPlanks.glsl"
        } else {
            #include "/lib/materials/paleOakWood.glsl"
        }
    } else if (mat < 10940) {
        noSmoothLighting = true;
        #include "/lib/materials/paleOakPlanks.glsl"
    } else if (mat < 10944) {
        smoothnessG = color.r * 0.25;
        smoothnessD = smoothnessG;
    } else if (mat < 10948) {
        #include "/lib/materials/paleOakWood.glsl"
    } else if (mat < 10952) {
        #include "/lib/materials/paleOakWood.glsl"
        if (color.r + color.g > color.b * 4.0) {
            emission = pow2(color.r) * 2.5 + 0.2;
        }
    } else if (mat < 10956) {
        #include "/lib/materials/snow.glsl"
        #if defined GBUFFERS_TERRAIN && defined TAA
            float snowFadeOut = 0.0;
            snowFadeOut = clamp01((playerPos.y) * 0.1);
            snowFadeOut *= clamp01((lViewPos - 64.0) * 0.01);
            if (dither + 0.25 < snowFadeOut) discard;
        #endif
    } else if (mat < 10960) {
        smoothnessG = pow2(color.r) * 0.5;
        smoothnessD = smoothnessG * 0.5;
    } else if (mat < 10964) {
        smoothnessG = pow2(color.r) * 0.5;
        smoothnessD = smoothnessG * 0.5;
        if (color.r > color.g + color.b) {
            if (CheckForColor(color.rgb, vec3(220, 74, 74))) {
                emission = 5.0;
                color.rgb *= mix(vec3(1.0), pow2(color.rgb), 0.9);
            } else {
                emission = 3.0;
                color.rgb *= pow2(color.rgb);
            }
        }
    } else if (mat < 10968) {
        smoothnessG = pow2(color.g) * 0.2;
        smoothnessD = smoothnessG * 0.5;
    } else if (mat < 10972) {
        smoothnessG = color.g * 0.75;
        highlightMult = 0.3;
        smoothnessD = smoothnessG * 0.25;
    } else if (mat < 10976) {
        subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;
        #if defined COATED_TEXTURES && defined GBUFFERS_TERRAIN
            doTileRandomisation = false;
        #endif
        color.rgb *= 1.5;
    } else if (mat < 10980) {
        #include "/lib/materials/openEyeblossom.glsl"
    } else if (mat < 10984) {
        noSmoothLighting = true;
        float NdotE = dot(normalM, eastVec);
        if (abs(abs(NdotE) - 0.5) < 0.4) {
            #include "/lib/materials/openEyeblossom.glsl"
        }
    } else if (mat < 10988) {

    } else if (mat < 10992) {

    } else if (mat < 10996) {

    } else if (mat < 11000) {

    } else if (mat < 11004) {

    } else if (mat < 11008) {

    } else if (mat < 11012) {

    } else if (mat < 11016) {

    } else if (mat < 11020) {

    } else if (mat < 11024) {

    }
}
#ifdef GBUFFERS_TERRAIN
else {
    int blockEntityId = mat;
    #include "/lib/materials/blockEntityMaterials.glsl"
}
#endif
