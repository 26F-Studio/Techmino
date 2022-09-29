uniform highp float phase;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){
    float y=scrCoord.y/love_ScreenSize.y;
    return vec4(
        .8-y*.6,
        .2+y*.4,
        .3+.1*sin(phase),
        .4
    );
}
