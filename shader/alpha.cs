extern float a;
vec4 effect(vec4 color, Image text,vec2 pos,vec2 scr_pos){
	if(Texel(text,pos)[3]==0.)discard;
	return vec4(1.,1.,1.,a);
}