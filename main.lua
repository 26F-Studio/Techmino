--[[
第一次搞这么大的工程~参考价值不是很大
如果你有时间并且也热爱俄罗斯方块的话，来看代码或者帮助优化的话当然欢迎！
(顺便，无授权直接盗代码的先死个妈)
]]
local love=love
local ms,kb,tc=love.mouse,love.keyboard,love.touch
local gc,sys=love.graphics,love.system
local Timer=love.timer.getTime
local int,rnd,max,min=math.floor,math.random,math.max,math.min
local rem=table.remove
NULL=function()end
-------------------------------------------------------------
system=sys.getOS()
local xOy=love.math.newTransform()
local mx,my,mouseShow=-20,-20,false
local touching--第一触摸ID

local devMode=0
modeSel,levelSel=1,3--初始模式选择
players={alive={},human=0}
scr={x=0,y=0,w=gc.getWidth(),h=gc.getHeight(),k=1}
local scr=scr
curBG="none"
bgmPlaying=nil
voiceQueue={free=0}
virtualkeyDown,virtualkeyPressTime={},{}
for i=1,20 do
	virtualkeyDown[i]=X
	virtualkeyPressTime[i]=0
end

kb.setKeyRepeat(true)
kb.setTextInput(false)
ms.setVisible(false)
--Application Vars
-------------------------------------------------------------
local Fonts={}
function setFont(s)
	if s~=currentFont then
		if Fonts[s]then
			gc.setFont(Fonts[s])
		else
			local t=gc.setNewFont("font.ttf",s-5)
			Fonts[s]=t
			gc.setFont(t)
		end
		currentFont=s
	end
	return Fonts[s]
end
customSel={22,22,1,1,7,3,1,1,8,4,1,1,1}
preField={h=20}
for i=1,10 do preField[i]={-1,-1,-1,-1,-1,-1,-1,-1,-1,-1}end
for i=11,20 do preField[i]={0,0,0,0,0,0,0,0,0,0}end
freeRow={L=40}for i=1,40 do freeRow[i]={0,0,0,0,0,0,0,0,0,0}end
--Game system Vars
-------------------------------------------------------------
scene=require("scene")
require("default_data")
require("class")
require("ai")
require("toolfunc")
require("list")
require("dataList")
require("texture")
require("light")
local Tmr=require("timer")
local Pnt=require("paint")
require("player")
--Modules
-------------------------------------------------------------
local powerInfoCanvas,updatePowerInfo
if sys.getPowerInfo()~="unknown"then
	powerInfoCanvas=gc.newCanvas(147,22)
	updatePowerInfo=function()
		local state,pow=sys.getPowerInfo()
		if state~="unknown"then
			gc.setCanvas(powerInfoCanvas)gc.push("transform")gc.origin()
			gc.clear(0,0,0,.3)
			gc.setLineWidth(4)
			setFont(25)
			local charging
			if state~="battery"then
				gc.setColor(1,1,1)
				if state=="nobattery"then
					gc.setLineWidth(2)
					gc.line(61.5,.5,83.5,22.5)
				elseif state=="charging"or state=="charged"then
					gc.draw(chargeImage,84,3)
				end
			end
			if pow then
				if charging then	gc.setColor(0,1,0)
				elseif pow>50 then	gc.setColor(1,1,1)
				elseif pow>26 then	gc.setColor(1,1,0)
				elseif pow<26 then	gc.setColor(1,0,0)
				else				gc.setColor(.5,0,1)--special~
				end
				::L::
				gc.rectangle("fill",61,6,pow*.15,10)
				gc.setColor(1,1,1)
				gc.draw(batteryImage,58,3)
				gc.print(pow.."%",94,-3)
			end
			gc.print(os.date("%H:%M",os.time()),2,-3)
			gc.pop()gc.setCanvas()
		end
	end
end
local function getNewBlock()
	FX_BGblock.ct=FX_BGblock.ct+1
	if FX_BGblock.ct==17 then FX_BGblock.ct=1 end
	local t=FX_BGblock.list[FX_BGblock.ct]
	t.bn,t.size=FX_BGblock.next,2+3*rnd()
	t.b=blocks[t.bn][rnd(0,3)]
	t.x=rnd(-#t.b[1]*t.size*30+100,1180)
	t.y=-#t.b*30*t.size
	t.v=t.size*(1+rnd())
	FX_BGblock.next=FX_BGblock.next%7+1
	return t
end
local function onVirtualkey(x,y)
	local dist,nearest=1e15
	for K=1,#virtualkey do
		local b=virtualkey[K]
		if b.ava then
			local d1=(x-b.x)^2+(y-b.y)^2
			if d1<b.r^2 then
				if d1<dist then
					nearest,dist=K,d1
				end
			end
		end
	end
	return nearest
end
-------------------------------------------------------------
local floatWheel=0
local function wheelScroll(y)
	if y>0 then
		if floatWheel<0 then floatWheel=0 end
		floatWheel=floatWheel+y^1.2
	elseif y<0 then
		if floatWheel>0 then floatWheel=0 end
		floatWheel=floatWheel-(-y)^1.2
	end
	while floatWheel>=1 do
		love.keypressed("up")
		floatWheel=floatWheel-1
	end
	while floatWheel<=-1 do
		love.keypressed("down")
		floatWheel=floatWheel+1
	end
end
local mouseDown,mouseMove,mouseUp,wheelmoved={},{},{},{}
local touchDown,touchUp,touchMove={},{},{}
local keyDown,keyUp={},{}
local gamepadDown,gamepadUp={},{}
function mouseDown.intro(x,y,k)
	if k==2 then
		scene.back()
	else
		scene.push()
		scene.swapTo("main")
	end
end
function touchDown.intro(id,x,y)
	scene.push()
	scene.swapTo("main")
end
function keyDown.intro(key)
	if key=="escape"then
		scene.back()
	else
		scene.push()
		scene.swapTo("main")
	end
end

function wheelmoved.mode(x,y)
	wheelScroll(y)

end
function keyDown.mode(key)
	if key=="down"then
		if modeSel<#modeID then
			modeSel=modeSel+1
			levelSel=int(#modeLevel[modeID[modeSel]]*.4)+1
			SFX("move",.4)
		end
	elseif key=="up"then
		if modeSel>1 then
			modeSel=modeSel-1
			levelSel=int(#modeLevel[modeID[modeSel]]*.4)+1
			SFX("move",.4)
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
		scene.push()loadGame(modeSel,levelSel)
	elseif key=="c"then
		scene.push()
		scene.swapTo("custom")
	elseif key=="escape"then
		scene.back()
	end
end

function wheelmoved.music(x,y)
	if y>0 then
		keyDown.music("up")
	elseif y<0 then
		keyDown.music("down")
	end
end
function keyDown.music(key)
	if key=="down"then
		sel=sel%#musicID+1
	elseif key=="up"then
		sel=(sel-2)%#musicID+1
	elseif key=="return"or key=="space"then
		if bgmPlaying~=musicID[sel]then
			BGM(musicID[sel])
		else
			BGM()
		end
	elseif key=="escape"then
		scene.back()
	end
end

function keyDown.custom(key)
	if key=="left"then
		customSel[sel]=(customSel[sel]-2)%#customRange[customID[sel]]+1
		if sel==12 then
			curBG=customRange.bg[customSel[12]]
		elseif sel==13 then
			BGM(customRange.bgm[customSel[13]])
		end
	elseif key=="right"then
		customSel[sel]=customSel[sel]%#customRange[customID[sel]]+1
		if sel==12 then
			curBG=customRange.bg[customSel[sel]]
		elseif sel==13 then
			BGM(customRange.bgm[customSel[sel]])
		end
	elseif key=="down"then
		sel=sel%#customID+1
	elseif key=="up"then
		sel=(sel-2)%#customID+1
	elseif key=="d"then
		scene.push()
		scene.swapTo("draw")
	elseif key=="return"then
		scene.push()loadGame(0,1)
	elseif key=="space"then
		scene.push()loadGame(0,2)
	elseif key=="1"then
		Widget.custom.set1.code()
	elseif key=="2"then
		Widget.custom.set2.code()
	elseif key=="3"then
		Widget.custom.set3.code()
	elseif key=="4"then
		Widget.custom.set4.code()
	elseif key=="5"then
		Widget.custom.set5.code()
	elseif key=="escape"then
		scene.back()
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
		preField[sy][sx]=ms.isDown(1)and pen or ms.isDown(2)and -1 or 0
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
	mouseMove.draw(x,y)
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
		if clearSureTime>15 then
			for y=1,20 do for x=1,10 do preField[y][x]=0 end end
			clearSureTime=0
		else
			clearSureTime=50
		end
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
	elseif key=="backspace"or key=="lalt"then
		pen=0
	elseif key=="escape"then
		scene.back()
	else
		pen=string.find("123qwea#sdzxc",key)or pen
	end
end

function keyDown.setting_key(key)
	if key=="escape"then
		if keyboardSetting then
			keyboardSetting=false
			SFX("error",.5)
		else
			scene.back()
		end
	elseif keyboardSetting then
		for l=1,8 do
			for y=1,20 do
				if setting.keyMap[l][y]==key then
					setting.keyMap[l][y]=""
				end
			end
		end
		setting.keyMap[curBoard][keyboardSet]=key
		SFX("reach",.5)
		keyboardSetting=false
	elseif key=="return"then
		keyboardSetting=true
		SFX("lock",.5)
	elseif key=="up"then
		if keyboardSet>1 then
			keyboardSet=keyboardSet-1
			SFX("move",.5)
		end
	elseif key=="down"then
		if keyboardSet<20 then
			keyboardSet=keyboardSet+1
			SFX("move",.5)
		end
	elseif key=="left"then
		if curBoard>1 then
			curBoard=curBoard-1
			SFX("rotate",.5)
		end
	elseif key=="right"then
		if curBoard<8 then
			curBoard=curBoard+1
			SFX("rotate",.5)
		end
	end
end
function gamepadDown.setting_key(key)
	if key=="back"then
		if joystickSetting then
			joystickSetting=false
			SFX("error",.5)
		else
			scene.back()
		end
	elseif joystickSetting then
		for l=9,16 do
			for y=1,20 do
				if setting.keyMap[l][y]==key then
					setting.keyMap[l][y]=""
				end
			end
		end
		setting.keyMap[8+curBoard][joystickSet]=key
		SFX("reach",.5)
		joystickSetting=false
	elseif key=="start"then
		joystickSetting=true
		SFX("lock",.5)
	elseif key=="up"then
		if joystickSet>1 then
			joystickSet=joystickSet-1
			SFX("move",.5)
		end
	elseif key=="down"then
		if joystickSet<20 then
			joystickSet=joystickSet+1
			SFX("move",.5)
		end
	elseif key=="left"then
		if curBoard>1 then
			curBoard=curBoard-1
			SFX("rotate",.5)
		end
	elseif key=="right"then
		if curBoard<8 then
			curBoard=curBoard+1
			SFX("rotate",.5)
		end
	end
end

function mouseDown.setting_touch(x,y,k)
	if k==2 then scene.back()end
	for K=1,#VK_org do
		local B=VK_org[K]
		if (x-B.x)^2+(y-B.y)^2<B.r^2 then
			sel=K
		end
	end
end
function mouseMove.setting_touch(x,y,dx,dy)
	if sel and ms.isDown(1)then
		local B=VK_org[sel]
		B.x,B.y=B.x+dx,B.y+dy
	end
end
function mouseUp.setting_touch(x,y,k)
	if sel then
		local B=VK_org[sel]
		local k=snapLevelValue[snapLevel]
		B.x,B.y=int(B.x/k+.5)*k,int(B.y/k+.5)*k
	end
end
function touchDown.setting_touch(id,x,y)
	for K=1,#VK_org do
		local B=VK_org[K]
		if (x-B.x)^2+(y-B.y)^2<B.r^2 then
			sel=K
		end
	end
end
function touchUp.setting_touch(id,x,y)
	if sel then
		x,y=xOy:inverseTransformPoint(x,y)
		if sel then
			local B=VK_org[sel]
			local k=snapLevelValue[snapLevel]
			B.x,B.y=int(B.x/k+.5)*k,int(B.y/k+.5)*k
		end
	end
end
function touchMove.setting_touch(id,x,y,dx,dy)
	if sel then
		local B=VK_org[sel]
		B.x,B.y=B.x+dx,B.y+dy
	end
end

function keyDown.pause(key)
	if key=="escape"then
		scene.back()
	elseif key=="return"or key=="space"then
		resumeGame()
	elseif key=="r"and kb.isDown("lctrl","rctrl")then
		clearTask("play")
		updateStat()
		resetGameData()
		scene.swapTo("play","none")
	end--Ctrl+R重开
end

function touchDown.play(id,x,y)
	if setting.VKSwitch then
		local t=onVirtualkey(x,y)
		if t then
			players[1]:pressKey(t)
			if setting.VKTrack then
				local B=virtualkey[t]
				for i=1,#virtualkey do
					local b=virtualkey[i]
					local d=B.r+b.r-((B.x-b.x)^2+(B.y-b.y)^2)^.5--碰撞深度(负数=间隔距离)
					if d>0 then
						b.x=b.x+(b.x-B.x)*d*b.r*.00005
						b.y=b.y+(b.y-B.y)*d*b.r*.00005
					end
				end
				--按钮软碰撞(做不来hhh随便做一个,效果还行!)
				local O=VK_org[t]
				local _FW,_CW=setting.VKTchW*.1,1-setting.VKCurW*.1
				local _OW=1-_FW-_CW
				B.x,B.y=x*_FW+B.x*_CW+O.x*_OW,y*_FW+B.y*_CW+O.y*_OW
				--按钮自动跟随:手指位置,当前位置,原始位置,权重取决于设置
			end
			VIB(0)
		end
	end
end
function touchUp.play(id,x,y)
	if setting.VKSwitch then
		local t=onVirtualkey(x,y)
		if t then
			players[1]:releaseKey(t)
		end
	end
end
function touchMove.play(id,x,y,dx,dy)
	if setting.VKSwitch then
		local l=tc.getTouches()
		for n=1,#virtualkey do
			local B=virtualkey[n]
			for i=1,#l do
				local x,y=xOy:inverseTransformPoint(tc.getPosition(l[i]))
				if(x-B.x)^2+(y-B.y)^2<=B.r^2 then
					goto nextButton
				end
			end
			players[1]:releaseKey(n)
			::nextButton::
		end
	end
end
function keyDown.play(key)
	if key=="escape"and not scene.swapping then
		return(frame<180 and back or pauseGame)()
	end
	local m=setting.keyMap
	for p=1,players.human do
		for k=1,20 do
			if key==m[2*p-1][k]or key==m[2*p][k]then
				players[p]:pressKey(k)
				return
			end
		end
	end
end
function keyUp.play(key)
	local m=setting.keyMap
	for p=1,players.human do
		for k=1,20 do
			if key==m[2*p-1][k]or key==m[2*p][k]then
				players[p]:releaseKey(k)
				return
			end
		end
	end
end
function gamepadDown.play(key)
	if key=="back"then scene.back()return end
	local m=setting.keyMap
	for p=1,players.human do
		for k=1,20 do
			if key==m[2*p+7][k]or key==m[2*p+8][k]then
				players[p]:pressKey(k)
				return
			end
		end
	end
end
function gamepadUp.play(key)
	local m=setting.keyMap
	for p=1,players.human do
		for k=1,20 do
			if key==m[2*p+7][k]or key==m[2*p+8][k]then
				players[p]:releaseKey(k)
				return
			end
		end
	end
end

function wheelmoved.history(x,y)
	wheelScroll(y)
end
function keyDown.history(key)
	if key=="up"then
		sel=max(sel-5,1)
	elseif key=="down"then
		sel=min(sel+5,#updateLog-22)
	elseif key=="escape"then
		scene.back()
	end
end
-------------------------------------------------------------
local function widgetPress(W,x,y)
	if W.type=="button"then
		W.code()
		W:FX()
		SFX("button")
		VOICE("nya")
	elseif W.type=="switch"then
		W.code()
		W:FX()
		SFX("move",.6)
	elseif W.type=="slider"then
		if not x then return end
		local p=W.disp()
		W.code(x<W.x and 0 or x>W.x+W.w and W.unit or int((x-W.x)*W.unit/W.w+.5))
		if p==W.disp()then return end
		W:FX(p)
		if W.change then W.change()end
	end
	if W.hide and W.hide()then widget_sel=nil end
end
local function widgetDrag(W,x,y,dx,dy)
	if W.type=="slider"then
		local p=W.disp()
		W.code(x<W.x and 0 or x>W.x+W.w and W.unit or int((x-W.x)*W.unit/W.w+.5))
		if p==W.disp()then return end
		W:FX(p)
		if W.change then W.change()end
	elseif not W:isAbove(x,y)then
		widget_sel=nil
	end
end
local function widgetControl_key(i)
	if i=="tab"then
		if widget_sel then
			widget_sel=kb.isDown("lshift")and widget_sel.prev or widget_sel.next or widget_sel
		else
			widget_sel=select(2,next(Widget[scene.cur]))
		end
	elseif i=="space"or i=="return"then
		if not scene.swapping and widget_sel then
			widgetPress(widget_sel)
		end
	else
		if widget_sel then
			local W=widget_sel
			if W.type=="slider"then
				local p=W.disp()
				if i=="left"then
					if W.disp()>0 then W.code(W.disp()-1)end
				elseif i=="right"then
					if W.disp()<W.unit then W.code(W.disp()+1)end
				end
				if p==W.disp()then return end
				W:FX(p)
				if W.change then W.change()end
			end
		end
	end
end
local function widgetControl_gamepad(i)
	if i=="dpup"or i=="dpdown"then
		if widget_sel then
			widget_sel=i=="dpup"and widget_sel.prev or widget_sel.next or widget_sel
		else
			widget_sel=select(2,next(Widget[scene.cur]))
		end
	elseif i=="start"then
		if not scene.swapping and widget_sel then
			local W=widget_sel
			if W.hide and W.hide()then widget_sel=nil end
			if W.type=="button"then
				W.code()
				W:FX()
				SFX("button")
				VOICE("nya")
			elseif W.type=="switch"then
				W.code()
				W:FX()
				SFX("move",.6)
			-- elseif W.type=="slider"then
			end
		end
	end
end
function love.mousepressed(x,y,k,t,num)
	if devMode>0 then print(x,y)end
	if t then return end
	mx,my=xOy:inverseTransformPoint(x,y)
	if mouseDown[scene.cur]then
		mouseDown[scene.cur](mx,my,k)
	elseif k==2 then
		scene.back()
	end
	if k==1 then
		if widget_sel and not scene.swapping then
			widgetPress(widget_sel,mx,my)
		end
	end
	mouseShow=true
end
function love.mousemoved(x,y,dx,dy,t)
	if t then return end
	mx,my=xOy:inverseTransformPoint(x,y)
	dx,dy=dx/scr.k,dy/scr.k
	if mouseMove[scene.cur]then
		mouseMove[scene.cur](mx,my,dx,dy)
	end
	if ms.isDown(1)and widget_sel then
		widgetDrag(widget_sel,mx,my,dx,dy)
	else
		widget_sel=nil
		for _,W in next,Widget[scene.cur]do
			if not(W.hide and W.hide())and W:isAbove(mx,my)then
				widget_sel=W
				return
			end
		end
	end
	mouseShow=true
end
function love.mousereleased(x,y,k,t,num)
	if t then return end
	mx,my=xOy:inverseTransformPoint(x,y)
	if mouseUp[scene.cur]then
		mouseUp[scene.cur](mx,my,k)
	end
end
function love.wheelmoved(x,y)
	if wheelmoved[scene.cur]then wheelmoved[scene.cur](x,y)end
end

function love.touchpressed(id,x,y)
	mouseShow=false
	if not touching then
		touching=id
		love.touchmoved(id,x,y,0,0)
	end
	if touchDown[scene.cur]then
		touchDown[scene.cur](id,xOy:inverseTransformPoint(x,y))
	end
end
function love.touchmoved(id,x,y,dx,dy)
	x,y=xOy:inverseTransformPoint(x,y)
	if touchMove[scene.cur]then
		touchMove[scene.cur](id,x,y,dx/scr.k,dy/scr.k)
	end
	if widget_sel then
		widgetDrag(widget_sel,x,y,dx,dy)
	else
		widget_sel=nil
		for _,W in next,Widget[scene.cur]do
			if not(W.hide and W.hide())and W:isAbove(x,y)then
				widget_sel=W
				return
			end
		end
	end
	if not widget_sel then
		touching=nil
	end
end
function love.touchreleased(id,x,y)
	x,y=xOy:inverseTransformPoint(x,y)
	if id==touching then
		touching=nil
		if widget_sel and not scene.swapping then
			widgetPress(widget_sel,x,y)
		end
		widget_sel=nil
	end
	if touchUp[scene.cur]then
		touchUp[scene.cur](id,x,y)
	end
end
function love.keypressed(i)
	mouseShow=false
	if i=="f8"then devMode=0
	elseif i=="f9"then devMode=1
	elseif i=="f10"then devMode=2
	elseif devMode==2 then
		if i=="k"then
			for i=1,8 do
				local P=players.alive[rnd(#players.alive)]
				P.lastRecv=players[1]
				Event.lose(P)
			end
			--Test code here
		elseif i=="q"then
			local W=widget_sel
			if W then W:getInfo()end
		elseif widget_sel then
			local W=widget_sel
			if i=="left"then W.x=W.x-10
			elseif i=="right"then W.x=W.x+10
			elseif i=="up"then W.y=W.y-10
			elseif i=="down"then W.y=W.y+10
			elseif i==","then W.w=W.w-10
			elseif i=="."then W.w=W.w+10
			elseif i=="/"then W.h=W.h-10
			elseif i=="'"then W.h=W.h+10
			elseif i=="["then W.font=W.font-1
			elseif i=="]"then W.font=W.font+1
			end
		end
	else
		if keyDown[scene.cur]then keyDown[scene.cur](i)
		elseif i=="escape"then scene.back()
		else widgetControl_key(i)
		end
	end
end
function love.keyreleased(i)
	if keyUp[scene.cur]then keyUp[scene.cur](i)end
end

local keyMirror={
	dpup="up",
	dpdown="down",
	dpleft="left",
	dpright="right",
	start="return",
	back="escape",
}
function love.gamepadpressed(joystick,i)
	mouseShow=false
	if gamepadDown[scene.cur]then gamepadDown[scene.cur](i)
	elseif keyDown[scene.cur]then keyDown[scene.cur](keyMirror[i]or i)
	elseif i=="back"then scene.back()
	else widgetControl_gamepad(i)
	end
end
function love.gamepadreleased(joystick,i)
	if gamepadUp[scene.cur]then gamepadUp[scene.cur](i)
	end
end
--[[
function love.joystickpressed(js,k)end
function love.joystickaxis(js,axis,val)end
function love.joystickhat(js,hat,dir)end
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
end
function love.focus(f)
	if system~="Android" and not f and scene.cur=="play"then pauseGame()end
end
function love.update(dt)
	-- if players then for k,v in pairs(players[1])do
	-- 	if rawget(_G,k)and k~="next"and k~="hold"and k~="stat"then print(k,_G[v])end
	-- end end--check player data flew
	for i=#sysFX,1,-1 do
		local S=sysFX[i]
		S[2]=S[2]+1
		if S[2]==S[3]then
			for i=i,#sysFX do
				sysFX[i]=sysFX[i+1]
			end
		end
	end
	for i=#FX_BGblock,1,-1 do
		FX_BGblock[i].y=FX_BGblock[i].y+FX_BGblock[i].v
		if FX_BGblock[i].y>720 then rem(FX_BGblock,i)end
	end
	if setting.bgblock then
		FX_BGblock.tm=FX_BGblock.tm-1
		if FX_BGblock.tm==0 then
			FX_BGblock[#FX_BGblock+1]=getNewBlock()
			FX_BGblock.tm=rnd(20,30)
		end
	end
	if scene.swapping then
		local S=scene.swap
		S.time=S.time-1
		if S.time==S.mid then
			scene.cur=S.tar
			scene.init(S.tar)
			widget_sel=nil
			--此时场景切换
		end
		if S.time==0 then
			scene.swapping=false
		end
	end
	if Tmr[scene.cur]then
		Tmr[scene.cur](dt)
	end
	for i=#Task,1,-1 do
		local T=Task[i]
		if T.code(T.P,T.data)then
			rem(Task,i)
		end
	end
	for i=1,#voiceQueue do
		local Q=voiceQueue[i]
		if #Q>0 then
			if type(Q[1])=="userdata"then
				if not Q[1]:isPlaying()then
					for i=1,#Q do
						Q[i]=Q[i+1]
					end
				end--放完后放下一个
			else
				local n=1
				local L=voiceBank[Q[1]]
				while L[n]:isPlaying()do
					n=n+1
					if not L[n]then
						L[n]=L[n-1]:clone()
						L[n]:seek(0)
						break
					end
				end
				Q[1]=L[n]
				Q[1]:setVolume(setting.voc*.1)
				Q[1]:play()
				--load voice with string
			end
		end
	end
	-- for k,W in next,Widget[scene.cur]do
	-- end--更新控件
end
local scs={1,2,1,2,1,2,1,2,1,2,1.5,1.5,.5,2.5}
local FPS=love.timer.getFPS
function love.draw()
	gc.discard()--SPEED UPUPUP!
	Pnt.BG[setting.bg and curBG or"grey"]()
	gc.setColor(1,1,1,.2)
	for n=1,#FX_BGblock do
		local b,img=FX_BGblock[n].b,blockSkin[FX_BGblock[n].bn]
		local size=FX_BGblock[n].size
		for i=1,#b do for j=1,#b[1]do
			if b[i][j]then
				gc.draw(img,FX_BGblock[n].x+(j-1)*30*size,FX_BGblock[n].y+(i-1)*30*size,nil,size)
			end
		end end
	end--Draw BG falling blocks
	if Pnt[scene.cur]then Pnt[scene.cur]()end
	for k,W in next,Widget[scene.cur]do
		if not(W.hide and W.hide())then
			W:draw()
		end
	end--Draw widgets
	if mouseShow and not touching then
		local r=Timer()*.5
		gc.setColor(1,1,1,min(1-math.abs(1-r%1*2),.3))
		r=int(r)%7+1
		gc.draw(miniBlock[r],mx,my,Timer()%3.1416*4,20,20,scs[2*r]-.5,#blocks[r][0]-scs[2*r-1]+.5)
		gc.setColor(1,1,1,.5)gc.circle("fill",mx,my,5)
		gc.setColor(1,1,1)gc.circle("fill",mx,my,3)
	end--Awesome mouse!
	gc.setColor(1,1,1)
	if powerInfoCanvas then
		gc.draw(powerInfoCanvas)
	end--Power Info
	gc.setLineWidth(6)
	for i=1,#sysFX do
		local S=sysFX[i]
		if S[1]==0 then
			gc.setColor(1,1,1,1-S[2]/S[3])
			local r=(10*S[2]/S[3])^1.2
			gc.rectangle("line",S[4]-r,S[5]-r,S[6]+2*r,S[7]+2*r)
			--按钮波纹
		elseif S[1]==1 then
			gc.setColor(S[4],S[5],S[6],1-S[2]/S[3])
			gc.rectangle("fill",S[7],S[8],S[9],S[10],2)
			--开关/滑条残影
		end
	end--sysFXs
	if scene.swapping then
		scene.swap.draw(scene.swap.time)
	end--Swapping animation
	if scr.r~=.5625 then
		gc.setColor(0,0,0)
		if scr.r>.5625 then
			local d=(scr.h-scr.w*9/16)*.5/scr.k
			gc.rectangle("fill",0,0,1280,-d)
			gc.rectangle("fill",0,720,1280,d)
		else--高窗口
			local d=(scr.w-scr.h*16/9)*.5/scr.k
			gc.rectangle("fill",0,0,-d,720)
			gc.rectangle("fill",1280,0,d,720)
		end--扁窗口
	end--Black side
	setFont(20)
	gc.setColor(1,1,1)
	gc.print(FPS(),5,700)
	if devMode>0 then
		gc.setColor(1,devMode==2 and .5 or 1,1)
		gc.print("Tasks:"..#Task,5,600)
		gc.print("Voices:"..#voiceQueue,5,620)
		gc.print("Mouse:"..mx.." "..my,5,640)
		gc.print("Free Row:"..#freeRow.."/"..freeRow.L,5,660)
		gc.print("Cache used:"..gcinfo(),5,680)
	end
end
function love.run()
	local T=love.timer
	local lastFrame,lastFreshPow=T.getTime(),T.getTime()
	local readyDrawFrame=0
	local mini=love.window.isMinimized
	local PUMP,POLL=love.event.pump,love.event.poll
	love.resize(gc.getWidth(),gc.getHeight())
	scene.init("load")--Scene Launch
	return function()
		PUMP()
		for N,a,b,c,d,e in POLL()do
			if N=="quit"then
				destroyPlayers()
				saveData()
				saveSetting()
				return 0
			elseif love[N]then
				love[N](a,b,c,d,e)
			end
		end
		T.step()
		love.update(T.getDelta())
		if not mini()then
			readyDrawFrame=readyDrawFrame+setting.frameMul
			if readyDrawFrame>=100 then
				readyDrawFrame=readyDrawFrame-100
				love.draw()
				gc.present()
			end
		end
		while Timer()-lastFrame<.0158 do
			T.sleep(.001)
		end
		lastFrame=Timer()
		if Timer()-lastFreshPow>5 then
			updatePowerInfo()
			lastFreshPow=Timer()
		end
	end
end

local fs=love.filesystem
userData,userSetting=fs.newFile("userdata"),fs.newFile("usersetting")
if fs.getInfo("userdata")then
	loadData()
end
if fs.getInfo("usersetting")then
	loadSetting()
elseif system=="Android"or system=="iOS" then
	setting.swap=false
else
	setting.VKSwitch=false
end
math.randomseed(os.time()*626)
swapLanguage(setting.lang)
changeBlockSkin(setting.skin)