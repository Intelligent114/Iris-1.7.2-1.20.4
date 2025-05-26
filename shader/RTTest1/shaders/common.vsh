// 3-point full-screen triangle, no VAO needed
void main() {
    const vec2 verts[3] = vec2[3](vec2(-1,-1), vec2(3,-1), vec2(-1,3));
    gl_Position = vec4(verts[gl_VertexID], 0, 1);
}
