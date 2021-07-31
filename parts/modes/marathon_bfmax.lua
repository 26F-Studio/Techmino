local gc=love.graphics
local dropSpeed={50,40,30,25,20,15,12,9,7,5,4,3,2,1,1,.5,.5,.25,.25}

return{
	color=COLOR.yellow,
	env={
		noTele=true,
		drop=60,wait=8,fall=20,
		task=function(P)P.modeData.target=10 end,
		dropPiece=function(P)
			local flag
			local l=P.lastPiece
			if P.combo>1 then	flag=true;P:showText("2x",0,-220,40,'flicker',.3)end
			if l.spin then		flag=true;P:showText("spin",0,-180,40,'flicker',.3)end
			if l.row>1 then		flag=true;P:showText("1+",0,-140,40,'flicker',.3)end
			if l.pc then		flag=true;P:showText("PC",0,-100,40,'flicker',.3)end
			if l.hpc then		flag=true;P:showText("HPC",0,-100,40,'flicker',.3)end
			if flag then
				P:lose()
			else
				local T=P.modeData.target
				if P.stat.row>=T then
					if T==200 then
						P:win('finish')
					else
						T=T+10
						P.gameEnv.drop=dropSpeed[T/10]
						P.modeData.target=T
						SFX.play('reach')
					end
				end
			end
		end,
		mindas=7,minarr=1,minsdarr=1,
		bg='bg2',bgm='blank',
	},
	pauseLimit=true,
	slowMark=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(45)
		mStr(P.stat.row,69,320)
		mStr(P.modeData.target,69,370)
		gc.rectangle('fill',25,375,90,4)
		PLY.draw.drawTargetLine(P,200-P.stat.row)
	end,
	getRank=function(P)
		local L=P.stat.row
		if L>=200 then
			local T=P.stat.time
			return
			T<=400 and 5 or
			T<=600 and 4 or
			3
		else
			return
			L>=150 and 2 or
			L>=80 and 1 or
			L>=20 and 0
		end
	end,
}