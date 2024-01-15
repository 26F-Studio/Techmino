local abs=math.abs

-- Converts from HSV to RGB color. All arguments should be between 0 and 1, inclusively.
local function HSVToRGB(h,s,v,a)
    if s<=0 then return v,v,v,a end
    h=h%1*6
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

local function RGBToHSV(r,g,b,a)
    local max=math.max(r,g,b) -- = value
    local min=math.min(r,g,b)
    local chroma=max-min
    local hue=(
        max==min and 0 or
        max==r and (g-b)/chroma%6/6 or
        max==g and (2+(b-r)/chroma)/6 or
        (4+(r-g)/chroma)/6
    )
    local saturation=max==0 and 0 or chroma/max
    return hue,saturation,max,a
end

local COLOR={
    hsv=HSVToRGB, -- backwards compatibility
    HSVToRGB=HSVToRGB,
    RGBToHSV=RGBToHSV,


    red=        {HSVToRGB(0.00, 0.89, 0.91)},
    fire=       {HSVToRGB(0.04, 0.93, 0.94)},
    orange=     {HSVToRGB(0.09, 0.99, 0.96)},
    yellow=     {HSVToRGB(0.15, 0.82, 0.90)},
    lime=       {HSVToRGB(0.20, 0.89, 0.88)},
    jade=       {HSVToRGB(0.25, 1.00, 0.82)},
    green=      {HSVToRGB(0.33, 1.00, 0.81)},
    aqua=       {HSVToRGB(0.47, 1.00, 0.76)},
    cyan=       {HSVToRGB(0.53, 1.00, 0.88)},
    navy=       {HSVToRGB(0.56, 1.00, 1.00)},
    sea=        {HSVToRGB(0.61, 1.00, 1.00)},
    blue=       {HSVToRGB(0.64, 1.00, 0.95)},
    violet=     {HSVToRGB(0.74, 1.00, 0.91)},
    purple=     {HSVToRGB(0.80, 1.00, 0.81)},
    magenta=    {HSVToRGB(0.86, 1.00, 0.78)},
    wine=       {HSVToRGB(0.92, 0.98, 0.91)},

    lRed=       {HSVToRGB(0.00, 0.38, 0.93)},
    lFire=      {HSVToRGB(0.04, 0.45, 0.91)},
    lOrange=    {HSVToRGB(0.10, 0.53, 0.92)},
    lYellow=    {HSVToRGB(0.14, 0.61, 0.95)},
    lLime=      {HSVToRGB(0.20, 0.66, 0.92)},
    lJade=      {HSVToRGB(0.26, 0.56, 0.90)},
    lGreen=     {HSVToRGB(0.34, 0.49, 0.89)},
    lAqua=      {HSVToRGB(0.47, 0.59, 0.86)},
    lCyan=      {HSVToRGB(0.51, 0.77, 0.88)},
    lNavy=      {HSVToRGB(0.54, 0.80, 0.95)},
    lSea=       {HSVToRGB(0.57, 0.72, 0.97)},
    lBlue=      {HSVToRGB(0.64, 0.44, 0.96)},
    lViolet=    {HSVToRGB(0.72, 0.47, 0.95)},
    lPurple=    {HSVToRGB(0.80, 0.62, 0.89)},
    lMagenta=   {HSVToRGB(0.86, 0.61, 0.89)},
    lWine=      {HSVToRGB(0.93, 0.57, 0.92)},

    dRed=       {HSVToRGB(0.00, 0.80, 0.48)},
    dFire=      {HSVToRGB(0.04, 0.80, 0.34)},
    dOrange=    {HSVToRGB(0.07, 0.80, 0.39)},
    dYellow=    {HSVToRGB(0.12, 0.80, 0.37)},
    dLime=      {HSVToRGB(0.20, 0.80, 0.26)},
    dJade=      {HSVToRGB(0.29, 0.80, 0.27)},
    dGreen=     {HSVToRGB(0.33, 0.80, 0.26)},
    dAqua=      {HSVToRGB(0.46, 0.80, 0.24)},
    dCyan=      {HSVToRGB(0.50, 0.80, 0.30)},
    dNavy=      {HSVToRGB(0.58, 0.80, 0.42)},
    dSea=       {HSVToRGB(0.64, 0.80, 0.40)},
    dBlue=      {HSVToRGB(0.67, 0.80, 0.34)},
    dViolet=    {HSVToRGB(0.71, 0.80, 0.35)},
    dPurple=    {HSVToRGB(0.76, 0.80, 0.32)},
    dMagenta=   {HSVToRGB(0.87, 0.80, 0.28)},
    dWine=      {HSVToRGB(0.92, 0.80, 0.28)},

    black=      {HSVToRGB(0.04, 0.04, 0.14)},
    dGray=      {HSVToRGB(0.02, 0.05, 0.44)},
    gray=       {HSVToRGB(0.02, 0.05, 0.65)},
    lGray=      {HSVToRGB(0.02, 0.06, 0.86)},
    white=      {HSVToRGB(0.01, 0.02, 0.99)},

    xGray=      {HSVToRGB(0.00, 0.00, 0.35,.8)},
    lxGray=     {HSVToRGB(0.00, 0.00, 0.62,.8)},
    dxGray=     {HSVToRGB(0.00, 0.00, 0.16,.8)},
}
for k,v in next,{
    R='red', F='fire', O='orange', Y='yellow', L='lime', J='jade', G='green', A='aqua', C='cyan', N='navy', S='sea', B='blue', V='violet', P='purple', M='magenta', W='wine',
    lR='lRed',lF='lFire',lO='lOrange',lY='lYellow',lL='lLime',lJ='lJade',lG='lGreen',lA='lAqua',lC='lCyan',lN='lNavy',lS='lSea',lB='lBlue',lV='lViolet',lP='lPurple',lM='lMagenta',lW='lWine',
    dR='dRed',dF='dFire',dO='dOrange',dY='dYellow',dL='dLime',dJ='dJade',dG='dGreen',dA='dAqua',dC='dCyan',dN='dNavy',dS='dSea',dB='dBlue',dV='dViolet',dP='dPurple',dM='dMagenta',dW='dWine',
    D='black',dH='dGray',H='gray',lH='lGray',Z='white',
    X='xGray',lX='lxGray',dX='dxGray',
    -- Remain letter: EIKQTU
} do
    COLOR[k]=COLOR[v]
end
setmetatable(COLOR,{__index=function(_,k)
    error("No color: "..tostring(k))
end})


do-- Random generators
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

do-- Rainbow generators
    local twoThirdsOfPi=2*math.pi/3
    local sin=math.sin
    function COLOR.rainbow(phase,alpha)
        return
            sin(phase)*.4+.6,
            sin(phase+twoThirdsOfPi)*.4+.6,
            sin(phase-twoThirdsOfPi)*.4+.6,
            alpha
    end
    function COLOR.rainbow_light(phase,alpha)
        return
            sin(phase)*.2+.7,
            sin(phase+twoThirdsOfPi)*.2+.7,
            sin(phase-twoThirdsOfPi)*.2+.7,
            alpha
    end
    function COLOR.rainbow_dark(phase,alpha)
        return
            sin(phase)*.2+.4,
            sin(phase+twoThirdsOfPi)*.2+.4,
            sin(phase-twoThirdsOfPi)*.2+.4,
            alpha
    end
    function COLOR.rainbow_gray(phase,alpha)
        return
            sin(phase)*.16+.5,
            sin(phase+twoThirdsOfPi)*.16+.5,
            sin(phase-twoThirdsOfPi)*.16+.5,
            alpha
    end
end

do -- Color interpolation https://www.alanzucconi.com/2016/01/06/colour-interpolation/
    local lerp=MATH.mix
    function COLOR.interpolateRGB(rgba1,rgba2,t)
        return
            lerp(rgba1[1],rgba2[1],t),
            lerp(rgba1[2],rgba2[2],t),
            lerp(rgba1[3],rgba2[3],t),
            ((rgba1[4] and rgba2[4]) and lerp(rgba1[4],rgba1[4],t) or nil)
    end

    function COLOR.interpolateHSV(hsv1,hsv2,t)
        local hue1,hue2=hsv1[1],hsv2[1]
        if hue1>hue2 then
            hue1,hue2=hue2,hue1
            t=1-t
        end

        local hueDiff=hue2-hue1
        local finalHue=.0
        if hueDiff>.5 then
            hue1=hue1+1
            finalHue=(hue1+t*(hue2-hue1))%1;
        else
            finalHue=hue1+t*hueDiff
        end

        return finalHue,
            lerp(hsv1[2],hsv2[2],t),
            lerp(hsv1[3],hsv2[3],t),
            ((hsv1[4] and hsv2[4]) and lerp(hsv1[4],hsv1[4],t) or nil)
    end
end

--[[
    Returns either color1 or color2 based on time.
    Args:
        - color1, color2: colors to switch between
        - period: the length of time in a cycle in seconds. ("wavelength")
        - percentage [optional]: percentage of time in the color1 phase (default: 50%)
]]
function COLOR.flicker(color1,color2,period,percentage)
    percentage=percentage or .5
    return TIME()%period>percentage*period and color1 or color2
end

local lerpRGB,lerpHSV=COLOR.interpolateRGB,COLOR.interpolateHSV
local tau=MATH.tau
--[[
    Oscillates between color1 and color2 over time in a sinusoidal fashion.
    Args:
        - color1, color2: colors to switch between.
            [FORMAT IS BASED ON TYPE, WHICH DEFAULTS TO HSV]
            Use COLOR.HSVtoRGB() and/or COLOR.RGBtoHSV to convert between color formats.
        - period: the length of time in a cycle in seconds. (wavelength)
        - type [optional]: the type of interpolation, defaulting to 'hsv'.
            Supported values: nil, 'hsv', 'rgb'
]]
function COLOR.sine(color1,color2,period,type)
    type=type or 'hsv'
    local t=math.sin(tau*TIME()/period)
    if type=='hsv' then
        return lerpHSV(color1, color2, t)
    elseif type=='rgb' then
        return lerpRGB(color1, color2, t)
    end
end

return COLOR
