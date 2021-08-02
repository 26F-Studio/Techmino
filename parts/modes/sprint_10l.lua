return{
	color=COLOR.cyan,
	env={
		drop=60,lock=60,
		dropPiece=function(P)if P.stat.row>=10 then P:win('finish')end end,
		bg='bg2',bgm='race',
	},
	mesDisp=function(P)
		setFont(55)
		local r=10-P.stat.row
		if r<0 then r=0 end
		mStr(r,69,265)
		PLY.draw.drawTargetLine(P,r)
	end,
	score=function(P)return{P.stat.time,P.stat.piece}end,
	scoreDisp=function(D)return STRING.time(D[1]).."   "..D[2].." Pieces"end,
	comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		if P.stat.row<10 then return end
		local T=P.stat.time
		return
		T<=7 and 5 or
		T<=10 and 4 or
		T<=25 and 3 or
		T<=40 and 2 or
		T<=62 and 1 or
		0
	end,
}