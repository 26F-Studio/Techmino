local gc=love.graphics
local sin,min=math.sin,math.min
local Timer=love.timer.getTime
return{
	color=COLOR.red,
	env={
		drop=30,lock=60,
		next=1,
		block=false,center=0,ghost=0,
		dropFX=0,lockFX=0,
		visible="none",
		dropPiece=PLY.check_lineReach,
		freshLimit=15,
		target=40,
		bg="none",bgm="push",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
		if SETTING.spawn==0 then
			LOG.print(text.switchSpawnSFX,COLOR.yellow)
		end
	end,
	mesDisp=function(P)
		if not GAME.result then
			if GAME.replaying then
				gc.setColor(.3,.3,.3,.7)
				gc.push("transform")
				gc.origin()
				gc.rectangle("fill",0,0,SCR.w,SCR.h)
				gc.pop()
			else
				gc.clear(.26,.26,.26)
				--Frame
				gc.setColor(.5,.5,.5)
				gc.push("transform")
				gc.translate(150,70)
				gc.rectangle("line",-1,-11,302,612)--Boarder
				gc.rectangle("line",301,-3,15,604)--AtkBuffer boarder
				gc.rectangle("line",-16,-3,15,604)--B2b bar boarder
				gc.pop()
			end
		end

		--Figures
		local t=Timer()
		gc.setColor(1,1,1,.5+.2*sin(t))
		gc.draw(IMG.hbm,-276,-16,0,1.5)
		gc.draw(IMG.electric,476,212,0,2.6)

		--Texts
		gc.setColor(.8,.8,.8)
		mText(drawableText.line,69,370)
		mText(drawableText.techrash,69,490)
		setFont(75)
		mStr(P.stat.row,69,290)
		mStr(P.stat.clears[4],69,410)
	end,
	score=function(P)return{min(P.stat.row,40),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		return
		L>=40 and 5 or
		L>=30 and 4 or
		L>=20 and 3 or
		L>=10 and 2 or
		L>=5 and 1 or
		L>=1 and 0
	end,
}