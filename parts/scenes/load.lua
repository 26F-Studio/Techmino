local gc=love.graphics
local tc=love.touch
local Timer=love.timer.getTime

local max,min,sin=math.max,math.min,math.sin

function sceneInit.load()
	sceneTemp={
		time=0,--Animation timer
		phase=1,--Loading stage
		cur=1,--Loading timer
		tar=#VOC.name,--Current Loading bar length
		list={
			#VOC.name,
			#BGM.list,
			#SFX.list,
			IMG.getCount(),
			17,--Fontsize 20~100
			SKIN.getCount(),
			#MODES,
			1,
			1,
		},
		skip=false,--If skipped

		text=gc.newText(getFont(80),"26F Studio"),
	}
end
function sceneBack.load()
	love.event.quit()
end

function keyDown.load(k)
	if k=="a"then
		sceneTemp.skip=true
	elseif k=="s"then
		sceneTemp.skip,MARKING=true
	elseif k=="space"then
		sceneTemp.time=max(sceneTemp.time-5,0)
	elseif k=="escape"then
		SCN.back()
	end
end
function touchDown.load()
	if #tc.getTouches()==2 then
		sceneTemp.skip=true
	end
end

function Tmr.load()
	local S=sceneTemp
	if S.time==400 then return end
	repeat
		if S.phase==1 then
			VOC.loadOne(S.cur)
		elseif S.phase==2 then
			BGM.loadOne(S.cur)
		elseif S.phase==3 then
			SFX.loadOne(S.cur)
		elseif S.phase==4 then
			IMG.loadOne(S.cur)
		elseif S.phase==5 then
			getFont(15+5*S.cur)
		elseif S.phase==6 then
			SKIN.loadOne(S.cur)
		elseif S.phase==7 then
			local m=MODES[S.cur]--Mode template
			local M=require("modes/"..m.name)--Mode file
			MODES[m.name],MODES[S.cur]=M
			for k,v in next,m do
				M[k]=v
			end
			M.records=FILE.loadRecord(m.name)or M.score and{}
			if M.score then
				if RANKS[M.name]==6 then
					RANKS[M.name]=0
				end
			else
				RANKS[M.name]=6
			end
			-- M.icon=gc.newImage("image/modeIcon/"..m.icon..".png")
			-- M.icon=gc.newImage("image/modeIcon/custom.png")
		elseif S.phase==8 then
			local function C(x,y)
				local _=gc.newCanvas(x,y)
				gc.setCanvas(_)
				return _
			end

			puzzleMark={}
			gc.setLineWidth(3)
			for i=1,17 do
				puzzleMark[i]=C(30,30)
				_=SKIN.libColor[i]
				gc.setColor(_[1],_[2],_[3],.6)
				gc.rectangle("line",5,5,20,20)
				gc.rectangle("line",10,10,10,10)
			end
			for i=18,24 do
				puzzleMark[i]=C(30,30)
				gc.setColor(SKIN.libColor[i])
				gc.rectangle("line",7,7,16,16)
			end
			local _=C(30,30)
			gc.setColor(1,1,1)
			gc.line(5,5,25,25)
			gc.line(5,25,25,5)
			puzzleMark[-1]=C(30,30)
			gc.setColor(1,1,1,.9)
			gc.draw(_)
			_:release()
			gc.setCanvas()
		elseif S.phase==9 then
			SKIN.change(SETTING.skinSet)
			STAT.run=STAT.run+1
			LOADED=true
			SFX.play("welcome_sfx")
			VOC.play("welcome_voc")
			httpRequest(TICK.httpREQ_launch,"api/game")
		end
		if S.tar then
			S.cur=S.cur+1
			if S.cur>S.tar then
				S.phase=S.phase+1
				S.cur=1
				S.tar=S.list[S.phase]
			end
		end
		S.time=S.time+1
		if S.time==400 then
			SCN.swapTo("intro")
			return
		end
	until not S.skip
end

function Pnt.load()
	local S=sceneTemp

	gc.push("transform")
	gc.translate(640,360)
	gc.scale(2)

	local Y=3250*(sin(-1.5708+min(S.time,260)/260*3.1416)+1)+200

	--Draw 26F Studio logo
	if S.time>200 then
		gc.push("transform")
		gc.translate(-220,Y-6840)

		gc.setColor(.4,.4,.4)
		gc.rectangle("fill",0,0,440,260)

		local T=Timer()
		gc.setColor(COLOR.dCyan)
		mDraw(S.text,220,Y*.2-1204)
		mDraw(S.text,220,-Y*.2+1476)

		gc.setColor(COLOR.cyan)
		mDraw(S.text,220+4*sin(T*10),136+4*sin(T*6))
		mDraw(S.text,220+4*sin(T*12),136+4*sin(T*8))

		gc.setColor(COLOR.dCyan)
		mDraw(S.text,219,137)
		mDraw(S.text,219,135)
		mDraw(S.text,221,137)
		mDraw(S.text,221,135)

		gc.setColor(.2,.2,.2)
		mDraw(S.text,220,136)

		gc.pop()
	end

	--Draw floors
	setFont(50)
	gc.setLineWidth(4)
	for i=1,27 do
		if i<26 then
			local r,g,b=COLOR.rainbow(i+3.5)
			gc.setColor(r*.26,g*.26,b*.26)
			gc.rectangle("fill",-220,Y-260*i-80,440,260)
			gc.setColor(r*1.6,g*1.6,b*1.6)
			gc.printf(i.."F",100,Y-260*i-70,100,"right")
			gc.setColor(1,1,1)
			gc.rectangle("line",-160,Y-260*i,80,50)
		end
		gc.line(-220,Y-260*i+180,220,Y-260*i+180)
	end

	--Draw side line
	gc.setColor(1,1,1)
	gc.line(-220,Y-80,-220,Y-6840)
	gc.line(220,Y-80,220,Y-6840)

	gc.pop()
end