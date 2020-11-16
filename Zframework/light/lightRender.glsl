#define PI 3.14159
extern float xresolution;
//sample from 1D vis-depth map
float samp(vec2 coord,float r,Image u_texture){
	return step(r,Texel(u_texture,coord).r);
}
vec4 effect(vec4 color,Image texture,vec2 texture_coords,vec2 screen_coords){
	//cartesian to polar, y of 1D sample is always 0
	vec2 norm=texture_coords.st*2.-1.;
	vec2 tc=vec2((atan(norm.y,norm.x)+PI)/(2.*PI),0.);
	float r=length(norm);

	//enlarge blur parameter by distance, light scattering simulation
	float blur=(1./xresolution)*smoothstep(0.3,1.,r);

	//Simple Gaussian blur
	float sum=//brightness(0~1)
		samp(vec2(tc.x-3.*blur,tc.y),r,texture)*0.1
		+samp(vec2(tc.x-2.*blur,tc.y),r,texture)*0.13
		+samp(vec2(tc.x-1.*blur,tc.y),r,texture)*0.17

		+samp(tc,r,texture)*0.2//The center tex coord,which gives us hard shadows.
		+samp(vec2(tc.x+1.*blur,tc.y),r,texture)*0.17
		+samp(vec2(tc.x+2.*blur,tc.y),r,texture)*0.13
		+samp(vec2(tc.x+3.*blur,tc.y),r,texture)*0.1;

	//Multiply the distance to get a soft fading
	return vec4(vec3(1.),sum*smoothstep(1.,0.,r));
}