local gc=love.graphics
local max,min=math.max,math.min

local ins,rem=table.insert,table.remove

local posLists={
	--1~5
	(function()
		local L={}
		for i=1,5 do
			L[i]={x=70,y=20+90*i,w=1000,h=80}
		end
		return L
	end)(),
	--6~17
	(function()
		local L={}
		for i=1,10 do
			L[i]={x=40,y=60+55*i,w=520,h=50}
		end
		for i=1,7 do
			L[10+i]={x=600,y=60+55*i,w=520,h=50}
		end
		return L
	end)(),
	--18~31
	(function()
		local L={}
		for i=1,11 do L[i]=		{x=40,y=65+50*i,w=330,h=45}end
		for i=1,11 do L[11+i]=	{x=400,y=65+50*i,w=330,h=45}end
		for i=1,9 do L[22+i]=	{x=760,y=65+50*i,w=330,h=45}end
		return L
	end)(),
	--32~49
	(function()
		local L={}
		for i=1,10 do L[i]=		{x=30,y=60+50*i,w=200,h=45}end
		for i=1,10 do L[10+i]=	{x=240,y=60+50*i,w=200,h=45}end
		for i=1,10 do L[20+i]=	{x=450,y=60+50*i,w=200,h=45}end
		for i=1,10 do L[30+i]=	{x=660,y=60+50*i,w=200,h=45}end
		for i=1,9 do L[40+i]=	{x=870,y=60+50*i,w=200,h=45}end
		return L
	end)(),
	--50~99
	(function()
		local L={}
		for i=1,11 do L[i]=		{x=30,y=60+50*i,w=100,h=45}end
		for i=1,11 do L[i+11]=	{x=135,y=60+50*i,w=100,h=45}end
		for i=1,11 do L[i+22]=	{x=240,y=60+50*i,w=100,h=45}end
		for i=1,11 do L[i+33]=	{x=345,y=60+50*i,w=100,h=45}end
		for i=1,11 do L[i+44]=	{x=450,y=60+50*i,w=100,h=45}end
		for i=1,11 do L[i+55]=	{x=555,y=60+50*i,w=100,h=45}end
		for i=1,11 do L[i+66]=	{x=660,y=60+50*i,w=100,h=45}end
		for i=1,11 do L[i+77]=	{x=765,y=60+50*i,w=100,h=45}end
		for i=1,7 do L[i+88]=	{x=870,y=60+50*i,w=100,h=45}end
		for i=1,4 do L[i+95]=	{x=975,y=60+50*i,w=100,h=45}end
		return L
	end)(),
}
local posList

local PLY=setmetatable({},{
	__index=function(self,uid)
		for _,p in next,self do
			if p.uid==uid then
				return p
			end
		end
	end
})

local netPLY={list=PLY}

local function freshPosList()
	if #PLY<=5 then
		posList=posLists[1]
	elseif #PLY<=17 then
		posList=posLists[2]
	elseif #PLY<=31 then
		posList=posLists[3]
	elseif #PLY<=49 then
		posList=posLists[4]
	else--if #PLY<=99 then
		posList=posLists[5]
	end
end

function netPLY.clear()
	while PLY[1]do rem(PLY)end
end
function netPLY.add(p)
	ins(PLY,p.uid==USER.uid and 1 or #PLY+1,p)
	p.x,p.y,p.w,p.h=2600,2600,0,0
	freshPosList()
end
function netPLY.remove(sid)
	for i=1,#PLY do
		if PLY[i].sid==sid then
			rem(PLY,i)
			break
		end
	end
	freshPosList()
end

function netPLY.getCount()return #PLY end
function netPLY.getUID(i)return PLY[i].uid end
function netPLY.getUsername(uid)return PLY[uid].username end
function netPLY.getSID(i)return PLY[i].sid end
function netPLY.getReady(i)return PLY[i].ready end
function netPLY.getConfig(i)return PLY[i].config end

function netPLY.setPlayerObj(uid,p)
	PLY[uid].p=p
end
function netPLY.setConf(uid,config)
	if tostring(USER.uid)~=uid then
		PLY[uid].config=config
	end
end
function netPLY.setReady(uid,ready)
	for i,p in next,PLY do
		if p.uid==uid then
			if p.ready~=ready then
				p.ready=ready
				if not ready then NET.allReady=false end
				SFX.play('spin_0',.6)
				if i==1 then
					NET.unlock('ready')
				elseif not PLY[1].ready then
					for j=2,#PLY do
						if not PLY[j].ready then
							return
						end
					end
					SFX.play('blip_2',.5)
				end
			end
			return
		end
	end
end
function netPLY.resetReady()
	for i=1,#PLY do
		PLY[i].ready=false
	end
end

local selP,mouseX,mouseY
function netPLY.mouseMove(x,y)
	selP=nil
	for i=1,#PLY do
		local p=PLY[i]
		if x>p.x and y>p.y and x<p.x+p.w and y<p.y+p.h then
			mouseX,mouseY=x,y
			selP=p
			break
		end
	end
end

function netPLY.update(dt)
	for i=1,#PLY do
		local p=PLY[i]
		local t=posList[i]
		p.x=p.x*.9+t.x*.1
		p.y=p.y*.9+t.y*.1
		p.w=p.w*.9+t.w*.1
		p.h=p.h*.9+t.h*.1
	end
end

local stencilW,stencilH
local function plyStencil()
	gc.rectangle('fill',0,0,stencilW,stencilH)
end
function netPLY.draw()
	for i=1,#PLY do
		local p=PLY[i]
		gc.translate(p.x,p.y)
			--Rectangle
			gc.setColor(COLOR[p.ready and'G'or'Z'])
			gc.setLineWidth(2)
			gc.rectangle('line',0,0,p.w,p.h)

			--Stencil
			stencilW,stencilH=p.w,p.h
			gc.setStencilTest('equal',1)
				gc.stencil(plyStencil,'replace',1)
				gc.setColor(1,1,1)

				--Avatar
				local avatarSize=min(p.h,50)/128*.9
				gc.draw(USERS.getAvatar(p.uid),2,2,nil,avatarSize)

				--UID & Username
				if p.h>=47 then
					setFont(40)
					gc.print("#"..p.uid,50,-5)
					gc.print(p.username,210,-5)
				else
					setFont(159)
					gc.print("#"..p.uid,p.h,-2)
					setFont(30)
					gc.print(p.username,p.h,8)
				end
			gc.setStencilTest()
		gc.translate(-p.x,-p.y)
	end
	if selP then
		gc.translate(min(mouseX,880),min(mouseY,460))
			gc.setColor(.2,.2,.2,.7)
			gc.rectangle('fill',0,0,400,260)
			gc.setColor(1,1,1)
			gc.setLineWidth(2)
			gc.rectangle('line',0,0,400,260)

			gc.draw(USERS.getAvatar(selP.uid),5,5,nil,.5)
			setFont(30)
			gc.print("#"..selP.uid,75,0)
			setFont(35)
			gc.print(selP.username,75,25)
		gc.translate(-min(mouseX,880),-min(mouseY,460))
	end
end

return netPLY