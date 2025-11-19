shader_type canvas_item;

uniform float outline_size : hint_range(1.0, 10.0) = 2.0;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 center = texture(TEXTURE, UV);
    if (center.a > 0.0) {
        // Wir zeichnen innen NICHTS → Sprite oben deckt ab
        discard;
    }

    // offsets für Sampling
    float px = outline_size / float(textureSize(TEXTURE, 0).x);
    float py = outline_size / float(textureSize(TEXTURE, 0).y);

    // Wenn irgendeiner der Nachbarn alpha > 0 hat → Outline Pixel
    if (texture(TEXTURE, UV + vec2(px, 0.0)).a > 0.0 ||
        texture(TEXTURE, UV + vec2(-px, 0.0)).a > 0.0 ||
        texture(TEXTURE, UV + vec2(0.0, py)).a > 0.0 ||
        texture(TEXTURE, UV + vec2(0.0, -py)).a > 0.0 ) {
        
        COLOR = outline_color;
    } else {
        discard;
    }
}
