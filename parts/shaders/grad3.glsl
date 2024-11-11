uniform highp float phase;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){
    float y=scrCoord.y/love_ScreenSize.y;
    return vec4(
        .3+.1*sin(phase),
        .8-y*.6,
        .15+y*.7,
        .4
    );
}
