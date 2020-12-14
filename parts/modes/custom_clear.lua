local int=math.floor

local function notAir(L)
	for i=1,10 do
		if L[i]>0 then return true end
	end
end
local function setField(P,page)
	local F=FIELD[page]
	local height=0
	for y=20,1,-1 do
		if notAir(F[y])then
			height=y
			break
		end
	end
	local t=P.showTime*3
	for y=1,height do
		local solid=notAir(F[y])
		P.field[y]=FREEROW.get(0,solid)
		P.visTime[y]=FREEROW.get(t)
		if solid then
			for x=1,10 do
				P.field[y][x]=F[y][x]
			end
			P.garbageBeneath=P.garbageBeneath+1
		end
	end
end
local function checkClear(P)
	if P.garbageBeneath==0 then
		P.modeData.point=P.modeData.point+1
		if FIELD[P.modeData.point+1]then
			P.waiting=26
			for _=#P.field,1,-1 do
				FREEROW.discard(P.field[_])
				FREEROW.discard(P.visTime[_])
				P.field[_],P.visTime[_]=nil
			end
			setField(P,P.modeData.point+1)
			SYSFX.newShade(.7,.6,.8,.6,P.x+150*P.size,P.y+60*P.size,300*P.size,610*P.size)
			SFX.play("blip_1")
		else
			P:win("finish")
		end
	end
end
return{
	color=COLOR.white,
	env={},
	load=function()
		for k,v in next,CUSTOMENV do
			MODEENV[k]=v
		end
		if BAG[1]then
			MODEENV.bag=BAG
		else
			MODEENV.bag=nil
		end
		if MISSION[1]then
			MODEENV.mission=MISSION
		else
			MODEENV.mission=nil
		end
		MODEENV.dropPiece=PLY.check_lineReach
		for y=1,20 do
			if notAir(FIELD[1][y])then
				--Switch clear mode on
				MODEENV.dropPiece=checkClear
				break
			end
		end
		PLY.newPlayer(1,340,15)
		local L=MODEENV.opponent
		if L~=0 then
			MODEENV.target=nil
			if L<6 then
				PLY.newAIPlayer(2,965,360,.5,AIBUILDER("9S",2*L))
			else
				PLY.newAIPlayer(2,965,360,.5,AIBUILDER("CC",2*L-11,int(L*.5-1.5),true,4000*L))
			end
		end
		for _,P in next,PLAYERS.alive do
			setField(P,1)
		end
		MODEENV.bg=CUSTOMENV.bg
		MODEENV.bgm=CUSTOMENV.bgm
	end,
	mesDisp=function(P)
		setFont(55)
		if P.gameEnv.target>1e10 then
			mStr(P.stat.row,69,295)
			mText(drawableText.line,69,360)
		else
			local R=P.gameEnv.target-P.stat.row
			mStr(R>=0 and R or 0,69,310)
		end
	end,
}