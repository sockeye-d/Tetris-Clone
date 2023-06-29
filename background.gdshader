shader_type canvas_item;

uniform vec3 color_0 : source_color;
uniform vec3 color_1 : source_color;
uniform vec2 direction;
uniform float threshold;
uniform float smoothness;
uniform vec4 movement_direction_0;
uniform vec4 movement_direction_1;
uniform vec3 movement_direction_2;
uniform float modulate;
uniform sampler2D noise;
uniform float dither;

vec4 hash42(vec2 p) {
	vec4 p4 = fract(vec4(p.xyxy) * vec4(.1031, .1030, .0973, .1099));
    p4 += dot(p4, p4.wzxy+33.33);
    return fract((p4.xxyz+p4.yzzw)*p4.zywx);
}

vec3 hue(float x) {
	return sin((x + vec3(0, 0.33, 0.66))*2.*PI)*0.5+0.5;
}

void fragment() {
	COLOR.rgb = mix(color_0, color_1, dot(UV, direction));
	float tex = texture(noise, fract(UV*0.1 + TIME*normalize(movement_direction_0.xy)*movement_direction_0.z)).r * movement_direction_0.w;
	tex += texture(noise, fract(UV*0.1 + TIME*normalize(movement_direction_1.xy)*movement_direction_1.z)).r * movement_direction_1.w;
	vec2 dir = normalize(vec2(dFdx(tex), dFdy(tex)));
	tex = smoothstep(threshold, threshold + smoothness, tex);
	COLOR.rgb += vec3(tex) * hue(texture(noise, fract(UV*0.05 + TIME*normalize(movement_direction_2.xy)*movement_direction_2.z)).r) * modulate;
	COLOR.rgb += (hash42(SCREEN_UV * 100.0 + fract(TIME * 1000.0)).rrr - 0.5) * dither;
}
