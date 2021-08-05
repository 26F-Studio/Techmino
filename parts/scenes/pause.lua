local gc=love.graphics
local sin,log=math.sin,math.log10

local GAME,SCR=GAME,SCR
local setFont,mStr=setFont,mStr

local fnsRankColor={
	Z=COLOR.lY,
	S=COLOR.lH,
	A=COLOR.N,
	B=COLOR.lG,
	C=COLOR.M,
	D=COLOR.dG,
	E=COLOR.R,
	F=COLOR.dR,
}

local scene={}

local timer--Animation timer
local form--Form of clear & spins
local radar--Radar chart
local val--Radar chart normalizer
local standard--Standard hexagon
local chartColor--Color of radar chart
local rank--Current rank
local trophy--Current trophy
local trophyColor--Current trophy color

function scene.sceneInit(org)
	if org:find("setting")then
		TEXT.show(text.needRestart,640,410,50,'fly',.6)
	end
	local P=PLAYERS[1]
	local S=P.stat

	timer=org=='game'and 0 or 50

	local frameLostRate=(S.frame/S.time/60-1)*100
	form={
		{COLOR.Z,STRING.time(S.time),COLOR[frameLostRate>10 and'R'or frameLostRate>3 and'Y'or'H'],(" (%.2f%%)"):format(frameLostRate)},
		("%d/%d/%d"):format(S.key,S.rotate,S.hold),
		("%d  %.2fPPS"):format(S.piece,S.piece/S.time),
		("%d(%d)  %.2fLPM"):format(S.row,S.dig,S.row/S.time*60),
		("%d(%d)  %.2fAPM"):format(S.atk,S.digatk,S.atk/S.time*60),
		("%d(%d-%d)"):format(S.pend,S.recv,S.recv-S.pend),
		("%d/%d/%d/%d"):format(S.clears[1],S.clears[2],S.clears[3],S.clears[4]),
		("(%d)/%d/%d/%d"):format(S.spins[1],S.spins[2],S.spins[3],S.spins[4]),
		("%d/%d ; %d/%d"):format(S.b2b,S.b3b,S.pc,S.hpc),
		("%d/%dx/%.2f%%"):format(S.extraPiece,S.maxFinesseCombo,S.finesseRate*20/S.piece),
	}
	--From right-down, 60 degree each
	radar={
		(S.off+S.dig)/S.time*60,--DefPM
		(S.atk+S.dig)/S.time*60,--ADPM
		S.atk/S.time*60,		--AtkPM
		S.send/S.time*60,		--SendPM
		S.piece/S.time*24,		--LinePM
		S.dig/S.time*60,		--DigPM
	}
	val={1/80,1/80,1/80,1/60,1/100,1/40}

	--Normalize Values
	for i=1,6 do
		val[i]=val[i]*radar[i]if val[i]>1.26 then val[i]=1.26+log(val[i]-.26)end
	end

	for i=1,6 do
		radar[i]=("%.2f%s"):format(radar[i],text.radarData[i])
	end
	local f=1
	for i=1,6 do
		if val[i]>.5 then f=2 end
		if val[i]>1 then f=3 break end
	end
	if f==1 then	 chartColor,f={.4,.9,.5},1.25	--Vegetable
	elseif f==2 then chartColor,f={.4,.7,.9},1		--Normal
	elseif f==3 then chartColor,f={1,.3,.3},.626	--Diao
	end
	standard={
		120*.5*f,	120*3^.5*.5*f,
		120*-.5*f,	120*3^.5*.5*f,
		120*-1*f,	120*0*f,
		120*-.5*f,	120*-3^.5*.5*f,
		120*.5*f,	120*-3^.5*.5*f,
		120*1*f,	120*0*f,
	}

	for i=6,1,-1 do
		val[2*i-1],val[2*i]=val[i]*standard[2*i-1],val[i]*standard[2*i]
	end

	if P.result=='win'and P.stat.piece>4 then
		local acc=P.stat.finesseRate*.2/P.stat.piece
		rank=
			acc==1. and"Z"or
			acc>.97 and"S"or
			acc>.94 and"A"or
			acc>.87 and"B"or
			acc>.70 and"C"or
			acc>.50 and"D"or
			acc>.30 and"E"or
			"F"
		if acc==1 then
			trophy=text.finesse_ap
			trophyColor=COLOR.Y
		elseif P.stat.maxFinesseCombo==P.stat.piece then
			trophy=text.finesse_fc
			trophyColor=COLOR.lC
		else
			trophy=nil
		end
	else
		rank,trophy=nil
	end
	if GAME.prevBG then
		BG.set(GAME.prevBG)
		GAME.prevBG=false
	end
end
function scene.sceneBack()
	trySave()
end

function scene.keyDown(key,isRep)
	if isRep then return end
	if key=="q"then
		SCN.back()
	elseif key=="escape"then
		SCN.swapTo(GAME.result and'game'or'depause','none')
	elseif key=="s"then
		if not GAME.fromRepMenu then
			GAME.prevBG=BG.cur
			SCN.go('setting_sound')
		end
	elseif key=="r"then
		if not GAME.fromRepMenu then
			resetGameData()
			SCN.swapTo('game','none')
		end
	elseif key=="p"then
		if(GAME.result or GAME.replaying)and #PLAYERS==1 then
			resetGameData('r')
			SCN.swapTo('game','none')
		end
	elseif key=="o"then
		if(GAME.result or GAME.replaying)and #PLAYERS==1 and not GAME.saved then
			if DATA.saveReplay()then
				GAME.saved=true
				SFX.play('connected')
			end
		end
	else
		WIDGET.keyPressed(key)
	end
end

function scene.update(dt)
	if not(GAME.result or GAME.replaying)then
		GAME.pauseTime=GAME.pauseTime+dt
	end
	if timer<50 then
		timer=timer+1
	end
end

local hexList={1,0,.5,1.732*.5,-.5,1.732*.5}
for i=1,6 do hexList[i]=hexList[i]*150 end
local textPos={90,131,-90,131,-200,-25,-90,-181,90,-181,200,-25}
local dataPos={90,143,-90,143,-200,-13,-90,-169,90,-169,200,-13}
function scene.draw()
	local T=timer*.02
	if T<1 or GAME.result then SCN.scenes.game.draw()end

	--Dark BG
	local _=T
	if GAME.result then _=_*.76 end
	gc.setColor(.15,.15,.15,_)
	gc.replaceTransform(SCR.origin)
	gc.rectangle('fill',0,0,SCR.w,SCR.h)
	gc.replaceTransform(SCR.xOy)

	--Pause Info
	setFont(25)
	if GAME.pauseCount>0 then
		gc.setColor(.96,.92,.92,T)
		mStr(("%s:[%d] %.2fs"):format(text.pauseCount,GAME.pauseCount,GAME.pauseTime),640,510)
	end

	gc.setColor(.97,.97,.97,T)

	--Result Text
	setFont(35)
	mDraw(GAME.result and drawableText[GAME.result]or drawableText.pause,640,90-10*(5-timer*.1)^1.5)

	--Mode Info
	mDraw(drawableText.modeName,640,180)

	--Level rank
	if GAME.rank>0 then
		gc.push('transform')
			gc.translate(1090,50)
			local str=text.ranks[GAME.rank]
			setFont(80)
			gc.setColor(0,0,0,T*.7)
			gc.print(str,-5,-4,nil,1.5)
			local L=rankColor[GAME.rank]
			gc.setColor(L[1],L[2],L[3],T)
			gc.print(str,0,0,nil,1.5)
		gc.pop()
	end

	--Infos
	if PLAYERS[1].frameRun>180 then
		gc.push('transform')
			gc.translate(830,220)
			gc.scale(.85)
			gc.setLineWidth(2)

			--Frame
			gc.setColor(.97,.97,.97,T*.05)
			gc.rectangle('fill',-5,-5,475,360,8)
			gc.setColor(.97,.97,.97,T)
			gc.rectangle('line',-5,-5,475,360,8)

			--Stats
			_=form
			setFont(25)
			for i=1,10 do
				gc.print(text.pauseStat[i],5,35*(i-1))
				gc.printf(_[i],160,35*(i-1),300,'right')
			end

			--Finesse rank & trophy
			if rank then
				setFont(40)
				local c=fnsRankColor[rank]
				gc.setColor(c[1],c[2],c[3],T)
				gc.print(rank,440,344)
				if trophy then
					setFont(20)
					gc.setColor(trophyColor[1],trophyColor[2],trophyColor[3],T*2-1)
					gc.printf(trophy,130-120*(1-T^.5),359,300,'right')
				end
			end
		gc.pop()
	end

	--Radar Chart
	if T>.5 and PLAYERS[1].frameRun>180 then
		local t=T*2-1
		gc.setLineWidth(2)
		gc.push('transform')
			gc.translate(640,390)
			gc.scale(.67)

			--Polygon
			gc.push('transform')
				gc.scale((3-2*t)*t)
				gc.setColor(.97,.97,.97,t*(.5+.3*sin(TIME()*6.26)))gc.polygon('line',standard)
				gc.setColor(chartColor[1],chartColor[2],chartColor[3],t*.626)
				for i=1,9,2 do
					gc.polygon('fill',0,0,val[i],val[i+1],val[i+2],val[i+3])
				end
				gc.polygon('fill',0,0,val[11],val[12],val[1],val[2])
				gc.setColor(.97,.97,.97,t)gc.polygon('line',val)
			gc.pop()

			--Axes
			gc.setColor(.97,.97,.97,t)
			for i=1,3 do
				local x,y=hexList[2*i-1],hexList[2*i]
				gc.line(-x,-y,x,y)
			end

			--Texts
			local C
			_=TIME()%6.2832
			if _>3.1416 then
				gc.setColor(.97,.97,.97,-t*sin(_))
				setFont(35)
				C,_=text.radar,textPos
			else
				gc.setColor(.97,.97,.97,t*sin(_))
				setFont(20)
				C,_=radar,dataPos
			end
			for i=1,6 do
				mStr(C[i],_[2*i-1],_[2*i])
			end
		gc.pop()
	end

	--Mods
	gc.push('transform')
		gc.translate(735,555)
		gc.scale()
		if #GAME.mod>0 then
			gc.setLineWidth(2)
			if scoreValid()then
				gc.setColor(.7,.7,.7,T)
				gc.rectangle('line',-5,-5,500,150,8)
				gc.setColor(.7,.7,.7,T*.04)
				gc.rectangle('fill',-5,-5,500,150,8)
			else
				gc.setColor(.95,0,0,T)
				gc.rectangle('line',-5,-5,500,150,8)
				gc.setColor(.95,0,0,T*.26)
				gc.rectangle('fill',-5,-5,500,150,8)
			end
			setFont(35)
			for _,M in next,MODOPT do
				if M.sel>0 then
					_=M.color
					gc.setColor(_[1],_[2],_[3],T)
					mStr(M.id,35+M.no%8*60,math.floor(M.no/8)*45)
				end
			end
		end
	gc.pop()
end

scene.widgetList={
	WIDGET.newKey{name="resume",	x=290,y=240,w=300,h=70,code=pressKey"escape"},
	WIDGET.newKey{name="restart",	x=290,y=340,w=300,h=70,code=pressKey"r",hideF=function()return GAME.fromRepMenu end},
	WIDGET.newKey{name="setting",	x=290,y=440,w=300,h=70,code=pressKey"s",hideF=function()return GAME.fromRepMenu end},
	WIDGET.newKey{name="quit",		x=290,y=540,w=300,h=70,code=backScene},
	WIDGET.newKey{name="replay",	x=0,y=0,w=50,h=50,code=pressKey"p",hideF=function()return not(GAME.result or GAME.replaying)or #PLAYERS>1 end},
	WIDGET.newKey{name="save",		x=0,y=0,w=50,h=50,code=pressKey"o",hideF=function()return not(GAME.result or GAME.replaying)or #PLAYERS>1 or GAME.saved end},
}

return scene