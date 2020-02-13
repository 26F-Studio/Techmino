local format,rnd=string.format,math.random
local function check_rise(P)
	local L=P.cleared
	for i=1,#L do
		if L[i]<6 then
			P:garbageRise(10,1,rnd(10))
			P.modeData.point=P.modeData.point+1
		end
	end
end

return{
	name={
		"无尽:挖掘",
		"无尽:挖掘",
		"Infinite:dig",
	},
	level={
		"时间杀手 III",
		"时间杀手 III",
		"Time Killer III",
	},
	info={
		"挖呀挖呀挖",
		"挖呀挖呀挖",
		"Dig to Nether?",
	},
	color=color.white,
	env={
		drop=1e99,lock=1e99,
		oncehold=false,
		dropPiece=check_rise,
		pushSpeed=1,
		bg="glow",bgm="infinite",
	},
	load=function()
		newPlayer(1,340,15)
		for _=1,5 do
			players[1]:garbageRise(10,1,rnd(10))
		end
	end,
	mesDisp=function(P,dx,dy)
		setFont(45)
		mStr(P.modeData.point,-82,190)
		mStr(P.stat.atk,-82,310)
		mStr(format("%.2f",P.stat.atk/P.stat.row),-82,420)
		mDraw(drawableText.line,-82,243)
		mDraw(drawableText.atk,-82,363)
		mDraw(drawableText.eff,-82,475)
	end,
	score=function(P)return{P.modeData.point}end,
	scoreDisp=function(D)return D[1].." Lines"end,
	comp=function(a,b)return a[1]>b[1]end,
	getRank=function(P)
		local L=P.modeData.point
		return
		L>=626 and 5 or
		L>=400 and 4 or
		L>=200 and 3 or
		L>=100 and 2 or
		L>=10 and 1
	end,
}