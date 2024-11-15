shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

uniform float texLod;

void vertex() {
	// Called for every vertex the material is visible on.
}

vec4 cubic(float v)
{
    vec4 n = vec4(1.0, 2.0, 3.0, 4.0) - v;
    vec4 s = n * n * n;
    float x = s.x;
    float y = s.y - 4.0 * s.x;
    float z = s.z - 4.0 * s.y + 6.0 * s.x;
    float w = 6.0 - x - y - z;
    return vec4(x, y, z, w) * (1.0/6.0);
}

vec4 textureBc(sampler2D sampler, vec2 texCoords, float lod)
{
   vec2 texSize = vec2(textureSize(sampler, int(lod)));
   vec2 invTexSize = 1.0 / texSize;

   texCoords = texCoords * texSize - 0.5;


    vec2 fxy = fract(texCoords);
    texCoords -= fxy;

    vec4 xcubic = cubic(fxy.x);
    vec4 ycubic = cubic(fxy.y);

    vec4 c = texCoords.xxyy + vec2(-0.5, 1.5).xyxy;

    vec4 s = vec4(xcubic.xz + xcubic.yw, ycubic.xz + ycubic.yw);
    vec4 offset = c + vec4 (xcubic.yw, ycubic.yw) / s;

    offset *= invTexSize.xxyy;

    vec4 sample0 = textureLod(sampler, offset.xz, lod);
    vec4 sample1 = textureLod(sampler, offset.yz, lod);
    vec4 sample2 = textureLod(sampler, offset.xw, lod);
    vec4 sample3 = textureLod(sampler, offset.yw, lod);

    float sx = s.x / (s.x + s.y);
    float sy = s.z / (s.z + s.w);

    return mix(mix(sample3, sample2, sx), mix(sample1, sample0, sx), sy);
}

vec3 tmo(vec3 c)
{
    c *= mat3(vec3(1.000, 0.150, 0.050),
              vec3(0.100, 1.000, 0.125),
              vec3(0.035, 0.100, 1.000));
    c = c*c / (c*c + 1.0);
    return c;
}

void fragment() {
	COLOR = texture(screen_texture, SCREEN_UV);
	COLOR += textureBc(screen_texture, SCREEN_UV, 2.0) * 0.0;
	COLOR += textureBc(screen_texture, SCREEN_UV, 4.0) * 2.0;
	COLOR += textureBc(screen_texture, SCREEN_UV, 5.0) * 1.56;
	COLOR += textureBc(screen_texture, SCREEN_UV, 6.0) * 1.0;
	COLOR.rgb = tmo(COLOR.rgb);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
