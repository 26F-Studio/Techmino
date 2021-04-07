local gc=love.graphics

return{
	color=COLOR.magenta,
	env={
		noTele=true,
		mindas=7,minarr=1,minsdarr=1,
		drop=.5,wait=8,fall=20,
		task=function(P)P.modeData.target=50 end,
		dropPiece=function(P)
			if P.stat.row>=P.modeData.target then
				if P.modeData.target==50 then
					P.gameEnv.drop=.25
					P.modeData.target=100
					SFX.play("reach")
				elseif P.modeData.target==100 then
					P:set20G(true)
					P.modeData.target=200
					SFX.play("reach")
				else
					P:win("finish")
				end
			end
		end,
		bg="cubes",bgm="push",
	},
	pauseLimit=true,
	slowMark=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(45)
		mStr(P.stat.row,69,320)
		mStr(P.modeData.target,69,370)
		gc.rectangle("fill",25,375,90,4)
	end,
	score=function(P)return{math.min(P.stat.row,200),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..TIMESTR(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		if L>=200 then
			local T=P.stat.time
			return
			T<=240 and 5 or
			T<=360 and 4 or
			3
		else
			return
			L>=100 and 2 or
			L>=50 and 1 or
			L>=10 and 0
		end
	end,
}