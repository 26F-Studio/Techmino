extern float t,w,h;
vec4 effect(vec4 color,Image text,vec2 pos,vec2 scr_pos){
	float x=scr_pos.x/w;
	float y=scr_pos.y/h;
	return vec4(
		.8-y*.8-.1*sin(t/6.26),
		.4+.1*sin(t/4.)*(y+2.)/(y+5.),
		abs(.7-x*1.4+y*.5*sin(t/16.)),
		1.
	);
}