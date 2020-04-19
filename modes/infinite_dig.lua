local format,rnd=string.format,math.random
local function check_rise(P)
	while P.garbageBeneath<6 do
		P:garbageRise(10,1,rnd(10))
		P.modeData.point=P.modeData.point+1
	end
end

return{
	name={
		"无尽:挖掘",
		"无尽:挖掘",
		"Infinite:dig",
	},
	level={
		"",
		"",
		"",
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
		mStr(P.modeData.point,-81,190)
		mStr(P.stat.atk,-81,310)
		mStr(format("%.2f",P.stat.atk/P.stat.row),-81,420)
		mText(drawableText.line,-81,243)
		mText(drawableText.atk,-81,363)
		mText(drawableText.eff,-81,475)
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
		L>=40 and 1 or
		L>=5 and 0
	end,
}