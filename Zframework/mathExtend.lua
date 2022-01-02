local MATH={}for k,v in next,math do MATH[k]=v end

local int,ceil=math.floor,math.ceil
local rnd=math.random

MATH.tau=2*math.pi

function MATH.sign(a)
    return a>0 and 1 or a<0 and -1 or 0
end

function MATH.roll(chance)
    return rnd()<(chance or .5)
end

function MATH.coin(a,b)
    if rnd()<.5 then
        return a
    else
        return b
    end
end

function MATH.interval(v,low,high)
    if v<=low then
        return low
    elseif v>=high then
        return high
    else
        return v
    end
end

function MATH.lerp(s,e,t)
    return s+(e-s)*t
end

do--function MATH.listLerp(list,t)
    local interval,lerp=MATH.interval,MATH.lerp
    function MATH.listLerp(list,t)
        local t2=(#list-1)*interval(t,0,1)+1
        return lerp(list[int(t2)],list[ceil(t2)],t2%1)
    end
end

function MATH.expApproach(a,b,k)
    return b+(a-b)*2.718281828459045^-k
end

return MATH
