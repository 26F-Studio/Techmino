local gc=love.graphics
local int=math.floor
return{
	color=color.white,
	env={
		dropPiece=PLY.check_lineReach,
	},
	load=function()
		for k,v in next,customEnv do
			modeEnv[k]=v
		end
		if preBag[1]then
			modeEnv.bag=preBag
		else
			modeEnv.bag=nil
		end
		if preMission[1]then
			modeEnv.mission=preMission
		else
			modeEnv.mission=nil
		end
		PLY.newPlayer(1,340,15)
		local L=modeEnv.opponent
		if L~=0 then
			modeEnv.target=nil
			if L<6 then
				PLY.newAIPlayer(2,965,360,.5,AITemplate("9S",2*L))
			else
				PLY.newAIPlayer(2,965,360,.5,AITemplate("CC",2*L-11,int(L*.5-1.5),modeEnv.hold,4000*L))
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
		modeEnv.bg=customEnv.bg
		modeEnv.bgm=customEnv.bgm
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