local format=string.format
return{
	color=color.lightGrey,
	env={
		drop=1e99,lock=1e99,
		oncehold=false,
		bg="glow",bgm="infinite",
	},
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(45)
		mStr(P.stat.atk,-81,260)
		mStr(format("%.2f",P.stat.atk/P.stat.row),-81,370)
		mText(drawableText.atk,-81,313)
		mText(drawableText.eff,-81,425)
	end,
	score=function(P)return{P.stat.score}end,
	scoreDisp=function(D)return tostring(D[1])end,
	comp=function(a,b)return a[1]>b[1]end,
	getRank=function(P)
		local L=P.stat.row
		return
		L>=2600 and 5 or
		L>=1500 and 4 or
		L>=1000 and 3 or
		L>=500 and 2 or
		L>=100 and 1 or
		L>=20 and 0
	end,
}