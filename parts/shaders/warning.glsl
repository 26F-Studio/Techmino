uniform float level;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){
    float dx=abs(scrCoord.x/love_ScreenSize.x-0.5);
    float a=(dx*2.6-.626)*level;
    return vec4(1.,0.,0.,a);
}
