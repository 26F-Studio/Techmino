#define PI 3.14159265
extern float t;
vec4 effect(vec4 color,Image text,vec2 pos,vec2 scr_pos){
	float x=scr_pos.x/262.+t;
	return vec4(
		color.r*(sin(x+PI*0./3.)*0.3+0.5),
		color.g*(sin(x+PI*2./3.)*0.3+0.5),
		color.b*(sin(x+PI*4./3.)*0.3+0.5),
		1.
	);
}