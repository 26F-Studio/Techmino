return{
	color=COLOR.cyan,
	env={
		drop=60,lock=60,
		freshLimit=15,
		fieldH=40,
		highCam=true,
		fillClear=false,
		seqData={1,2,3,4,5,6,7,1,2,3,4,5,6,7,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25},
		bg='none',bgm='there',
	},
	mesDisp=function(P)
		setFont(55)
		mStr(P.stat.piece,63,265)
	end,
	score=function(P)return{P.stat.piece,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Pieces".."   "..STRING.time(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local B=P.stat.piece
		return
		B>=90 and 5 or
		B>=87 and 4 or
		B>=83 and 3 or
		B>=78 and 2 or
		B>=70 and 1 or
		0
	end,
}