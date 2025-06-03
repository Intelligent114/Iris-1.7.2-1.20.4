switch (entityId) {
    case 50000:
        lmCoordM.x *= 0.7;
        if (color.g * 1.2 < color.r) {
            emission = 12.0 * color.g;
            color.r *= 1.1;
        }
        break;
    case 50004:
        #include "/lib/materials/lightningBolt.glsl"
        break;
    case 50008:
        noSmoothLighting = true;
        break;
    case 50012:
        #include "/lib/materials/ironBlock.glsl"
        smoothnessD *= 0.4;
        break;
    case 50016:
        if (entityColor.a < 0.001) {
            #ifdef COATED_TEXTURES
                noiseFactor = 0.5;
            #endif
            if (CheckForColor(texelFetch(tex, ivec2(0, 0), 0).rgb, vec3(23, 46, 92))) {
                for (int i = 63; i >= 56; i--) {
                    vec3 dif = color.rgb - texelFetch(tex, ivec2(i, 0), 0).rgb;
                    if (dif == clamp(dif, vec3(-0.001), vec3(0.001))) {
                        emission = 2.0 * texelFetch(tex, ivec2(i, 1), 0).r;
                    }
                }
            }
        }
        break;
    case 50020:
        lmCoordM = vec2(0.9, 0.0);
        emission = min(color.r, 0.7) * 1.4;
        float dotColor_50020 = dot(color.rgb, color.rgb);
        if (abs(dotColor_50020 - 1.5) > 1.4) {
            emission = 5.0;
        }
        break;
    case 50024:
        emission = max0(color.b - color.g - color.r) * 10.0;
        break;
    case 50028:
        if (atlasSize.x < 900) {
            if (CheckForColor(color.rgb, vec3(143, 241, 215)) ||
                CheckForColor(color.rgb, vec3( 49, 173, 183)) ||
                CheckForColor(color.rgb, vec3(101, 224, 221))) emission = 2.5;
        }
        break;
    case 50032:
        vec3 absDif = abs(vec3(color.r - color.g, color.g - color.b, color.r - color.b));
        float maxDif = max(absDif.r, max(absDif.g, absDif.b));
        if (maxDif < 0.1 && color.b > 0.5 && color.b < 0.88) {
            emission = pow2(pow1_5(color.b)) * 5.0;
            color.rgb *= color.rgb;
        }
        break;
    case 50036:
        if (CheckForColor(color.rgb, vec3(203, 177, 165)) ||
            CheckForColor(color.rgb, vec3(214, 155, 126))) {
            emission = pow2(pow1_5(color.b)) * 10.0;
            color.r *= 1.2;
        }
        break;
    case 50040:
        if (CheckForColor(color.rgb, vec3(87, 23, 50))) {
            emission = 8.0;
            color.rgb *= color.rgb;
        }
        break;
    case 50044:
        if (entityColor.a < 0.001)
            emission = max0(color.r - color.g - color.b) * 6.0;
        break;
    case 50048:
        lmCoordM.x = 0.0;
        float dotColor_50048 = dot(color.rgb, color.rgb);
        emission = pow2(pow2(min(dotColor_50048 * 0.65, 1.5))) + 0.45;
        break;
    case 50052:
        emission = color.g * 6.0;
        break;
    case 50056:
        if (CheckForColor(color.rgb, vec3(230, 242, 246)) && texCoord.y > 0.35)
            emission = 2.5;
        break;
    case 50060:
        lmCoordM = vec2(0.0);
        emission = pow2(pow2(color.r)) * 3.5 + 0.5;
        color.a *= color.a;
        break;
    case 50064:
        emission = 2.0 * color.g * float(color.g * 1.5 > color.b + color.r);
        break;
    case 50068:
        lmCoordM.x = 0.9;
        emission = 3.0 * float(dot(color.rgb, color.rgb) > 1.0);
        break;
    case 50072:
        emission = 7.5;
        color.rgb *= color.rgb;
        break;
    case 50076:
        playerPos.y += 0.38;
        break;
    case 50080:
        if (atlasSize.x < 900) {
            lmCoordM = vec2(0.0);
            emission = float(color.r > 0.9 && color.b > 0.9) * 5.0 + color.g;
        } else {
            lmCoordM.x = 0.8;
        }
        break;
    case 50084:

        break;
    case 50088:
        emission = 1.3;
        break;
    case 50092:
        #ifdef IS_IRIS
            #include "/lib/materials/trident.glsl"
        #endif
        break;
    case 50096:
        if (atlasSize.x < 900 && color.r * color.g * color.b + color.b > 0.3) {
            #include "/lib/materials/ironBlock.glsl"
            smoothnessD *= 0.6;
        }
        break;
    case 50100:
        if (CheckForColor(color.rgb, vec3(239, 254, 194)))
            emission = 2.5;
        break;
    case 50104:
        if (atlasSize.x < 900) {
            if (CheckForColor(color.rgb, vec3(255)) || CheckForColor(color.rgb, vec3(255, 242, 246))) {
                vec2 tSize = textureSize(tex, 0);
                vec4 checkRightmostColor = texelFetch(tex, ivec2(texCoord * tSize) + ivec2(1, 0), 0);
                if (
                    CheckForColor(checkRightmostColor.rgb, vec3(201, 130, 101)) ||
                    CheckForColor(checkRightmostColor.rgb, vec3(241, 158, 152)) ||
                    CheckForColor(checkRightmostColor.rgb, vec3(223, 127, 119)) ||
                    CheckForColor(checkRightmostColor.rgb, vec3(241, 158, 152)) ||
                    CheckForColor(checkRightmostColor.rgb, vec3(165, 99, 80)) ||
                    CheckForColor(checkRightmostColor.rgb, vec3(213, 149, 122)) ||
                    CheckForColor(checkRightmostColor.rgb, vec3(255))
                ) {
                    emission = 1.0;
                }
            }
        }
        break;
    case 50108:
        if (color.r > 0.7 && color.r > color.g * 1.2 && color.g > color.b * 2.0) {
            lmCoordM.x = 0.5;
            emission = 5.0 * color.g;
            color.rgb *= color.rgb;
        }
        break;
    case 50112:
        noDirectionalShading = true;
        color.rgb *= 1.5;
        if (color.a < 0.5) {
            color.a = 0.12;
            color.rgb *= 5.0;
        }
        break;
    case 50116:

        break;
    case 50120:

        break;
    case 50124:

        break;


}
