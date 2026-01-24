shader_type canvas_item;

uniform vec2  light_uv = vec2(0.5, 0.5);
uniform float radius    = 140.0;
uniform float softness  = 80.0;    
uniform float darkness_alpha = 1.0;

void fragment() {
    vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;

    // in Pixel umrechnen
    vec2 frag_px  = SCREEN_UV * viewport_size;
    vec2 light_px = light_uv   * viewport_size;

    float d = distance(frag_px, light_px);
    float t = smoothstep(radius, radius + softness, d);

    COLOR = vec4(0.0, 0.0, 0.0, darkness_alpha * t);
}
