local format=string.format
return{
	color=COLOR.lGrey,
	env={
		drop=1e99,lock=1e99,
		oncehold=false,
		bg="glow",bgm="infinite",
	},
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
	score=function(P)return{P.stat.score}end,
	scoreDisp=function(D)return tostring(D[1])end,
	comp=function(a,b)return a[1]>b[1]end,
	getRank=function(P)
		local L=P.stat.row
		return
		L>=1200 and 5 or
		L>=900 and 4 or
		L>=600 and 3 or
		L>=300 and 2 or
		L>=100 and 1 or
		L>=20 and 0
	end,
}