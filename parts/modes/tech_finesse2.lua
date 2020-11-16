local format=string.format
local int=math.floor
local function tech_check_hard(P)
	local C=P.lastPiece
	if C.row>0 then
		if not C.special then
			P:lose()
			return
		end
	end
	if P.stat.atk>=200 then
		P:win("finish")
	end
end

return{
	color=COLOR.grey,
	env={
		arr=0,
		drop=1e99,lock=60,
		freshLimit=15,
		fineKill=true,
		dropPiece=tech_check_hard,
		bg="flink",bgm="infinite",
	},
	slowMark=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		setFont(45)
		mStr(format("%.1f",P.stat.atk),69,260)
		mStr(format("%.2f",P.stat.atk/P.stat.row),69,380)
		mText(drawableText.atk,69,313)
		mText(drawableText.eff,69,433)
	end,
	score=function(P)return{P.stat.atk<=200 and int(P.stat.atk)or 200,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Attack  "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.atk
		if L>=200 then
			local T=P.stat.time
			return
			T<120 and 5 or
			T<150 and 4 or
			3
		else
			return
			L>=150 and 3 or
			L>=100 and 2 or
			L>=60 and 1 or
			L>=20 and 0
		end
	end,
}