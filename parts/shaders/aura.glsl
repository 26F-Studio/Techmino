#define PI 3.1415926535897932384626
extern float w,h;
extern float t;
vec4 effect(vec4 color,Image tex,vec2 tex_coords,vec2 scr_coords){
    float x=scr_coords.x/w;
    float y=scr_coords.y/h;
    float dx,dy;
    vec3 V=vec3(0.);

    dx=0.5+cos(t*3.*0.26)*0.4-x;
    dy=0.5-sin(t*3.*0.62)*0.4-y;
    dx=sqrt(dx*dx+dy*dy);
    V.r=V.r+smoothstep(1.26,0.,dx);

    dx=(0.5+cos(t*3.*0.32)*0.4)-x;
    dy=(0.5-sin(t*3.*0.80)*0.4)-y;
    dx=sqrt(dx*dx+dy*dy);
    V.g=V.g+smoothstep(1.26,0.,dx);

    dx=(0.5-cos(t*3.*0.49)*0.4)-x;
    dy=(0.5+sin(t*3.*0.18)*0.4)-y;
    dx=sqrt(dx*dx+dy*dy);
    V.b=V.b+smoothstep(1.26,0.,dx);

    dx=(0.5+cos(t*0.53)*0.4)-x;
    dy=(0.5-sin(t*0.46)*0.4)-y;
    dx=sqrt(dx*dx+dy*dy);
    V.rg+=vec2(smoothstep(0.626,0.,dx));

    dx=(0.5+cos(t*0.98)*0.4)-x;
    dy=(0.5+sin(t*0.57)*0.4)-y;
    dx=sqrt(dx*dx+dy*dy);
    V.rb+=vec2(smoothstep(0.626,0.,dx));

    dx=(0.5-cos(t*0.86)*0.4)-x;
    dy=(0.5-sin(t*0.32)*0.4)-y;
    dx=sqrt(dx*dx+dy*dy);
    V.gb+=vec2(smoothstep(0.626,0.,dx));

    dx=1.626*max(max(V.r,V.g),V.b);
    return vec4(V/dx,0.4);
}
