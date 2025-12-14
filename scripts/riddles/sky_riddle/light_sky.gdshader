shader_type canvas_item;

uniform vec2  light_pos = vec2(200.0, 200.0);
uniform float radius    = 140.0;
uniform float softness  = 80.0;
uniform float darkness_alpha = 1.0;

void fragment() {
    // Pixelposition dieses Fragments im Screen
    vec2 frag_pos = SCREEN_UV * vec2(SCREEN_PIXEL_SIZE.x > 0.0 ? 1.0 / SCREEN_PIXEL_SIZE.x : 0.0,
                                     SCREEN_PIXEL_SIZE.y > 0.0 ? 1.0 / SCREEN_PIXEL_SIZE.y : 0.0);

    float d = distance(frag_pos, light_pos);
    float t = smoothstep(radius, radius + softness, d);

    // Außen schwarz, innen transparent
    COLOR = vec4(0.0, 0.0, 0.0, darkness_alpha * t);
}
