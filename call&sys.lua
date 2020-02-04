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
		curBG="none"
		keeprun=true
		loading=1--Loading mode
		loadnum=1--Loading counter
		loadprogress=0--Loading bar(0~1)
	end,
	intro=function()
		curBG="none"
		count=0
		keeprun=true
	end,
	main=function()
		curBG="none"
		keeprun=true
		collectgarbage()
	end,
	mode=function()
		saveData()
		modeSel=modeSel or 1
		levelSel=levelSel or 3
		curBG="none"
		keeprun=true
	end,
	custom=function()
		optSel=optSel or 1
		curBG="matrix"
		keeprun=true
	end,
	draw=function()
		kb.setKeyRepeat(true)
		clearSureTime=0
		pen=1
		sx,sy=1,1
		curBG="none"
		keeprun=true
	end,
	play=function()
		keeprun=false
		resetGameData()
		sysSFX("ready")
	end,
	setting=function()
		curBG="none"
		keeprun=true
	end,
	setting2=function()
		curBG="none"
		keeprun=true
			curBoard=1
			keyboardSet=1
			joystickSet=1
			keyboardSetting=false
			joystickSetting=false
	end,--Control settings
	setting3=function()
		curBG="game1"
		keeprun=true
		defaultSel=1
		sel=nil
		snapLevel=1
	end,--Touch setting
	help=function()
		curBG="none"
		keeprun=true
	end,
	stat=function()
		curBG="none"
		keeprun=true
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
local scs={{1,2},nil,nil,nil,nil,{1.5,1.5},{0.5,2.5}}for i=2,5 do scs[i]=scs[1]end

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
			mouseShow=false
		end
	elseif i=="space"or i=="return"then
		if not sceneSwaping and Buttons.sel then
			Buttons.sel.alpha=1
			Buttons.sel.code()
			sysSFX("button")
		end
	end
end
function buttonControl_gamepad(i)
	if i=="dpup"or i=="dpdown"or i=="dpleft"or i=="dpright"then
		if Buttons.sel then
			Buttons.sel=Buttons[scene][Buttons.sel[i=="dpup"and"up"or i=="dpdown"and"down"or i=="dpleft"and"left"or"right"]]or Buttons.sel
		else
			Buttons.sel=select(2,next(Buttons[scene]))
			mouseShow=false
		end
	elseif i=="start"then
		if not sceneSwaping and Buttons.sel then
			Buttons.sel.alpha=1
			Buttons.sel.code()
			sysSFX("button")
		end
	end
	mouseShow=false
end

mouseDown={}
function mouseDown.intro(x,y,k)
	if k==2 then
		back()
	else
		gotoScene("main")
	end
end
function mouseDown.draw(x,y,k)
	mouseMove.draw(x,y)
	return sx and sy
end
function mouseDown.setting3(x,y,k)
	if k==2 then back()end
	x,y=xOy:inverseTransformPoint(x,y)
	for K=1,#virtualkey do
		local b=virtualkey[K]
		if (x-b[1])^2+(y-b[2])^2<b[3]then
			sel=K
		end
	end
end
mouseMove={}
function mouseMove.draw(x,y,dx,dy)
	sx,sy=int((x-200)/30)+1,20-int((y-60)/30)
	if sx<1 or sx>10 then sx=nil end
	if sy<1 or sy>20 then sy=nil end
	if sx and sy and ms.isDown(1,2)then
		preField[sy][sx]=ms.isDown(1)and pen or 0
	end
end
function mouseMove.setting3(x,y,dx,dy)
	x,y=xOy:inverseTransformPoint(x,y)
	dx,dy=dx*scr.k,dy*scr.k
	if sel and ms.isDown(1)then
		local b=virtualkey[sel]
		b[1],b[2]=b[1]+dx,b[2]+dy
	end
end
mouseUp={}
function mouseUp.setting3(x,y,k)
	if sel then
		local b=virtualkey[sel]
		local k=snapLevelValue[snapLevel]
		b[1],b[2]=int(b[1]/k+.5)*k,int(b[2]/k+.5)*k
	end
end
wheelmoved={}
function wheelmoved.draw(x,y)
	if y<0 then
		pen=pen+1
		if pen==8 then pen=9 elseif pen==14 then pen=0 end
	else
		pen=pen-1
		if pen==8 then pen=7 elseif pen==-1 then pen=13 end
	end
end
function wheelmoved.mode(x,y)
	modeSel=min(max(modeSel+(y>0 and -1 or 1),1),#modeID)
	levelSel=ceil(#modeLevel[modeID[modeSel]]*.5)
end
touchDown={}
function touchDown.intro(id,x,y)
	gotoScene("main")
end
function touchDown.draw(id,x,y)
end
function touchDown.setting3(id,x,y)
	for K=1,#virtualkey do
		local b=virtualkey[K]
		if (x-b[1])^2+(y-b[2])^2<b[3]then
			sel=K
		end
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
touchUp={}
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
function touchUp.play(id,x,y)
	if setting.virtualkeySwitch then
		local t=onVirtualkey(x,y)
		if t then
			releaseKey(t,players[1])
		end
	end
end
touchMove={}
function touchMove.setting3(id,x,y)
	dx,dy=dx*scr.k,dy*scr.k
	if sel then
		local b=virtualkey[sel]
		b[1],b[2]=b[1]+dx,b[2]+dy
	end
end
function touchMove.play(id,x,y)
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
keyDown={}
function keyDown.intro(key)
	if key=="escape"then
		back()
	else
		gotoScene("main")
	end
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
function keyDown.custom(key)
	if key=="left"then
		local k=customID[optSel]
		customSel[k]=(customSel[k]-2)%#customRange[k]+1
	elseif key=="right"then
		local k=customID[optSel]
		customSel[k]=customSel[k]%#customRange[k]+1
	elseif key=="down"then
		optSel=optSel%#customID+1
	elseif key=="up"then
		optSel=(optSel-2)%#customID+1
	elseif key=="d"then
		gotoScene("draw")
	elseif key=="return"then
		loadGame(0,1)
	elseif key=="escape"then
		back()
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
function keyDown.play(key)
	if key=="escape"then back()end
	local m=setting.keyMap
	for p=1,human do
		local lib=setting.keyLib[p]
		for s=1,#lib do
			for k=1,12 do
				if key==m[lib[s]][k]then
					pressKey(k,players[p])
					return
				end
			end
		end
	end
end
keyUp={}
function keyUp.play(key)
	local m=setting.keyMap
	for p=1,human do
		local lib=setting.keyLib[p]
		for s=1,#lib do
			for k=1,12 do
				if key==m[lib[s]][k]then
					releaseKey(k,players[p])
					return
				end
			end
		end
	end
end
gamepadDown={}
function gamepadDown.intro(key)
	if key=="back"then
		back()
	else
		gotoScene("main")
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
function gamepadDown.play(key)
	if key=="back"then back()return end
	local m=setting.keyMap
	for p=1,4 do
		local lib=setting.keyLib[p]
		for s=1,#lib do
			for k=1,12 do
				if key==m[8+lib[s]][k]then
					pressKey(k,players[p])
					return
				end
			end
		end
	end
end
gamepadUp={}
function gamepadUp.play(key)
	local m=setting.keyMap
	for p=1,4 do
		local lib=setting.keyLib[p]
		for s=1,#lib do
			for k=1,12 do
				if key==m[8+lib[s]][k]then
					releaseKey(k,players[p])
					return
				end
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
			sysSFX("button")
		end
	end
end
function love.mousemoved(x,y,dx,dy,t)
	if t then return end
	mouseShow=true
	mx,my=xOy:inverseTransformPoint(x,y)
	Buttons.sel=nil
	if mouseMove[scene]then
		mouseMove[scene](mx,my,dx,dy)
	end
	for N,B in next,Buttons[scene]do
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
	if not touching then
		touching=id
		love.mousemoved(x,y)
		mouseShow=false
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
			sysSFX("button")
		end
		Buttons.sel=nil
		mouseShow=false
	end
	if touchUp[scene]then
		x,y=
		touchUp[scene](id,xOy:inverseTransformPoint(x,y))
	end
end
function love.touchmoved(id,x,y,dx,dy)
	love.mousemoved(x,y)
	mouseShow=false
	if not Buttons.sel then
		touching=nil
	end
	if touchMove[scene]then
		touchMove[scene](id,xOy:inverseTransformPoint(x,y))
	end
end

function love.keypressed(i)
	if i=="f8"then devMode=not devMode end
	if devMode then
		if i=="k"then
			P=players.alive[rnd(#players.alive)]
			Event_gameover.lose()
			--Test code here
		elseif i=="q"then
			for k,B in next,Buttons[scene]do
				print(format("x=%d,y=%d,w=%d,h=%d",B.x,B.y,B.w,B.h))
			end
		elseif i=="s"then
			print(scr.x,scr.y,scr.w,scr.h,scr.k)
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
	mouseShow=false
end
function love.keyreleased(i)
	if keyUp[scene]then keyUp[scene](i)
	end
end

function love.gamepadpressed(joystick,i)
	if gamepadDown[scene]then return gamepadDown[scene](i)
	elseif i=="back"then back()
	else buttonControl_gamepad(i)
	end
	mouseShow=false
end
function love.gamepadreleased(joystick,i)
	if gamepadUp[scene]then gamepadUp[scene](i)
	end
end
--[[
function love.joystickpressed(js,k)
	
end
function love.joystickaxis(js,axis,val)

end
function love.joystickhat(js,hat,dir)

end

function love.sendData(data)
	return
end
function love.receiveData(id,data)
	return
end
]]

function love.lowmemory()
	collectgarbage()
end
function love.resize(w,h)
	if w>=h then scr.w,scr.h=w,h
	else scr.w,scr.h=h,w
	end
	scr.r=h/w
	if h/w>=.5625 then
		scr.k=w/1280
		scr.x,scr.y=0,(h-w*9/16)*.5
	else
		scr.k=h/720
		scr.x,scr.y=(w-h*16/9)*.5,0
	end
	xOy=xOy:setTransformation(w*.5,h*.5,nil,scr.k,nil,640,360)
	gc.replaceTransform(xOy)
	collectgarbage()
end
function love.update(dt)
	--[[
	if players then
		for k,v in pairs(players[1])do
			if rawget(_G,k)then print(k)end
		end
	end--check player data flew(debugging)
	]]
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
			scene=sceneSwaping.tar
			BGM("blank")
			sceneInit[scene]()
			Buttons.sel=nil
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
	updateButton()
end
function love.draw()
	gc.discard()
	Pnt.BG[curBG]()
	gc.setColor(1,1,1,.22)
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
	drawButton()
	if mouseShow and not touching then
		local r=Timer()*.5
		gc.setColor(1,1,1,min(1-abs(1-r%1*2),.3))
		r=int(r)%7+1
		gc.draw(mouseBlock[r],mx,my,Timer()%pi*4,20,20,scs[r][2]-.5,#blocks[r][0]-scs[r][1]+.5)
		gc.setColor(1,1,1,.5)
		gc.circle("fill",mx,my,5)
		gc.setColor(1,1,1)
		gc.circle("fill",mx,my,3)
	end
	if sceneSwaping then sceneSwaping.draw()end

	if scr.r==.5625 then goto L end
		if scr.r>.5625 then
			gc.setColor(0,0,0)
			gc.rectangle("fill",0,0,1280,scr.w*9/16-scr.h)
			gc.rectangle("fill",0,720,1280,scr.h-scr.w*9/16)
		else
			gc.setColor(0,0,0)
			gc.rectangle("fill",0,0,scr.h*16/9-scr.w,720)
			gc.rectangle("fill",1280,0,scr.w-scr.h*16/9,720)
		end
	::L::
	setFont(20)gc.setColor(1,1,1)
	gc.print(tm.getFPS(),5,700)
	if devMode then
		gc.print(gcinfo(),5,680)
		gc.print(#freeRow or 0,5,660)
	end
end
function love.run()
	local frameT=Timer()
	local readyDrawFrame=0
	love.resize(gc.getWidth(),gc.getHeight())
	scene="load"sceneInit.load()--System Launch
	math.randomseed(os.time()*626)
	return function()
		love.event.pump()
		for name,a,b,c,d,e,f in love.event.poll()do
			if name=="quit"then return 0 end
			love.handlers[name](a,b,c,d,e,f)
		end
		if focus then
			tm.step()
			-- love.receiveData(id,data)
			love.update(tm.getDelta())
			readyDrawFrame=readyDrawFrame+setting.frameMul
			if readyDrawFrame>=100 then
				readyDrawFrame=readyDrawFrame-100
				gc.clear()
				love.draw()
				gc.present()
			end
			if not(wd.hasFocus()or keeprun)then
				focus=false
				ms.setVisible(true)
				if bgmPlaying then bgm[bgmPlaying]:pause()end
				if scene=="play"then
					for i=1,#players.alive do
						local l=players.alive[i].keyPressing
						for j=1,#l do
							if l[j]then
								releaseKey(j,players.alive[i])
							end
						end
					end
				end
			end
		else
			tm.sleep(.5)
			if wd.hasFocus()then
				tm.step()
				focus=true
				ms.setVisible(false)
				if bgmPlaying then bgm[bgmPlaying]:play()end
			end
		end
		::L::if Timer()-frameT<1/60 then goto L end
		frameT=Timer()
	end
end