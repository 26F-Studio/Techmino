local gc=love.graphics
local sin,min=math.sin,math.min
return{
	color=COLOR.red,
	env={
		drop=30,lock=60,
		nextCount=1,
		block=false,center=0,ghost=0,
		dropFX=0,lockFX=0,
		visible='none',
		dropPiece=function(P)if P.stat.row>=40 then P:win('finish')end end,
		freshLimit=15,
		bg='none',bgm='far',
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1)
		if SETTING.sfx_spawn==0 then
			MES.new(text.switchSpawnSFX)
		end
	end,
	mesDisp=function(P)
		if not GAME.result then
			gc.push('transform')
			if GAME.replaying then
				gc.origin()
				gc.setColor(.3,.3,.3,.7)
				gc.rectangle('fill',0,0,SCR.w,SCR.h)
			else
				gc.clear(.2,.2,.2)
				gc.translate(150,0)
				gc.setColor(.5,.5,.5)
				--Frame
				gc.rectangle('line',-1,-11,302,612)--Boarder
				gc.rectangle('line',301,-3,15,604)--AtkBuffer boarder
				gc.rectangle('line',-16,-3,15,604)--B2b bar boarder
			end
			gc.pop()
		end

		--Figures
		local t=TIME()
		gc.setColor(1,1,1,.5+.2*sin(t))
		gc.draw(IMG.hbm,-276,-86,0,1.5)
		gc.draw(IMG.electric,476,142,0,2.6)

		--Texts
		gc.setColor(.8,.8,.8)
		mText(drawableText.line,69,300)
		mText(drawableText.techrash,69,420)
		setFont(75)
		mStr(P.stat.row,69,220)
		mStr(P.stat.clears[4],69,340)
	end,
	score=function(P)return{min(P.stat.row,40),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..STRING.time(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		return
		L>=40 and 5 or
		L>=30 and 4 or
		L>=20 and 3 or
		L>=10 and 2 or
		L>=5 and 1 or
		L>=2 and 0
	end,
}