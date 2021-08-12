return{
	color=COLOR.green,
	env={
		infHold=true,
		drop=150,lock=1e99,
		dropPiece=function(P)if P.stat.row>=100 then P:win('finish')end end,
		bg='rgb',bgm='truth',
	},
	mesDisp=function(P)
		setFont(55)
		local r=100-P.stat.row
		if r<0 then r=0 end
		mStr(r,63,220)
		PLY.draw.drawTargetLine(P,r)

		setFont(60)
		mStr(P.stat.pc,63,300)
		mText(drawableText.pc,63,370)
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