local gc=love.graphics
local min=math.min
return{
	color=color.magenta,
	env={
		drop=15,lock=45,
		fall=10,lock=60,
		center=false,
		visible="none",
		dropPiece=PLY.reach_winCheck,
		freshLimit=15,
		target=200,
		bg="rgb",bgm="secret7th",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		mText(drawableText.line,-81,300)
		mText(drawableText.techrash,-81,420)
		setFont(75)
		mStr(P.stat.row,-81,220)
		mStr(P.stat.clear_S[4],-81,340)
		gc.setColor(1,1,1,.2)
		gc.draw(IMG.electric,-26,120,0,2.6)
	end,
	score=function(P)return{min(P.stat.row or 200),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		if L>=200 then
			local T=P.stat.time
			return
			T<=150 and 5 or
			T<=210 and 4 or
			3
		else
			return
			L>=150 and 3 or
			L>=90 and 2 or
			L>=40 and 1 or
			L>=1 and 0
		end
	end,
}