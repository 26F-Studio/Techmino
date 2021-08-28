extern float t,w;
vec4 effect(vec4 color,Image tex,vec2 tex_coords,vec2 scr_coords){
    float x=scr_coords.x/w;
    return vec4(
        .8-x*.6,
        .3+.2*sin(t),
        .15+x*.7,
        .4
    );
}
