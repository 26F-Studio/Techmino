extern float t,w,h;
vec4 effect(vec4 color,Image tex,vec2 tex_coords,vec2 scr_coords){
    float x=scr_coords.x/w;
    float y=scr_coords.y/h;
    return vec4(
        .8-y*.7+.2*sin(t/6.26),
        .2+y*.5+.15*sin(t/4.),
        .2+x*.6-.1*sin(t/2.83),
        .4
    );
}
