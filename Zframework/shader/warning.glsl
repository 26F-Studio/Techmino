extern float w,h;
extern float level;
vec4 effect(vec4 color,Image text,vec2 pos,vec2 scr_pos){
	float dx=abs(scr_pos.x/w-0.5);
	float dy=abs(scr_pos.y/h-0.5);
	float a=(max(dx,dy)*2.-.626)*level;
	return vec4(1.,0.,0.,a);
}