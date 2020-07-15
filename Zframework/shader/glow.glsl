extern float X,Y,W,H;
vec4 effect(vec4 C,Image Tx,vec2 pos,vec2 scr_pos){
	C[3]=min((scr_pos.x-X)/W*0.3+(scr_pos.y-Y)/H*0.1,0.3)+0.5;
	return C;
}