uniform float a;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){
    return vec4(1.,1.,1.,sign(texture2D(tex,texCoord).a)*a);
}
