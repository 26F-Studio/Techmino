uniform highp float phase;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){
    float x=scrCoord.x/love_ScreenSize.x;
    return vec4(
        .8-x*.6,
        .3+.2*sin(phase),
        .15+x*.7,
        .4
    );
}
