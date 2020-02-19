local gc=love.graphics
return{
	name={
		"限时打分",
		"限时打分",
		"Ultra",
	},
	level={
		"挑战",
		"挑战",
		"EXTRA",
	},
	info={
		"在两分钟内尽可能拿到最多的分数",
		"在两分钟内尽可能拿到最多的分数",
		"Score attack in 120s",
	},
	color=color.lightGrey,
	env={
		drop=1e99,lock=1e99,
		task=function(P)
			if P.stat.time>=120 then
				Event.win(P,"finish")
			end
		end,
		bg="matrix",bgm="infinite",
	},
	pauseLimit=true,
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		gc.circle("line",-30,100,40)
		gc.setColor(1,0,0)
		gc.arc("fill",-40,100,50,0,1)
	end,
	score=function(P)return{P.stat.score}end,
	scoreDisp=function(D)return tostring(D[1])end,
	comp=function(a,b)return a[1]>b[1]end,
	getRank=function(P)
		local T=P.stat.score
		return 1
	end,
}