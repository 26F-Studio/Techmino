local gc=love.graphics
local int=math.floor
local function puzzleCheck(P)
	for y=1,20 do
		local L=P.field[y]
		for x=1,10 do
			local a,b=preField[y][x],L and L[x]or 0
			if a~=0 then
				if a==-1 then if b>0 then return end
				elseif a<12 then if a~=b then return end
				elseif a>7 then if b==0 then return end
				end
			end
		end
	end
	P.modeData.event=1
	P:win("finish")
end

return{
	color=color.white,
	env={
		puzzle=true,
		Fkey=function(P)P.modeData.event=1-P.modeData.event end,
		dropPiece=puzzleCheck,
	},
	load=function()
		for i=1,#customID do
			local k=customID[i]
			modeEnv[k]=customRange[k][customSel[i]]
		end
		modeEnv._20G=modeEnv.drop==0
		modeEnv.oncehold=customSel[6]==1
		modeEnv.target=0
		PLY.newPlayer(1,340,15)
		local L=modeEnv.opponent
		if L~=0 then
			modeEnv.target=nil
			if L<10 then
				PLY.newAIPlayer(2,965,360,.5,AITemplate("9S",2*L))
			else
				PLY.newAIPlayer(2,965,360,.5,AITemplate("CC",L-6,2+int((L-11)*.5),modeEnv.hold,15000+5000*(L-10)))
			end
		end
		preField.h=20
		repeat
			for i=1,10 do
				if preField[preField.h][i]~=0 then
					goto L
				end
			end
			preField.h=preField.h-1
		until preField.h==0
		::L::
		modeEnv.bg=customRange.bg[customSel[12]]
		modeEnv.bgm=customRange.bgm[customSel[13]]
	end,
	mesDisp=function(P)
		local dx,dy=P.fieldOff.x,P.fieldOff.y
		setFont(55)
		mStr(P.stat.row,-81,225)
		mText(drawableText.line,-81,290)
		if P.gameEnv.puzzle and P.modeData.event==0 then
			local m=puzzleMark
			for y=1,preField.h do for x=1,10 do
				local T=preField[y][x]
				if T~=0 then
					gc.draw(m[T],30*x-30+dx,600-30*y+dy)
				end
			end end
		end
	end,
}