local gc=love.graphics
local dropSpeed={[0]=60,50,40,30,25,20,15,12,9,7,5,4,3,2,1,1,.5,.5,.25,.25}
local function check_LVup(P)
	local T=P.modeData.point+10
	if P.stat.row>=T then
		if T==200 then
			P:win("finish")
		else
			P.gameEnv.drop=dropSpeed[T/10]
			P.modeData.point=T
			SFX.play("reach")
		end
	end
end

return{
	color=color.green,
	env={
		noFly=true,
		minsdarr=1,
		wait=8,fall=20,
		target=10,dropPiece=check_LVup,
		mindas=7,minarr=1,minsdarr=1,
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
		mStr(P.modeData.point+10,-81,370)
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
			T<=226 and 5 or
			T<=262 and 4 or
			3
		else
			return
			L>=150 and 2 or
			L>=100 and 1 or
			L>=20 and 0
		end
	end,
}