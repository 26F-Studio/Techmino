--[[
第一次搞这么大的工程,参考价值不是很大
如果你有时间并且也热爱俄罗斯方块的话,来看代码或者帮助优化的话欢迎!
]]
math.randomseed(os.time()*626)
local love=love
local ms,kb,tc=love.mouse,love.keyboard,love.touch
local gc,sys=love.graphics,love.system
local Timer=love.timer.getTime
local int,rnd,max,min=math.floor,math.random,math.max,math.min
local abs=math.abs
local rem=table.remove
function NULL()end
--LIBs
-------------------------------------------------------------
system=sys.getOS()
local xOy=love.math.newTransform()
local mx,my,mouseShow=-20,-20,false
local touching=nil--第一触摸ID
local touchDist=nil
joysticks={}

local devMode=0
players={alive={},human=0}
scr={x=0,y=0,w=0,h=0,rad=0,k=1}--x,y,wid,hei,radius,scale K
local scr=scr
mapCam={
	sel=nil,--selected mode ID

	x=0,y=0,k=1,--camera pos/k
	x1=0,y1=0,k1=1,--camera pos/k shown
	--basic paras

	keyCtrl=false,--if controlling with key

	zoomMethod=nil,
	zoomK=nil,
	--for auto zooming when enter/leave scene
}
curBG="none"
voiceQueue={free=0}
texts={}
widget_sel=nil--selected widget object

kb.setKeyRepeat(true)
kb.setTextInput(false)
ms.setVisible(false)
--Application Vars
-------------------------------------------------------------
customSel={1,22,1,1,7,3,1,1,8,4,1,1,1}
preField={h=20}
for i=1,20 do preField[i]={0,0,0,0,0,0,0,0,0,0}end
-- blockSkin,blockSkinMini={},{}--redefined in skin.change
--Game system Vars
-------------------------------------------------------------
require("parts/list")
space=require("parts/space")local space=space
setFont=require("parts/setfont")
freeRow=require("parts/freeRow")
blocks=require("parts/mino")
VIB=require("parts/vib")
SFX=require("parts/sfx")
BGM=require("parts/bgm")
require("parts/voice")

Event_task=require("parts/task")
AITemplate=require("parts/AITemplate")
require("parts/modes")
skin=require("parts/skin")
-- require("parts/light")
-- require("parts/shader")
scene=require("scene")
require("default_data")
require("class")
require("ai")
require("toolfunc")
require("file")
require("text")
require("player")
Widget=require("widgetList")
require("texture")
local Tmr=require("timer")
local Pnt=require("paint")
--Modules
-------------------------------------------------------------
local powerInfoCanvas,updatePowerInfo
if sys.getPowerInfo()~="unknown"then
	powerInfoCanvas=gc.newCanvas(108,27)
	function updatePowerInfo()
		local state,pow=sys.getPowerInfo()
		if state~="unknown"then
			gc.setCanvas(powerInfoCanvas)gc.push("transform")gc.origin()
			gc.clear(0,0,0,.25)
			gc.setLineWidth(4)
			local charging=state=="charging"
			if state=="nobattery"then
				gc.setColor(1,1,1)
				gc.setLineWidth(2)
				gc.line(74,5,100,22)
			else
				if charging then	gc.setColor(0,1,0)
				elseif pow>50 then	gc.setColor(1,1,1)
				elseif pow>26 then	gc.setColor(1,1,0)
				elseif pow<26 then	gc.setColor(1,0,0)
				else				gc.setColor(.5,0,1)
				end
				gc.rectangle("fill",76,6,pow*.22,14)
				if pow<100 then
					setFont(14)
					gc.setColor(0,0,0)
					gc.print(pow,77,2)
					gc.print(pow,77,4)
					gc.print(pow,79,2)
					gc.print(pow,79,4)
					gc.setColor(1,1,1)
					gc.print(pow,78,3)
				end
			end
			gc.draw(batteryImage,73,3)
			setFont(25)
			gc.print(os.date("%H:%M",os.time()),3,-5)
			gc.pop()gc.setCanvas()
		end
	end
end
local function onVirtualkey(x,y)
	local dist,nearest=1e10
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
local function onVK_org(x,y)
	local dist,nearest=1e10
	for K=1,#VK_org do
		local b=VK_org[K]
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
local mouseClick,touchClick={},{}
local mouseDown,mouseMove,mouseUp,wheelMoved={},{},{},{}
local touchDown,touchUp,touchMove={},{},{}
local keyDown,keyUp={},{}
local gamepadDown,gamepadUp={},{}

function mouseDown.load()
	sceneTemp.skip=true
end
function keyDown.load()
	sceneTemp.skip=true
end
function touchDown.load()
	sceneTemp.skip=true
end

function mouseDown.intro(x,y,k)
	if k==2 then
		VOICE("bye")
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
		VOICE("bye")
		scene.back()
	else
		scene.push()
		scene.swapTo("main")
	end
end

local function onMode(x,y)
	local cam=mapCam
	x=(cam.x1-640+x)/cam.k1
	y=(cam.y1-360+y)/cam.k1
	local MM,R=modes,modeRanks
	for _=1,#MM do
		if R[_]then
			local M=MM[_]
			local s=M.size
			if M.shape==1 then
				if x>M.x-s and x<M.x+s and y>M.y-s and y<M.y+s then return _ end
			elseif M.shape==2 then
				if abs(x-M.x)+abs(y-M.y)<s then return _ end
			elseif M.shape==3 then
				if(x-M.x)^2+(y-M.y)^2<s^2 then return _ end
			end
		end
	end
end
function wheelMoved.mode(x,y)
	local cam=mapCam
	local t=cam.k
	local k=t+y*.1
	if k>1.5 then k=1.5
	elseif k<.3 then k=.3
	end
	t=k/t
	if cam.sel then
		cam.x=(cam.x-180)*t+180;cam.y=cam.y*t
	else
		cam.x=cam.x*t;cam.y=cam.y*t
	end
	cam.k=k
	cam.keyCtrl=false
end
function mouseMove.mode(x,y,dx,dy)
	if ms.isDown(1)then
		mapCam.x,mapCam.y=mapCam.x-dx,mapCam.y-dy
	end
	mapCam.keyCtrl=false
end
function mouseClick.mode(x,y,k)
	local cam=mapCam
	local _=cam.sel
	if not cam.sel or x<920 then
		local __=onMode(x,y)
		if _~=__ then
			if __ then
				SFX.play("click")
				cam.moving=true
				_=modes[__]
				cam.x=_.x*cam.k+180
				cam.y=_.y*cam.k
				cam.sel=__
			else
				cam.sel=nil
				cam.x=cam.x-180
			end
		end
	end
	cam.keyCtrl=false
end
function touchMove.mode(id,x,y,dx,dy)
	local L=tc.getTouches()
	if not L[2]then
		mapCam.x,mapCam.y=mapCam.x-dx,mapCam.y-dy
	elseif not L[3]then
		x,y=xOy:inverseTransformPoint(tc.getPosition(L[1]))
		dx,dy=xOy:inverseTransformPoint(tc.getPosition(L[2]))--dx,dy not Δ!
		local d=(x-dx)^2+(y-dy)^2
		if d>100 then
			d=d^.5
			if touchDist then
				wheelMoved.mode(nil,(d-touchDist)*.02)
			end
			touchDist=d
		end
	end
	mapCam.keyCtrl=false
end
function touchClick.mode(x,y,id)
	mouseClick.mode(x,y,1)
end
function keyDown.mode(key)
	if key=="return"then
		if mapCam.sel then
			mapCam.keyCtrl=false
			scene.push()loadGame(mapCam.sel)
		end
	elseif key=="escape"then
		if mapCam.sel then
			mapCam.sel=nil
		else
			scene.back()
		end
	elseif mapCam.sel==71 or mapCam.sel==72 then
		if key=="q"then
			scene.push()scene.swapTo("draw")
		elseif key=="e"then
			scene.push()scene.swapTo("custom")
		end
	end
end

function wheelMoved.music(x,y)
	if y>0 then
		keyDown.music("up")
	elseif y<0 then
		keyDown.music("down")
	end
end
function keyDown.music(key)
	if key=="down"then
		sceneTemp=sceneTemp%#musicID+1
	elseif key=="up"then
		sceneTemp=(sceneTemp-2)%#musicID+1
	elseif key=="return"or key=="space"then
		if BGM.nowPlay~=musicID[sceneTemp]then
			SFX.play("click")
			BGM.play(musicID[sceneTemp])
		else
			BGM.stop()
		end
	elseif key=="escape"then
		scene.back()
	end
end

function keyDown.custom(key)
	local sel=sceneTemp
	if key=="left"then
		customSel[sel]=(customSel[sel]-2)%#customRange[customID[sel]]+1
		if sel==12 then
			curBG=customRange.bg[customSel[12]]
		elseif sel==13 then
			BGM.play(customRange.bgm[customSel[13]])
		end
	elseif key=="right"then
		customSel[sel]=customSel[sel]%#customRange[customID[sel]]+1
		if sel==12 then
			curBG=customRange.bg[customSel[sel]]
		elseif sel==13 then
			BGM.play(customRange.bgm[customSel[sel]])
		end
	elseif key=="down"then
		sceneTemp=sel%#customID+1
	elseif key=="up"then
		sceneTemp=(sel-2)%#customID+1
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
	local sx,sy=int((x-200)/30)+1,20-int((y-60)/30)
	if sx<1 or sx>10 then sx=nil end
	if sy<1 or sy>20 then sy=nil end
	sceneTemp.x,sceneTemp.y=sx,sy
	if sx and sy and ms.isDown(1,2,3)then
		preField[sy][sx]=ms.isDown(1)and sceneTemp.pen or ms.isDown(2)and -1 or 0
	end
end
function wheelMoved.draw(x,y)
	local pen=sceneTemp.pen
	if y<0 then
		pen=pen+1
		if pen==8 then pen=9 elseif pen==14 then pen=0 end
	else
		pen=pen-1
		if pen==8 then pen=7 elseif pen==-1 then pen=13 end
	end
	sceneTemp.pen=pen
end
function touchDown.draw(id,x,y)
	mouseMove.draw(x,y)
end
function touchMove.draw(id,x,y,dx,dy)
	local sx,sy=int((x-200)/30)+1,20-int((y-60)/30)
	if sx<1 or sx>10 then sx=nil end
	if sy<1 or sy>20 then sy=nil end
	sceneTemp.x,sceneTemp.y=sx,sy
	if sx and sy then
		preField[sy][sx]=sceneTemp.pen
	end
end
local penKey={
	q=1,w=2,e=3,r=4,t=5,y=6,u=7,i=8,o=9,p=10,["["]=11,
	a=12,s=13,d=14,f=15,g=16,h=17,
	z=0,x=-1,
}
function keyDown.draw(key)
	local sx,sy,pen=sceneTemp.x,sceneTemp.y,sceneTemp.pen
	if key=="up"or key=="down"or key=="left"or key=="right"then
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
	elseif key=="delete"then
		if sceneTemp.sure>20 then
			for y=1,20 do for x=1,10 do preField[y][x]=0 end end
			sceneTemp.sure=0
		else
			sceneTemp.sure=50
		end
	elseif key=="space"then
		if sx and sy then
			preField[sy][sx]=pen
		end
	elseif key=="escape"then
		scene.back()
	elseif key=="c"and kb.isDown("lctrl","rctrl")then
		copyBoard()
	elseif key=="v"and kb.isDown("lctrl","rctrl")then
		pasteBoard()
	else
		pen=penKey[key]or pen
	end
	sceneTemp.x,sceneTemp.y,sceneTemp.pen=sx,sy,pen
end

function mouseDown.setting_sound(x,y,k)
	if x>780 and x<980 and y>470 and sceneTemp.jump==0 then
		sceneTemp.jump=10
		local t=Timer()-sceneTemp.last
		if t>1 then
			VOICE((t<1.5 or t>15)and"doubt"or rnd()<.8 and"happy"or"egg")
			sceneTemp.last=Timer()
			if rnd()<.0626 then
				for i=1,#modes do
					local M=modes[i]
					for i=1,#M.unlock do
						local m=M.unlock[i]
						if not modeRanks[m]then
							modeRanks[m]=modes[m].score and 0 or 6
						end
					end
				end
				saveUnlock()
				TEXT("DEVMODE:UNLOCKALL",640,360,50,"stretch",.6)
			end
		end
	end
end
function touchDown.setting_sound(id,x,y)
	mouseDown.setting_sound(x,y)
end

function keyDown.setting_key(key)
	local s=sceneTemp
	if key=="escape"then
		if s.kS then
			s.kS=false
			SFX.play("finesseError",.5)
		else
			scene.back()
		end
	elseif s.kS then
		for l=1,8 do
			for y=1,20 do
				if keyMap[l][y]==key then
					keyMap[l][y]=""
					goto L
				end
			end
		end
		::L::
		keyMap[s.board][s.kb]=key
		SFX.play("reach",.5)
		s.kS=false
	elseif key=="return"then
		s.kS=true
		SFX.play("lock",.5)
	elseif key=="up"then
		if s.kb>1 then
			s.kb=s.kb-1
			SFX.play("move",.5)
		end
	elseif key=="down"then
		if s.kb<20 then
			s.kb=s.kb+1
			SFX.play("move",.5)
		end
	elseif key=="left"then
		if s.board>1 then
			s.board=s.board-1
			SFX.play("rotate",.5)
		end
	elseif key=="right"then
		if s.board<8 then
			s.board=s.board+1
			SFX.play("rotate",.5)
		end
	end
end
function gamepadDown.setting_key(key)
	local s=sceneTemp
	if key=="back"then
		if s.jS then
			s.jS=false
			SFX.play("finesseError",.5)
		else
			scene.back()
		end
	elseif s.jS then
		for l=9,16 do
			for y=1,20 do
				if keyMap[l][y]==key then
					keyMap[l][y]=""
					goto L
				end
			end
		end
		::L::
		keyMap[8+s.board][s.js]=key
		SFX.play("reach",.5)
		s.jS=false
	elseif key=="start"then
		s.jS=true
		SFX.play("lock",.5)
	elseif key=="dpup"then
		if s.js>1 then
			s.js=s.js-1
			SFX.play("move",.5)
		end
	elseif key=="dpdown"then
		if s.js<20 then
			s.js=s.js+1
			SFX.play("move",.5)
		end
	elseif key=="dpleft"then
		if s.board>1 then
			s.board=s.board-1
			SFX.play("rotate",.5)
		end
	elseif key=="dpright"then
		if s.board<8 then
			s.board=s.board+1
			SFX.play("rotate",.5)
		end
	end
end

function mouseDown.setting_touch(x,y,k)
	if k==2 then scene.back()end
	sceneTemp.sel=onVK_org(x,y)or sceneTemp.sel
end
function mouseMove.setting_touch(x,y,dx,dy)
	if sceneTemp.sel and ms.isDown(1)and not widget_sel then
		local B=VK_org[sceneTemp.sel]
		B.x,B.y=B.x+dx,B.y+dy
	end
end
function mouseUp.setting_touch(x,y,k)
	if sceneTemp.sel then
		local B=VK_org[sceneTemp.sel]
		local k=snapLevelValue[sceneTemp.snap]
		B.x,B.y=int(B.x/k+.5)*k,int(B.y/k+.5)*k
	end
end
function touchDown.setting_touch(id,x,y)
	sceneTemp.sel=onVK_org(x,y)or sceneTemp.sel
end
function touchUp.setting_touch(id,x,y)
	if sceneTemp.sel then
		local B=VK_org[sceneTemp.sel]
		local k=snapLevelValue[sceneTemp.snap]
		B.x,B.y=int(B.x/k+.5)*k,int(B.y/k+.5)*k
	end
end
function touchMove.setting_touch(id,x,y,dx,dy)
	if sceneTemp.sel and not widget_sel then
		local B=VK_org[sceneTemp.sel]
		B.x,B.y=B.x+dx,B.y+dy
	end
end

function keyDown.pause(key)
	if key=="escape"then
		scene.back()
	elseif key=="space"then
		resumeGame()
	elseif key=="s"then
		scene.push()
		scene.swapTo("setting_sound")
	elseif key=="r"then
		clearTask("play")
		updateStat()
		resetGameData()
		scene.swapTo("play","none")
	end
end

function touchDown.play(id,x,y)
	if setting.VKSwitch then
		local t=onVirtualkey(x,y)
		if t then
			players[1]:pressKey(t)
			virtualkey[t].isDown=true
			virtualkey[t].pressTime=10
			if setting.VKTrack then
				local B=virtualkey[t]
				if setting.VKDodge then--按钮软碰撞(做不来hhh随便做一个,效果还行!)
				for i=1,#virtualkey do
						local b=virtualkey[i]
						local d=B.r+b.r-((B.x-b.x)^2+(B.y-b.y)^2)^.5--碰撞深度(负数=间隔距离)
						if d>0 then
							b.x=b.x+(b.x-B.x)*d*b.r*.00005
							b.y=b.y+(b.y-B.y)*d*b.r*.00005
						end
					end
				end
				local O=VK_org[t]
				local _FW,_CW=setting.VKTchW*.1,1-setting.VKCurW*.1
				local _OW=1-_FW-_CW
				--按钮自动跟随:手指位置,当前位置,原始位置,权重取决于设置
				B.x,B.y=x*_FW+B.x*_CW+O.x*_OW,y*_FW+B.y*_CW+O.y*_OW
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
	if key=="escape"then
		(frame<180 and scene.back or pauseGame)()
		return
	end
	local m=keyMap
	for p=1,players.human do
		for k=1,20 do
			if key==m[2*p-1][k]or key==m[2*p][k]then
				players[p]:pressKey(k)
				if p==1 then
					virtualkey[k].isDown=true
					virtualkey[k].pressTime=10
				end
				return
			end
		end
	end
end
function keyUp.play(key)
	local m=keyMap
	for p=1,players.human do
		for k=1,20 do
			if key==m[2*p-1][k]or key==m[2*p][k]then
				players[p]:releaseKey(k)
				if p==1 then virtualkey[k].isDown=false end
				return
			end
		end
	end
end
function gamepadDown.play(key)
	if key=="back"then scene.back()return end
	local m=keyMap
	for p=1,players.human do
		for k=1,20 do
			if key==m[2*p+7][k]or key==m[2*p+8][k]then
				players[p]:pressKey(k)
				if p==1 then
					virtualkey[k].isDown=true
					virtualkey[k].pressTime=10
				end
				return
			end
		end
	end
end
function gamepadUp.play(key)
	local m=keyMap
	for p=1,players.human do
		for k=1,20 do
			if key==m[2*p+7][k]or key==m[2*p+8][k]then
				players[p]:releaseKey(k)
				if p==1 then virtualkey[k].isDown=false end
				return
			end
		end
	end
end
function wheelMoved.history(x,y)
	wheelScroll(y)
end
function keyDown.history(key)
	if key=="up"then
		sceneTemp[2]=max(sceneTemp[2]-3,1)
	elseif key=="down"then
		sceneTemp[2]=min(sceneTemp[2]+3,#sceneTemp[1]-22)
	elseif key=="escape"then
		scene.back()
	end
end
-------------------------------------------------------------
local function widgetPress(W,x,y)
	if W.type=="button"then
		W.code()
		W:FX()
		SFX.play("button")
		VOICE("nya")
	elseif W.type=="switch"then
		W.code()
		SFX.play("move",.6)
	elseif W.type=="slider"then
		if not x then return end
		local p,P=W.disp(),x<W.x and 0 or x>W.x+W.w and W.unit or int((x-W.x)*W.unit/W.w+.5)
		if p==P then return end
		W.code(P)
		if W.change then W.change()end
	end
	if W.hide and W.hide()then widget_sel=nil end
end
local function widgetDrag(W,x,y,dx,dy)
	if W.type=="slider"then
		local p,P=W.disp(),x<W.x and 0 or x>W.x+W.w and W.unit or int((x-W.x)*W.unit/W.w+.5)
		if p==P then return end
		W.code(P)
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
		if widget_sel then
			widgetPress(widget_sel)
		end
	elseif i=="left"or i=="right"then
		if widget_sel then
			local W=widget_sel
			if W.type=="slider"then
				local p=W.disp()
				local P=i=="left"and(p>0 and p-1)or p<W.unit and p+1
				if p==P or not P then return end
				W.code(P)
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
		if widget_sel then
			widgetPress(widget_sel)
		end
	elseif i=="dpleft"or i=="dpright"then
		if widget_sel then
			local W=widget_sel
			if W.type=="slider"then
				local p=W.disp()
				local P=i=="left"and(p>0 and p-1)or p<W.unit and p+1
				if p==P or not P then return end
				W.code(P)
				if W.change then W.change()end
			end
		end
	end
end
local lastX,lastY=0,0--last clickDown pos
function love.mousepressed(x,y,k,t,num)
	if t then return end
	mouseShow=true
	mx,my=xOy:inverseTransformPoint(x,y)
	if devMode>0 then print(mx,my)end
	if scene.swapping then return end
	if mouseDown[scene.cur]then
		mouseDown[scene.cur](mx,my,k)
	elseif k==2 then
		scene.back()
	end
	if k==1 then
		if widget_sel then
			widgetPress(widget_sel,mx,my)
		end
	end
	lastX,lastY=mx,my
end
function love.mousemoved(x,y,dx,dy,t)
	if t then return end
	mouseShow=true
	mx,my=xOy:inverseTransformPoint(x,y)
	if scene.swapping then return end
	dx,dy=dx/scr.k,dy/scr.k
	if mouseMove[scene.cur]then
		mouseMove[scene.cur](mx,my,dx,dy)
	end
	if ms.isDown(1) then
		if widget_sel then
			widgetDrag(widget_sel,mx,my,dx,dy)
		end
	else
		widget_sel=nil
		for _,W in next,Widget[scene.cur]do
			if not(W.hide and W.hide())and W:isAbove(mx,my)then
				widget_sel=W
				return
			end
		end
	end
end
function love.mousereleased(x,y,k,t,num)
	if t then return end
	mx,my=xOy:inverseTransformPoint(x,y)
	if t or scene.swapping then return end
	if mouseUp[scene.cur]then
		mouseUp[scene.cur](mx,my,k)
	end
	if lastX and(mx-lastX)^2+(my-lastY)^2<26 and mouseClick[scene.cur]then
		mouseClick[scene.cur](mx,my,k)
	end
end
function love.wheelmoved(x,y)
	if scene.swapping then return end
	if wheelMoved[scene.cur]then wheelMoved[scene.cur](x,y)end
end

function love.touchpressed(id,x,y)
	mouseShow=false
	if scene.swapping then return end
	if not touching then
		touching=id
		love.touchmoved(id,x,y,0,0)
	end
	touchDist=nil--reset distance
	x,y=xOy:inverseTransformPoint(x,y)
	lastX,lastY=x,y
	if touchDown[scene.cur]then
		touchDown[scene.cur](id,x,y)
	end
end
function love.touchmoved(id,x,y,dx,dy)
	if scene.swapping then return end
	x,y=xOy:inverseTransformPoint(x,y)
	if touchMove[scene.cur]then
		touchMove[scene.cur](id,x,y,dx/scr.k,dy/scr.k)
	end
	if widget_sel then
		if touching then
			widgetDrag(widget_sel,x,y,dx,dy)
		end
	else
		for _,W in next,Widget[scene.cur]do
			if not(W.hide and W.hide())and W:isAbove(x,y)then
				widget_sel=W
				return
			end
		end
		if not widget_sel then
			touching=nil
		end
	end
end
function love.touchreleased(id,x,y)
	if scene.swapping then return end
	x,y=xOy:inverseTransformPoint(x,y)
	if id==touching then
		touching=nil
		if widget_sel then
			widgetPress(widget_sel,x,y)
		end
		widget_sel=nil
	end
	if touchUp[scene.cur]then
		touchUp[scene.cur](id,x,y)
	end
	if(x-lastX)^2+(y-lastY)^2<26 and touchClick[scene.cur]then
		touchClick[scene.cur](x,y,k)
	end
end
function love.keypressed(i)
	mouseShow=false
	if scene.swapping then return end
	if i=="f8"then devMode=0
	elseif i=="f9"then devMode=1
	elseif i=="f10"then devMode=2
	elseif i=="f11"then devMode=3
	elseif devMode==2 then
		if i=="k"then
			for i=1,8 do
				local P=players.alive[rnd(#players.alive)]
				if P~=players[1]then
					P.lastRecv=players[1]
					P:lose()
				end
			end
			--Test code here
		elseif i=="q"then
			local W=widget_sel
			if W then W:getInfo()end
		elseif i=="f3"then
			error("Techmino:挂了")
		elseif i=="e"then
			for k,v in next,_G do
				print(k,v)
			end
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
	if scene.swapping then return end
	if keyUp[scene.cur]then keyUp[scene.cur](i)end
end

function love.joystickadded(JS)
	joysticks[#joysticks+1]=JS
end
function love.joystickremoved(JS)
	for i=1,#joysticks do
		if joysticks[i]==JS then
			rem(joysticks,i)
			return
		end
	end
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
	if scene.swapping then return end
	if gamepadDown[scene.cur]then gamepadDown[scene.cur](i)
	elseif keyDown[scene.cur]then keyDown[scene.cur](keyMirror[i]or i)
	elseif i=="back"then scene.back()
	else widgetControl_gamepad(i)
	end
end
function love.gamepadreleased(joystick,i)
	if scene.swapping then return end
	if gamepadUp[scene.cur]then gamepadUp[scene.cur](i)
	end
end
--[[
function love.joystickpressed(JS,k)
	mouseShow=false
	if scene.swapping then return end
	if gamepadDown[scene.cur]then gamepadDown[scene.cur](i)
	elseif keyDown[scene.cur]then keyDown[scene.cur](keyMirror[i]or i)
	elseif i=="back"then scene.back()
	else widgetControl_gamepad(i)
	end
end
function love.joystickreleased(JS,k)
	if scene.swapping then return end
	if gamepadUp[scene.cur]then gamepadUp[scene.cur](i)
	end
end
function love.joystickaxis(JS,axis,val)
	
end
function love.joystickhat(JS,hat,dir)

end
function love.sendData(data)end
function love.receiveData(id,data)end
]]
function love.lowmemory()
	collectgarbage()
end
function love.resize(w,h)
	love.timer.sleep(.26)
	scr.w,scr.h,scr.r=w,h,h/w
	scr.rad=(w^2+h^2)^.5
	if scr.r>=.5625 then
		scr.k=w/1280
		scr.x,scr.y=0,(h-w*9/16)*.5
	else
		scr.k=h/720
		scr.x,scr.y=(w-h*16/9)*.5,0
	end
	xOy=xOy:setTransformation(w*.5,h*.5,nil,scr.k,nil,640,360)
	if setting.bgspace then space.new()end
end
function love.focus(f)
	if scene.cur=="play"and not f and setting.autoPause then pauseGame()end
end
local function love_update(dt)
	if setting.bgspace then space.update()end
	for i=#sysFX,1,-1 do
		local S=sysFX[i]
		S[2]=S[2]+1
		if S[2]==S[3]then
			for i=i,#sysFX do
				sysFX[i]=sysFX[i+1]
			end
		end
	end
	for i=#texts,1,-1 do
		local t=texts[i]
		t.c=t.c+t.spd
		if t.stop then
			if t.c>t.stop then
				t.c=t.stop
			end
		end
		if t.c>60 then
			rem(texts,i)
		end
	end
	if scene.swapping then
		local S=scene.swap
		S.time=S.time-1
		if S.time==S.mid then
			scene.init(S.tar,scene.cur)
			scene.cur=S.tar
			for _,W in next,Widget[S.tar]do
				W:reset()
			end--重置控件
			widget_sel=nil
			collectgarbage()
			--此时场景切换
		end
		if S.time==0 then
			scene.swapping=false
		end
	end
	local _=Tmr[scene.cur]
	if _ then _(dt)end
	for i=#Task,1,-1 do
		local T=Task[i]
		if T.code(T.P,T.data)then
			for i=i,#Task do
				Task[i]=Task[i+1]
			end
 		end
	end
	for i=#voiceQueue,1,-1 do
		local Q=voiceQueue[i]
		if Q.s==0 then--闲置轨，自动删除多余
			if i>3 then
				local _=voiceQueue
				::L::
					_[i]=_[i+1]
				if _[i]then i=i+1 goto L end
			end
		elseif Q.s==1 then--等待转换
			Q[1]=getVoice(Q[1])
			Q[1]:setVolume(setting.voc*.1)
			Q[1]:play()
			Q.s=Q[2]and 2 or 4
		elseif Q.s==2 then--播放1,准备2
			if Q[1]:getDuration()-Q[1]:tell()<.08 then
				Q[2]=getVoice(Q[2])
				Q[2]:setVolume(setting.voc*.1)
				Q[2]:play()
				Q.s=3
			end
		elseif Q.s==3 then--12同时播放
			if not Q[1]:isPlaying()then
				for i=1,#Q do
					Q[i]=Q[i+1]
				end
				Q.s=Q[2]and 2 or 4
			end
		elseif Q.s==4 then--最后播放
			if not Q[1].isPlaying(Q[1])then
				Q[1]=nil
				Q.s=0
			end
		end
	end
	--更新控件
	for _,W in next,Widget[scene.cur]do
		W:update()
	end
end
local scs={1,2,1,2,1,2,1,2,1,2,1.5,1.5,.5,2.5}
local FPS=love.timer.getFPS
local function love_draw()
	gc.discard()--SPEED UPUPUP!
	Pnt.BG[setting.bg and curBG or"grey"]()
	if setting.bgspace then
		space.draw()
	end
	gc.push("transform")
		gc.replaceTransform(xOy)
		if Pnt[scene.cur]then Pnt[scene.cur]()end
		for k,W in next,Widget[scene.cur]do
			if not(W.hide and W.hide())then
				W:draw()
			end
		end--Draw widgets
		if mouseShow then
			local r=Timer()*.5
			local R=int(r)%7+1
			local _=skin.libColor[setting.skin[R]]
			gc.setColor(_[1],_[2],_[3],min(1-abs(1-r%1*2),.3))
			gc.draw(miniBlock[R],mx,my,Timer()%3.1416*4,20,20,scs[2*R]-.5,#blocks[R][0]-scs[2*R-1]+.5)
			gc.setColor(1,1,1,.5)gc.circle("fill",mx,my,5)
			gc.setColor(1,1,1)gc.circle("fill",mx,my,3)
		end--Awesome mouse!
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
		end--guiFXs
		for i=1,#texts do
			local t=texts[i]
			local p=t.c
			gc.setColor(1,1,1,p<.2 and p*5 or p<.8 and 1 or 5-p*5)
			setFont(t.font)
			t:draw()
		end--Floating Texts
	gc.pop()
	gc.setColor(1,1,1)
	if powerInfoCanvas then
		gc.draw(powerInfoCanvas,0,0,0,scr.k)
	end--Power Info
	if scene.swapping then
		local _=scene.swap
		_.draw(_.time)
	end--Scene swapping animation
	setFont(15)
	gc.setColor(1,1,1)
	local _=scr.h-20
	gc.print(FPS(),5,_)
	if devMode>0 then
		gc.setColor(1,1,devMode==2 and .6 or 1)
		gc.print("Cache used:"..gcinfo(),5,_-20)
		gc.print("Free Row:"..freeRow.getCount(),5,_-40)
		gc.print("Mouse:"..mx.." "..my,5,_-60)
		gc.print("Voices:"..#voiceQueue,5,_-80)
		gc.print("Tasks:"..#Task,5,_-100)
		if devMode==3 then
			love.timer.sleep(.5)
		end
	end--DEV info
end
love.draw,love.update=NULL,NULL

function love.run()
	local T=love.timer
	local sleep=T.sleep
	local lastFrame,lastFreshPow=T.getTime()
	local lastFreshPow=lastFrame
	local readyDrawFrame=0
	local mini=love.window.isMinimized
	local PUMP,POLL=love.event.pump,love.event.poll
	love.resize(gc.getWidth(),gc.getHeight())
	scene.init("load")--Scene Launch
	return function()
		PUMP()
		for N,a,b,c,d,e in POLL()do
			if love[N]then
				love[N](a,b,c,d,e)
			elseif N=="quit"then
				destroyPlayers()
				return 1
			end
		end
		T.step()
		love_update(T.getDelta())
		if not mini()then
			readyDrawFrame=readyDrawFrame+setting.frameMul
			if readyDrawFrame>=100 then
				readyDrawFrame=readyDrawFrame-100
				love_draw()
				gc.present()
			end
		end
		if Timer()-lastFrame<.058 then
			sleep(.01)
		end
		while Timer()-lastFrame<.0159 do
			sleep(.001)
		end--try easily control 60FPS
		lastFrame=Timer()
		if Timer()-lastFreshPow>1 then
			updatePowerInfo()
			lastFreshPow=Timer()
		end
	end
end
function love.errorhandler(msg)
	local PUMP,POLL=love.event.pump,love.event.poll
	love.mouse.setVisible(true)
	love.audio.stop()
	local err={"Error:"..msg}
	local trace=debug.traceback("",2)
	local c=2
	for l in string.gmatch(trace,"(.-)\n")do
		if c>2 then
			if not string.find(l,"boot")then
				err[c]=string.gsub(l,"^\t*","")
				c=c+1
			end
		else
			err[2]="Traceback"
			c=3
		end
	end
	print(table.concat(err,"\n"),1,c-2)
	gc.reset()
	local CAP
	local function _(_)CAP=gc.newImage(_)end
	gc.captureScreenshot(_)
	gc.present()
	setting.sfx=setting.voc--only for error "voice" played with voice volume,not saved
	if SFX.list.error then SFX.play("error",.8)end
	local BGcolor=rnd()>.026 and{.3,.5,.9},{.62,.3,.926}
	local needDraw=true
	return function()
		PUMP()
		for E,a,b,c,d,e in POLL()do
			if E=="quit"or a=="escape"then
				destroyPlayers()
				return 1
			elseif E=="resize"then
				love.resize(a,b)
				needDraw=true
			elseif E=="focus"then
				needDraw=true
			end
		end
		if needDraw then
			gc.discard()
			gc.clear(BGcolor)
			gc.setColor(1,1,1)
			gc.push("transform")
			gc.replaceTransform(xOy)
			gc.draw(CAP,100,365,nil,512/CAP:getWidth(),288/CAP:getHeight())
			setFont(120)gc.print(":(",100,40)
			setFont(38)gc.printf(text.errorMsg,100,200,1280-100)
			setFont(20)
			gc.print(system.."-"..gameVersion,100,660)
			gc.print("scene:"..scene.cur,400,660)
			gc.printf(err[1],626,360,1260-626)
			gc.print("TRACEBACK",626,426)
			for i=4,#err-2 do
				gc.print(err[i],626,370+20*i)
			end
			gc.pop()
			gc.present()
			needDraw=false
		end
		love.timer.sleep(.2)
	end
end
-------------------------------------------------------------Reset data relied on setting
changeLanguage(setting.lang)