uniform highp float phase;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){
    float x=scrCoord.x/love_ScreenSize.x;
    float y=scrCoord.y/love_ScreenSize.y;
    return vec4(
        .8-y*.7+.2*sin(phase/6.26),
        .2+y*.5+.15*sin(phase/4.),
        .2+x*.6-.1*sin(phase/2.83),
        .4
    );
}
