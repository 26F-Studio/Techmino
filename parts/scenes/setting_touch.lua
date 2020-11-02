local gc=love.graphics
local ms=love.mouse
local Timer=love.timer.getTime

local int,sin=math.floor,math.sin

function sceneInit.setting_touch()
	BG.set("rainbow")
	sceneTemp={
		default=1,
		snap=1,
		sel=nil,
	}
end
function sceneBack.setting_touch()
	FILE.saveVK()
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
function mouseDown.setting_touch(x,y,k)
	if k==2 then SCN.back()end
	sceneTemp.sel=onVK_org(x,y)or sceneTemp.sel
end
function mouseMove.setting_touch(_,_,dx,dy)
	if sceneTemp.sel and ms.isDown(1)and not WIDGET.sel then
		local B=VK_org[sceneTemp.sel]
		B.x,B.y=B.x+dx,B.y+dy
	end
end
function mouseUp.setting_touch()
	if sceneTemp.sel then
		local B=VK_org[sceneTemp.sel]
		local k=sceneTemp.snap
		B.x,B.y=int(B.x/k+.5)*k,int(B.y/k+.5)*k
	end
end
function touchDown.setting_touch(_,x,y)
	sceneTemp.sel=onVK_org(x,y)or sceneTemp.sel
end
function touchUp.setting_touch()
	if sceneTemp.sel then
		local B=VK_org[sceneTemp.sel]
		local k=sceneTemp.snap
		B.x,B.y=int(B.x/k+.5)*k,int(B.y/k+.5)*k
	end
end
function touchMove.setting_touch(_,_,_,dx,dy)
	if sceneTemp.sel and not WIDGET.sel then
		local B=VK_org[sceneTemp.sel]
		B.x,B.y=B.x+dx,B.y+dy
	end
end

local function VirtualkeyPreview()
	if SETTING.VKSwitch then
		for i=1,#VK_org do
			local B=VK_org[i]
			if B.ava then
				local c=sceneTemp.sel==i and .6 or 1
				gc.setColor(c,1,c,SETTING.VKAlpha)
				gc.setLineWidth(B.r*.07)
				gc.circle("line",B.x,B.y,B.r,10)
				if SETTING.VKIcon then gc.draw(TEXTURE.VKIcon[i],B.x,B.y,nil,B.r*.025,nil,18,18)end
			end
		end
	end
end
function Pnt.setting_touch()
	gc.setColor(1,1,1)
	gc.setLineWidth(7)gc.rectangle("line",340,15,600,690)
	gc.setLineWidth(3)gc.rectangle("line",490,85,300,600)
	VirtualkeyPreview()
	local d=sceneTemp.snap
	if d>=10 then
		gc.setLineWidth(3)
		gc.setColor(1,1,1,sin(Timer()*4)*.1+.1)
		for i=1,1280/d-1 do
			gc.line(d*i,0,d*i,720)
		end
		for i=1,720/d-1 do
			gc.line(0,d*i,1280,d*i)
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
		{9,	1280-80,	280,		80},--func
		{10,80,			280,		80},--restart
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
		{9,	80,			280,		80},--func
		{10,1280-80,	280,		80},--restart
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
		{9,	80,			360,		80},--func
		{10,80,			80,			80},--restart
	},--Author's set, not recommend
	{
		{1,	1280-400,	720-80,		80},--moveLeft
		{2,	1280-80,	720-80,		80},--moveRight
		{3,	240,		720-80,		80},--rotRight
		{4,	80,			720-80,		80},--rotLeft
		{5,	240,		720-240,	80},--rot180
		{6,	1280-240,	720-240,	80},--hardDrop
		{7,	1280-240,	720-80,		80},--softDrop
		{8,	1280-80,	720-240,	80},--hold
		{9,	80,			720-240,	80},--func
		{10,80,			320,		80},--restart
	},--Keyboard set
	{
		{10,70,		50,30},--restart
		{9,	130,	50,30},--func
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
WIDGET.init("setting_touch",{
	WIDGET.newButton({name="default",	x=520,y=90,w=200,h=80,font=35,
		code=function()
			local D=virtualkeySet[sceneTemp.default]
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
			sceneTemp.default=sceneTemp.default%5+1
			sceneTemp.sel=nil
			LOG.print("[ "..sceneTemp.default.." ]")
		end}),
	WIDGET.newSelector({name="snap",	x=760,y=90,w=200,h=80,color="yellow",list={1,10,20,40,60,80},disp=WIDGET.lnk.STPval("snap"),code=WIDGET.lnk.STPsto("snap")}),
	WIDGET.newButton({name="option",	x=520,y=190,w=200,h=80,font=40,
		code=function()
			SCN.go("setting_touchSwitch")
		end}),
	WIDGET.newButton({name="back",		x=760,y=190,w=200,h=80,font=35,code=WIDGET.lnk.BACK}),
	WIDGET.newSlider({name="size",		x=450,y=270,w=460,unit=19,font=40,show="vkSize",
		disp=function()
			return VK_org[sceneTemp.sel].r/10-1
		end,
		code=function(v)
			if sceneTemp.sel then
				VK_org[sceneTemp.sel].r=(v+1)*10
			end
		end,
		hide=function()
			return not sceneTemp.sel
		end}),
})