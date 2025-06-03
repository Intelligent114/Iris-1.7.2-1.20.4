#ifndef INCLUDE_VOXELIZATION
    #define INCLUDE_VOXELIZATION

    #if COLORED_LIGHTING_INTERNAL <= 512
        const ivec3 voxelVolumeSize = ivec3(COLORED_LIGHTING_INTERNAL, COLORED_LIGHTING_INTERNAL * 0.5, COLORED_LIGHTING_INTERNAL);
    #else
        const ivec3 voxelVolumeSize = ivec3(COLORED_LIGHTING_INTERNAL, 512 * 0.5, COLORED_LIGHTING_INTERNAL);
    #endif

    float effectiveACLdistance = min(float(COLORED_LIGHTING_INTERNAL), shadowDistance * 2.0);

    vec3 transform(mat4 m, vec3 pos) {
        return mat3(m) * pos + m[3].xyz;
    }

    vec3 SceneToVoxel(vec3 scenePos) {
        return scenePos + cameraPositionBestFract + (0.5 * vec3(voxelVolumeSize));
    }

    bool CheckInsideVoxelVolume(vec3 voxelPos) {
        #ifndef SHADOW
            voxelPos -= voxelVolumeSize / 2;
            voxelPos += sign(voxelPos) * 0.95;
            voxelPos += voxelVolumeSize / 2;
        #endif
        voxelPos /= vec3(voxelVolumeSize);
        return clamp01(voxelPos) == voxelPos;
    }

    vec4 GetLightVolume(vec3 pos) {
        vec4 lightVolume;

        #ifdef COMPOSITE
            #undef ACL_CORNER_LEAK_FIX
        #endif

        #ifdef ACL_CORNER_LEAK_FIX
            float minMult = 1.5;
            ivec3 posTX = ivec3(pos * voxelVolumeSize);

            ivec3[6] adjacentOffsets = ivec3[](
                ivec3( 1, 0, 0),
                ivec3(-1, 0, 0),
                ivec3( 0, 1, 0),
                ivec3( 0,-1, 0),
                ivec3( 0, 0, 1),
                ivec3( 0, 0,-1)
            );

            int adjacentCount = 0;
            for (int i = 0; i < 6; i++) {
                int voxel = int(texelFetch(voxel_sampler, posTX + adjacentOffsets[i], 0).r);
                if (voxel == 1 || voxel >= 200) adjacentCount++;
            }

            if (int(texelFetch(voxel_sampler, posTX, 0).r) >= 200) adjacentCount = 6;
        #endif

        if ((frameCounter & 1) == 0) {
            lightVolume = texture(floodfill_sampler_copy, pos);
            #ifdef ACL_CORNER_LEAK_FIX
                if (adjacentCount >= 3) {
                    vec4 lightVolumeTX = texelFetch(floodfill_sampler_copy, posTX, 0);
                    if (dot(lightVolumeTX, lightVolumeTX) > 0.01)
                    lightVolume.rgb = min(lightVolume.rgb, lightVolumeTX.rgb * minMult);
                }
            #endif
        } else {
            lightVolume = texture(floodfill_sampler, pos);
            #ifdef ACL_CORNER_LEAK_FIX
                if (adjacentCount >= 3) {
                    vec4 lightVolumeTX = texelFetch(floodfill_sampler, posTX, 0);
                    if (dot(lightVolumeTX, lightVolumeTX) > 0.01)
                    lightVolume.rgb = min(lightVolume.rgb, lightVolumeTX.rgb * minMult);
                }
            #endif
        }

        return lightVolume;
    }

    int GetVoxelIDs(int mat) {
        #define ALWAYS_DO_IPBR_LIGHTS

        #if defined IPBR || defined ALWAYS_DO_IPBR_LIGHTS
            #define DO_IPBR_LIGHTS
        #endif

        if (mat >= 31000 && mat < 32000) {
            return 200 + (mat - 31000) / 2;
        }

        #ifndef COLORED_CANDLE_LIGHT
            if (mat >= 10900 && mat <= 10922) {
                return 24;
            }
        #endif

        switch (mat) {
            case 10056: return 14;
            case 10068: return 13;
            case 10072: return 5;
            case 10076: return 27;
            case 10216:
                #ifdef DO_IPBR_LIGHTS
                    return 62;
                #endif
                break;
            case 10224:
                #ifdef DO_IPBR_LIGHTS
                    return 63;
                #endif
                break;
            case 10228: return 255;
            case 10252:
                #if defined GLOWING_ORE_ANCIENTDEBRIS && defined DO_IPBR_LIGHTS
                    return 52;
                #endif
                break;
            case 10272:
            case 10276:
                #if defined GLOWING_ORE_IRON && defined DO_IPBR_LIGHTS
                    return 43;
                #endif
                break;
            case 10284:
            case 10288:
                #if defined GLOWING_ORE_COPPER && defined DO_IPBR_LIGHTS
                    return 45;
                #endif
                break;
            case 10300:
            case 10304:
                #if defined GLOWING_ORE_GOLD && defined DO_IPBR_LIGHTS
                    return 44;
                #endif
                break;
            case 10308:
                #if defined GLOWING_ORE_NETHERGOLD && defined DO_IPBR_LIGHTS
                    return 50;
                #endif
                break;
            case 10320:
            case 10324:
                #if defined GLOWING_ORE_DIAMOND && defined DO_IPBR_LIGHTS
                    return 48;
                #endif
                break;
            case 10332: return 36;
            case 10340:
            case 10344:
                #if defined GLOWING_ORE_EMERALD && defined DO_IPBR_LIGHTS
                    return 47;
                #endif
                break;
            case 10352:
                #if defined EMISSIVE_LAPIS_BLOCK && defined DO_IPBR_LIGHTS
                    return 42;
                #endif
                break;
            case 10356:
            case 10360:
                #if defined GLOWING_ORE_LAPIS && defined DO_IPBR_LIGHTS
                    return 46;
                #endif
                break;
            case 10368:
                #if defined GLOWING_ORE_NETHERQUARTZ && defined DO_IPBR_LIGHTS
                    return 49;
                #endif
                break;
            case 10396: return 11;
            case 10404: return 6;
            case 10412: return 10;
            case 10448: return 18;
            case 10452: return 37;
            case 10456:
                #ifdef DO_IPBR_LIGHTS
                    return 60;
                #endif
                break;
            case 10476: return 26;
            case 10484:
                #if defined GLOWING_ORE_GILDEDBLACKSTONE && defined DO_IPBR_LIGHTS
                    return 51;
                #endif
                break;
            case 10496: return 2;
            case 10500: return 3;
            case 10508:
            case 10512:
                #ifdef DO_IPBR_LIGHTS
                    return 39;
                #endif
                break;
            case 10516: return 21;
            case 10528: return 28;
            case 10544: return 34;
            case 10548: return 33;
            case 10556: return 58;
            case 10560: return 12;
            case 10564: return 29;
            case 10572:
                #ifdef DO_IPBR_LIGHTS
                    return 38;
                #endif
                break;
            case 10576: return 22;
            case 10580: return 23;
            case 10592: return 17;
            case 10596:
                #ifdef DO_IPBR_LIGHTS
                    return 66;
                #endif
                break;
            case 10604: return 35;
            case 10608:
                #if defined EMISSIVE_REDSTONE_BLOCK && defined DO_IPBR_LIGHTS
                    return 41;
                #endif
                break;
            case 10612:
                #if defined GLOWING_ORE_REDSTONE && defined DO_IPBR_LIGHTS
                    return 32;
                #endif
                break;
            case 10616: return 31;
            case 10620:
                #if defined GLOWING_ORE_REDSTONE && defined DO_IPBR_LIGHTS
                    return 32;
                #endif
                break;
            case 10624: return 31;
            case 10632: return 20;
            case 10640: return 16;
            case 10644:
                #ifdef DO_IPBR_LIGHTS
                    return 67;
                #endif
                break;
            case 10646:
                #ifdef DO_IPBR_LIGHTS
                    return 66;
                #endif
                break;
            case 10648: return 19;
            case 10652: return 15;
            case 10656: return 30;
            case 10680: return 7;
            case 10684: return 8;
            case 10688: return 9;
            case 10696: case 10700: case 10704: return 57;
            case 10708:
                #ifdef DO_IPBR_LIGHTS
                    return 53;
                #endif
                break;
            case 10736:
                #ifdef DO_IPBR_LIGHTS
                    return 64;
                #endif
                break;
            case 10776:
            case 10780:
                #ifdef DO_IPBR_LIGHTS
                    return 61;
                #endif
                break;
            case 10784: case 10788: return 36;
            case 10836:
                #ifdef DO_IPBR_LIGHTS
                    return 40;
                #endif
                break;
            case 10852: return 55;
            case 10856: return 56;
            case 10868: return 54;
            case 10872: return 68;
            case 10876: return 69;
            case 10884:
                #ifdef DO_IPBR_LIGHTS
                    return 65;
                #endif
                break;
            #ifdef COLORED_CANDLE_LIGHT
                case 10900: return 24;
                case 10902: return 70;
                case 10904: return 71;
                case 10906: return 72;
                case 10908: return 73;
                case 10910: return 74;
                case 10912: return 75;
                case 10914: return 76;
                case 10916: return 77;
                case 10918: return 78;
                case 10920: return 79;
                case 10922: return 80;
            #endif
            case 10948: return 82;
            case 10972: return 83;
            case 10976: case 10980: return 81;
            case 30008: return 254;
            case 30012: return 213;
            case 30016: return 201;
            case 30020: return 25;
            case 32004: return 216;
            case 32008: return 217;
            case 32012: return 218;
            case 32016: return 4;
            default:
                return 1;
        }
    }
    
    #if defined SHADOW && defined VERTEX_SHADER
        void UpdateVoxelMap(int mat) {
            if (mat == 32000 
            || mat < 30000 && mat % 4 == 1 
            || mat < 10000 
            ) return;

            vec3 modelPos = gl_Vertex.xyz + at_midBlock / 64.0;
            vec3 viewPos = transform(gl_ModelViewMatrix, modelPos);
            vec3 scenePos = transform(shadowModelViewInverse, viewPos);
            vec3 voxelPos = SceneToVoxel(scenePos);

            bool isEligible = any(equal(ivec4(renderStage), ivec4(
                MC_RENDER_STAGE_TERRAIN_SOLID,
                MC_RENDER_STAGE_TERRAIN_TRANSLUCENT,
                MC_RENDER_STAGE_TERRAIN_CUTOUT,
                MC_RENDER_STAGE_TERRAIN_CUTOUT_MIPPED)));

            if (isEligible && CheckInsideVoxelVolume(voxelPos)) {
                int voxelData = GetVoxelIDs(mat);
                
                imageStore(voxel_img, ivec3(voxelPos), uvec4(voxelData, 0u, 0u, 0u));
            }
        }
    #endif

#endif //INCLUDE_VOXELIZATION