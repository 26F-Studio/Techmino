--Flandre's wing
local gc=love.graphics
local rnd=math.random
local back={}
local wingColor={
	{0., .9, .9,.626},
	{.3, 1., .3,.626},
	{.9, .9, 0.,.626},
	{1., .5, 0.,.626},
	{1., .3, .3,.626},
	{.5, 0., 1.,.626},
	{.3, .3, 1.,.626},
	{0., .9, .9,.626},
}
local bar,crystal
local W,H
function back.init()
	bar=gc.newCanvas(41,1)
	gc.setCanvas(bar)
	gc.push("transform")
	gc.origin()
	for x=0,20 do
		gc.setColor(1,1,1,x/11)
		gc.rectangle("fill",x,0,1,1)
		gc.rectangle("fill",41-x,0,1,1)
	end
	gc.pop()
	gc.setCanvas()
	BG.resize()
end
function back.resize()
	crystal={}
	W,H=SCR.w,SCR.h
	for i=1,16 do
		crystal[i]={
			x=i<9 and W*.05*i or W*.05*(28-i),
			y=H*.1,
			a=0,
			va=0,
			f=i<9 and .012-i*.0005 or .012-(17-i)*.0005
		}
	end
end
function back.update()
	for i=1,16 do
		local B=crystal[i]
		B.a=B.a+B.va
		B.va=B.va*.986-B.a*B.f
	end
end
function back.draw()
	gc.clear(.06,.06,.06)
	local sy=H*.8
	for i=1,8 do
		gc.setColor(wingColor[i])
		local B=crystal[i]
		gc.draw(bar,B.x,B.y,B.a,1,sy,20,0)
		B=crystal[17-i]
		gc.draw(bar,B.x,B.y,B.a,1,sy,20,0)
	end
end
function back.event(level)
	for i=1,8 do
		local B=crystal[i]
		B.va=B.va+.001*level*(1+rnd())
		B=crystal[17-i]
		B.va=B.va-.001*level*(1+rnd())
	end
end
function back.discard()
	bar,crystal=nil
end
return back