--Black-White grid
local gc=love.graphics
local rnd,sin=math.random,math.sin
local ceil=math.ceil
local back={}

local t
local matrixT={}for i=1,50 do matrixT[i]={}for j=1,50 do matrixT[i][j]=love.math.noise(i,j)+2 end end
function back.init()
	t=rnd()*2600
end
function back.update(dt)
	t=t+dt
end
function back.draw()
	gc.clear(.15,.15,.15)
	gc.push("transform")
		local k=SCR.k
		gc.scale(k)
		local Y=ceil(SCR.h/80/k)
		for x=1,ceil(SCR.w/80/k)do
			for y=1,Y do
				gc.setColor(1,1,1,sin(x+matrixT[x][y]*t)*.1+.1)
				gc.rectangle("fill",80*x,80*y,-80,-80)
			end
		end
	gc.pop()
end
return back