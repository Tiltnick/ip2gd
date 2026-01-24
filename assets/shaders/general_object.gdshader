shader_type canvas_item;

uniform float outline_size = 2.0;
uniform vec4 outline_color = vec4(1.0,1.0,1.0,1.0);

void fragment() {
    vec4 base = texture(TEXTURE, UV);

    float px = outline_size / float(textureSize(TEXTURE,0).x);
    float py = outline_size / float(textureSize(TEXTURE,0).y);

    float alpha =
        texture(TEXTURE, UV + vec2(px,0.0)).a +
        texture(TEXTURE, UV + vec2(-px,0.0)).a +
        texture(TEXTURE, UV + vec2(0.0,py)).a +
        texture(TEXTURE, UV + vec2(0.0,-py)).a;

    // wenn kein Pixel da → nichts
    if(base.a == 0.0 && alpha > 0.0){
        COLOR = outline_color;
    } else {
        COLOR = vec4(0.0);
    }
}