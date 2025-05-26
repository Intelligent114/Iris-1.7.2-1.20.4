#ifndef INTERSECT_GLSL
#define INTERSECT_GLSL

#include "/lib/buffers.glsl"

// 光线定义
struct Ray {
    vec3 origin;
    vec3 direction;
    float tMin;
    float tMax;
};

// 光线与AABB盒相交测试
bool intersectAABB(Ray ray, vec3 boxMin, vec3 boxMax, inout float tNear, inout float tFar) {
    vec3 tMin = (boxMin - ray.origin) / ray.direction;
    vec3 tMax = (boxMax - ray.origin) / ray.direction;
    vec3 t1 = min(tMin, tMax);
    vec3 t2 = max(tMin, tMax);
    tNear = max(max(t1.x, t1.y), max(t1.z, ray.tMin));
    tFar = min(min(t2.x, t2.y), min(t2.z, ray.tMax));
    return tNear <= tFar;
}

// 光线与方块相交测试
struct HitInfo {
    bool hit;
    float t;
    vec3 position;
    vec3 normal;
    int materialId;
};

HitInfo traceRay(Ray ray) {
    HitInfo hitInfo;
    hitInfo.hit = false;
    hitInfo.t = ray.tMax;
    
    // 示例：一个简单的地面平面相交测试
    if (ray.direction.y < 0.0) {
        float t = -ray.origin.y / ray.direction.y;
        if (t > ray.tMin && t < ray.tMax) {
            hitInfo.hit = true;
            hitInfo.t = t;
            hitInfo.position = ray.origin + ray.direction * t;
            hitInfo.normal = vec3(0.0, 1.0, 0.0);
            hitInfo.materialId = 1; // 地面材质ID
        }
    }
    
    return hitInfo;
}

#endif // INTERSECT_GLSL