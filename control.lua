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
		for K=1,#virtualkey do
			local b=virtualkey[K]
			if (x-b[1])^2+(y-b[2])^2<b[3]then
				b[1],b[2]=b[1]+dx,b[2]+dy
			end
		end
	end
end

function love.keypressed(i)
	if keyDown[scene]then keyDown[scene](i)
	elseif i=="escape"or i=="back"then back()
	else buttonControl_key(i)
	end
end
function love.keyreleased(i)
	if keyUp[scene]then keyUp[scene](i)
	end
end

function love.gamepadpressed(joystick,i)
	if scene~="play"or scene=="setting2"and not gamepadsetting then
		if i=="dpup"or i=="dpdown"or i=="dpleft"or i=="dpright"then
			if not Buttons.sel then
				Buttons.sel=1
				mouseShow=false
			else
				Buttons.sel=Buttons[scene][Buttons.sel][i]or Buttons.sel
			end
		elseif i=="start"then
			if not sceneSwaping and Buttons.sel then
				local B=Buttons[scene][Buttons.sel]
				B.code()
				B.alpha=1
				sysSFX("button")
			end
		end
	end
	if gamepadDown[scene]then return gamepadDown[scene](i)
	elseif i=="back"then return back()
	else buttonControl_gamepad(i)
	end
end
function love.gamepadreleased(joystick,i)
	if gamepadUp[scene]then gamepadUp[scene](i)
	end
end

function love.wheelmoved(x,y)
	if wheelmoved[scene]then wheelmoved[scene](x,y)end
end