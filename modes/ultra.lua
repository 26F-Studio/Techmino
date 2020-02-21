local gc=love.graphics
local warnTime={60,90,105,115,116,117,118,119,120}
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
		drop=60,lock=60,
		fall=20,
		minarr=1,minsdarr=1,
		task=function(P)
			local _=P.modeData.counter+1
			if P.stat.time>=warnTime[_]then
				if _<9 then
					P.modeData.counter=_
					SFX.play("ready",.7+_*.03)
				else
					SFX.play("start")
					Event.win(P,"finish")
					return true
				end
			end
		end,
		bg="matrix",bgm="infinite",
	},
	slowMark=true,
	pauseLimit=true,
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		gc.setLineWidth(2)
		gc.rectangle("line",-95,112,32,402)
		local T=P.stat.time/120
		gc.setColor(2*T,2-2*T,.2)
		gc.rectangle("fill",-94,513,30,(T-1)*400)
	end,
	score=function(P)return{P.stat.score}end,
	scoreDisp=function(D)return tostring(D[1])end,
	comp=function(a,b)return a[1]>b[1]end,
	getRank=function(P)
		local T=P.stat.score
		return
		T>=62000 and 5 or
		T>=50000 and 4 or
		T>=26000 and 3 or
		T>=10000 and 2 or
		T>=6200 and 1
	end,
}