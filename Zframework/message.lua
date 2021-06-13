local gc=love.graphics
local gc_push,gc_pop=gc.push,gc.pop
local gc_replaceTransform=gc.replaceTransform
local gc_translate,gc_setColor,gc_draw=gc.translate,gc.setColor,gc.draw

local ins,rem=table.insert,table.remove

local mesList={}

local MES={}

function MES.new(...)
	local icon,str,time=...
	if type(icon)~='userdata'then
		icon,str,time=false,icon,str
	else
	end
	local t=gc.newText(getFont(30),str)
	local w=math.max(t:getWidth()+(icon and 45 or 5),200)
	local L={w+20,48,
		{'setCL',.5,.5,.5,.7},
		{'fRect',0,0,w+20,48},
		{'setCL',.9,.9,.9},
		{'setLW',2},
		{'dRect',1,1,w+18,46},
		{'setCL',1,1,1},
	}
	if icon then
		ins(L,{'draw',icon,4,4,nil,40/icon:getWidth(),40/icon:getHeight()})
	end
	ins(L,{'draw',t,icon and 50 or 10,2})

	ins(mesList,{
		startTime=.5,
		endTime=.5,
		time=time or 3,
		canvas=DOGC(L),
	})
end

function MES.update(dt)
	for i=#mesList,1,-1 do
		local m=mesList[i]
		if m.startTime>0 then
			m.startTime=m.startTime-dt
		elseif m.time>0 then
			m.time=m.time-dt
		elseif m.endTime>0 then
			m.endTime=m.endTime-dt
		else
			rem(mesList,i)
		end
	end
end

function MES.draw()
	gc_push('transform')
	if #mesList>0 then
		gc_translate(0,25)
		for i=1,#mesList do
			local m=mesList[i]
			gc_setColor(1,1,1,2*(m.endTime-m.startTime))
			gc_draw(m.canvas,40-80*(m.endTime+m.startTime))
			gc_translate(0,52)
		end
		gc_replaceTransform(SCR.xOy)
	end
	gc_pop()
end
return MES