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
		local D=P.modeData
		D.finished=D.finished+1
		if FIELD[D.finished+1]then
			P.waiting=26
			for _=#P.field,1,-1 do
				FREEROW.discard(P.field[_])
				FREEROW.discard(P.visTime[_])
				P.field[_],P.visTime[_]=nil
			end
			setField(P,D.finished+1)
			SYSFX.newShade(1.4,P.absFieldX,P.absFieldY,300*P.size,610*P.size,.6,.8,.6)
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
		applyCustomGame()

		local ENV=GAME.modeEnv
		ENV.dropPiece=PLY.check_lineReach
		for y=1,20 do
			if notAir(FIELD[1][y])then
				--Switch clear sprint mode on
				ENV.dropPiece=checkClear
				break
			end
		end

		PLY.newPlayer(1)
		local AItype=ENV.opponent:sub(1,2)
		local AIlevel=tonumber(ENV.opponent:sub(-1))
		if AItype=="9S"then
			ENV.target=nil
			PLY.newAIPlayer(2,AIBUILDER("9S",2*AIlevel))
		elseif AItype=="CC"then
			ENV.target=nil
			PLY.newAIPlayer(2,AIBUILDER("CC",2*AIlevel-1,math.floor(AIlevel*.5+1),true,20000+5000*AIlevel))
		end

		for _,P in next,PLAYERS.alive do
			setField(P,1)
		end
	end,
	mesDisp=function(P)
		setFont(55)
		if P.modeData.target>1e10 then
			mStr(P.stat.row,69,225)
			mText(drawableText.line,69,290)
		else
			local R=P.modeData.target-P.stat.row
			mStr(R>=0 and R or 0,69,240)
		end
	end,
}