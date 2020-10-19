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
		if BAG[1]then
			modeEnv.bag=BAG
		else
			modeEnv.bag=nil
		end
		if MISSION[1]then
			modeEnv.mission=MISSION
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
		FIELD.h=20
		repeat
			for i=1,10 do
				if FIELD[FIELD.h][i]>0 then
					goto L
				end
			end
			FIELD.h=FIELD.h-1
		until FIELD.h==0
		::L::
		for _,P in next,PLAYERS.alive do
			local t=P.showTime*3
			for y=1,FIELD.h do
				P.field[y]=freeRow.get(0)
				P.visTime[y]=freeRow.get(t)
				for x=1,10 do P.field[y][x]=FIELD[y][x]end
			end
			P.garbageBeneath=FIELD.h
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