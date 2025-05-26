#version 450 core
layout(local_size_x=8, local_size_y=8) in;

layout(binding=1, rgba16f) uniform readonly  image2D pingImg;  // Pass-0 输出
layout(binding=3, rg16f)   uniform readonly  image2D gNorm;    // colortex3
layout(binding=0, rgba16f) uniform writeonly image2D col0;     // colortex0

#include "/include/denoise.glsl"

uniform vec2 viewSize;

void main(){
    ivec2 p = ivec2(gl_GlobalInvocationID.xy);
    if(any(greaterThanEqual(p, ivec2(viewSize)))) return;
    vec3 c = bilateral9(p, pingImg, gNorm, 1.0, 2.0);
    imageStore(col0, p, vec4(c,1));
}
