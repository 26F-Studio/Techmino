return{
	color=COLOR.red,
	env={
		drop=20,lock=60,
		fall=20,
		dropPiece=function(P)if P.stat.row>=100 then P:win('finish')end end,
		freshLimit=15,
		ospin=false,
		bg='rgb',bgm='moonbeam',
	},
	mesDisp=function(P)
		setFont(45)
		local R=100-P.stat.row
		mStr(R>=0 and R or 0,69,220)

		setFont(70)
		mStr(P.stat.pc,69,300)
		mText(drawableText.pc,69,380)
	end,
	score=function(P)return{P.stat.pc,P.stat.time}end,
	scoreDisp=function(D)return D[1].." PCs   "..STRING.time(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.pc
		return
		L>=24 and 5 or
		L>=20 and 4 or
		L>=16 and 3 or
		L>=12 and 2 or
		L>=8 and 1 or
		L>=1 and 0
	end,
}