local love=love
local max,min=math.max,math.min
local float=0
return function(y,key1,key2)
    if y>0 then
        float=max(float,0)+y^1.2
    elseif y<0 then
        if float>0 then float=0 end
        float=min(float,0)-(-y)^1.2
    end
    while float>=1 do
        love.keypressed(key1 or"up")
        float=float-1
    end
    while float<=-1 do
        love.keypressed(key2 or"down")
        float=float+1
    end
end