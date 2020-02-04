local gc,tm=love.graphics,love.timer
local ms,kb,tc=love.mouse,love.keyboard,love.touch
local wd=love.window
local setFont=setFont
local Timer=tm.getTime

local scr=scr
local xOy=love.math.newTransform()
local focus=true
local mx,my,mouseShow=-20,-20,false
local touching=nil--1st touching ID

local sceneInit={
	load=function()
		loading=1--Loading mode
		loadnum=1--Loading counter
		loadprogress=0--Loading bar(0~1)
		loadTip=text.tips[rnd(#text.tips)]
	end,
	intro=function()
		count=0
		BGM("blank")
	end,
	main=function()
		BGM("blank")
		collectgarbage()
	end,
	music=function()
		sel=1
		BGM()
	end,
	mode=function()
		curBG="none"
		saveData()
		modeSel=modeSel or 1
		levelSel=levelSel or 3
		BGM("blank")
	end,
	custom=function()
		optSel=optSel or 1
		curBG="matrix"
		BGM("blank")
	end,
	draw=function()
		curBG="none"
		kb.setKeyRepeat(true)
		clearSureTime=0
		pen,sx,sy=1,1,1
	end,
	play=function()
		restartCount=0
		if needResetGameData then
			resetGameData()
			needResetGameData=nil
		end
	end,
	pause=function()
	end,
	setting=function()
		curBG="none"
	end,
	setting2=function()
		curBoard=1
		keyboardSet=1
		joystickSet=1
		keyboardSetting=false
		joystickSetting=false
	end,--Control settings
	setting3=function()
		curBG="game1"
		defaultSel=1
		sel=nil
		snapLevel=1
	end,--Touch setting
	help=function()
	end,
	stat=function()
	end,
	quit=function()
		love.event.quit()
	end,
}

BGblockList={}for i=1,16 do BGblockList[i]={v=0}end
local BGblock={tm=150,next=7,ct=0}
local function getNewBlock()
	BGblock.ct=BGblock.ct+1
	if BGblock.ct==17 then BGblock.ct=1 end
	local t=BGblockList[BGblock.ct]
	t.bn,t.size=BGblock.next,2+3*rnd()
	t.b=blocks[t.bn][rnd(0,3)]
	t.x=rnd(-#t.b[1]*t.size*30+100,1180)
	t.y=-#t.b*30*t.size
	t.v=t.size*(1+rnd())
	BGblock.next=BGblock.next%7+1
	return t
end

function onVirtualkey(x,y)
	local d2,nearest,distance
	for K=1,#virtualkey do
		local b=virtualkey[K]
		d2=(x-b[1])^2+(y-b[2])^2
		if d2<b[3]then
			if not nearest or d2<distance then
				nearest,distance=K,d2
			end
		end
	end
	return nearest
end
function buttonControl_key(i)
	if i=="up"or i=="down"or i=="left"or i=="right"then
		if Buttons.sel then
			Buttons.sel=Buttons[scene][Buttons.sel[i]]or Buttons.sel
		else
			Buttons.sel=select(2,next(Buttons[scene]))
		end
	elseif i=="space"or i=="return"then
		if not sceneSwaping and Buttons.sel then
			Buttons.sel.alpha=1
			Buttons.sel.code()
			SFX("button")
			VOICE("nya")
		end
	end
end
function buttonControl_gamepad(i)
	if i=="dpup"or i=="dpdown"or i=="dpleft"or i=="dpright"then
		if Buttons.sel then
			Buttons.sel=Buttons[scene][Buttons.sel[i=="dpup"and"up"or i=="dpdown"and"down"or i=="dpleft"and"left"or"right"]]or Buttons.sel
		else
			Buttons.sel=select(2,next(Buttons[scene]))
		end
	elseif i=="start"then
		if not sceneSwaping and Buttons.sel then
			Buttons.sel.alpha=1
			Buttons.sel.code()
			SFX("button")
			VOICE("nya")
		end
	end
end

mouseDown,mouseMove,mouseUp,wheelmoved={},{},{},{}
touchDown,touchUp,touchMove={},{},{}
keyDown,keyUp={},{}
gamepadDown,gamepadUp={},{}
function mouseDown.intro(x,y,k)
	if k==2 then
		back()
	else
		gotoScene("main")
	end
end
function touchDown.intro(id,x,y)
	gotoScene("main")
end
function keyDown.intro(key)
	if key=="escape"then
		back()
	else
		gotoScene("main")
	end
end
function gamepadDown.intro(key)
	if key=="back"then
		back()
	else
		gotoScene("main")
	end
end

function wheelmoved.mode(x,y)
	modeSel=min(max(modeSel+(y>0 and -1 or 1),1),#modeID)
	levelSel=ceil(#modeLevel[modeID[modeSel]]*.5)
end
function keyDown.mode(key)
	if key=="down"then
		if modeSel<#modeID then
			modeSel=modeSel+1
			levelSel=ceil(#modeLevel[modeID[modeSel]]*.5)
		end
	elseif key=="up"then
		if modeSel>1 then
			modeSel=modeSel-1
			levelSel=ceil(#modeLevel[modeID[modeSel]]*.5)
		end
	elseif key=="left"then
		if levelSel>1 then
			levelSel=levelSel-1
		end
	elseif key=="right"then
		if levelSel<#modeLevel[modeID[modeSel]]then
			levelSel=levelSel+1
		end
	elseif key=="return"then
		loadGame(modeSel,levelSel)
	elseif key=="c"then
		gotoScene("custom")
	elseif key=="escape"then
		back()
	end
end
function gamepadDown.mode(key)
	if key=="dpdown"then
		if modeSel<#modeID then modeSel=modeSel+1 end
	elseif key=="dpup"then
		if modeSel>1 then modeSel=modeSel-1 end
	elseif key=="start"then
		loadGame(modeSel,levelSel)
	elseif key=="back"then
		back()
	end
end

function keyDown.music(key)
	if key=="down"then
		sel=sel%#musicID+1
	elseif key=="up"then
		sel=(sel-2)%#musicID+1
	elseif key=="return"or key=="space"then
		BGM(musicID[sel])
	elseif key=="escape"then
		back()
	end
end

function keyDown.custom(key)
	if key=="left"then
		customSel[optSel]=(customSel[optSel]-2)%#customRange[customID[optSel]]+1
	elseif key=="right"then
		customSel[optSel]=customSel[optSel]%#customRange[customID[optSel]]+1
	elseif key=="down"then
		optSel=optSel%#customID+1
	elseif key=="up"then
		optSel=(optSel-2)%#customID+1
	elseif key=="d"then
		gotoScene("draw")
	elseif key=="return"then
		loadGame(0,1)
	elseif key=="space"then
		loadGame(0,2)
	elseif key=="escape"then
		back()
	end
end

function mouseDown.draw(x,y,k)
	mouseMove.draw(x,y)
end
function mouseMove.draw(x,y,dx,dy)
	sx,sy=int((x-200)/30)+1,20-int((y-60)/30)
	if sx<1 or sx>10 then sx=nil end
	if sy<1 or sy>20 then sy=nil end
	if sx and sy and ms.isDown(1,2,3)then
		preField[sy][sx]=ms.isDown(1)and pen or ms.isDown(2)and 0 or -1
	end
end
function wheelmoved.draw(x,y)
	if y<0 then
		pen=pen+1
		if pen==8 then pen=9 elseif pen==14 then pen=0 end
	else
		pen=pen-1
		if pen==8 then pen=7 elseif pen==-1 then pen=13 end
	end
end
function touchDown.draw(id,x,y)
end
function touchMove.draw(id,x,y,dx,dy)
	sx,sy=int((x-200)/30)+1,20-int((y-60)/30)
	if sx<1 or sx>10 then sx=nil end
	if sy<1 or sy>20 then sy=nil end
	if sx and sy then
		preField[sy][sx]=pen
	end
end
function keyDown.draw(key)
	if key=="delete"then
		Buttons.draw.clear.code()
	elseif key=="up"or key=="down"or key=="left"or key=="right"then
		if not sx then sx=1 end
		if not sy then sy=1 end
		if key=="up"and sy<20 then sy=sy+1
		elseif key=="down"and sy>1 then sy=sy-1
		elseif key=="left"and sx>1 then sx=sx-1
		elseif key=="right"and sx<10 then sx=sx+1
		end
		if kb.isDown("space")then
			preField[sy][sx]=pen
		end
	elseif key=="space"then
		if sx and sy then
			preField[sy][sx]=pen
		end
	elseif key=="tab"then
		pen=-1
	elseif key=="backspace"then
		pen=0
	elseif key=="escape"then
		back()
	else
		pen=find("123qwea#sdzxc",key)or pen
	end
end

function keyDown.setting2(key)
	if key=="escape"then
		if keyboardSetting then
			keyboardSetting=false
		else
			back()
		end
	elseif keyboardSetting then
		for l=1,8 do
			for y=1,13 do
				if setting.keyMap[l][y]==key then
					setting.keyMap[l][y]=""
				end
			end
		end
		setting.keyMap[curBoard][keyboardSet]=key
		keyboardSetting=false
	elseif key=="return"then
		keyboardSetting=true
	elseif key=="up"then
		keyboardSet=max(keyboardSet-1,1)
	elseif key=="down"then
		keyboardSet=min(keyboardSet+1,13)
	elseif key=="left"then
		curBoard=max(curBoard-1,1)
	elseif key=="right"then
		curBoard=min(curBoard+1,8)
	end
end
function gamepadDown.setting2(key)
	if key=="back"then
		if joystickSetting then
			joystickSetting=false
		else
			back()
		end
	elseif joystickSetting then
		for l=9,16 do
			for y=1,12 do
				if setting.keyMap[l][y]==key then
					setting.keyMap[l][y]=""
				end
			end
		end
		setting.keyMap[8+curBoard][joystickSet]=key
		joystickSetting=false
	elseif key=="start"then
		joystickSetting=true
	elseif key=="up"then
		joystickSet=max(joystickSet-1,1)
	elseif key=="down"then
		joystickSet=min(joystickSet+1,12)
	elseif key=="left"then
		curBoard=max(curBoard-1,1)
	elseif key=="right"then
		curBoard=min(curBoard+1,8)
	end
end

function mouseDown.setting3(x,y,k)
	if k==2 then back()end
	for K=1,#virtualkey do
		local b=virtualkey[K]
		if (x-b[1])^2+(y-b[2])^2<b[3]then
			sel=K
		end
	end
end
function mouseMove.setting3(x,y,dx,dy)
	if sel and ms.isDown(1)then
		local b=virtualkey[sel]
		b[1],b[2]=b[1]+dx,b[2]+dy
	end
end
function mouseUp.setting3(x,y,k)
	if sel then
		local b=virtualkey[sel]
		local k=snapLevelValue[snapLevel]
		b[1],b[2]=int(b[1]/k+.5)*k,int(b[2]/k+.5)*k
	end
end
function touchDown.setting3(id,x,y)
	for K=1,#virtualkey do
		local b=virtualkey[K]
		if (x-b[1])^2+(y-b[2])^2<b[3]then
			sel=K
		end
	end
end
function touchUp.setting3(id,x,y)
	if sel then
		x,y=xOy:inverseTransformPoint(x,y)
		if sel then
			local b=virtualkey[sel]
			local k=snapLevelValue[snapLevel]
			b[1],b[2]=int(b[1]/k+.5)*k,int(b[2]/k+.5)*k
		end
	end
end
function touchMove.setting3(id,x,y,dx,dy)
	if sel then
		local b=virtualkey[sel]
		b[1],b[2]=b[1]+dx,b[2]+dy
	end
end

function keyDown.pause(key)
	if key=="escape"then
		back()
	elseif key=="return"or key=="space"then
		resumeGame()
	end
end

function touchDown.play(id,x,y)
	if setting.virtualkeySwitch then
		local t=onVirtualkey(x,y)
		if t then
			pressKey(t,players[1])
		end
	end
end
function touchUp.play(id,x,y)
	if setting.virtualkeySwitch then
		local t=onVirtualkey(x,y)
		if t then
			releaseKey(t,players[1])
		end
	end
end
function touchMove.play(id,x,y,dx,dy)
	if setting.virtualkeySwitch then
		local l=tc.getTouches()
		for n=1,#virtualkey do
			local b=virtualkey[n]
			for i=1,#l do
				local x,y=xOy:inverseTransformPoint(tc.getPosition(l[i]))
				if(x-b[1])^2+(y-b[2])^2<=b[3]then goto L end
			end
			releaseKey(n,players[1])
			::L::
		end
	end
end
function keyDown.play(key)
	if key=="escape"and not sceneSwaping then
		return(frame<180 and back or pauseGame)()
	end
	local m=setting.keyMap
	for p=1,human do
		for k=1,12 do
			if key==m[2*p-1][k]or key==m[2*p][k]then
				pressKey(k,players[p])
				return
			end
		end
	end
end
function keyUp.play(key)
	local m=setting.keyMap
	for p=1,human do
		for k=1,12 do
			if key==m[2*p-1][k]or key==m[2*p][k]then
				releaseKey(k,players[p])
				return
			end
		end
	end
end
function gamepadDown.play(key)
	if key=="back"then back()return end
	local m=setting.keyMap
	for p=1,human do
		for k=1,12 do
			if key==m[2*p+7][k]or key==m[2*p+8][k]then
				pressKey(k,players[p])
				return
			end
		end
	end
end
function gamepadUp.play(key)
	local m=setting.keyMap
	for p=1,human do
		for k=1,12 do
			if key==m[2*p+7][k]or key==m[2*p+8][k]then
				releaseKey(k,players[p])
				return
			end
		end
	end
end




function love.mousepressed(x,y,k,t,num)
	if t then return end
	mouseShow=true
	mx,my=xOy:inverseTransformPoint(x,y)
	if mouseDown[scene]then
		mouseDown[scene](mx,my,k)
	elseif k==2 then
		back()
	end
	if k==1 then
		if not sceneSwaping and Buttons.sel then
			local B=Buttons.sel
			B.code()
			B.alpha=1
			Buttons.sel=nil
			love.mousemoved(x,y,0,0)
			SFX("button")
			VOICE("nya")
			VIB(1)
		end
	end
end
function love.mousemoved(x,y,dx,dy,t)
	if t then return end
	mouseShow=true
	mx,my=xOy:inverseTransformPoint(x,y)
	Buttons.sel=nil
	if mouseMove[scene]then
		mouseMove[scene](mx,my,dx/scr.k,dy/scr.k)
	end
	for _,B in next,Buttons[scene]do
		if not(B.hide and B.hide())then
			if abs(mx-B.x)<B.w*.5 and abs(my-B.y)<B.h*.5 then
				Buttons.sel=B
				return
			end
		end
	end
end
function love.mousereleased(x,y,k,t,num)
	if t then return end
	mx,my=xOy:inverseTransformPoint(x,y)
	if mouseUp[scene]then
		mouseUp[scene](mx,my,k)
	end
end
function love.wheelmoved(x,y)
	if wheelmoved[scene]then wheelmoved[scene](x,y)end
end

function love.touchpressed(id,x,y)
	mouseShow=false
	if not touching then
		touching=id
		love.touchmoved(id,x,y,0,0)
	end
	if touchDown[scene]then
		touchDown[scene](id,xOy:inverseTransformPoint(x,y))
	end
end
function love.touchreleased(id,x,y)
	if id==touching then
		touching=nil
		if Buttons.sel then
			local B=Buttons.sel
			B.code()
			B.alpha=1
			Buttons.sel=nil
			SFX("button")
			VOICE("nya")
			VIB(1)
		end
		Buttons.sel=nil
	end
	if touchUp[scene]then
		touchUp[scene](id,xOy:inverseTransformPoint(x,y))
	end
end
function love.touchmoved(id,x,y,dx,dy)
	x,y=xOy:inverseTransformPoint(x,y)
	if touchMove[scene]then
		touchMove[scene](id,x,y,dx/scr.k,dy/scr.k)
	end
	Buttons.sel=nil
	for _,B in next,Buttons[scene]do
		if not(B.hide and B.hide())then
			if abs(x-B.x)<B.w*.5 and abs(y-B.y)<B.h*.5 then
				Buttons.sel=B
				return
			end
		end
	end
	if not Buttons.sel then
		touching=nil
	end
end

function love.keypressed(i)
	mouseShow=false
	if i=="f8"then devMode=not devMode end
	if devMode then
		if i=="k"then
			P=players.alive[rnd(#players.alive)]
			P.lastRecv=players[1]
			Event.lose()
			--Test code here
		elseif i=="q"then
			local B=Buttons.sel if B then print(format("x=%d,y=%d,w=%d,h=%d",B.x,B.y,B.w,B.h))end
		elseif Buttons.sel then
			local B=Buttons.sel
			if i=="left"then B.x=B.x-10
			elseif i=="right"then B.x=B.x+10
			elseif i=="up"then B.y=B.y-10
			elseif i=="down"then B.y=B.y+10
			elseif i==","then B.w=B.w-10
			elseif i=="."then B.w=B.w+10
			elseif i=="/"then B.h=B.h-10
			elseif i=="'"then B.h=B.h+10
			end
		end
	else
		if keyDown[scene]then keyDown[scene](i)
		elseif i=="escape"or i=="back"then back()
		else buttonControl_key(i)
		end
	end
end
function love.keyreleased(i)
	if keyUp[scene]then keyUp[scene](i)
	end
end

function love.gamepadpressed(joystick,i)
	mouseShow=false
	if gamepadDown[scene]then return gamepadDown[scene](i)
	elseif i=="back"then back()
	else buttonControl_gamepad(i)
	end
end
function love.gamepadreleased(joystick,i)
	if gamepadUp[scene]then gamepadUp[scene](i)
	end
end
--[[
function love.joystickpressed(js,k)end
function love.joystickaxis(js,axis,valend
function love.joystickhat(js,hat,dirend
function love.sendData(data)end
function love.receiveData(id,data)end
]]
function love.lowmemory()
	collectgarbage()
end
function love.resize(w,h)
	scr.w,scr.h,scr.r=w,h,h/w
	if scr.r>=.5625 then
		scr.k=w/1280
		scr.x,scr.y=0,(h-w*9/16)*.5
	else
		scr.k=h/720
		scr.x,scr.y=(w-h*16/9)*.5,0
	end
	gc.origin()
	xOy=xOy:setTransformation(w*.5,h*.5,nil,scr.k,nil,640,360)
	gc.replaceTransform(xOy)
	collectgarbage()
end
function love.focus(f)
	if system~="Android" and not f and scene=="play"then pauseGame()end
end
function love.update(dt)
	-- if players then for k,v in pairs(players[1])do
	-- 	if rawget(_G,k)and k~="next"and k~="hold"and k~="stat"then print(k,_G[v])end
	-- end end--check player data flew(debugging)
	for i=#BGblock,1,-1 do
		BGblock[i].y=BGblock[i].y+BGblock[i].v
		if BGblock[i].y>720 then rem(BGblock,i)end
	end
	if setting.bgblock then
		BGblock.tm=BGblock.tm-1
		if BGblock.tm==0 then
			ins(BGblock,getNewBlock())
			BGblock.tm=rnd(20,30)
		end
	end
	if sceneSwaping then
		sceneSwaping.time=sceneSwaping.time-1
		if sceneSwaping.time==sceneSwaping.mid then
			for k,B in next,Buttons[scene]do
				B.alpha=0
			end--Reset buttons' alpha
			Buttons.sel=nil
			scene=sceneSwaping.tar
			sceneInit[scene]()
		elseif sceneSwaping.time==0 then
			sceneSwaping=nil
		end
	end
	if Tmr[scene]then
		Tmr[scene](dt)
	end
	for i=#Task,1,-1 do
		Task[i]:update()
	end
	if voicePlaying[1]then
		if not voicePlaying[1]:isPlaying()then
			rem(voicePlaying,1)
		end
		if voicePlaying[1] and not voicePlaying[1]:isPlaying()then voicePlaying[1]:play()end
	end
	for k,B in next,Buttons[scene]do
		local t=B==Buttons.sel and .4 or 0
		B.alpha=abs(B.alpha-t)>.02 and(B.alpha+(B.alpha<t and .02 or -.02))or t
		if B.alpha>t then B.alpha=B.alpha-.02 elseif B.alpha<t then B.alpha=B.alpha+.02 end
	end--update Buttons
end
local scs={1,2,1,2,1,2,1,2,1,2,1.5,1.5,.5,2.5}
function love.draw()
	gc.discard()--SPEED UPUPUP!
	Pnt.BG[setting.bg and curBG or"grey"]()
	gc.setColor(1,1,1,.2)
	for n=1,#BGblock do
		local b,img=BGblock[n].b,blockSkin[BGblock[n].bn]
		local size=BGblock[n].size
		for i=1,#b do for j=1,#b[1]do
			if b[i][j]then
				gc.draw(img,BGblock[n].x+(j-1)*30*size,BGblock[n].y+(i-1)*30*size,nil,size)
			end
		end end
	end
	if Pnt[scene]then Pnt[scene]()end
	for k,B in next,Buttons[scene]do
		if not(B.hide and B.hide())then
			local C=B.rgb or color.white
			gc.setColor(C[1],C[2],C[3],B.alpha)
			gc.rectangle("fill",B.x-B.w*.5,B.y-B.h*.5,B.w,B.h)
			gc.setColor(C)
			gc.setLineWidth(3)gc.rectangle("line",B.x-B.w*.5,B.y-B.h*.5,B.w,B.h,4)
			gc.setColor(C[1],C[2],C[3],.3)
			gc.setLineWidth(5)gc.rectangle("line",B.x-B.w*.5,B.y-B.h*.5,B.w,B.h,4)
			local t=B.t
			local y0
			if t then
				if type(t)=="function"then t=t()end
				setFont(B.f or 40)
				y0=B.y-currentFont*.64
				gc.printf(t,B.x-201,y0+2,400,"center")
				gc.printf(t,B.x-199,y0+2,400,"center")
				gc.printf(t,B.x-201,y0,400,"center")
				gc.printf(t,B.x-199,y0,400,"center")
				gc.setColor(C)
				mStr(t,B.x,y0+1)
			end
		end
	end--Draw buttons
	if mouseShow and not touching then
		local r=Timer()*.5
		gc.setColor(1,1,1,min(1-abs(1-r%1*2),.3))
		r=int(r)%7+1
		gc.draw(mouseBlock[r],mx,my,Timer()%3.1416*4,20,20,scs[2*r]-.5,#blocks[r][0]-scs[2*r-1]+.5)
		gc.setColor(1,1,1,.5)gc.circle("fill",mx,my,5)
		gc.setColor(1,1,1)gc.circle("fill",mx,my,3)
	end--Awesome mouse!
	if sceneSwaping then sceneSwaping.draw()end--Swaping animation
	if scr.r~=.5625 then
		gc.setColor(0,0,0)
		if scr.r>.5625 then
			local d=(scr.h-scr.w*9/16)*.5/scr.k
			gc.rectangle("fill",0,0,1280,-d)
			gc.rectangle("fill",0,720,1280,d)
		else--high
			local d=(scr.w-scr.h*16/9)*.5/scr.k
			gc.rectangle("fill",0,0,-d,720)
			gc.rectangle("fill",1280,0,d,720)
		end--wide
	end--Black side
	setFont(20)gc.setColor(1,1,1)
	gc.print(tm.getFPS(),5,700)
	if devMode then
		gc.print(mx.." "..my,5,640)
		gc.print(#freeRow or 0,5,660)
		gc.print(gcinfo(),5,680)
	end
end
function love.run()
	local frameT=Timer()
	local readyDrawFrame=0
	local PUMP,POLL=love.event.pump,love.event.poll
	love.resize(gc.getWidth(),gc.getHeight())
	scene="load"sceneInit.load()--System Launch
	return function()
		PUMP()
		for N,a,b,c,d,e in POLL()do
			if N=="quit"then return 0
			elseif love[N]then love[N](a,b,c,d,e)end
		end
		tm.step()
		love.update(tm.getDelta())
		if not wd.isMinimized()then
			readyDrawFrame=readyDrawFrame+setting.frameMul
			if readyDrawFrame>=100 then
				readyDrawFrame=readyDrawFrame-100
				love.draw()
				gc.present()
			end
		end
		::L::if Timer()-frameT<1/60 then goto L end
		frameT=Timer()
		tm.sleep(.001)
	end
end