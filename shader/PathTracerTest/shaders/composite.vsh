#version 150 core
//
// 全屏三角形顶点着色器 — 不需要任何输入 VAO/VBO
// 只利用 gl_VertexID 生成 3 个顶点 (-1/-1, 3/-1, -1/3)
// 这样可避免在窗口分辨率与 FBO 分辨率不同步时出现缝隙
//

void main() {
    // gl_VertexID: 0,1,2
    vec2 pos = vec2(
    (gl_VertexID << 1) & 2,  // 0 → 0, 1 → 2, 2 → 0
    (gl_VertexID & 2)        // 0 → 0, 1 → 0, 2 → 2
    );
    // pos ∈ { (0,0), (2,0), (0,2) } → 映射到 NDC
    gl_Position = vec4(pos * 2.0 - 1.0, 0.0, 1.0);
}
