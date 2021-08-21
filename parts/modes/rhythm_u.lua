local gc=love.graphics

local function bgmPosition(target, beat)
	local section = math.floor(target/10)  -- 0-19
	local sectiontime = 0
	for s=1,section-1 do
		sectiontime = sectiontime + 16 / (120+2*(s-1))
	end
	return (sectiontime + beat/(120+2*(section-1))) * 60 + 8
end

return{
	color=COLOR.magenta,
	env={
		noTele=true,
		lock=1e99,
		drop=.5,
		wait=5,fall=30,
		das=6,minarr=1,minsdarr=1,
		keyCancel={6},
		dropPiece=function(P)
			if P.stat.row>=P.modeData.target then
				if P.modeData.target==200 then
					BGM.seek(bgmPosition(200,0))
					P:win('finish')
				else
					P.modeData.bpm=120+2*P.modeData.target/10
					P.modeData.beatFrame=math.floor(3600/P.modeData.bpm)
					P.gameEnv.fall=P.modeData.beatFrame
					P.gameEnv.wait=math.max(P.gameEnv.wait-1,0)
					if P.modeData.target==50 then
						P.gameEnv.das=5
						P.gameEnv.drop=.25
					elseif P.modeData.target==100 then
						P.gameEnv.das=4
						P:set20G(true)
					end
					P.modeData.target=P.modeData.target+10
					SFX.play('reach')
				end
			end
		end,
		task=function(P)
			P.modeData.target=10
			P.modeData.bpm=120
			P.modeData.beatFrame=30
			P.modeData.counter=30
			P.modeData.beat=0
			BGM.seek(0)
			while true do
				YIELD()
				if P.modeData.counter==P.modeData.beatFrame then
					SFX.play('click',.3)
					local pos = bgmPosition(P.modeData.target, P.modeData.beat)
					BGM.seek(pos)
					P.modeData.beat=(P.modeData.beat+1)%16
				end
				P.modeData.counter=P.modeData.counter-1
				if P.modeData.counter==0 then
					P.modeData.counter=P.modeData.beatFrame
					P:switchKey(6,true)
					P:pressKey(6)
					P:switchKey(6,false)
				end
			end
		end,
		bg='bg2',bgm='untitled1',
	},
	slowMark=true,
	mesDisp=function(P)
		PLY.draw.drawProgress(P.stat.row,P.modeData.target)

		setFont(30)
		mStr(P.modeData.bpm,63,178)

		gc.setLineWidth(4)
		gc.circle('line',63,200,30)

		local beat=P.modeData.counter/P.modeData.beatFrame
		gc.setColor(1,1,1,1-beat)
		gc.setLineWidth(3)
		gc.circle('line',63,200,30+45*beat)
	end,
	score=function(P)return{math.min(P.stat.row,200),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..STRING.time(D[2])end,
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