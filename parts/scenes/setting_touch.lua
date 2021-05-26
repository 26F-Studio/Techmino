local gc,ms=love.graphics,love.mouse
local int,sin=math.floor,math.sin
local VK_org=VK_org

local scene={}

local defaultSetSelect
local snapUnit=1
local selected--Button selected

local function save1()
	FILE.save(VK_org,"conf/vkSave1")
end
local function load1()
	local D=FILE.load("conf/vkSave1")
	if D then
		TABLE.update(D,VK_org)
	else
		LOG.print(text.noFile,'message')
	end
end
local function save2()
	FILE.save(VK_org,"conf/vkSave2")
end
local function load2()
	local D=FILE.load("conf/vkSave2")
	if D then
		TABLE.update(D,VK_org)
	else
		LOG.print(text.noFile,'message')
	end
end

function scene.sceneInit()
	BG.set('rainbow')
	defaultSetSelect=1
	selected=false
end
function scene.sceneBack()
	FILE.save(VK_org,'conf/virtualkey')
end

local function onVK_org(x,y)
	local dist,nearest=1e10
	for K=1,#VK_org do
		local B=VK_org[K]
		if B.ava then
			local d1=(x-B.x)^2+(y-B.y)^2
			if d1<B.r^2 then
				if d1<dist then
					nearest,dist=K,d1
				end
			end
		end
	end
	return nearest
end
function scene.mouseDown(x,y,k)
	if k==1 then scene.touchDown(x,y)end
end
function scene.mouseUp()
	scene.touchUp()
end
function scene.mouseMove(_,_,dx,dy)
	if ms.isDown(1)then
		scene.touchMove(nil,nil,dx,dy)
	end
end
function scene.touchDown(x,y)
	selected=onVK_org(x,y)or selected
end
function scene.touchUp()
	if selected then
		local B=VK_org[selected]
		B.x,B.y=int(B.x/snapUnit+.5)*snapUnit,int(B.y/snapUnit+.5)*snapUnit
	end
end
function scene.touchMove(_,_,dx,dy)
	if selected and WIDGET.isFocus(false)then
		local B=VK_org[selected]
		B.x,B.y=B.x+dx,B.y+dy
	end
end

function scene.draw()
	gc.setColor(1,1,1)
	gc.setLineWidth(3)
	gc.rectangle('line',490,65,300,610)
	VK.preview(selected)
	if snapUnit>=10 then
		gc.setLineWidth(3)
		gc.setColor(1,1,1,sin(TIME()*4)*.1+.1)
		for i=1,1280/snapUnit-1 do
			gc.line(snapUnit*i,0,snapUnit*i,720)
		end
		for i=1,720/snapUnit-1 do
			gc.line(0,snapUnit*i,1280,snapUnit*i)
		end
	end
end

local virtualkeySet={
	{
		{1,	80,			720-200,	80},--moveLeft
		{2,	320,		720-200,	80},--moveRight
		{3,	1280-80,	720-200,	80},--rotRight
		{4,	1280-200,	720-80,		80},--rotLeft
		{5,	1280-200,	720-320,	80},--rot180
		{6,	200,		720-320,	80},--hardDrop
		{7,	200,		720-80,		80},--softDrop
		{8,	1280-320,	720-200,	80},--hold
		{9,	80,			280,		80},--func1
		{10,1280-80,	280,		80},--func2
	},--Farter's tetr.js set
	{
		{1,	1280-320,	720-200,	80},--moveLeft
		{2,	1280-80,	720-200,	80},--moveRight
		{3,	200,		720-80,		80},--rotRight
		{4,	80,			720-200,	80},--rotLeft
		{5,	200,		720-320,	80},--rot180
		{6,	1280-200,	720-320,	80},--hardDrop
		{7,	1280-200,	720-80,		80},--softDrop
		{8,	320,		720-200,	80},--hold
		{9,	1280-80,	280,		80},--func1
		{10,80,			280,		80},--func2
	},--Mirrored tetr.js set
	{
		{1,	80,			720-80,		80},--moveLeft
		{2,	240,		720-80,		80},--moveRight
		{3,	1280-240,	720-80,		80},--rotRight
		{4,	1280-400,	720-80,		80},--rotLeft
		{5,	1280-240,	720-240,	80},--rot180
		{6,	1280-80,	720-80,		80},--hardDrop
		{7,	1280-80,	720-240,	80},--softDrop
		{8,	1280-80,	720-400,	80},--hold
		{9,	80,			720-240,	80},--func1
		{10,240,		720-240,	80},--func2
	},--Author's set, not recommend
	{
		{1,	1280-400,	720-80,		80},--moveLeft
		{2,	1280-80,	720-80,		80},--moveRight
		{3,	240,		720-80,		80},--rotRight
		{4,	80,			720-80,		80},--rotLeft
		{5,	240,		720-240,	80},--rot180
		{6,	1280-240,	720-240,	80},--hardDrop
		{7,	1280-240,	720-80,		80},--softDrop
		{8,	400,		720-80,		80},--hold
		{9,	80,			720-240,	80},--func1
		{10,80,			720-400,	80},--func2
	},--Keyboard set
	{
		{9,	70,		50,30},--func1
		{10,130,	50,30},--func2
		{4,	190,	50,30},--rotLeft
		{3,	250,	50,30},--rotRight
		{5,	310,	50,30},--rot180
		{1,	370,	50,30},--moveLeft
		{2,	430,	50,30},--moveRight
		{8,	490,	50,30},--hold
		{7,	550,	50,30},--softDrop1
		{6,	610,	50,30},--hardDrop
		{11,670,	50,30},--insLeft
		{12,730,	50,30},--insRight
		{13,790,	50,30},--insDown
		{14,850,	50,30},--down1
		{15,910,	50,30},--down4
		{16,970,	50,30},--down10
		{17,1030,	50,30},--dropLeft
		{18,1090,	50,30},--dropRight
		{19,1150,	50,30},--zangiLeft
		{20,1210,	50,30},--zangiRight
	},--PC key feedback(top&in a row)
}
scene.widgetList={
	WIDGET.newButton{name="default",x=530,y=90,w=200,h=80,font=35,
		code=function()
			local D=virtualkeySet[defaultSetSelect]
			for i=1,#VK_org do
				VK_org[i].ava=false
			end

			--Replace keys
			for n=1,#D do
				local T=D[n]
				if T[1]then
					local B=VK_org[n]
					B.ava=true
					B.x,B.y,B.r=T[2],T[3],T[4]
				end
			end
			LOG.print(("==[ %d ]=="):format(defaultSetSelect))
			defaultSetSelect=defaultSetSelect%5+1
			selected=false
		end},
	WIDGET.newSelector{name="snap",	x=750,y=90,w=200,h=80,color='Y',list={1,10,20,40,60,80},disp=function()return snapUnit end,code=function(i)snapUnit=i end},
	WIDGET.newButton{name="option",	x=530,y=190,w=200,h=80,font=40,code=function()SCN.go('setting_touchSwitch')end},
	WIDGET.newButton{name="back",	x=750,y=190,w=200,h=80,font=35,code=backScene},
	WIDGET.newKey{name="save1",		x=475,y=290,w=90,h=70,code=save1},
	WIDGET.newKey{name="load1",		x=585,y=290,w=90,h=70,code=load1},
	WIDGET.newKey{name="save2",		x=695,y=290,w=90,h=70,code=save2},
	WIDGET.newKey{name="load2",		x=805,y=290,w=90,h=70,code=load2},
	WIDGET.newSlider{name="size",	x=440,y=370,w=460,unit=19,font=40,show="vkSize",
		disp=function()
			return VK_org[selected].r/10-1
		end,
		code=function(v)
			if selected then
				VK_org[selected].r=(v+1)*10
			end
		end,
		hideF=function()
			return not selected
		end},
	WIDGET.newKey{name="shape",x=640,y=600,w=200,h=80,code=function()SETTING.VKSkin=VK.nextShape()end},
}

return scene