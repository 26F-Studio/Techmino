#define PI 3.14
extern float yresolution;
vec4 effect(vec4 color,Image texture,vec2 texture_coords,vec2 screen_coords){
	//Iterate through the occluder map's y-axis.
	for(float y=0.;y<yresolution;y++){
		//直角转极坐标
		vec2 norm=vec2(texture_coords.s,y/yresolution)*2.-1.;
		float theta=PI*1.5+norm.x*PI; 
		float r=(1.+norm.y)*.5;
		//y/yresolution为到光源的距离(0~1)
		//遮光物采样
		vec4 data=Texel(texture,(vec2(-r*sin(theta),-r*cos(theta))*.5+.5));//vec2()..是遮光物采样的coord
		if(data.a>.1)return vec4(vec3(y/yresolution),1.);//碰撞检测，像素透明度>.1即透光
	}
	return vec4(vec3(1),1.);//返回最远距离1
}