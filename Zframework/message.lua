local gc=love.graphics
local gc_push,gc_pop=gc.push,gc.pop
local gc_translate,gc_setColor,gc_draw=gc.translate,gc.setColor,gc.draw

local ins,rem=table.insert,table.remove

local mesList={}
local mesIcon={
	check=DOGC{40,40,
		{'setLW',10},
		{'setCL',0,0,0},
		{'line',4,19,15,30,36,9},
		{'setLW',6},
		{'setCL',.7,1,.6},
		{'line',5,20,15,30,35,10},
	},
	info=DOGC{40,40,
		{'setCL',.2,.25,.85},
		{'fCirc',20,20,15},
		{'setCL',1,1,1},
		{'setLW',2},
		{'dCirc',20,20,15},
		{'fRect',18,11,4,4},
		{'fRect',18,17,4,12},
	},
	broadcast=DOGC{40,40,
		{'setCL',1,1,1},
		{'fRect',2,4,36,26,3},
		{'fPoly',2,27,2,37,14,25},
		{'setCL',.5,.5,.5},
		{'fRect',6,11,4,4},{'fRect',14,11,19,4},
		{'fRect',6,19,4,4},{'fRect',14,19,19,4},
	},
	warn=DOGC{40,40,
		{'setCL',.95,.83,.4},
		{'fPoly',20.5,1,0,38,40,38},
		{'setCL',0,0,0},
		{'dPoly',20.5,1,0,38,40,38},
		{'fRect',17,10,7,18},
		{'fRect',17,29,7,7},
		{'setCL',1,1,1},
		{'fRect',18,11,5,16},
		{'fRect',18,30,5,5},
	},
	error=DOGC{40,40,
		{'setCL',.95,.3,.3},
		{'fCirc',20,20,19},
		{'setCL',0,0,0},
		{'dCirc',20,20,19},
		{'setLW',6},
		{'line',10.2,10.2,29.8,29.8},
		{'line',10.2,29.8,29.8,10.2},
		{'setLW',4},
		{'setCL',1,1,1},
		{'line',11,11,29,29},
		{'line',11,29,29,11},
	},
}

local MES={}

function MES.new(icon,str,time)
	if type(icon)=='string'then icon=mesIcon[icon]end
	local t=gc.newText(getFont(30),str)
	local w=math.max(t:getWidth()+(icon and 45 or 5),200)+20
	local h=math.max(t:getHeight(),46)
	local L={w,h,
		{'clear',.5,.5,.5,.7},
		{'setCL',.7,.7,.7},
		{'setLW',2},
		{'dRect',1,1,w-2,h-2},
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
		width=w,height=h,
		scale=h>400 and 1/math.min(h/400,2.6)or 1
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
		gc_translate(0,30)
		for i=1,#mesList do
			local m=mesList[i]
			gc_setColor(1,1,1,2*(m.endTime-m.startTime))
			gc_draw(m.canvas,40-80*(m.endTime+m.startTime),0,nil,m.scale)
			gc_translate(0,(m.height+4)*m.scale)
		end
	end
	gc_pop()
end
return MES