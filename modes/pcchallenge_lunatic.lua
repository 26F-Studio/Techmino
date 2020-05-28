local gc=love.graphics
return{
	color=color.red,
	env={
		drop=20,lock=60,
		fall=20,
		target=100,dropPiece=PLY.reach_winCheck,
		freshLimit=15,
		ospin=false,
		bg="rgb",bgm="infinite",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(45)
		local R=100-P.stat.row
		mStr(R>=0 and R or 0,-81,250)

		setFont(75)
		mStr(P.stat.pc,-81,350)
		mText(drawableText.pc,-81,432)
	end,
	score=function(P)return{P.stat.pc,P.stat.time}end,
	scoreDisp=function(D)return D[1].." PCs   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.pc
		return
		L>=15 and 5 or
		L>=12 and 4 or
		L>=9 and 3 or
		L>=6 and 2 or
		L>=3 and 1 or
		L>=1 and 0
	end,
}