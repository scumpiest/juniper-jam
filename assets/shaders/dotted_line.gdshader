shader_type canvas_item;

uniform float speed = 2.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV) * COLOR;
	float dot = step(0.4, fract(UV.x * speed));
	COLOR = vec4(col.rgb, col.a * dot);
}
