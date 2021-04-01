--Block rain
local gc=love.graphics
local rnd=math.random
local ins,rem=table.insert,table.remove
local back={}

local t
local cell
function back.init()
	t=0
	cell={}
end
function back.update()
	t=t+1
	if t%10==0 then
		ins(cell,{
			bid=rnd(29),
			x=SCR.w*rnd(),
			y=-25,
			a=rnd()*6.2832,
			vy=.5+rnd()*.4,
			vx=rnd()*.4-.2,
			va=rnd()*.04-.02,
		})
	end
	for i=#cell,1,-1 do
		local P=cell[i]
		P.y=P.y+P.vy
		if P.y>SCR.h+25 then
			rem(cell,i)
		else
			P.x=P.x+P.vx
			P.a=P.a+P.va
			P.vx=P.vx-.01+rnd()*.02
		end
	end
end
function back.draw()
	gc.clear(.15,.15,.15)
	gc.push("transform")
	gc.origin()
	local texture=TEXTURE.miniBlock
	local minoColor=minoColor
	for i=1,#cell do
		local C=cell[i]
		local tex=texture[C.bid]
		local c=minoColor[SETTING.skin[C.bid]]
		gc.setColor(c[1],c[2],c[3],.5)
		gc.draw(tex,C.x,C.y,C.a,10,10,tex:getWidth()/2,tex:getHeight()/2)
	end
	gc.pop()
end
function back.discard()
	cell=nil
end
return back