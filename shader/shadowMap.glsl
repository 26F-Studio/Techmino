#define PI 3.14
extern float yresolution;
vec4 effect(vec4 color,Image texture,vec2 texture_coords,vec2 screen_coords){
	//Iterate through the occluder map's y-axis.
	for(float y=0.;y<yresolution;y++){
		//cartesian to polar
		// y/yresolution=distance to light source(0~1)
		vec2 norm=vec2(texture_coords.s,y/yresolution)*2.-1.;
		float theta=PI*1.5+norm.x*PI;
		float r=(1.+norm.y)*0.5;

		//sample from solid
		if(
			Texel(texture,(
				vec2(-r*sin(theta),-r*cos(theta))*0.5+0.5//coord of solid sampling
			))
			.a>0.1
		)return vec4(vec3(y/yresolution),1.);//collision check, alpha>0.1 means transparent
	}
	return vec4(1.,1.,1.,1.);//return max distance 1
}