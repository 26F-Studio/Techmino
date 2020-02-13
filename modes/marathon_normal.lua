local gc=love.graphics
local marathon_drop={[0]=60,48,40,30,24,18,15,12,10,8,7,6,5,4,3,2,1,1,0,0}
local function check_LVup(P)
	local T=P.modeData.point+10
	if P.stat.row>=T then
		if T==200 then
			Event.win(P,"finish")
		else
			P.gameEnv.drop=marathon_drop[T/10]
			if T==180 then P.gameEnv._20G=true end
			SFX("reach")
			P.modeData.point=T
		end
	end
end

return{
	name={
		"马拉松",
		"马拉松",
		"Marathon",
	},
	level={
		"普通",
		"普通",
		"NORMAL",
	},
	info={
		"200行变速马拉松",
		"200行变速马拉松",
		"200L marathon with acceleration",
	},
	color=color.green,
	env={
		drop=60,fall=20,
		target=10,dropPiece=check_LVup,
		bg="strap",bgm="way",
	},
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(45)
		mStr(P.stat.row,-82,320)
		mStr(P.modeData.point+10,-82,370)
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
			T<=180 and 5 or
			T<=240 and 4 or
			3
		else
			return
			L>=150 and 2 or
			L>=100 and 1
		end
	end,
}