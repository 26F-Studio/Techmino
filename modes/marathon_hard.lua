local gc=love.graphics
local function check(P)
	if P.stat.row>=P.gameEnv.target then
		local T=P.gameEnv.target
		if T==50 then
			P.gameEnv.drop=.25
			P.gameEnv.target=100
		elseif T==100 then
			P.gameEnv._20G=true
			P.gameEnv.target=200
		else
			P:win("finish")
		end
	end
end

return{
	color=color.magenta,
	env={
		noFly=true,
		mindas=7,minarr=1,minsdarr=1,
		drop=.5,wait=8,fall=20,
		target=50,dropPiece=check,
		bg="strap",bgm="push",
	},
	pauseLimit=true,
	slowMark=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(45)
		mStr(P.stat.row,-81,320)
		mStr(P.gameEnv.target,-81,370)
		gc.rectangle("fill",-125,375,90,4)
	end,
	score=function(P)return{P.stat.row<=200 and P.stat.row or 200,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		if L>=200 then
			local T=P.stat.time
			return
			T<=200 and 5 or
			T<=270 and 4 or
			3
		else
			return
			L>=100 and 2 or
			L>=50 and 1 or
			L>=10 and 0
		end
	end,
}