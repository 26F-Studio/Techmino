local gc=love.graphics
local gc_draw,gc_rectangle,gc_print,gc_printf=gc.draw,gc.rectangle,gc.print,gc.printf
local gc_setColor,gc_setLineWidth,gc_translate=gc.setColor,gc.setLineWidth,gc.translate
local gc_stencil,gc_setStencilTest=gc.stencil,gc.setStencilTest

local rnd,min=math.random,math.min
local sin,cos=math.sin,math.cos
local ins=table.insert
local setFont=setFont

local posLists={
	--1~5
	(function()
		local L={}
		for i=1,5 do
			L[i]={x=70,y=20+90*i,w=790,h=80}
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
local function _placeSort(a,b)return a.place<b.place end

local PLYlist,PLYmap={},{}
local function freshPosList()
	table.sort(PLYlist,_placeSort)
	if #PLYlist<=5 then
		posList=posLists[1]
	elseif #PLYlist<=17 then
		posList=posLists[2]
	elseif #PLYlist<=31 then
		posList=posLists[3]
	elseif #PLYlist<=49 then
		posList=posLists[4]
	else--if #PLY<=99 then
		posList=posLists[5]
	end
end
local netPLY={
	list=PLYlist,
	map=PLYmap,
	freshPos=freshPosList,
}

function netPLY.clear()
	TABLE.cut(PLYlist)
	TABLE.clear(PLYmap)
end
function netPLY.add(p)
	p.connected=false
	p.username=p.username
	p.place=1e99
	p.stat=false
	local a=rnd()*6.2832
	p.x,p.y,p.w,p.h=640+2600*cos(a),360+2600*sin(a),47,47

	ins(PLYlist,p)
	PLYmap[p.uid]=p
	freshPosList()
end

function netPLY.getCount()return #PLYlist end
function netPLY.getSID(uid)return PLYmap[uid].sid end
function netPLY.getSelfJoinMode()return PLYmap[USER.uid].mode end
function netPLY.getSelfReady()return PLYmap[USER.uid].mode>0 end

function netPLY.setPlayerObj(ply,p)ply.p=p end
function netPLY.setConf(uid,config)PLYmap[uid].config=config end
function netPLY.setJoinMode(uid,ready)
	for _,p in next,PLYlist do
		if p.uid==uid then
			if p.mode~=ready then
				p.mode=ready
				if ready==0 then NET.allReady=false end
				SFX.play('spin_0',.6)
				if p.uid==USER.uid then
					NET.unlock('ready')
				elseif PLYmap[USER.uid].mode==0 then
					for j=1,#PLYlist do
						if not p.uid==USER.uid and PLYlist[j].mode==0 then
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
function netPLY.setConnect(uid)PLYmap[uid].connected=true end
function netPLY.setPlace(uid,place)PLYmap[uid].place=place end
function netPLY.setStat(uid,S)
	PLYmap[uid].stat={
		lpm=("%.1f %s"):format(S.row/S.time*60,text.radarData[5]),
		apm=("%.1f %s"):format(S.atk/S.time*60,text.radarData[3]),
		adpm=("%.1f %s"):format((S.atk+S.dig)/S.time*60,text.radarData[2]),
	}
end
function netPLY.resetState()
	for i=1,#PLYlist do
		PLYlist[i].mode=0
		PLYlist[i].connected=false
	end
end

local selP,mouseX,mouseY
function netPLY.mouseMove(x,y)
	selP=nil
	for i=1,#PLYlist do
		local p=PLYlist[i]
		if x>p.x and y>p.y and x<p.x+p.w and y<p.y+p.h then
			mouseX,mouseY=x,y
			selP=p
			break
		end
	end
end

function netPLY.update()
	for i=1,#PLYlist do
		local p=PLYlist[i]
		local t=posList[i]
		p.x=p.x*.9+t.x*.1
		p.y=p.y*.9+t.y*.1
		p.w=p.w*.9+t.w*.1
		p.h=p.h*.9+t.h*.1
	end
end

local stencilW,stencilH
local function plyStencil()
	gc_rectangle('fill',0,0,stencilW,stencilH)
end
function netPLY.draw()
	for i=1,#PLYlist do
		local p=PLYlist[i]
		gc_translate(p.x,p.y)
			--Rectangle
			gc_setColor(COLOR[
				p.mode==0 and'Z'or
				p.mode==1 and(p.connected and"N"or"G")or
				p.mode==2 and(p.connected and"Y"or"F")
			])
			gc_setLineWidth(2)
			gc_rectangle('line',0,0,p.w,p.h)

			--Stencil
			stencilW,stencilH=p.w,p.h
			gc_setStencilTest('equal',1)
				gc_stencil(plyStencil,'replace',1)
				gc_setColor(1,1,1)

				--Avatar
				local avatarSize=min(p.h,50)/128*.9
				gc_draw(USERS.getAvatar(p.uid),2,2,nil,avatarSize)

				--UID & Username
				if p.h>=47 then
					setFont(40)
					gc_print("#"..p.uid,50,-5)
					gc_print(p.username,210,-5)
				else
					setFont(15)
					gc_print("#"..p.uid,46,-1)
					setFont(30)
					gc_print(p.username,p.h,8)
				end

				--Stat
				local S=p.stat
				if S and(p.h>=55 or p.w>=180)then
					setFont(20)
					local x=p.w-155
					if p.h>=55 then
						gc_printf(S.adpm,x,2,150,'right')
						gc_printf(S.apm,x,24,150,'right')
						gc_printf(S.lpm,x,46,150,'right')
					else
						gc_printf(S.adpm,x,0,150,'right')
						gc_printf(S.lpm,x,19,150,'right')
					end
				end
			gc_setStencilTest()
		gc_translate(-p.x,-p.y)
	end
	if selP then
		gc_translate(min(mouseX,880),min(mouseY,460))
			gc_setColor(.2,.2,.2,.7)
			gc_rectangle('fill',0,0,400,260)
			gc_setColor(1,1,1)
			gc_setLineWidth(2)
			gc_rectangle('line',0,0,400,260)

			gc_draw(USERS.getAvatar(selP.uid),5,5,nil,.5)
			setFont(30)
			gc_print("#"..selP.uid,75,0)
			setFont(35)
			gc_print(selP.username,75,25)
			setFont(20)
			gc_printf(USERS.getMotto(selP.uid),5,70,390)
			if selP.stat then
				local S=selP.stat
				gc_print(S.lpm,5,193)
				gc_print(S.apm,5,213)
				gc_print(S.adpm,5,233)
			end
		gc_translate(-min(mouseX,880),-min(mouseY,460))
	end
end

return netPLY