local gc=love.graphics
local abs=math.abs
local SCR=SCR

local scenes={}

local SCN={
	cur="NULL",--Current scene name
	swapping=false,--If Swapping
	stat={
		tar=false,	--Swapping target
		style=false,--Swapping style
		mid=false,	--Loading point
		time=false,	--Full swap time
		draw=false,	--Swap draw  func
	},
	stack={"quit","slowFade"},--Scene stack

	scenes=scenes,

	--Events
	update=false,
	draw=false,
	mouseClick=false,
	touchClick=false,
	mouseDown=false,
	mouseMove=false,
	mouseUp=false,
	wheelMoved=false,
	touchDown=false,
	touchUp=false,
	touchMove=false,
	keyDown=false,
	keyUp=false,
	gamepadDown=false,
	gamepadUp=false,
	socketRead=false,
}--Scene datas, returned

function SCN.add(name,scene)
	scenes[name]=scene
	if not scene.widgetList then scene.widgetList={}end
	setmetatable(scene.widgetList,WIDGET.indexMeta)
end

function SCN.swapUpdate()
	local S=SCN.stat
	S.time=S.time-1
	if S.time==S.mid then
		SCN.init(S.tar,SCN.cur)
		collectgarbage()
		--Scene swapped this moment
	end
	if S.time==0 then
		SCN.swapping=false
	end
end
function SCN.init(s,org)
	local S=scenes[s]
	SCN.cur=s

	SCN.sceneInit=S.sceneInit
	SCN.sceneBack=S.sceneBack
	SCN.update=S.update
	SCN.draw=S.draw
	SCN.mouseClick=S.mouseClick
	SCN.touchClick=S.touchClick
	SCN.mouseDown=S.mouseDown
	SCN.mouseMove=S.mouseMove
	SCN.mouseUp=S.mouseUp
	SCN.wheelMoved=S.wheelMoved
	SCN.touchDown=S.touchDown
	SCN.touchUp=S.touchUp
	SCN.touchMove=S.touchMove
	SCN.keyDown=S.keyDown
	SCN.keyUp=S.keyUp
	SCN.gamepadDown=S.gamepadDown
	SCN.gamepadUp=S.gamepadUp
	SCN.socketRead=S.socketRead
	if S.sceneInit then S.sceneInit(org)end
	WIDGET.set(S.widgetList)
end
function SCN.push(tar,style)
	if not SCN.swapping then
		local m=#SCN.stack
		SCN.stack[m+1]=tar or SCN.cur
		SCN.stack[m+2]=style or"fade"
	end
end
function SCN.pop()
	local _=SCN.stack
	_[#_],_[#_-1]=nil
end

local swap={
	none={1,0,NULL},--swapTime, changeTime, drawFunction
	flash={8,1,function()gc.clear(1,1,1)end},
	fade={30,15,function(t)
		t=t>15 and 2-t/15 or t/15
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
	end},
	fade_togame={120,20,function(t)
		t=t>20 and(120-t)/100 or t/20
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
	end},
	slowFade={180,90,function(t)
		t=t>90 and 2-t/90 or t/90
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,SCR.w,SCR.h)
	end},
	swipeL={30,15,function(t)
		t=t/30
		gc.setColor(.1,.1,.1,1-abs(t-.5))
		t=t*t*(3-2*t)*2-1
		gc.rectangle("fill",t*SCR.w,0,SCR.w,SCR.h)
	end},
	swipeR={30,15,function(t)
		t=t/30
		gc.setColor(.1,.1,.1,1-abs(t-.5))
		t=t*t*(2*t-3)*2+1
		gc.rectangle("fill",t*SCR.w,0,SCR.w,SCR.h)
	end},
	swipeD={30,15,function(t)
		t=t/30
		gc.setColor(.1,.1,.1,1-abs(t-.5))
		t=t*t*(2*t-3)*2+1
		gc.rectangle("fill",0,t*SCR.h,SCR.w,SCR.h)
	end},
}--Scene swapping animations
function SCN.swapTo(tar,style)--Parallel scene swapping, cannot back
	if scenes[tar]then
		local S=SCN.stat
		if not SCN.swapping and tar~=SCN.cur then
			if not style then style="fade"end
			SCN.swapping=true
			S.tar,S.style=tar,style
			S.time,S.mid,S.draw=unpack(swap[style])
		end
	else
		LOG.print("No Scene: "..tar,"warn")
	end
end
function SCN.go(tar,style)--Normal scene swapping, can back
	if scenes[tar]then
		SCN.push()
		SCN.swapTo(tar,style)
	else
		LOG.print("No Scene: "..tar,"warn")
	end
end
function SCN.back()
	--Leave scene
	if SCN.sceneBack then SCN.sceneBack()end

	--Poll&Back to previous Scene
	local m=#SCN.stack
	if m>0 then
		SCN.swapTo(SCN.stack[m-1],SCN.stack[m])
		SCN.stack[m],SCN.stack[m-1]=nil
	end
end
return SCN