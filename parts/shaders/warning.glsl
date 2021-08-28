extern float w,level;
vec4 effect(vec4 color,Image tex,vec2 tex_coords,vec2 scr_coords){
    float dx=abs(scr_coords.x/w-0.5);
    float a=(dx*2.6-.626)*level;
    return vec4(1.,0.,0.,a);
}
