extern float t,h;
vec4 effect(vec4 color,Image tex,vec2 tex_coords,vec2 scr_coords){
    float y=scr_coords.y/h;
    return vec4(
        .8-y*.6,
        .2+y*.4,
        .3+.1*sin(t),
        .4
    );
}
