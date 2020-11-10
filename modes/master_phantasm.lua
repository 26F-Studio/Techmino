local gc=love.graphics
local function check_LVup(P)
	local p=P.modeData.point+P.lastPiece.row
	if p>=P.gameEnv.target then
		local ENV=P.gameEnv
		local T=ENV.target
		--Stage 1: clear 3 techrash
		if T==12 then--Stage 2: swap color of S/Z & J/L
			P.waiting=30
			P.curMission=nil

			ENV.skin[1],ENV.skin[2]=ENV.skin[2],ENV.skin[1]
			ENV.skin[3],ENV.skin[4]=ENV.skin[4],ENV.skin[3]

			ENV.lock=14
			ENV.wait=7
			ENV.fall=7
			ENV.next=4

			ENV.target=26
			SFX.play("reach")
		elseif T==26 then--Stage 3: dig to bottom
			if not P.hd then P.life=P.life+1 end--1 up if ban hold
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
						P.field[i][P:RND(10)]=0
					end
				else
					P.field[i]=FREEROW.get(0)
					P.visTime[i]=FREEROW.get(30)
					for j=1,10 do
						if P:RND()>.9 then
							P.field[i][j]=math.random(16)
						end
					end
					P.field[i][P:RND(10)]=0
				end
				P.field[i][11]=true
			end
			P.garbageBeneath=10
			for i=1,10 do
				P:createClearingFX(i,1.5)
			end
			sysFX.newShade(.4,1,1,1,P.x+150*P.size,P.y+370*P.size,300*P.size,300*P.size)

			ENV.lock=13
			ENV.wait=6
			ENV.fall=6
			ENV.next=5

			ENV.target=42
			SFX.play("reach")
		elseif T==42 then--Stage 4: survive in high speed
			if P.garbageBeneath==0 then
				P.waiting=30
				ENV.lock=11
				ENV.next=6
				P:setHold(false)
				ENV.bone=true

				ENV.target=62
			else
				p=41
			end
		elseif T==62 then--Stage 5: survive without easy-fresh rule
			P.life=1
			ENV.lock=13
			ENV.wait=5
			ENV.fall=5

			ENV.easyFresh=false

			ENV.target=126
			SFX.play("reach")
		elseif T==126 then--Stage 6: speed up
			P.life=P.life+1

			ENV.lock=11
			ENV.wait=4
			ENV.fall=4

			ENV.target=162
		elseif T==162 then--Stage 7: speed up+++
			P.life=P.life+1

			ENV.lock=10

			P:setHold(true)
			P.keepVisible=false
			P.showTime=180

			ENV.target=226
			SFX.play("reach")
		elseif T==226 then--Stage 8: final invisible
			P.life=P.life+2

			ENV.bone=false
			P.showTime=90

			ENV.target=259
			SFX.play("reach")
		elseif T==259 then--Stage 9: ending
			P.life=P.life+1
			for i=1,7 do ENV.skin[i]=math.random(16)end

			P.showTime=40
			ENV.lock=15
			P.curMission=1
			ENV.mission={4,4,4,4,4,4,4,4}
			ENV.missionKill=false

			ENV.target=260
			SFX.play("blip_2")
		else
			p=P.result=="WIN"and 260 or 259
		end
	end
	P.modeData.point=p
end

return{
	color=COLOR.black,
	env={
		noTele=true,
		das=5,arr=1,
		drop=0,lock=15,
		wait=10,fall=10,
		next=2,
		sequence="his4",
		target=12,dropPiece=check_LVup,
		mission={4,4,4,64},
		missionKill=true,
		freshLimit=12,
		bg="none",bgm="distortion",
	},
	slowMark=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		setFont(45)
		mStr(P.modeData.point,69,390)
		mStr(P.gameEnv.target,69,440)
		gc.rectangle("fill",25,445,90,4)
	end,
	score=function(P)return{P.result=="WIN"and 260 or P.modeData.point,P.stat.time}end,
	scoreDisp=function(D)return D[1].."P   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		P=P.modeData.point
		return
		P==260 and 5 or
		P>=226 and 4 or
		P>=162 and 3 or
		P>=62 and 2 or
		P>=42 and 1 or
		P>=26 and 0
	end,
}