local abs=math.abs
local function hsv(h,s,v,a)
    if s<=0 then return v,v,v end
    h=h*6
    local c=v*s
    local x=abs((h-1)%2-1)*c
    if h<1     then return v,x+v-c,v-c,a
    elseif h<2 then return x+v-c,v,v-c,a
    elseif h<3 then return v-c,v,x+v-c,a
    elseif h<4 then return v-c,x+v-c,v,a
    elseif h<5 then return x+v-c,v-c,v,a
    else            return v,v-c,x+v-c,a
    end
end

local COLOR={
    hsv=hsv,

    red=     {hsv(0,     .85,.85)},
    fire=    {hsv(0.0625,.85,.85)},
    orange=  {hsv(0.125, .85,.85)},
    yellow=  {hsv(0.1875,.85,.85)},
    lime=    {hsv(0.25,  .85,.85)},
    jade=    {hsv(0.3125,.85,.85)},
    green=   {hsv(0.375, .85,.85)},
    aqua=    {hsv(0.4375,.85,.85)},
    cyan=    {hsv(0.5,   .85,.85)},
    navy=    {hsv(0.5625,.85,.85)},
    sea=     {hsv(0.625, .85,.85)},
    blue=    {hsv(0.6875,.85,.85)},
    violet=  {hsv(0.75,  .85,.85)},
    purple=  {hsv(0.8125,.85,.85)},
    magenta= {hsv(0.875, .85,.85)},
    wine=    {hsv(0.9375,.85,.85)},

    lRed=    {hsv(0,     .5,.95)},
    lFire=   {hsv(0.0625,.5,.95)},
    lOrange= {hsv(0.125, .5,.95)},
    lYellow= {hsv(0.1875,.5,.95)},
    lLime=   {hsv(0.25,  .5,.95)},
    lJade=   {hsv(0.3125,.5,.95)},
    lGreen=  {hsv(0.375, .5,.95)},
    lAqua=   {hsv(0.4375,.5,.95)},
    lCyan=   {hsv(0.5,   .5,.95)},
    lNavy=   {hsv(0.5625,.5,.95)},
    lSea=    {hsv(0.625, .5,.95)},
    lBlue=   {hsv(0.6875,.5,.95)},
    lViolet= {hsv(0.75,  .5,.95)},
    lPurple= {hsv(0.8125,.5,.95)},
    lMagenta={hsv(0.875, .5,.95)},
    lWine=   {hsv(0.9375,.5,.95)},

    dRed=    {hsv(0,     .9,.5)},
    dFire=   {hsv(0.0625,.9,.5)},
    dOrange= {hsv(0.125, .9,.5)},
    dYellow= {hsv(0.1875,.9,.5)},
    dLime=   {hsv(0.25,  .9,.5)},
    dJade=   {hsv(0.3125,.9,.5)},
    dGreen=  {hsv(0.375, .9,.5)},
    dAqua=   {hsv(0.4375,.9,.5)},
    dCyan=   {hsv(0.5,   .9,.5)},
    dNavy=   {hsv(0.5625,.9,.5)},
    dSea=    {hsv(0.625, .9,.5)},
    dBlue=   {hsv(0.6875,.9,.5)},
    dViolet= {hsv(0.75,  .9,.5)},
    dPurple= {hsv(0.8125,.9,.5)},
    dMagenta={hsv(0.875, .9,.5)},
    dWine=   {hsv(0.9375,.9,.5)},

    black=   {hsv(0,0,.05)},
    dGray=   {hsv(0,0,0.3)},
    gray=    {hsv(0,0,0.6)},
    lGray=   {hsv(0,0,0.8)},
    white=   {hsv(0,0,.97)},
}
for k,v in next,{
    R='red', F='fire', O='orange', Y='yellow', L='lime', J='jade', G='green', A='aqua', C='cyan', N='navy', S='sea', B='blue', V='violet', P='purple', M='magenta', W='wine',
    lR='lRed',lF='lFire',lO='lOrange',lY='lYellow',lL='lLime',lJ='lJade',lG='lGreen',lA='lAqua',lC='lCyan',lN='lNavy',lS='lSea',lB='lBlue',lV='lViolet',lP='lPurple',lM='lMagenta',lW='lWine',
    dR='dRed',dF='dFire',dO='dOrange',dY='dYellow',dL='dLime',dJ='dJade',dG='dGreen',dA='dAqua',dC='dCyan',dN='dNavy',dS='dSea',dB='dBlue',dV='dViolet',dP='dPurple',dM='dMagenta',dW='dWine',
    D='black',dH='dGray',H='gray',lH='lGray',Z='white',
    --Remain letter: EIKQTUX
}do
    COLOR[k]=COLOR[v]
end
setmetatable(COLOR,{__index=function(_,k)
    error("No color: "..tostring(k))
end})


do--Random generators
    local rnd=math.random
    local list_norm={'red','fire','orange','yellow','lime','jade','green','aqua','cyan','navy','sea','blue','violet','purple','magenta','wine'}
    local len_list_norm=#list_norm
    function COLOR.random_norm()
        return COLOR[list_norm[rnd(len_list_norm)]]
    end

    local list_bright={'lRed','lFire','lOrange','lYellow','lLime','lJade','lGreen','lAqua','lCyan','lNavy','lSea','lBlue','lViolet','lPurple','lMagenta','lWine'}
    local len_list_bright=#list_bright
    function COLOR.random_bright()
        return COLOR[list_bright[rnd(len_list_bright)]]
    end

    local list_dark={'dRed','dFire','dOrange','dYellow','dLime','dJade','dGreen','dAqua','dCyan','dNavy','dSea','dBlue','dViolet','dPurple','dMagenta','dWine'}
    local len_list_dark=#list_dark
    function COLOR.random_dark()
        return COLOR[list_dark[rnd(len_list_dark)]]
    end
end

do--Rainbow generators
    local sin=math.sin
    function COLOR.rainbow(phase,a)
        return
            sin(phase)*.4+.6,
            sin(phase+2.0944)*.4+.6,
            sin(phase-2.0944)*.4+.6,
            a
    end
    function COLOR.rainbow_light(phase,a)
        return
            sin(phase)*.2+.7,
            sin(phase+2.0944)*.2+.7,
            sin(phase-2.0944)*.2+.7,
            a
    end
    function COLOR.rainbow_dark(phase,a)
        return
            sin(phase)*.2+.4,
            sin(phase+2.0944)*.2+.4,
            sin(phase-2.0944)*.2+.4,
            a
    end
    function COLOR.rainbow_gray(phase,a)
        return
            sin(phase)*.16+.5,
            sin(phase+2.0944)*.16+.5,
            sin(phase-2.0944)*.16+.5,
            a
    end
end

return COLOR
