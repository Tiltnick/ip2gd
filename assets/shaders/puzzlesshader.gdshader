shader_type canvas_item;

// Wird von außen (AnimationPlayer / Script) animiert
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// Farbe des Nebels
uniform vec4 fog_color : source_color = vec4(0.8, 0.9, 1.0, 1.0);

// Wie „weich“ der Rand ist
uniform float softness : hint_range(0.0, 1.0) = 0.4;

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5, 0.5);

    // Abstand vom Mittelpunkt (0 = Mitte, 1 = Ecke)
    float dist = distance(uv, center);

    // Radius wächst mit progress
    // progress = 0 -> kleiner Kern
    // progress = 1 -> Nebel füllt alles & wird wieder transparent
    float radius = mix(0.0, 1.2, progress);

    // weicher Rand
    float edge = smoothstep(radius - softness, radius, dist);

    // Nebel innen, transparent außen
    vec4 col = fog_color;
    col.a *= (1.0 - edge);

    // am Ende (progress nahe 1) alles ausfaden
    col.a *= (1.0 - progress);

    COLOR = col;
}
