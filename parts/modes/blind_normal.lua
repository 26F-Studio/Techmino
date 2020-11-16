local gc=love.graphics
local min=math.min
return{
	color=COLOR.green,
	env={
		drop=15,lock=45,
		freshLimit=10,
		visible="fast",
		dropPiece=PLY.check_lineReach,
		target=200,
		bg="glow",bgm="reason",
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
	score=function(P)return{min(P.stat.row,200),P.stat.time}end,
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
			L>=126 and 3 or
			L>=80 and 2 or
			L>=40 and 1 or
			L>=1 and 0
		end
	end,
}