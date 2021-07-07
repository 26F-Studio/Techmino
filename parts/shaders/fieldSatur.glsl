extern float k,b;
vec4 effect(vec4 color,Image tex,vec2 tex_coords,vec2 scr_coords){
	vec4 texcolor=Texel(tex,tex_coords);
	return vec4(
		b+texcolor.r*k,
		b+texcolor.g*k,
		b+texcolor.b*k,
		texcolor.a*color.a
	);
}