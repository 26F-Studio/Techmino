uniform highp float phase;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){
    float x=scrCoord.x/love_ScreenSize.x;
    float y=scrCoord.y/love_ScreenSize.y;
    return vec4(
        .8-y*.8-.1*sin(phase/6.26),
        .4+.1*sin(phase/4.)*(y+2.)/(y+5.),
        abs(.7-x*1.4+y*.5*sin(phase/16.)),
        .4
    );
}
