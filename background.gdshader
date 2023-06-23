shader_type canvas_item;

uniform vec3 color_0 : source_color;
uniform vec3 color_1 : source_color;
uniform vec2 direction;

void fragment() {
	COLOR.rgb = mix(color_0, color_1, dot(UV, direction));
}
