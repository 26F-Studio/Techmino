return{
	color=COLOR.cyan,
	env={
		drop=60,lock=60,
		freshLimit=15,
		fieldH=40,
		fillClear=false,
		bg='none',bgm='there',
	},
	mesDisp=function(P)
		setFont(55)
		mStr(P.stat.piece,69,265)
	end,
	score=function(P)return{P.stat.piece,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Pieces".."   "..STRING.time(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local B=P.stat.piece
		return
		B>=105 and 5 or
		B>=101 and 4 or
		B>=97 and 3 or
		B>=94 and 2 or
		B>=90 and 1 or
		0
	end,
}