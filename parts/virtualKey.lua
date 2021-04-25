local gc=love.graphics

local SETTING=SETTING

--Virtualkey icons
local VKIcon={}
gc.setDefaultFilter("nearest","nearest")
local VKI=gc.newImage("media/image/virtualkey.png")
for i=1,20 do VKIcon[i]=DOGC{36,36,{"draw",VKI,(i-1)%5*-36,math.floor((i-1)*.2)*-36}}end
gc.setDefaultFilter("linear","linear")

--In-game virtualkey layout data
local keys={}for i=1,#VK_org do keys[i]={}end

local VK={keys=keys}


function VK.on(x,y)
	local dist,nearest=1e10
	for K=1,#keys do
		local B=keys[K]
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

function VK.touch(id,x,y)
	local B=keys[id]
	B.isDown=true
	B.pressTime=10

	if SETTING.VKTrack then
		--Auto follow
		local O=VK_org[id]
		local _FW,_CW=SETTING.VKTchW,1-SETTING.VKCurW
		local _OW=1-_FW-_CW
		--(finger+current+origin)
		B.x=x*_FW+B.x*_CW+O.x*_OW
		B.y=y*_FW+B.y*_CW+O.y*_OW

		--Button collision (not accurate)
		if SETTING.VKDodge then
			for i=1,#keys do
				local b=keys[i]
				local d=B.r+b.r-((B.x-b.x)^2+(B.y-b.y)^2)^.5--Hit depth(Neg means distance)
				if d>0 then
					b.x=b.x+(b.x-B.x)*d*b.r*2.6e-5
					b.y=b.y+(b.y-B.y)*d*b.r*2.6e-5
				end
			end
		end
	end
	SFX.play("virtualKey",SETTING.VKSFX)
	VIB(SETTING.VKVIB)
end

function VK.press(id)
	keys[id].isDown=true
	keys[id].pressTime=10
end

function VK.release(id)
	keys[id].isDown=false
end

function VK.switchKey(id,on)
	keys[id].ava=on
end

function VK.restore()
	for i=1,#VK_org do
		local B,O=keys[i],VK_org[i]
		B.ava=O.ava
		B.x=O.x
		B.y=O.y
		B.r=O.r
		B.color=O.color
		B.isDown=false
		B.pressTime=0
	end
	for k,v in next,PLAYERS[1].keyAvailable do
		if not v then
			keys[k].ava=false
		end
	end
end

function VK.update()
	if SETTING.VKSwitch then
		for i=1,#keys do
			local _=keys[i]
			if _.pressTime>0 then
				_.pressTime=_.pressTime-1
			end
		end
	end
end

local gc_circle,gc_draw,gc_setColor,gc_setLineWidth=gc.circle,gc.draw,gc.setColor,gc.setLineWidth
function VK.draw()
	if SETTING.VKSwitch then
		local a=SETTING.VKAlpha
		if SETTING.VKIcon then
			for i=1,#keys do
				if keys[i].ava then
					local B=keys[i]

					--Button outline
					gc_setColor(1,1,1,a)
					gc_setLineWidth(B.r*.07)
					gc_circle("line",B.x,B.y,B.r,10)

					--Icon
					local _=keys[i].pressTime
					local c=B.color
					gc_setColor(c[1],c[2],c[3],a)
					gc_draw(VKIcon[i],B.x,B.y,nil,B.r*.026+_*.08,nil,18,18)

					--Ripple
					if _>0 then
						gc_setColor(1,1,1,a*_*.08)
						gc_circle("line",B.x,B.y,B.r*(1.4-_*.04),10)
					end

					--Glow when press
					if B.isDown then
						gc_setColor(1,1,1,a*.4)
						gc_circle("fill",B.x,B.y,B.r*.94,10)
					end
				end
			end
		else
			for i=1,#keys do
				if keys[i].ava then
					local B=keys[i]
					gc_setColor(1,1,1,a)
					gc_setLineWidth(B.r*.07)
					gc_circle("line",B.x,B.y,B.r,10)
					local _=keys[i].pressTime
					if _>0 then
						gc_setColor(1,1,1,a*_*.08)
						gc_circle("fill",B.x,B.y,B.r*.94,10)
						gc_circle("line",B.x,B.y,B.r*(1.4-_*.04),10)
					end
				end
			end
		end
	end
end
function VK.preview(selected)
	if SETTING.VKSwitch then
		for i=1,#VK_org do
			local B=VK_org[i]
			if B.ava then
				gc_setColor(1,1,1,SETTING.VKAlpha)
				gc_setLineWidth(B.r*.07)
				gc_circle("line",B.x,B.y,B.r,10)
				if selected==i and TIME()%.26<.13 then
					gc_setColor(1,1,1,SETTING.VKAlpha*.62)
					gc_circle("fill",B.x,B.y,B.r,10)
				end
				if SETTING.VKIcon then
					local c=B.color
					gc_setColor(c[1],c[2],c[3],SETTING.VKAlpha)
					gc_draw(VKIcon[i],B.x,B.y,nil,B.r*.025,nil,18,18)
				end
			end
		end
	end
end

return VK