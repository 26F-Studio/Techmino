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