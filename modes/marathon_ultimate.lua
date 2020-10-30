local gc=love.graphics
local dropSpeed={[0]=60,50,40,30,25,20,15,12,9,7,5,4,3,2,1,1,.5,.5,.25,.25}
local function check_LVup(P)
	if P.combo>1 or P.b2b>0 or P.lastClear.row>1 then
		if P.combo>1 then 			P:showText("2x",0,-220,40,"flicker",.3)end
		if P.b2b>0 then 			P:showText("spin",0,-160,40,"flicker",.3)end
		if P.lastClear.row>1 then 	P:showText("1+",0,-100,40,"flicker",.3)end
		P:lose()
		return
	end
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
	color=color.yellow,
	env={
		noTele=true,
		wait=8,fall=20,
		target=10,dropPiece=check_LVup,
		mindas=7,minarr=1,minsdarr=1,
		bg="bg2",bgm="push",
	},
	pauseLimit=true,
	slowMark=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		setFont(45)
		mStr(P.stat.row,69,390)
		mStr(P.modeData.point+10,69,440)
		gc.rectangle("fill",25,445,90,4)
	end,
	score=function(P)return{math.min(P.stat.row,200),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		if L>=200 then
			local T=P.stat.time
			return
			T<=400 and 5 or
			T<=600 and 4 or
			3
		else
			return
			L>=150 and 2 or
			L>=80 and 1 or
			L>=20 and 0
		end
	end,
}