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
	color=COLOR.lYellow,
	env={
		drop=15,lock=60,
		fall=20,
		royaleMode=true,
		Fkey=selectTarget,
		pushSpeed=2,
		freshLimit=15,
		bg="rainbow",bgm="rockblock",
	},
	load=function()
		royaleData={
			powerUp={2,5,10,20},
			stage={30,20,15,10,5},
		}
		PLY.newPlayer(1,340,15)
		local L={}for i=1,49 do L[i]=true end
		local t=CC and 6 or 0
		while t>0 do
			local r=rnd(2,49)
			if L[r]then L[r],t=false,t-1 end
		end
		local n=2
		for i=1,4 do for j=1,6 do
			if L[n]then
				PLY.newAIPlayer(n,78*i-54,115*j-98,.09,AIBUILDER("9S",rnd(8,10)))
			else
				PLY.newAIPlayer(n,78*i-54,115*j-98,.09,AIBUILDER("CC",rnd(4,7),3,true,40000))
			end
			n=n+1
		end end
		for i=9,12 do for j=1,6 do
			if L[n]then
				PLY.newAIPlayer(n,78*i+267,115*j-98,.09,AIBUILDER("9S",rnd(8,9)))
			else
				PLY.newAIPlayer(n,78*i+267,115*j-98,.09,AIBUILDER("CC",rnd(5,8),3,true,40000))
			end
			n=n+1
		end end
	end,
	mesDisp=function(P)
		setFont(35)
		mStr(#PLAYERS.alive.."/49",69,245)
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
		R==2 and 4 or
		R==3 and 3 or
		R==4 and 2 or
		R<=6 and 1 or
		R<=45 and 0
	end,
}