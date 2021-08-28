vec4 effect(vec4 color,Image tex,vec2 tex_coords,vec2 scr_coords){
    vec4 texcolor=Texel(tex,tex_coords);
    return vec4(
        pow(texcolor.r+.26,.7023),
        pow(texcolor.g+.26,.7023),
        pow(texcolor.b+.26,.7023),
        texcolor.a*color.a
    );
}
