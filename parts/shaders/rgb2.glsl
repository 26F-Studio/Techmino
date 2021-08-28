extern float t,w,h;
vec4 effect(vec4 color,Image tex,vec2 tex_coords,vec2 scr_coords){
    float x=scr_coords.x/w;
    float y=scr_coords.y/h;
    return vec4(
        .8-y*.8-.1*sin(t/6.26),
        .4+.1*sin(t/4.)*(y+2.)/(y+5.),
        abs(.7-x*1.4+y*.5*sin(t/16.)),
        .4
    );
}
