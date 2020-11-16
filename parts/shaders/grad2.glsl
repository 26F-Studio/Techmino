extern float t,h;
vec4 effect(vec4 color,Image text,vec2 pos,vec2 scr_pos){
	float y=scr_pos.y/h;
	return vec4(
		.8-y*.6,
		.2+y*.4,
		.3+.1*sin(t),
		1.
	);
}