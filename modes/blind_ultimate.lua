local min=math.min
return{
	name={
		"隐形",
		"隐形",
		"Blind",
	},
	level={
		"啥都不剩隐",
		"啥都不剩隐",
		"NOTHING",
	},
	info={
		"最强大脑",
		"最强大脑",
		"Invisible board",
	},
	color=color.red,
	env={
		drop=30,lock=60,
		fall=5,
		block=false,
		center=false,ghost=false,
		visible="none",
		dropPiece=Event.reach_winCheck,
		freshLimit=15,
		target=200,
		bg="rgb",bgm="secret7th",
	},
	pauseLimit=true,
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		mDraw(drawableText.line,-82,300)
		mDraw(drawableText.techrash,-82,420)
		setFont(75)
		mStr(P.stat.row,-82,220)
		mStr(P.stat.clear_4,-82,340)
	end,
	score=function(P)return{min(P.stat.row or 200),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		return
		L>=200 and 5 or
		L>=100 and 4 or
		L>=50 and 3 or
		L>=26 and 2 or
		L>=10 and 1 or
		L>=1 and 0
	end,
}