local gc=love.graphics
local warnTime={60,90,105,115,116,117,118,119,120}
return{
	color=COLOR.lGrey,
	env={
		noTele=true,
		minarr=1,minsdarr=1,
		drop=60,lock=60,
		fall=20,
		task=function(P)
			local _=P.modeData.counter+1
			if P.stat.time>=warnTime[_]then
				if _<9 then
					P.modeData.counter=_
					SFX.play("ready",.7+_*.03)
				else
					SFX.play("start")
					P:win("finish")
					return true
				end
			end
		end,
		bg="fan",bgm="infinite",
	},
	slowMark=true,
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		gc.setLineWidth(2)
		gc.rectangle("line",55,190,32,402)
		local T=P.stat.time/120
		gc.setColor(2*T,2-2*T,.2)
		gc.rectangle("fill",56,591,30,(T-1)*400)
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