local gc=love.graphics
local rnd=math.random
local powerUp={[0]="000%UP","025%UP","050%UP","075%UP","100%UP",}
local function selectTarget(P)
	if SETTING.swap then
		for i=1,#P.keyPressing do
			if P.keyPressing[i]then
				P.keyPressing[i]=false
			end
		end
		P.keyPressing[9]=true
	else
		P:changeAtkMode(P.atkMode<3 and P.atkMode+2 or 5-P.atkMode)
		P.swappingAtkMode=30
	end
end

return{
	color=COLOR.cyan,
	env={
		drop=60,lock=60,
		fall=20,
		royaleMode=true,
		Fkey=selectTarget,
		pushSpeed=2,
		freshLimit=15,
		bg="rainbow",bgm="rockblock",
	},
	load=function()
		royaleData={
			powerUp={2,6,14,30},
			stage={75,50,35,20,10},
		}
		PLY.newPlayer(1,340,15)
		local L={}for i=1,100 do L[i]=true end
		local t=CC and 4 or 0
		while t>0 do
			local r=rnd(2,99)
			if L[r]then L[r],t=false,t-1 end
		end
		local n=2
		for i=1,7 do for j=1,7 do
			if L[n]then
				PLY.newAIPlayer(n,46*i-36,97*j-72,.068,AIBUILDER("9S",rnd(4,6)))
			else
				PLY.newAIPlayer(n,46*i-36,97*j-72,.068,AIBUILDER("CC",rnd(2,4),2,true,20000))
			end
			n=n+1
		end end
		for i=15,21 do for j=1,7 do
			if L[n]then
				PLY.newAIPlayer(n,46*i+264,97*j-72,.068,AIBUILDER("9S",rnd(4,5)))
			else
				PLY.newAIPlayer(n,46*i+264,97*j-72,.068,AIBUILDER("CC",rnd(3,5),2,true,20000))
			end
			n=n+1
		end end
	end,
	mesDisp=function(P)
		setFont(35)
		mStr(#PLAYERS.alive.."/99",69,245)
		mStr(P.modeData.point,80,285)
		gc.draw(drawableText.ko,23,295)
		setFont(20)
		gc.setColor(1,.5,0,.6)
		gc.print(P.badge,103,297)
		gc.setColor(1,1,1)
		setFont(25)
		gc.print(powerUp[P.strength],18,360)
		for i=1,P.strength do
			gc.draw(IMG.badgeIcon,16*i+12,330)
		end
	end,
	score=function(P)return{P.modeData.event,P.modeData.point}end,
	scoreDisp=function(D)return"NO."..D[1].."   KO:"..D[2]end,
	comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]>b[2]end,
	getRank=function(P)
		local R=P.modeData.event
		return
		R==1 and 5 or
		R<=3 and 4 or
		R<=6 and 3 or
		R<=10 and 2 or
		R<=20 and 1 or
		R<=90 and 0
	end,
}