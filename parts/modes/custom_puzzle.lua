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
		SYSFX.newShade(.7,.3,1,.3,P.x+150*P.size,P.y+60*P.size,300*P.size,610*P.size)
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
		Fkey=function(P)P.modeData.event=1-P.modeData.event end,
		dropPiece=puzzleCheck,
	},
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
		PLY.newPlayer(1,340,15)
		local L=MODEENV.opponent
		if L~=0 then
			MODEENV.target=nil
			if L<6 then
				PLY.newAIPlayer(2,965,360,.5,AIBUILDER("9S",2*L))
			else
				PLY.newAIPlayer(2,965,360,.5,AIBUILDER("CC",2*L-11,int(L*.5-1.5),MODEENV.hold,4000*L))
			end
		end
		MODEENV.bg=CUSTOMENV.bg
		MODEENV.bgm=CUSTOMENV.bgm
	end,
	mesDisp=function(P)
		local dx,dy=P.fieldOff.x,P.fieldOff.y
		setFont(55)
		mStr(P.stat.row,69,295)
		mText(drawableText.line,69,360)
		if P.modeData.event==0 then
			local m=puzzleMark
			local F=FIELD[P.modeData.point+1]
			for y=1,20 do for x=1,10 do
				local T=F[y][x]
				if T~=0 then
					gc.draw(m[T],150+30*x-30+dx,70+600-30*y+dy)
				end
			end end
		end
	end,
}