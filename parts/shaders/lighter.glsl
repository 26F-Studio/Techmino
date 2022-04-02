vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){
    vec4 texcolor=texture2D(tex,texCoord);
    return vec4(
        pow(texcolor.r+.26,.7023),
        pow(texcolor.g+.26,.7023),
        pow(texcolor.b+.26,.7023),
        texcolor.a*color.a
    );
}
