extern float t,w;
vec4 effect(vec4 color,Image text,vec2 pos,vec2 scr_pos){
	float x=scr_pos.x/w;
	return vec4(
		.8-x*.6,
		.3+.2*sin(t),
		.15+x*.7,
		1.
	);
}