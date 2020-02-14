return{
	name={
		"干旱",
		"干旱",
		"Drought",
	},
	level={
		"100L",
		"100行",
		"100L",
	},
	info={
		"你I没了",
		"你I没了",
		"B a g 6",
	},
	color=color.green,
	env={
		drop=20,lock=60,
		sequence="drought1",
		target=100,dropPiece=Event.reach_winCheck,
		ospin=false,
		freshLimit=15,
		bg="glow",bgm="reason",
	},
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(70)
		local R=100-P.stat.row
		mStr(R>=0 and R or 0,-82,280)
	end,
	score=function(P)return{P.stat.row<=100 and P.stat.row or 100,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		if L>=100 then
			local T=P.stat.time
			return 
			T<=65 and 5 or
			T<=100 and 4 or
			T<=145 and 3 or
			T<=220 and 2 or
			1
		else
			return
			L>=50 and 1 or
			L>=10 and 0
		end
	end,
}