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
	BGblock.ct=BGblock.ct-1
	if BGblock.ct==0 then
		ins(BGblock,getNewBlock())
		BGblock.ct=rnd(20,30)
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
	setFont(40)
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

	numFont(20)gc.setColor(1,1,1)
	gc.print(tm.getFPS(),0,700)
	gc.print(gcinfo(),0,680)
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
	tm.step()
	love.resize(nil,gc.getHeight())
	game.load()--System scene Launch
	math.randomseed(os.time()*626)--true  A-lthour's  ID!
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
			gc.clear()
			love.draw()
			gc.present()
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
			tm.sleep(.1)
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