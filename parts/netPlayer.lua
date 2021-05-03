local gc=love.graphics
local ins,rem=table.insert,table.remove

local posLists={
	--1~5
	(function()
		local L={}
		for i=1,5 do
			L[i]={x=40,y=65+50*i,w=1000,h=46}
		end
		return L
	end)(),
	--6~17
	(function()
		local L={}
		for i=1,17 do
			L[i]={x=40,y=65+50*i,w=1000,h=46}
		end
		return L
	end)(),
	--18~31
	(function()
		local L={}
		for i=1,31 do
			L[i]={x=40,y=65+50*i,w=1000,h=46}
		end
		return L
	end)(),
	--32~49
	(function()
		local L={}
		for i=1,49 do
			L[i]={x=40,y=65+50*i,w=1000,h=46}
		end
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
	elseif #PLY<=15 then
		posList=posLists[2]
	elseif #PLY<=30 then
		posList=posLists[3]
	end
end

function netPLY.clear()
	while PLY[1]do rem(PLY)end
end
function netPLY.add(p)
	ins(PLY,p.uid==USER.uid and 1 or #PLY+1,p)
	p.x,p.y,p.w,p.h=640,2600,0,0
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

function netPLY.draw()
	for i=1,#PLY do
		local p=PLY[i]
		gc.translate(p.x,p.y)
		--Rectangle
		gc.setColor(COLOR[p.ready and'G'or'Z'])
		gc.setLineWidth(2)
		gc.rectangle('line',0,0,p.w,p.h)

		--UID
		setFont(40)
		gc.setColor(.5,.5,.5)
		gc.print("#"..p.uid,10,-5)

		--Avatar
		gc.setColor(1,1,1)
		gc.draw(USERS.getAvatar(p.uid),160,3,nil,.3125)

		--Username
		gc.print(p.username,210,-5)
		gc.translate(-p.x,-p.y)
	end
end

return netPLY