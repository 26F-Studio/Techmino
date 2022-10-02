-- Black-White grid
local gc=love.graphics
local gc_clear,gc_scale=gc.clear,gc.scale
local gc_setColor=gc.setColor
local gc_rectangle=gc.rectangle

local sin=math.sin
local ceil=math.ceil
local back={}

local t
local matrixT={} for i=1,50 do matrixT[i]={} for j=1,50 do matrixT[i][j]=love.math.noise(i,j)+2 end end
function back.init()
    t=math.random()*2600
end
function back.update(dt)
    t=t+dt
end
function back.draw()
    gc_clear(.1,.1,.1)
    local k=SCR.k
    gc_scale(k)
    local Y=ceil(SCR.h/80/k)
    for x=1,ceil(SCR.w/80/k) do
        for y=1,Y do
            gc_setColor(1,1,1,sin(x+matrixT[x][y]*t)*.04+.04)
            gc_rectangle('fill',80*x,80*y,-80,-80)
        end
    end
end
return back
