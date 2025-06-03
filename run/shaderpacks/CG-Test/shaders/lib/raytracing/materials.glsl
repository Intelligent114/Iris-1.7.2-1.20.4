#ifndef MATERIALS_GLSL
#define MATERIALS_GLSL

#include "/lib/buffers.glsl"

// 材质定义
#define MAT_DEFAULT 0
#define MAT_GROUND 1
#define MAT_WATER 2
#define MAT_GLASS 3
#define MAT_EMISSIVE 4
#define MAT_METAL 5
#define MAT_WOOD 6
#define MAT_FOLIAGE 7

// 材质颜色查找
vec3 getMaterialColor(int materialId) {
    switch(materialId) {
        case MAT_GROUND:
            return vec3(0.3, 0.3, 0.3);
        case MAT_WATER:
            return vec3(0.0, 0.25, 0.5);
        case MAT_GLASS:
            return vec3(0.9, 0.9, 0.9);
        case MAT_EMISSIVE:
            return vec3(0.9, 0.7, 0.3);
        case MAT_METAL:
            return vec3(0.7, 0.7, 0.7);
        case MAT_WOOD:
            return vec3(0.5, 0.3, 0.1);
        case MAT_FOLIAGE:
            return vec3(0.1, 0.5, 0.1);
        case MAT_DEFAULT:
        default:
            return vec3(0.8, 0.8, 0.8);
    }
}

// 材质发光强度
vec3 getMaterialEmission(int materialId) {
    if (materialId == MAT_EMISSIVE) {
        return vec3(2.0, 1.5, 0.7);
    }
    return vec3(0.0);
}

// 材质粗糙度
float getMaterialRoughness(int materialId) {
    switch(materialId) {
        case MAT_WATER:
            return 0.05;
        case MAT_GLASS:
            return 0.02;
        case MAT_METAL:
            return 0.1;
        case MAT_WOOD:
            return 0.5;
        case MAT_GROUND:
            return 0.7;
        case MAT_FOLIAGE:
            return 0.8;
        case MAT_DEFAULT:
        default:
            return 0.5;
    }
}

// 材质金属性
float getMaterialMetallic(int materialId) {
    if (materialId == MAT_METAL) {
        return 0.9;
    }
    return 0.0;
}

// 获取天空颜色
vec3 getSkyColor(vec3 direction) {
    float sunFactor = max(dot(direction, normalize(vec3(0.2, 1.0, 0.1))), 0.0);
    vec3 skyColor = mix(vec3(0.2, 0.4, 0.8), vec3(0.8, 0.9, 1.0), sunFactor * sunFactor);
    return skyColor * (1.0 + pow(sunFactor, 8.0) * 5.0);
}

#endif // MATERIALS_GLSL