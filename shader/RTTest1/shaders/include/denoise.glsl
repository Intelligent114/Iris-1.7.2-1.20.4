#include "/include/octa_normal.glsl"

vec3 bilateral9(ivec2 pix, image2D img, image2D gNorm,
                float sigma_s, float sigma_r) {
    vec3 n0 = decodeOcta(imageLoad(gNorm, pix).xy);
    vec3 sum = vec3(0); float wSum = 0;
    for (int y=-1; y<=1; ++y)
    for (int x=-1; x<=1; ++x) {
        ivec2 q = pix + ivec2(x,y);
        vec3 n1 = decodeOcta(imageLoad(gNorm, q).xy);
        float w = exp(-(x*x+y*y)/sigma_s) *
        exp(-pow(max(0.0,1.0-dot(n0,n1)),2.0)/sigma_r);
        vec3 c1 = imageLoad(img, q).rgb;
        sum += w * c1; wSum += w;
    }
    return sum / wSum;
}
