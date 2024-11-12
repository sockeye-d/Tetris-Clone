// NOTE: Shader automatically converted from Godot Engine 4.0.3.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_add;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap;
uniform float point_size : hint_range(0,128);
uniform float brightness;

//uniform sampler2D depth : hint_depth_texture;

varying float depth;

void vertex() {
	depth = distance(NODE_POSITION_WORLD, CAMERA_POSITION_WORLD);
	POINT_SIZE = point_size / depth * 40.0;
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, POINT_COORD);
	ALBEDO = albedo.rgb * albedo_tex.rgb * COLOR.rgb;
	ALPHA *= albedo.a * albedo_tex.a * COLOR.a;
	ALBEDO.rgb *= brightness;
	ALPHA *= smoothstep(0.0, 20.0, depth);
}
