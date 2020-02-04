#define PI 3.14
extern float xresolution;
//从1D距离map采样
float samp(vec2 coord,float r,Image u_texture){
	return step(r,Texel(u_texture,coord).r);
}
vec4 effect(vec4 color,Image texture,vec2 texture_coords,vec2 screen_coords){
	//直角转极坐标，用于采样1D材质的y总是0
	vec2 norm=texture_coords.st*2.-1.;
	float r=length(norm);
	vec2 tc=vec2((atan(norm.y,norm.x)+PI)/(2.*PI),0.);
	//根据离光源距离放大模糊系数，模拟影子淡出
	float blur=(1./xresolution)*smoothstep(0.,1.,r); 

	//简易高斯模糊
	float sum=
		samp(vec2(tc.x-4.*blur,tc.y),r,texture)*.5
		+samp(vec2(tc.x-3.*blur,tc.y),r,texture)*.9
		+samp(vec2(tc.x-2.*blur,tc.y),r,texture)*.12
		+samp(vec2(tc.x-1.*blur,tc.y),r,texture)*.15

		+samp(tc,r,texture)*.16//The center tex coord,which gives us hard shadows.
		+samp(vec2(tc.x+1.*blur,tc.y),r,texture)*.15
		+samp(vec2(tc.x+2.*blur,tc.y),r,texture)*.12
		+samp(vec2(tc.x+3.*blur,tc.y),r,texture)*.9
		+samp(vec2(tc.x+4.*blur,tc.y),r,texture)*.5;
	//sum值为亮度(0~1)
	//乘上距离得到逐渐变淡的光线
	return vec4(vec3(1.),sum*smoothstep(1.,.1,r));
}