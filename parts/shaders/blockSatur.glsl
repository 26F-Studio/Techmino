uniform float k,b;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){
    vec4 texcolor=texture2D(tex,texCoord);
    return vec4(
        (texcolor.r*k+b)*color.r,
        (texcolor.g*k+b)*color.g,
        (texcolor.b*k+b)*color.b,
        texcolor.a*color.a
    );
}
