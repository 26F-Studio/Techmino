local MATH={}for k,v in next,math do MATH[k]=v end

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

return MATH