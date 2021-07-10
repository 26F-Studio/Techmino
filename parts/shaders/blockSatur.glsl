extern float k,b;
vec4 effect(vec4 color,Image tex,vec2 tex_coords,vec2 scr_coords){
	vec4 texcolor=Texel(tex,tex_coords);
	return vec4(
		(b+texcolor.r*k)*color.r,
		(b+texcolor.g*k)*color.g,
		(b+texcolor.b*k)*color.b,
		texcolor.a*color.a
	);
}