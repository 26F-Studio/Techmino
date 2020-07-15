#define PI 3.14159265
extern float w,h;
extern float t;
vec4 effect(vec4 color,Image text,vec2 pos,vec2 scr_pos){
	float x=scr_pos.x-w/2.;
	float y=scr_pos.y-h/2.;
	float a=(step(0.,x)*2.-1.)*PI+atan(y,x)+PI*0.5+t*0.626;

	return vec4(
		color.r*(sin(a+PI*0./3.)*0.3+0.5),
		color.g*(sin(a+PI*2./3.)*0.3+0.5),
		color.b*(sin(a+PI*4./3.)*0.3+0.5),
		1.
	);
}