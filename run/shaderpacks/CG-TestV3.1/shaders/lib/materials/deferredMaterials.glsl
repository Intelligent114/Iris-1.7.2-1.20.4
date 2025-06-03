if (abs(materialMaskInt - 149.5) < 50.0) {
    materialMaskInt -= 100;
    entityOrHand = true;
}

if (materialMaskInt != 0) {
    switch (materialMaskInt) {
        case 1:
            intenseFresnel = 1.0;
            break;
        case 2:
            intenseFresnel = 1.0;
            reflectColor = mix(vec3(0.5, 0.75, 0.5), vec3(1.0, 0.45, 0.3), sqrt1(smoothnessD));
            break;
        case 3:
            intenseFresnel = 1.0;
            reflectColor = vec3(1.0, 0.8, 0.5);
            break;
        case 4:
            break;
        case 5:
            intenseFresnel = 1.0;
            reflectColor = vec3(1.0, 0.3, 0.2);
            break;
        case 6:
            break;
        case 7:
            break;
        case 8:
            break;
        case 9:
            break;
        case 10:
            break;
        case 11:
            break;
        case 12:
            break;
        case 13:
            break;
        case 14:
            break;
        case 15:
            break;
        default:
            break;
    }
}