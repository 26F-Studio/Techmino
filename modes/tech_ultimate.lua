local format=string.format
local function tech_check_hard(P)
	if #P.cleared>0 and P.lastClear<10 then
		Event.lose(P)
	end
end

return{
	name={
		"科研",
		"科研",
		"Tech",
	},
	level={
		"极限",
		"极限",
		"ULTIMATE",
	},
	info={
		"仅允许spin与PC,强制最简操作",
		"仅允许spin与全清,强制最简操作",
		"Don't do normal clear,no finesse error",
	},
	color=color.lightYellow,
	env={
		drop=1e99,lock=60,
		freshLimit=15,
		target=200,
		fineKill=true,
		dropPiece=tech_reach_hard,
		bg="flink",bgm="infinite",
	},
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(45)
		mStr(P.stat.atk,-82,310)
		mStr(format("%.2f",P.stat.atk/P.stat.row),-82,420)
		mDraw(drawableText.atk,-82,363)
		mDraw(drawableText.eff,-82,475)
	end,
	score=function(P)return{P.stat.row<=200 and P.stat.row or 200,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines  "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		return
		L>=200 and 5 or
		L>=150 and 4 or
		L>=100 and 3 or
		L>=70 and 2 or
		L>=40 and 1 or
		L>=10 and 0
	end,
}