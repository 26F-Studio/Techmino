local format=string.format
return{
	name={
		"无尽",
		"无尽",
		"Infinite",
	},
	level={
		"时间杀手 II",
		"时间杀手 II",
		"Time Killer II",
	},
	info={
		"沙盒",
		"沙盒",
		"Sandbox",
	},
	color=color.lightGrey,
	env={
		drop=1e99,lock=1e99,
		oncehold=false,
		bg="glow",bgm="infinite",
	},
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(45)
		mStr(P.stat.atk,-82,260)
		mStr(format("%.2f",P.stat.atk/P.stat.row),-82,370)
		mDraw(drawableText.atk,-82,313)
		mDraw(drawableText.eff,-82,425)
	end,
	score=function(P)return{P.stat.score}end,
	scoreDisp=function(D)return D[1]end,
	comp=function(a,b)return a[1]>b[1]end,
	getRank=function(P)
		local L=P.stat.row
		return
		L>=2600 and 5 or
		L>=1500 and 4 or
		L>=1000 and 3 or
		L>=500 and 2 or
		L>=100 and 1
	end,
}