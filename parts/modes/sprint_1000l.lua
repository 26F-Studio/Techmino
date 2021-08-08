return{
	color=COLOR.lGray,
	env={
		drop=60,lock=60,
		dropPiece=function(P)if P.stat.row>=1000 then P:win('finish')end end,
		bg='rainbow',bgm='push',
	},
	mesDisp=function(P)
		setFont(55)
		local r=1000-P.stat.row
		if r<0 then r=0 end
		mStr(r,63,265)
		PLY.draw.drawTargetLine(P,r)
	end,
	score=function(P)return{P.stat.time,P.stat.piece}end,
	scoreDisp=function(D)return STRING.time(D[1]).."   "..D[2].." Pieces"end,
	comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		if P.stat.row<1000 then return end
		local T=P.stat.time
		return
		T<=750 and 5 or
		T<=900 and 4 or
		T<=1260 and 3 or
		T<=1620 and 2 or
		T<=2000 and 1 or
		0
	end,
}