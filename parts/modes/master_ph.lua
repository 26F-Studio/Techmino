local gc=love.graphics

return{
	color=COLOR.black,
	env={
		noTele=true,
		das=5,arr=1,
		drop=0,lock=15,
		wait=10,fall=10,
		nextCount=2,
		sequence='his',
		task=function(P)P.modeData.target=12 end,
		dropPiece=function(P)
			local p=P.modeData.pt+P.lastPiece.row
			if p>=P.modeData.target then
				local ENV=P.gameEnv
				local T=P.modeData.target
				--Stage 1: clear 3 techrash
				if T==12 then--Stage 2: swap color of S/Z & J/L
					P.waiting=30
					P.curMission=false

					ENV.skin[1],ENV.skin[2]=ENV.skin[2],ENV.skin[1]
					ENV.skin[3],ENV.skin[4]=ENV.skin[4],ENV.skin[3]

					ENV.lock=14
					ENV.wait=7
					ENV.fall=7
					P:setNext(4)

					P.modeData.target=26
					SFX.play('reach')
				elseif T==26 then--Stage 3: dig to bottom
					if not P.holdQueue[1]then P.life=P.life+1 end--1 up if ban hold
					P.waiting=45
					ENV.skin[1],ENV.skin[2]=ENV.skin[2],ENV.skin[1]
					ENV.skin[3],ENV.skin[4]=ENV.skin[4],ENV.skin[3]

					for i=1,10 do
						if P.field[i]then
							for j=1,10 do
								if P.field[i][j]>0 then
									P.field[i][j]=17
									P.visTime[i][j]=15
								end
							end
							for _=1,5 do
								P.field[i][P.holeRND:random(10)]=0
							end
						else
							P.field[i]=FREEROW.get(0)
							P.visTime[i]=FREEROW.get(30)
							for j=1,10 do
								if P.holeRND:random()>.9 then
									P.field[i][j]=math.random(16)
								end
							end
							P.field[i][P.holeRND:random(10)]=0
						end
						P.field[i].garbage=true
					end
					P.garbageBeneath=10
					for i=1,10 do
						P:createClearingFX(i,1.5)
					end
					SYSFX.newShade(2.5,P.absFieldX,P.y+300*P.size,300*P.size,300*P.size)

					ENV.lock=13
					ENV.wait=6
					ENV.fall=6
					P:setNext(5)

					P.modeData.target=42
					SFX.play('reach')
				elseif T==42 then--Stage 4: survive in high speed
					if P.garbageBeneath==0 then
						P.waiting=30
						ENV.lock=11
						P:setNext(6)
						P:setHold(false)
						ENV.bone=true

						P.modeData.target=62
					else
						p=41
					end
				elseif T==62 then--Stage 5: survive without easy-fresh rule
					P.life=P.life+1
					ENV.lock=13
					ENV.wait=5
					ENV.fall=5

					ENV.easyFresh=false

					P.modeData.target=126
					SFX.play('reach')
				elseif T==126 then--Stage 6: speed up
					P.life=P.life+1

					ENV.lock=11
					ENV.wait=4
					ENV.fall=4

					P.modeData.target=162
				elseif T==162 then--Stage 7: speed up+++
					P.life=P.life+1

					ENV.lock=10

					P:setHold(true)
					P:setInvisible(180)

					P.modeData.target=226
					SFX.play('reach')
				elseif T==226 then--Stage 8: final invisible
					P.life=P.life+1

					ENV.bone=false
					P:setInvisible(90)

					P.modeData.target=259
					SFX.play('reach')
				elseif T==259 then--Stage 9: ending
					P.life=P.life+1
					for i=1,7 do ENV.skin[i]=math.random(16)end

					P:setInvisible(40)
					ENV.lock=15
					P.curMission=1
					ENV.mission={4,4,4,4,4,4,4,4}
					ENV.missionKill=false

					P.modeData.target=260
					p=260
					SFX.play('blip_2')
				else
					p=260
				end
			end
			P.modeData.pt=p
		end,
		mission={4,4,4,64},
		missionKill=true,
		freshLimit=12,
		noInitSZO=true,
		bg='blockspace',bgm='super7th',
	},
	slowMark=true,
	mesDisp=function(P)
		setFont(45)
		mStr(P.modeData.pt,69,320)
		mStr(P.modeData.target,69,370)
		gc.rectangle('fill',25,375,90,4)
	end,
	score=function(P)return{P.result=='win'and 260 or P.modeData.pt,P.stat.time}end,
	scoreDisp=function(D)return D[1].."P   "..STRING.time(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local p=P.modeData.pt
		return
		P.result=='win'and 5 or
		p>=226 and 4 or
		p>=162 and 3 or
		p>=62 and 2 or
		p>=42 and 1 or
		p>=26 and 0
	end,
}