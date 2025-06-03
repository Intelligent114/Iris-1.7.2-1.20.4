void ColorCodeProgram(inout vec4 color, int mat) {
    
    if (heldItemId == 40000 && heldItemId2 == 40000) return;

    #if defined GBUFFERS_TERRAIN 
        color.rgb = vec3(0.0, 1.0, 0.0);
    #elif defined GBUFFERS_WATER 
        color.rgb = vec3(0.0, 0.0, 1.0);
    #elif defined GBUFFERS_SKYBASIC 
        color.rgb = vec3(0.0, 1.0, 2.0);
    #elif defined GBUFFERS_WEATHER 
        color.rgb = vec3(3.0, 0.0, 3.0);
    #elif defined GBUFFERS_BLOCK 
        color.rgb = vec3(1.5, 1.5, 0.0);
    #elif defined GBUFFERS_HAND 
        color.rgb = vec3(1.5, 0.7, 0.0);
    #elif defined GBUFFERS_ENTITIES 
        color.rgb = vec3(1.5, 0.0, 0.0);
    #elif defined GBUFFERS_BASIC 
        color.rgb = vec3(3.0, 3.0, 3.0);
    #elif defined GBUFFERS_SPIDEREYES 
        color.rgb = mix(vec3(2.0, 0.0, 0.0), vec3(0.0, 0.0, 2.0), mod(gl_FragCoord.x, 20.0) / 20.0);
    #elif defined GBUFFERS_TEXTURED   
        color.rgb = mix(vec3(2.0, 0.0, 0.0), vec3(0.0, 0.0, 2.0), mod(gl_FragCoord.y, 20.0) / 20.0);
    #elif defined GBUFFERS_CLOUDS     
        color.rgb = mix(vec3(2.0, 0.0, 0.0), vec3(0.0, 2.0, 0.0), mod(gl_FragCoord.x, 20.0) / 20.0);
    #elif defined GBUFFERS_BEACONBEAM 
        color.rgb = mix(vec3(2.0, 0.0, 0.0), vec3(0.0, 2.0, 0.0), mod(gl_FragCoord.y, 20.0) / 20.0);
    #elif defined GBUFFERS_ARMOR_GLINT  
        color.rgb = mix(vec3(0.0, 0.0, 0.0), vec3(1.5, 1.5, 1.5), mod(gl_FragCoord.x, 20.0) / 20.0);
    #elif defined GBUFFERS_DAMAGEDBLOCK 
        color.rgb = mix(vec3(0.0, 0.0, 0.0), vec3(1.5, 1.5, 1.5), mod(gl_FragCoord.y, 20.0) / 20.0);
    #elif defined GBUFFERS_SKYTEXTURED 
        color.rgb = mix(vec3(0.0, 2.0, 0.0), vec3(0.0, 0.0, 2.0), mod(gl_FragCoord.y, 20.0) / 20.0);
    #endif

    color.rgb *= 0.75;

    
    if (heldItemId == 40000 || heldItemId2 == 40000) {
        if (mat == 0) 
        color.rgb = mix(vec3(0.0, 0.0, 0.0), vec3(3.0, 0.0, 3.0), mod(gl_FragCoord.y, 20.0) / 20.0);
        else
        color.rgb = vec3(0.25);
    }
}