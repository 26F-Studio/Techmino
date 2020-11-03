local gc=love.graphics
local min=math.min
return{
	color=COLOR.red,
	env={
		drop=30,lock=60,
		block=false,center=0,ghost=0,
		dropFX=0,lockFX=0,
		visible="none",
		score=false,
		dropPiece=PLY.check_lineReach,
		freshLimit=15,
		target=100,
		bg="rgb",bgm="push",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		mText(drawableText.line,69,370)
		mText(drawableText.techrash,69,490)
		setFont(75)
		mStr(P.stat.row,69,290)
		mStr(P.stat.clears[4],69,410)
		gc.setColor(1,1,1,.2)
		gc.draw(IMG.electric,124,176,0,2.6)
	end,
	score=function(P)return{min(P.stat.row,100),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		return
		L>=100 and 5 or
		L>=75 and 4 or
		L>=50 and 3 or
		L>=26 and 2 or
		L>=10 and 1 or
		L>=1 and 0
	end,
}