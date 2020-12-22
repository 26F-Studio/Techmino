--Cool Tunnel
local gc=love.graphics
local rnd=math.random
local ins,rem=table.insert,table.remove
local back={}

local ring
local t
local W,H
function back.init()
	ring={}
	t=26
	back.resize(SCR.w,SCR.h)
end
function back.resize(w,h)
	W,H=w,h
end
function back.update(dt)
	t=t-1
	if t==0 then
		t=rnd(26,62)
		ins(ring,0)
	end
	for i=#ring,1,-1 do
		ring[i]=ring[i]+dt
		if ring[i]>3.55 then
			rem(ring,i)
		end
	end
end
function back.draw()
	gc.clear(.1,.1,.1)
	gc.setColor(.4,.4,.4)
	for i=1,#ring do
		local r=ring[i]^2/12
		gc.setLineWidth(30-15/(r+.5))
		gc.rectangle("line",W*.5-W*r/2,H*.5-H*r/2,W*r,H*r)
	end
end
function back.discard()
	ring=false
end
return back