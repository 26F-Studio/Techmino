local gc=love.graphics
local next=next
local SETTING,TIME=SETTING,TIME
local VK_org=VK_org

--Virtualkey icons
local VKIcon={}
gc.setDefaultFilter('nearest','nearest')
local VKI=gc.newImage("media/image/virtualkey.png")
for i=1,20 do VKIcon[i]=DOGC{36,36,{"draw",VKI,(i-1)%5*-36,math.floor((i-1)*.2)*-36}}end
gc.setDefaultFilter('linear','linear')

--In-game virtualkey layout data
local keys={}for i=1,#VK_org do keys[i]={}end

local VK={keys=keys}


function VK.on(x,y)
	local dist,nearest=1e10
	for id,B in next,keys do
		if B.ava then
			local d1=(x-B.x)^2+(y-B.y)^2
			if d1<B.r^2 then
				if d1<dist then
					nearest,dist=id,d1
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
			for _,b in next,keys do
				local d=B.r+b.r-((B.x-b.x)^2+(B.y-b.y)^2)^.5--Hit depth(Neg means distance)
				if d>0 then
					b.x=b.x+(b.x-B.x)*d*b.r*2.6e-5
					b.y=b.y+(b.y-B.y)*d*b.r*2.6e-5
				end
			end
		end
	end
	SFX.play('virtualKey',SETTING.VKSFX)
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
		B.isDown=false
		B.pressTime=0
	end
	for id,v in next,PLAYERS[1].keyAvailable do
		if not v then
			keys[id].ava=false
		end
	end
end

function VK.update()
	if SETTING.VKSwitch then
		for _,B in next,keys do
			if B.pressTime>0 then
				B.pressTime=B.pressTime-1
			end
		end
	end
end

local gc_draw,gc_setColor,gc_setLineWidth=gc.draw,gc.setColor,gc.setLineWidth
local buttonImage=DOGC{100,100,
	{'setLW',4},{'dRect',2,2,96,96},
	{'setLW',4},{'dRect',10,10,80,80},
}
local rippleImage=DOGC{100,100,
	{'setLW',4},{'dRect',2,2,96,96},
}
local holdImage=DOGC{100,100,
	{'fRect',14,14,72,72},
}
function VK.draw()
	if not SETTING.VKSwitch then return end
	local a=SETTING.VKAlpha
	if SETTING.VKIcon then
		for i,B in next,keys do
			if B.ava then
				local r=B.r*.71
				--Button outline
				gc_setColor(1,1,1,a)
				gc_setLineWidth(r*.07)
				gc_draw(buttonImage,B.x,B.y,nil,r/50,nil,50,50)

				--Icon
				local _=B.pressTime
				gc_setColor(1,1,1,a)
				gc_draw(VKIcon[i],B.x,B.y,nil,r*.026+_*.06,nil,18,18)

				--Ripple
				if _>0 then
					gc_setColor(1,1,1,a*_*.08)
					local d=r*(1.4-_*.04)
					gc_draw(rippleImage,B.x,B.y,nil,d/50,nil,50,50)
				end

				--Glow when press
				if B.isDown then
					gc_setColor(1,1,1,a*.4)
					gc_draw(holdImage,B.x,B.y,nil,r/50,nil,50,50)
				end
			end
		end
	else
		for _,B in next,keys do
			if B.ava then
				local r=B.r*.71
				gc_setColor(1,1,1,a)
				gc_setLineWidth(r*.07)
				gc_draw(buttonImage,B.x,B.y,nil,r/50,nil,50,50)
				local _=B.pressTime
				if _>0 then
					gc_setColor(1,1,1,a*_*.08)
					gc_draw(holdImage,B.x,B.y,nil,r/50,nil,50,50)
					local d=r*(1.4-_*.04)
					gc_draw(rippleImage,B.x,B.y,nil,d/50,nil,50,50)
				end
			end
		end
	end
end
function VK.preview(selected)
	if not SETTING.VKSwitch then return end
	for id,B in next,VK_org do
		if B.ava then
			local r=B.r*.71
			gc_setColor(1,1,1,SETTING.VKAlpha)
			gc_setLineWidth(r*.07)
			gc_draw(buttonImage,B.x,B.y,nil,r/50,nil,50,50)
			if selected==id and TIME()%.26<.13 then
				gc_setColor(1,1,1,SETTING.VKAlpha*.62)
				gc_draw(holdImage,B.x,B.y,nil,r/50,nil,50,50)
			end
			if SETTING.VKIcon then
				gc_setColor(1,1,1,SETTING.VKAlpha)
				gc_draw(VKIcon[id],B.x,B.y,nil,r*.026,nil,18,18)
			end
		end
	end
end

return VK