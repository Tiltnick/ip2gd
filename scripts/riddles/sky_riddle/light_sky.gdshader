shader_type canvas_item;

uniform vec2  light_uv = vec2(0.5, 0.5);
uniform float radius    = 140.0;
uniform float softness  = 80.0;
uniform float darkness_alpha = 1.0;

void fragment() {
    // SCREEN_UV ist bereits 0..1 über den ganzen Screen/Viewport
    vec2 frag_uv = SCREEN_UV;

    // Radius/Softness sind noch in Pixeln -> UV umrechnen
    vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;
    float radius_uv   = radius   / viewport_size.x;   // x-basiert (ok für kreisförmig bei normalen Aspects)
    float softness_uv = softness / viewport_size.x;

    float d = distance(frag_uv, light_uv);
    float t = smoothstep(radius_uv, radius_uv + softness_uv, d);

    COLOR = vec4(0.0, 0.0, 0.0, darkness_alpha * t);
}
