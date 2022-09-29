uniform highp float phase;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){
    float x=scrCoord.x/love_ScreenSize.x;
    float y=scrCoord.y/love_ScreenSize.y;
    vec3 V=vec3(0.);
    V.r=V.r+smoothstep(1.26,0.,length(vec2(0.5+cos(phase*3.*0.26)*0.4-x,0.5-sin(phase*3.*0.62)*0.4-y)));
    V.g=V.g+smoothstep(1.26,0.,length(vec2((0.5+cos(phase*3.*0.32)*0.4)-x,(0.5-sin(phase*3.*0.80)*0.4)-y)));
    V.b=V.b+smoothstep(1.26,0.,length(vec2((0.5-cos(phase*3.*0.49)*0.4)-x,(0.5+sin(phase*3.*0.18)*0.4)-y)));
    V.rg+=vec2(smoothstep(0.626,0.,length(vec2((0.5+cos(phase*0.53)*0.4)-x,(0.5-sin(phase*0.46)*0.4)-y))));
    V.rb+=vec2(smoothstep(0.626,0.,length(vec2((0.5+cos(phase*0.98)*0.4)-x,(0.5+sin(phase*0.57)*0.4)-y))));
    V.gb+=vec2(smoothstep(0.626,0.,length(vec2((0.5-cos(phase*0.86)*0.4)-x,(0.5-sin(phase*0.32)*0.4)-y))));

    return vec4(V/max(max(V.r,V.g),V.b)/1.626,0.4);
}
