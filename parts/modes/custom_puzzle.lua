local gc=love.graphics
local int=math.floor
local function puzzleCheck(P)
	local F=FIELD[P.modeData.point+1]
	for y=1,20 do
		local L=P.field[y]
		for x=1,10 do
			local a,b=F[y][x],L and L[x]or 0
			if a~=0 then
				if a==-1 then if b>0 then return end
				elseif a<12 then if a~=b then return end
				elseif a>7 then if b==0 then return end
				end
			end
		end
	end
	P.modeData.point=P.modeData.point+1
	if FIELD[P.modeData.point+1]then
		P.waiting=26
		for _=#P.field,1,-1 do
			FREEROW.discard(P.field[_])
			FREEROW.discard(P.visTime[_])
			P.field[_],P.visTime[_]=nil
		end
		SYSFX.newShade(1.4,P.absFieldX,P.absFieldY,300*P.size,610*P.size,.3,1,.3)
		SFX.play("reach")
		P.modeData.event=0
	else
		P.modeData.event=1
		P:win("finish")
	end
end

return{
	color=COLOR.white,
	env={
		fkey1=function(P)P.modeData.event=1-P.modeData.event end,
		dropPiece=puzzleCheck,
	},
	load=function()
		applyCustomGame()
		PLY.newPlayer(1)
		local ENV=GAME.modeEnv
		local AItype=ENV.opponent:sub(1,2)
		local AIlevel=tonumber(ENV.opponent:sub(-1))
		if AItype=="9S"then
			ENV.target=nil
			PLY.newAIPlayer(2,AIBUILDER("9S",2*AIlevel))
		elseif AItype=="CC"then
			ENV.target=nil
			PLY.newAIPlayer(2,AIBUILDER("CC",2*AIlevel-1,int(AIlevel*.5+1),true,20000+5000*AIlevel))
		end
	end,
	mesDisp=function(P)
		local dx,dy=P.fieldOff.x,P.fieldOff.y
		setFont(55)
		mStr(P.stat.row,69,225)
		mText(drawableText.line,69,290)
		if P.modeData.event==0 then
			local mark=TEXTURE.puzzleMark
			local F=FIELD[P.modeData.point+1]
			for y=1,20 do for x=1,10 do
				local T=F[y][x]
				if T~=0 then
					gc.draw(mark[T],150+30*x-30+dx,600-30*y+dy)
				end
			end end
		end
	end,
}