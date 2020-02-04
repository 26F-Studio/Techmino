extern float X;extern float Y;extern float W;extern float H;
vec4 effect(vec4 C,Image Tx,vec2 Tcd,vec2 Pcd){
	C[3]=min((Pcd.x-X)/W*.3+(Pcd.y-Y)/H*.1,.3)+.5;
	return C;
}