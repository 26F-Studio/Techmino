local gc=love.graphics
local sin,min=math.sin,math.min
local Timer=love.timer.getTime
return{
	color=color.red,
	env={
		drop=30,lock=60,
		next=1,
		block=false,
		center=false,ghost=false,
		dropFX=0,lockFX=0,
		visible="none",
		dropPiece=PLY.reach_winCheck,
		freshLimit=15,
		target=100,
		bg="none",bgm="secret7th",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		if not game.result then
			gc.clear(.26,.26,.26)
		end

		--MD Figure
		local t=Timer()
		gc.setColor(.6+.3*sin(t*1.26),.6+.3*sin(t*2.6),.6+.3*sin(t*1.626),.2)
		gc.draw(IMG.electric,-162,-8,0,3.2)
		
		--Texts
		gc.setColor(.8,.8,.8)
		mText(drawableText.line,-81,300)
		mText(drawableText.techrash,-81,420)
		setFont(75)
		mStr(P.stat.row,-81,220)
		mStr(P.stat.clears[4],-81,340)

		--"Field"
		gc.setColor(.5,.5,.5)
		gc.rectangle("line",-1,-11,302,612)
		gc.rectangle("line",301,0,15,601)
		gc.rectangle("line",-16,-3,15,604)
	end,
	score=function(P)return{min(P.stat.row or 200),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		return
		L>=100 and 5 or
		L>=60 and 4 or
		L>=30 and 3 or
		L>=10 and 2 or
		L>=5 and 1 or
		L>=1 and 0
	end,
}