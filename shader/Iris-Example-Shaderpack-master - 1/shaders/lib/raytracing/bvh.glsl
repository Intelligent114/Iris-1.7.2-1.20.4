#ifndef BVH_GLSL
#define BVH_GLSL

#include "/lib/buffers.glsl"
#include "/lib/raytracing/intersect.glsl"

// BVH节点结构
struct BVHNode {
    vec3 min;        // 包围盒最小点
    vec3 max;        // 包围盒最大点
    int leftChild;   // 左子节点索引
    int rightChild;  // 右子节点索引
    int firstPrim;   // 第一个图元索引
    int primCount;   // 图元数量
};

// BVH遍历堆栈项
struct StackItem {
    int nodeIndex;
    float tMin;
};

#define MAX_STACK_SIZE 32
#define LEAF_NODE_THRESHOLD 4

// 测试光线是否与BVH节点相交
bool intersectBVHNode(Ray ray, BVHNode node, inout float tNear, inout float tFar) {
    return intersectAABB(ray, node.min, node.max, tNear, tFar);
}

// 优先队列实现
void pushStack(inout StackItem[MAX_STACK_SIZE] stack, inout int stackPtr, int nodeIndex, float tMin) {
    if (stackPtr < MAX_STACK_SIZE) {
        stack[stackPtr].nodeIndex = nodeIndex;
        stack[stackPtr].tMin = tMin;
        stackPtr++;
        
        // 简单的冒泡排序确保最近的节点位于栈顶
        for (int i = stackPtr - 1; i > 0; i--) {
            if (stack[i].tMin < stack[i-1].tMin) {
                // 交换
                StackItem temp = stack[i];
                stack[i] = stack[i-1];
                stack[i-1] = temp;
            } else {
                break;
            }
        }
    }
}

// 从栈顶弹出项
StackItem popStack(inout StackItem[MAX_STACK_SIZE] stack, inout int stackPtr) {
    stackPtr--;
    return stack[stackPtr];
}

// 简化的BVH遍历示例（使用球体示例）
bool simplifiedBVHRaycast(Ray ray, inout HitInfo hitInfo) {
    hitInfo.hit = false;
    hitInfo.t = ray.tMax;
    
    // 地面平面检测
    if (ray.direction.y < 0.0) {
        float t = -ray.origin.y / ray.direction.y;
        if (t > ray.tMin && t < hitInfo.t) {
            hitInfo.hit = true;
            hitInfo.t = t;
            hitInfo.position = ray.origin + ray.direction * t;
            hitInfo.normal = vec3(0.0, 1.0, 0.0);
            hitInfo.materialId = 1; // 地面材质ID
        }
    }
    
    // 添加一个简单的球体作为示例
    vec3 sphereCenter = vec3(0.0, 2.0, 0.0);
    float sphereRadius = 1.0;
    vec3 oc = ray.origin - sphereCenter;
    float a = dot(ray.direction, ray.direction);
    float b = 2.0 * dot(oc, ray.direction);
    float c = dot(oc, oc) - sphereRadius * sphereRadius;
    float discriminant = b*b - 4.0*a*c;
    
    if (discriminant > 0.0) {
        float t = (-b - sqrt(discriminant)) / (2.0*a);
        if (t > ray.tMin && t < hitInfo.t) {
            hitInfo.hit = true;
            hitInfo.t = t;
            hitInfo.position = ray.origin + ray.direction * t;
            hitInfo.normal = normalize(hitInfo.position - sphereCenter);
            hitInfo.materialId = 4; // 发光材质ID作为示例
        }
    }
    
    return hitInfo.hit;
}

// 尚未完全实现的BVH遍历函数
bool traverseBVH(BVHNode[] nodes, Ray ray, inout HitInfo hitInfo) {
    // 简化版本，直接调用simplifiedBVHRaycast
    return simplifiedBVHRaycast(ray, hitInfo);
}

#endif // BVH_GLSL