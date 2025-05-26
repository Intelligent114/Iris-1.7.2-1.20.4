#version 450 core
layout(local_size_x = 8, local_size_y = 8) in;

layout(binding = 0, rgba16f) uniform image2D accumImg;

uniform int frameCounter;
uniform vec2 viewSize;

struct Sphere { vec3 c; float r; vec3 albedo; float emissive; };
const int SPHERE_COUNT = 4;
layout(std140, binding = 5) uniform Scene {
    Sphere spheres[SPHERE_COUNT];
} scene;

void main() {
    ivec2 pix = ivec2(gl_GlobalInvocationID.xy);
    if (pix.x >= int(viewSize.x) || pix.y >= int(viewSize.y)) return;

    vec3 L = traceCameraRay(pix, frameCounter);

    vec4 prev = imageLoad(accumImg, pix);
    float a = 1.0 / float(frameCounter);
    vec3 color = mix(prev.rgb, L, a);
    imageStore(accumImg, pix, vec4(color, 1.0));
}
