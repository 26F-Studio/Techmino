--Blackhole
local gc=love.graphics
local rectangle=gc.rectangle
local rnd=math.random
local ins,rem=table.insert,table.remove
local back={}

local t
local squares
function back.init()
	t=26
	squares={}
end
function back.update()
	t=t-1
	if t==0 then
		local size=SCR.rad*(2+rnd()*3)/100
		local S={
			x=(SCR.w-size)*rnd()-SCR.w/2,
			y=(SCR.h-size)*rnd()-SCR.h/2,
			ang=6.28*rnd(),
			size=size,
			color=COLOR.random_dark(),
		}
		if rnd()<.5 then
			S.x=rnd()<.5 and
				-SCR.w/2-S.size or
				SCR.w/2
		else
			S.y=rnd()<.5 and
				-SCR.h/2-S.size or
				SCR.h/2
		end
		ins(squares,S)
		t=rnd(6,16)
	end
	for i=#squares,1,-1 do
		local S=squares[i]
		local ang=math.atan2(S.y,S.x)
		local d=(S.x^2+S.y^2)^.5
		d=d-2000/(d+60)
		if d>0 then
			S.x=d*math.cos(ang)
			S.y=d*math.sin(ang)
		else
			rem(squares,i)
		end
	end
end
function back.draw()
	gc.clear(.1,.1,.1)
	gc.push("transform")
	gc.origin()
	gc.translate(SCR.w/2,SCR.h/2)

	--Squares
	gc.setLineWidth(6)
	for i=1,#squares do
		local S=squares[i]
		local c=S.color
		gc.setColor(c[1],c[2],c[3],.6)
		rectangle("line",S.x,S.y,S.size,S.size)
		gc.setColor(c)
		rectangle("fill",S.x,S.y,S.size,S.size)
	end

	--Blackhole
	gc.setColor(0,0,0)
	gc.circle("fill",0,0,156)
	gc.setLineWidth(8)
	for i=0,10 do
		gc.setColor(0,0,0,1-i*.1)gc.circle("line",0,0,160+8*i)
	end
	gc.pop()
end
function back.discard()
	squares=nil
end
return back