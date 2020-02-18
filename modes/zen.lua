return{
	name={
		"禅",
		"禅",
		"Zen",
	},
	level={
		"时间杀手 I",
		"时间杀手 I",
		"Time Killer I",
	},
	info={
		"不限时200行",
		"不限时200行",
		"200 lines without any limits",
	},
	color=color.lightGrey,
	env={
		drop=1e99,lock=1e99,
		oncehold=false,target=200,
		dropPiece=Event.reach_winCheck,
		bg="strap",bgm="infinite",
	},
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(70)
		local R=200-P.stat.row
		mStr(R>=0 and R or 0,-82,280)
	end,
	score=function(P)return{P.stat.score}end,
	scoreDisp=function(D)return tostring(D[1])end,
	comp=function(a,b)return a[1]>b[1]end,
	getRank=function(P)
		local T=P.stat.score
		return
		T>=12e4 and 5 or
		T>=10e4 and 4 or
		T>=6e4 and 3 or
		T>=3e4 and 2 or
		T>=1e4 and 1
	end,
}