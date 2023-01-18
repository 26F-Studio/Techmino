local LINE={}
local L={}-- Storage
local len=0-- Length
function LINE.new(val,isGarbage)
    if len==0 then
        for i=1,10 do
            L[i]={0,0,0,0,0,0,0,0,0,0,garbage=false}
        end
        len=len+10
    end
    local t=L[len]
    for i=1,10 do t[i]=val end
    t.garbage=isGarbage==true
    L[len]=nil
    len=len-1
    return t
end
function LINE.discard(t)
    len=len+1
    L[len]=t
end
return LINE
