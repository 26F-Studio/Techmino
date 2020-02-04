function onVirtualkey(x,y)
	local x,y=convert(x,y)
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
		if not Buttons.sel then
			Buttons.sel=1
		else
			Buttons.sel=Buttons[scene][Buttons.sel][i]or Buttons.sel
		end
	elseif i=="space"or i=="return"then
		if not sceneSwaping and Buttons.sel then
			local B=Buttons[scene][Buttons.sel]
			B.code()
			B.alpha=1
			sysSFX("button")
		end
	end
	mouseShow=false
end
function buttonControl_gamepad(i)
	if i=="dpup"or i=="dpdown"or i=="dpleft"or i=="dpright"then
		if not Buttons.sel then
			Buttons.sel=1
			mouseShow=false
		else
			Buttons.sel=Buttons[scene][Buttons.sel][i=="dpup"and"up"or i=="dpdown"and"down"or i=="dpleft"and"left"or"right"]or Buttons.sel
		end
	elseif i=="start"then
		if not sceneSwaping and Buttons.sel then
			local B=Buttons[scene][Buttons.sel]
			B.code()
			B.alpha=1
			sysSFX("button")
		end
	end
	mouseShow=false
end

mouseDown={}
keyDown={}
function keyDown.mode(key)
	if key=="down"then
		if modeSel<#modeID then modeSel=modeSel+1 end
	elseif key=="up"then
		if modeSel>1 then modeSel=modeSel-1 end
	elseif key=="return"then
		startGame(modeID[modeSel])
	elseif key=="escape"then
		back()
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
			for y=1,12 do
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
		keyboardSet=min(keyboardSet+1,12)
	elseif key=="left"then
		curBoard=max(curBoard-1,1)
	elseif key=="right"then
		curBoard=min(curBoard+1,8)
	end
end
function keyDown.play(key)
	if key=="escape"then back()return nil end
	local m=setting.keyMap
	for p=1,4 do
		local lib=setting.keyLib[p]
		for s=1,#lib do
			for k=1,12 do
				if key==m[lib[s]][k]then
					pressKey(k,players[p])
					return nil
				end
			end
		end
	end
end
keyUp={}
function keyUp.play(key)
	local m=setting.keyMap
	for p=1,4 do
		local lib=setting.keyLib[p]
		for s=1,#lib do
			for k=1,12 do
				if key==m[lib[s]][k]then
					releaseKey(k,players[p])
					return nil
				end
			end
		end
	end
end
gamepadDown={}
function gamepadDown.mode(key)
	if key=="dpdown"then
		if modeSel<#modeID then modeSel=modeSel+1 end
	elseif key=="dpup"then
		if modeSel>1 then modeSel=modeSel-1 end
	elseif key=="start"then
		startGame(modeID[modeSel])
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
	if key=="back"then back()return nil end
	local m=setting.keyMap
	for p=1,4 do
		local lib=setting.keyLib[p]
		for s=1,#l[p]do
			for k=1,12 do
				if key==m[8+lib[s]][k]then
					pressKey(k)
					return nil
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
		for s=1,#l[p]do
			for k=1,12 do
				if key==m[8+lib[s]][k]then
					pressKey(k)
					return nil
				end
			end
		end
	end
end
wheelmoved={}
function wheelmoved.mode(x,y)
	modeSel=min(max(modeSel-sgn(y),1),#modeID)
end
--Warning,these are not system callbacks!


function love.mousemoved(x,y,dx,dy,t)
	if not t then
		mouseShow=true
		mx,my=convert(x,y)
		Buttons.sel=nil
		for i=1,#Buttons[scene]do
			local B=Buttons[scene][i]
			if not(B.hide and B.hide())then
				if abs(mx-B.x)<B.w*.5 and abs(my-B.y)<B.h*.5 then
					Buttons.sel=i
					return nil
				end
			end
		end
	end
end
function love.mousepressed(x,y,k,t,num)
	if not t then
		mouseShow=true
		mx,my=convert(x,y)
		if mouseDown[scene]then mouseDown[scene](mx,my,k)end
		if k==1 then
			if not sceneSwaping and Buttons.sel then
				local B=Buttons[scene][Buttons.sel]
				B.code()
				B.alpha=1
				Buttons.sel=nil
				love.mousemoved(x,y)
				sysSFX("button")
			end
		elseif k==3 then
			back()
		end
	end
end
function love.mousereleased(x,y,k,t,num)
end
function love.touchpressed(id,x,y)
	if not touching then
		touching=id
		love.mousemoved(x,y)
		mouseShow=false
	end
	if scene=="play"and setting.virtualkeySwitch then
		local t=onVirtualkey(x,y)
		if t then
			pressKey(t)
		end
	elseif scene=="setting3"then
		x,y=convert(x,y)
		for K=1,#virtualkey do
			local b=virtualkey[K]
			if (x-b[1])^2+(y-b[2])^2<b[3]then
				sel=K
			end
		end
	end
end
function love.touchreleased(id,x,y)
	if id==touching then
		touching=nil
		if Buttons.sel then
			local B=Buttons[scene][Buttons.sel]
			B.code()
			B.alpha=1
			Buttons.sel=nil
		end
		Buttons.sel=nil
		mouseShow=false
	end
	if scene=="play"and setting.virtualkeySwitch then
		local t=onVirtualkey(x,y)
		if t then
			releaseKey(t)
		end
	elseif scene=="setting3"and sel then
		x,y=convert(x,y)
		if sel then
			local b=virtualkey[sel]
			local k=snapLevelValue[snapLevel]
			b[1],b[2]=int(b[1]/k+.5)*k,int(b[2]/k+.5)*k
		end
	end
end
function love.touchmoved(id,x,y,dx,dy)
	love.mousemoved(x,y)
	mouseShow=false
	if not Buttons.sel then
		touching=nil
	end
	if scene=="play"and setting.virtualkeySwitch then
		local l=tc.getTouches()
		for n=1,#virtualkey do
			local b=virtualkey[n]
			local p=false
			for i=1,#l do
				local x,y=convert(tc.getPosition(l[i]))
				if(x-b[1])^2+(y-b[2])^2<=b[3]then
					p=true
					break
				end
			end
			if not p and players[1].keyPressing then
				releaseKey(n)
			end
		end
	elseif scene=="setting3"then
		x,y=convert(x,y)
		dx,dy=dx*screenK,dy*screenK
		if sel then
			local b=virtualkey[sel]
			b[1],b[2]=b[1]+dx,b[2]+dy
		end
	end
end

function love.keypressed(i)
	if keyDown[scene]then keyDown[scene](i)
	elseif i=="escape"or i=="back"then back()
	else buttonControl_key(i)
	end

	if i=="f12"then devMode=true end
end
function love.keyreleased(i)
	if keyUp[scene]then keyUp[scene](i)
	end
end

function love.gamepadpressed(joystick,i)
	if gamepadDown[scene]then return gamepadDown[scene](i)
	elseif i=="back"then return back()
	else buttonControl_gamepad(i)
	end
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
]]
function love.wheelmoved(x,y)
	if wheelmoved[scene]then wheelmoved[scene](x,y)end
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
		BGblock.ct=BGblock.ct-1
		if BGblock.ct==0 then
			ins(BGblock,getNewBlock())
			BGblock.ct=rnd(20,30)
		end
	end
	--Background blocks update

	if sceneSwaping then
		sceneSwaping.time=sceneSwaping.time-1
		if sceneSwaping.time==sceneSwaping.mid then
			for i=1,#Buttons[scene]do
				Buttons[scene][i].alpha=0
			end--Reset buttons' state
			game[sceneSwaping.tar]()
			Buttons.sel=nil
		elseif sceneSwaping.time==0 then
			sceneSwaping=nil
		end
	elseif Tmr[scene]then
		Tmr[scene](dt)
	end
	--scene swapping & Timer
end
function love.sendData(data)
	return nil
end
function love.receiveData(id,data)
	return nil
end
function love.draw()
	Pnt.BG[curBG]()
	gc.setColor(1,1,1,.3)
	for n=1,#BGblock do
		local b,img=BGblock[n].b,blockSkin[BGblock[n].bn]
		local size=BGblock[n].size
		for i=1,#b do for j=1,#b[1]do
			if b[i][j]>0 then
				gc.draw(img,BGblock[n].x+(j-1)*30*size,BGblock[n].y+(i-1)*30*size,nil,size)
			end
		end end--Block
	end
	if Pnt[scene]then Pnt[scene]()end
	drawButton()
	if mouseShow and not touching then
		gc.setColor(1,1,1)
		gc.draw(mouseIcon,mx,my,nil,nil,nil,10,10)
	end
	if sceneSwaping then sceneSwaping.draw()end

	gc.setColor(0,0,0)
	if screenM>0 then
		gc.rectangle("fill",0,0,1280,-screenM)
		gc.rectangle("fill",0,720,1280,screenM)
	end--Draw black side

	setFont(20)gc.setColor(1,1,1)
	gc.print(tm.getFPS(),0,700)
	if devMode then
		gc.print(gcinfo(),0,680)
		gc.print(freeRow and #freeRow or 0,0,660)
	end
	--if gcinfo()>500 then collectgarbage()end
end
function love.resize(x,y)
	screenK=1280/gc.getWidth()
	screenM=(gc.getHeight()*16/9-gc.getWidth())/2
	gc.origin()
	gc.scale(1/screenK,1/screenK)
	gc.translate(0,screenM)
end
function love.run()
	local frameT=Timer()
	local readyDrawFrame=0
	tm.step()
	love.resize(nil,gc.getHeight())
	game.load()--System scene Launch
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
			if not wd.hasFocus()then
				focus=false
				ms.setVisible(true)
				if bgmPlaying then bgm[bgmPlaying]:pause()end
				if scene=="play"then
					for i=1,#players[1].keyPressing do
						if players[1].keyPressing[i]then
							releaseKey(i)
						end
					end
				end
			end
		else
			tm.sleep(.2)
			if wd.hasFocus()then
				focus=true
				ms.setVisible(false)
				if bgmPlaying then bgm[bgmPlaying]:play()end
			end
		end
		while Timer()-frameT<1/60 do end
		frameT=Timer()
	end
end