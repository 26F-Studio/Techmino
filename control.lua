function love.mousemoved(x,y)
	x,y=mouseConvert(x,y)
	mx,my=x,y
	Buttons.sel=nil
	for i=1,#Buttons[scene]do
		local B=Buttons[scene][i]
		if not(B.hide and B.hide())then
			if abs(x-B.x)<B.w*.5 and abs(y-B.y)<B.h*.5 then
				Buttons.sel=B
				return nil
			end
		end
	end
	if not Buttons.sel then Buttons.pressing=0 end
end
function love.mousepressed(x,y,k)
	x,y=mouseConvert(x,y)
	if mouseDown[scene]then mouseDown[scene](x,y,k)end
	if k==1 then
		if not sceneSwaping and Buttons.sel then
			local B=Buttons.sel
			if B.hold then Buttons.pressing=max(Buttons.pressing,1)end
			B.code()
			B.alpha=1
			Buttons.sel=nil
			love.mousemoved(mx,my)
			SFX("button")
		end
	elseif k==3 then
		back()
	end
end
function love.mousereleased(x,y,k)
	Buttons.pressing=0
end
--[[
function love.touchpressed(id,x,y)
	local i=love.touch.getTouches
	if #i==1 then
		love.mousemoved(x,y)
	end
end
function love.touchrealeased(id,x,y)
	love.mousepressed(x,y,1)
end]]
function love.keypressed(i)
	if keyDown[scene]then keyDown[scene](i)
	elseif i=="escape"then back()
	end
end
function love.keyreleased(i)
	if keyUp[scene]then keyUp[scene](i)
	end
end
function love.wheelmoved(x,y)
	if wheelmoved[scene]then wheelmoved[scene](x,y)end
end