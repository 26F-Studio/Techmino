local gc=love.graphics
local int=math.floor
return{
	color=color.white,
	env={
		dropPiece=PLY.reach_winCheck,
	},
	load=function()
		for i=1,#customID do
			local k=customID[i]
			modeEnv[k]=customRange[k][customSel[i]]
		end
		modeEnv._20G=modeEnv.drop==0
		modeEnv.oncehold=customSel[6]==1
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
				if preField[preField.h][i]>0 then
					goto L
				end
			end
			preField.h=preField.h-1
		until preField.h==0
		::L::
		for _,P in next,players.alive do
			local t=P.showTime*3
			for y=1,preField.h do
				P.field[y]=freeRow.get(0)
				P.visTime[y]=freeRow.get(t)
				for x=1,10 do P.field[y][x]=preField[y][x]end
			end
			P.garbageBeneath=preField.h
		end
		modeEnv.bg=customRange.bg[customSel[12]]
		modeEnv.bgm=customRange.bgm[customSel[13]]
	end,
	mesDisp=function(P,dx,dy)
		setFont(55)
		if P.gameEnv.puzzle or P.gameEnv.target>1e10 then
			mStr(P.stat.row,-81,225)
			mText(drawableText.line,-81,290)
		else
			local R=P.gameEnv.target-P.stat.row
			mStr(R>=0 and R or 0,-81,240)
		end
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