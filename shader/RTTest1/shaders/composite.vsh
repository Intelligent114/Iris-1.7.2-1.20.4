#version 150 core
// 3-point full-screen triangle, no VAO needed
out vec2 v_texCoord; // Output for fragment shader

void main() {
    const vec2 verts[3] = vec2[3](vec2(-1,-1), vec2(3,-1), vec2(-1,3));
    gl_Position = vec4(verts[gl_VertexID], 0, 1);
    v_texCoord = verts[gl_VertexID] * 0.5 + 0.5; // Generate UVs for full-screen triangle
}
