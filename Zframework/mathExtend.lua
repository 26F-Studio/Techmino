local MATH={} for k,v in next,math do MATH[k]=v end

local floor,ceil=math.floor,math.ceil
local rnd=math.random
local exp=math.exp

MATH.tau=2*math.pi
MATH.phi=(1+math.sqrt(5))/2
MATH.inf=1/0
MATH.nan=0/0

function MATH.isnan(n)
    return n~=n
end

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

function MATH.clamp(v,low,high)
    if v<=low then
        return low
    elseif v>=high then
        return high
    else
        return v
    end
end

function MATH.mix(s,e,t)
    return s+(e-s)*t
end

do-- function MATH.listMix(list,t)
    local clamp,mix=MATH.clamp,MATH.mix
    function MATH.listMix(list,t)
        local t2=(#list-1)*clamp(t,0,1)+1
        return mix(list[floor(t2)],list[ceil(t2)],t2%1)
    end
end

function MATH.expApproach(a,b,k)
    return b+(a-b)*exp(-k)
end

function MATH.distance(x1,y1,x2,y2)
    return ((x1-x2)^2+(y1-y2)^2)^.5
end

-- By Pedro Gimeno,donated to the public domain
function MATH.pointInPolygon(x,y,poly,evenOddRule)
    local x1,y1,x2,y2
    local len=#poly
    x2,y2=poly[len-1],poly[len]
    local wn=0
    for idx=1,len,2 do
        x1,y1=x2,y2
        x2,y2=poly[idx],poly[idx+1]
        if y1>y then
            if y2<=y and (x1-x)*(y2-y)<(x2-x)*(y1-y) then
                wn=wn+1
            end
        else
            if y2>y and (x1-x)*(y2-y)>(x2-x)*(y1-y) then
                wn=wn-1
            end
        end
    end
    if evenOddRule then
        return wn%2~=0
    else-- non-zero winding rule
        return wn~=0
    end
end

return MATH
