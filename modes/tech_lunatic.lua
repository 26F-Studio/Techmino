local format=string.format
local function tech_check_easy(P)
	if #P.clearedRow>0 and P.b2b<40 then
		P:lose()
	end
end

return{
	color=color.red,
	env={
		_20G=true,lock=60,
		freshLimit=15,
		target=200,
		dropPiece=tech_check_easy,
		bg="matrix",bgm="secret7th",
	},
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(45)
		mStr(P.stat.atk,-81,310)
		mStr(format("%.2f",P.stat.atk/P.stat.row),-81,420)
		mText(drawableText.atk,-81,363)
		mText(drawableText.eff,-81,475)
	end,
	score=function(P)return{P.stat.row<=200 and P.stat.row or 200,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines  "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		return
		L>=200 and 5 or
		L>=140 and 4 or
		L>=90 and 3 or
		L>=60 and 2 or
		L>=30 and 1 or
		L>=5 and 0
	end,
}