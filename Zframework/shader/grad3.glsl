extern float t,w,h;
vec4 effect(vec4 color,Image text,vec2 pos,vec2 scr_pos){
	float x=scr_pos.x/w;
	float y=scr_pos.y/h;
	return vec4(
		.8-y*.6-.2*sin(t/6.26),
		.3+.1*sin(t),
		.2+x*.6,
		1
	);
}