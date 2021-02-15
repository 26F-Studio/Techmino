local gc=love.graphics
local dropSpeed={[0]=60,50,40,30,24,18,14,10,8,6,5,4,3,2,1,1,.5,.5,.25,.25}

return{
	color=COLOR.magenta,
	env={
		noTele=true,
		lock=1e99,
		wait=10,fall=60,
		mindas=7,minarr=1,minsdarr=1,
		keyCancel={6},
		dropPiece=function(P)
			if P.stat.row>=P.modeData.target then
				if P.modeData.target==200 then
					P:win("finish")
				else
					P.modeData.bpm=60+3*P.modeData.target/10
					P.modeData.beatFrame=math.floor(3600/P.modeData.bpm)
					P.gameEnv.fall=P.modeData.beatFrame
					P.gameEnv.wait=math.max(P.gameEnv.wait-1,0)
					P.gameEnv.drop=dropSpeed[P.modeData.target/10]
					P.modeData.target=P.modeData.target+10
					SFX.play("reach")
				end
			end
		end,
		task=function(P)
			P.modeData.target=10
			P.modeData.bpm=60
			P.modeData.beatFrame=60
			P.modeData.counter=60
			while true do
				coroutine.yield()
				P.modeData.counter=P.modeData.counter-1
				if P.modeData.counter==0 then
					P.modeData.counter=P.modeData.beatFrame
					SFX.play("click",.3)
					P:switchKey(6,true)
					P:pressKey(6)
					P:switchKey(6,false)
				end
			end
		end,
		bg="bg2",bgm="push",
	},
	pauseLimit=true,
	slowMark=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(45)
		mStr(P.stat.row,69,320)
		mStr(P.modeData.target,69,370)
		gc.rectangle("fill",25,375,90,4)

		setFont(30)
		mStr(P.modeData.bpm,69,178)

		gc.setLineWidth(4)
		gc.circle("line",69,200,30)

		local beat=P.modeData.counter/P.modeData.beatFrame
		gc.setColor(1,1,1,1-beat)
		gc.setLineWidth(3)
		gc.circle("line",69,200,30+45*beat)
	end,
	score=function(P)return{math.min(P.stat.row,200),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		return
			L>=200 and 5 or
			L>=170 and 4 or
			L>=140 and 3 or
			L>=100 and 2 or
			L>=50 and 1 or
			L>=20 and 0
	end,
}