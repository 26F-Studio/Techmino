local gc=love.graphics
local int,rnd=math.floor,math.random
local powerUp={[0]="000%UP","025%UP","050%UP","075%UP","100%UP",}
local function selectTarget(P)
	if setting.swap then
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
	color=color.cyan,
	env={
		drop=60,lock=60,
		fall=20,
		royaleMode=true,
		Fkey=selectTarget,
		pushSpeed=2,
		freshLimit=15,
		bg="game3",bgm="rockblock",
	},
	load=function()
		royaleData={
			powerUp={2,6,14,30},
			stage={75,50,35,20,10},
		}
		PLY.newPlayer(1,340,15)
		local L={}for i=1,100 do L[i]=true end
		local t=system~="Windows"and 0 or 4
		while t>0 do
			local r=rnd(2,99)
			if L[r]then L[r],t=false,t-1 end
		end
		local n=2
		for i=1,7 do for j=1,7 do
			if L[n]then
				PLY.newAIPlayer(n,46*i-36,97*j-72,.068,AITemplate("9S",rnd(2,5)))
			else
				PLY.newAIPlayer(n,46*i-36,97*j-72,.068,AITemplate("CC",rnd(2,5)-1,2,true,10000))
			end
			n=n+1
		end end
		for i=15,21 do for j=1,7 do
			if L[n]then
				PLY.newAIPlayer(n,46*i+264,97*j-72,.068,AITemplate("9S",rnd(2,5)))
			else
				PLY.newAIPlayer(n,46*i+264,97*j-72,.068,AITemplate("CC",rnd(2,5)-1,2,true,10000))
			end
			n=n+1
		end end
	end,
	mesDisp=function(P,dx,dy)
		setFont(35)
		mStr(#players.alive.."/99",-81,175)
		mStr(P.modeData.point,-70,215)
		gc.draw(drawableText.ko,-127,225)
		setFont(20)
		gc.setColor(1,.5,0,.6)
		gc.print(P.badge,-47,227)
		gc.setColor(1,1,1)
		setFont(25)
		gc.print(powerUp[P.strength],-132,290)
		for i=1,P.strength do
			gc.draw(IMG.badgeIcon,16*i-138,260)
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