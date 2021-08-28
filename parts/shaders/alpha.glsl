extern float a;
vec4 effect(vec4 color,Image tex,vec2 tex_coords,vec2 scr_coords){
    return vec4(1.,1.,1.,sign(Texel(tex,tex_coords).a)*a);
}
