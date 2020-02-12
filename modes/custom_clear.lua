local gc=love.graphics
local int=math.floor
return{
	name={
		"自定义",
		"自定义",
		"Custom",
	},
	level={
		"普通",
		"普通",
		"NORMAL",
	},
	info={
		"画点什么然后把它消除!",
		"画点什么然后把它消除!",
		"Draw something then clear it!",
	},
	color=color.white,
	env={
		dropPiece=Event.reach_winCheck,
	},
	load=function()
		for i=1,#customID do
			local k=customID[i]
			modeEnv[k]=customRange[k][customSel[i]]
		end
		modeEnv._20G=modeEnv.drop==0
		modeEnv.oncehold=customSel[6]==1
		newPlayer(1,340,15)
		local L=modeEnv.opponent
		if L~=0 then
			modeEnv.target=nil
			if L<10 then
				newPlayer(2,965,360,.5,AITemplate("9S",2*L))
			else
				newPlayer(2,965,360,.5,AITemplate("CC",L-6,2+int((L-11)*.5),modeEnv.hold,15000+5000*(L-10)))
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
				P.field[y]=getNewRow(0)
				P.visTime[y]=getNewRow(t)
				for x=1,10 do P.field[y][x]=preField[y][x]end
			end
		end
		modeEnv.bg=customRange.bg[customSel[12]]
		modeEnv.bgm=customRange.bgm[customSel[13]]
	end,
	mesDisp=function(P,dx,dy)
		setFont(55)
		if P.gameEnv.puzzle or P.gameEnv.target>1e10 then
			mStr(P.stat.row,-82,225)
			mDraw(drawableText.line,-82,290)
		else
			local R=P.gameEnv.target-P.stat.row
			mStr(R>=0 and R or 0,-82,240)
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