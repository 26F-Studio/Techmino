return{
	color=COLOR.green,
	env={
		oncehold=false,
		drop=300,lock=1e99,
		target=100,dropPiece=PLY.check_lineReach,
		ospin=false,
		bg="rgb",bgm="truth",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		setFont(45)
		local R=100-P.stat.row
		mStr(R>=0 and R or 0,69,320)

		setFont(75)
		mStr(P.stat.pc,69,420)
		mText(drawableText.pc,69,502)
	end,
	score=function(P)return{P.stat.pc,P.stat.time}end,
	scoreDisp=function(D)return D[1].." PCs   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.pc
		return
		L>=24 and 5 or
		L>=20 and 4 or
		L>=16 and 3 or
		L>=13 and 2 or
		L>=10 and 1 or
		L>=1 and 0
	end,
}