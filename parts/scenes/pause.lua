local gc=love.graphics
local Timer=love.timer.getTime

local setFont=setFont
local mStr=mStr

local sin,log=math.sin,math.log
local format=string.format

local SCR=SCR

local fnsRankColor={
	Z=COLOR.lYellow,
	S=COLOR.lGrey,
	A=COLOR.sky,
	B=COLOR.lGreen,
	C=COLOR.magenta,
	D=COLOR.dGreen,
	E=COLOR.red,
	F=COLOR.dRed,
}
function sceneInit.pause(org)
	if
		org=="setting_game"or
		org=="setting_video"or
		org=="setting_sound"
	then
		TEXT.show(text.needRestart,640,440,50,"fly",.6)
	end
	local P=PLAYERS[1]
	local S=P.stat
	sceneTemp={
		timer=org=="play"and 0 or 50,
		list={
			toTime(S.time),
			format("%d/%d/%d",S.key,S.rotate,S.hold),
			format("%d  %.2fPPS",S.piece,S.piece/S.time),
			format("%d(%d)  %.2fLPM",S.row,S.dig,S.row/S.time*60),
			format("%d(%d)  %.2fAPM",S.atk,S.digatk,S.atk/S.time*60),
			format("%d(%d-%d)",S.pend,S.recv,S.recv-S.pend),
			format("%d/%d/%d/%d",S.clears[1],S.clears[2],S.clears[3],S.clears[4]),
			format("(%d)/%d/%d/%d",S.spins[1],S.spins[2],S.spins[3],S.spins[4]),
			format("%d/%d ; %d/%d",S.b2b,S.b3b,S.pc,S.hpc),
			format("%d/%dx/%.2f%%",S.extraPiece,S.maxFinesseCombo,S.finesseRate*20/S.piece),
		},
		--From right-down, 60 degree each
		radar={
			(S.off+S.dig)/S.time*60,--DefPM
			(S.atk+S.dig)/S.time*60,--ADPM
			S.atk/S.time*60,		--AtkPM
			S.send/S.time*60,		--SendPM
			S.piece/S.time*24,		--LinePM
			S.dig/S.time*60,		--DigPM
		},
		val={1/80,1/80,1/80,1/60,1/100,1/40},
		timing=org=="play",
	}
	S=sceneTemp
	local A,B=S.radar,S.val

	--Normalize Values
	for i=1,6 do
		B[i]=B[i]*A[i]if B[i]>1.26 then B[i]=1.26+log(B[i]-.26,10)end
	end

	for i=1,6 do
		A[i]=format("%.2f",A[i])..text.radarData[i]
	end
	local f=1
	for i=1,6 do
		if B[i]>.5 then f=2 end
		if B[i]>1 then f=3 break end
	end
	if f==1 then	 S.color,f={.4,.9,.5},1.25	--Vegetable
	elseif f==2 then S.color,f={.4,.7,.9},1		--Normal
	elseif f==3 then S.color,f={1,.3,.3},.626	--Diao
	end
	A={
		120*.5*f,	120*3^.5*.5*f,
		120*-.5*f,	120*3^.5*.5*f,
		120*-1*f,	120*0*f,
		120*-.5*f,	120*-3^.5*.5*f,
		120*.5*f,	120*-3^.5*.5*f,
		120*1*f,	120*0*f,
	}
	S.scale=f
	S.standard=A

	for i=6,1,-1 do
		B[2*i-1],B[2*i]=B[i]*A[2*i-1],B[i]*A[2*i]
	end
	S.val=B

	if P.result=="WIN"and P.stat.piece>4 then
		local acc=P.stat.finesseRate*.2/P.stat.piece
		S.rank=
			acc==1. and"Z"or
			acc>.97 and"S"or
			acc>.94 and"A"or
			acc>.87 and"B"or
			acc>.70 and"C"or
			acc>.50 and"D"or
			acc>.30 and"E"or
			"F"
		S.fnsRankColor=fnsRankColor[S.rank]
		if acc==1 then
			S.trophy=text.finesse_ap
			S.trophyColor=COLOR.yellow
		elseif P.stat.maxFinesseCombo==P.stat.piece then
			S.trophy=text.finesse_fc
			S.trophyColor=COLOR.lCyan
		end
	end
	if GAME.bg then
		BG.set(GAME.BG)
		GAME.prevBG=nil
	end
end
function sceneBack.pause()
	love.keyboard.setKeyRepeat(true)
	if not GAME.replaying then
		mergeStat(STAT,PLAYERS[1].stat)
	end
	FILE.saveData()
end

function keyDown.pause(key)
	if key=="q"then
		SCN.back()
	elseif key=="escape"then
		resumeGame()
	elseif key=="s"then
		GAME.prevBG=BG.cur
		print(BG.cur)
		SCN.go("setting_sound")
	elseif key=="r"then
		resetGameData()
		SCN.swapTo("play","none")
	elseif key=="p"and(GAME.result or GAME.replaying)and #PLAYERS==1 then
		resetPartGameData(true)
		SCN.swapTo("play","none")
	end
end

function Tmr.pause(dt)
	if not GAME.result then
		GAME.pauseTime=GAME.pauseTime+dt
	end
	if sceneTemp.timer<50 then
		sceneTemp.timer=sceneTemp.timer+1
	end
end

local hexList={1,0,.5,1.732*.5,-.5,1.732*.5}
for i=1,6 do hexList[i]=hexList[i]*150 end
local textPos={90,131,-90,131,-200,-25,-90,-181,90,-181,200,-25}
local dataPos={90,143,-90,143,-200,-13,-90,-169,90,-169,200,-13}
function Pnt.pause()
	local S=sceneTemp
	local T=S.timer*.02
	if T<1 or GAME.result then Pnt.play()end

	--Dark BG
	local _=T
	if GAME.result then _=_*.7 end
	gc.setColor(.15,.15,.15,_)
	gc.push("transform")
		gc.origin()
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
	gc.pop()

	--Pause Info
	setFont(25)
	if GAME.pauseCount>0 then
		gc.setColor(1,.4,.4,T)
		gc.print(text.pauseCount..":["..GAME.pauseCount.."] "..format("%.2f",GAME.pauseTime).."s",40,160)
	end

	gc.setColor(1,1,1,T)

	--Result Text
	setFont(35)
	mText(GAME.result and drawableText[GAME.result]or drawableText.pause,640,50-10*(5-sceneTemp.timer*.1)^1.5)

	--Mode Info
	_=drawableText.modeName
	gc.draw(_,40,200)
	gc.draw(drawableText.levelName,60+_:getWidth(),200)

	--Infos
	if GAME.frame>180 then
		_=S.list
		setFont(26)
		for i=1,10 do
			gc.print(text.pauseStat[i],40,210+40*i)
			gc.printf(_[i],195,210+40*i,300,"right")
		end
	end

	--Level rank
	if GAME.rank>0 then
		local str=text.ranks[GAME.rank]
		setFont(80)

		gc.setColor(0,0,0,T*.3)
		gc.print(str,46,-14,nil,1.8)
		gc.print(str,46,-6,nil,1.8)
		gc.print(str,54,-14,nil,1.8)
		gc.print(str,54,-6,nil,1.8)

		gc.setColor(0,0,0,T*.15)
		gc.print(str,46,-10,nil,1.8)
		gc.print(str,54,-10,nil,1.8)
		gc.print(str,50,-14,nil,1.8)
		gc.print(str,50,-6,nil,1.8)

		local L=rankColor[GAME.rank]
		gc.setColor(L[1],L[2],L[3],T)
		gc.print(str,50,-10,nil,1.8)
	end

	--Finesse rank & trophy
	if S.rank then
		setFont(60)
		gc.setColor(S.fnsRankColor[1],S.fnsRankColor[2],S.fnsRankColor[3],T)
		gc.print(S.rank,420,635)
		if S.trophy then
			setFont(40)
			gc.setColor(S.trophyColor[1],S.trophyColor[2],S.trophyColor[3],T*2-1)
			gc.printf(S.trophy,100-120*(1-T^.5),650,300,"right")
		end
	end

	--Radar Chart
	if T>.5 and GAME.frame>180 then
		T=T*2-1
		gc.setLineWidth(2)
		gc.push("transform")
			gc.translate(1026,400)

			--Polygon
			gc.push("transform")
				gc.scale((3-2*T)*T)
				gc.setColor(1,1,1,T*(.5+.3*sin(Timer()*6.26)))gc.polygon("line",S.standard)
				_=S.color
				gc.setColor(_[1],_[2],_[3],T*.626)
				_=S.val
				for i=1,9,2 do
					gc.polygon("fill",0,0,_[i],_[i+1],_[i+2],_[i+3])
				end
				gc.polygon("fill",0,0,_[11],_[12],_[1],_[2])
				gc.setColor(1,1,1,T)gc.polygon("line",S.val)
			gc.pop()

			--Axes
			gc.setColor(1,1,1,T)
			for i=1,3 do
				local x,y=hexList[2*i-1],hexList[2*i]
				gc.line(-x,-y,x,y)
			end

			--Texts
			local C
			_=Timer()%6.2832
			if _>3.1416 then
				gc.setColor(1,1,1,-T*sin(_))
				setFont(35)
				C,_=text.radar,textPos
			else
				gc.setColor(1,1,1,T*sin(_))
				setFont(18)
				C,_=S.radar,dataPos
			end
			for i=1,6 do
				mStr(C[i],_[2*i-1],_[2*i])
			end
		gc.pop()
	end
end

WIDGET.init("pause",{
	WIDGET.newButton({name="setting",	x=1120,	y=70,	w=240,h=90,	color="lBlue",	font=35,code=WIDGET.lnk.pressKey("s")}),
	WIDGET.newButton({name="replay",	x=640,	y=250,	w=240,h=100,color="lYellow",font=30,code=WIDGET.lnk.pressKey("p"),hide=function()return not(GAME.result or GAME.replaying)or #PLAYERS>1 end}),
	WIDGET.newButton({name="resume",	x=640,	y=367,	w=240,h=100,color="lGreen",	font=30,code=WIDGET.lnk.pressKey("escape")}),
	WIDGET.newButton({name="restart",	x=640,	y=483,	w=240,h=100,color="lRed",	font=35,code=WIDGET.lnk.pressKey("r")}),
	WIDGET.newButton({name="quit",		x=640,	y=600,	w=240,h=100,font=35,code=WIDGET.lnk.BACK}),
})