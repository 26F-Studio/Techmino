extern float a;
vec4 effect(vec4 color,Image text,vec2 pos,vec2 scr_pos){
	return vec4(1.,1.,1.,sign(Texel(text,pos).a)*a);
}