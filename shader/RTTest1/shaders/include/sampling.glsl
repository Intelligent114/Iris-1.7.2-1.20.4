#include "/include/hashing.glsl"

vec3 cosineHemisphere(in vec3 n, inout uint seed) {
    float r1 = rand01(seed);
    float r2 = rand01(seed);
    float phi = 2.0 * 3.14159265 * r1;
    float r = sqrt(r2);
    vec3 t = normalize(abs(n.y) < 0.99 ? cross(n, vec3(0,1,0))
    : cross(n, vec3(1,0,0)));
    vec3 b = cross(t, n);
    return normalize(t * (r * cos(phi)) +
    b * (r * sin(phi)) +
    n * sqrt(1.0 - r2));
}
