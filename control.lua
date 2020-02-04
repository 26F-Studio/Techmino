function love.mousemoved(x,y)
	mx,my=mouseConvert(x,y)
	Buttons.sel=nil
	for i=1,#Buttons[scene]do
		local B=Buttons[scene][i]
		if not(B.hide and B.hide())then
			if abs(mx-B.x)<B.w*.5 and abs(my-B.y)<B.h*.5 then
				Buttons.sel=B
				return nil
			end
		end
	end
	if not Buttons.sel then Buttons.pressing=0 end
end
function love.mousepressed(x,y,k)
	mx,my=mouseConvert(x,y)
	if mouseDown[scene]then mouseDown[scene](mx,my,k)end
	if k==1 then
		if not sceneSwaping and Buttons.sel then
			local B=Buttons.sel
			if B.hold then Buttons.pressing=max(Buttons.pressing,1)end
			B.code()
			B.alpha=1
			Buttons.sel=nil
			love.mousemoved(x,y)
			SFX("button")
		end
	elseif k==3 then
		back()
	end
end
function love.mousereleased(x,y,k)
	Buttons.pressing=0
end

function love.touchpressed(id,x,y)
	ins(touches,id)
end
function love.touchrealeased(id,x,y)
	for i=1,#touches do
		if touches[i]==id then rem(touches,i)break end
	end
end
function love.touchmoved(id,x,y,dx,dy)
end

function love.keypressed(i)
	--[[
	if Buttons.sel then
		local b=Buttons.sel
		if i=="up"then b.y=b.y-10
		elseif i=="down"then b.y=b.y+10
		elseif i=="left"then b.x=b.x-10
		elseif i=="right"then b.x=b.x+10
		elseif i=="k"then b.w=b.w-10
		elseif i=="l"then b.w=b.w+10
		elseif i==","then b.h=b.h-10
		elseif i=="."then b.h=b.h+10
		elseif i=="s"then
			print("")
			for i=1,#Buttons[scene]do
				local b=Buttons[scene][i]
				print(b.t,b.x,b.y,b.w,b.h)
			end
		end
	end]]
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