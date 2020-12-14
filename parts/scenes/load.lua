local gc=love.graphics
local tc=love.touch
local Timer=love.timer.getTime

local max,min,sin=math.max,math.min,math.sin

local function tick_httpREQ_launch(task)
	local time=0
	while true do
		coroutine.yield()
		local response,request_error=client.poll(task)
		if response then
			local res=json.decode(response.body)
			if res then
				if response.code==200 then
					LOG.print(res.notice,360,COLOR.sky)
					if VERSION_CODE>=res.version_code then
						LOG.print(text.versionIsNew,360,COLOR.sky)
					else
						LOG.print(string.gsub(text.versionIsOld,"$1",res.version_name),"warn")
					end
				else
					LOG.print(text.netErrorCode..response.code..": "..res.message,"warn")
				end
			end
			return
		elseif request_error then
			LOG.print(text.getNoticeFail..": "..request_error,"warn")
			return
		end
		time=time+1
		if time>360 then
			LOG.print(text.httpTimeout,"message")
			return
		end
	end
end
local function tick_httpREQ_autoLogin(task)
	local time=0
	while true do
		coroutine.yield()
		local response,request_error=client.poll(task)
		if response then
			if response.code==200 then
				LOGIN=true
				local res=json.decode(response.body)
				if res then
					LOG.print(text.loginSuccessed)
				end
			else
				LOGIN=false
				local err=json.decode(response.body)
				if err then
					LOG.print(text.loginFailed..": "..text.netErrorCode..response.code.."-"..err.message,"warn")
				end
			end
			return
		elseif request_error then
			LOG.print(text.loginFailed..": "..request_error,"warn")
			return
		end
		time=time+1
		if time>360 then
			LOG.print(text.httpTimeout,"message")
			return
		end
	end
end

local scene={}

local time--Animation timer
local phase--Loading stage
local loadCur--Loading timer
local loadTar--Current Loading bar length
local stageLenth--Length of each stage
local studioLogo--Studio logo text object
local skip

function scene.sceneInit()
	time=0
	phase=0
	loadCur=0
	loadTar=0
	stageLenth={
		VOC.getCount(),
		BGM.getCount(),
		SFX.getCount(),
		IMG.getCount(),
		17,--Fontsize 20~100
		SKIN.getCount(),
		#MODES,
		1,
		1,
	}
	studioLogo=gc.newText(getFont(80),"26F Studio")
	skip=false--If skipped
end
function scene.sceneBack()
	love.event.quit()
end

function scene.keyDown(k)
	if k=="a"then
		skip=true
	elseif k=="s"then
		skip,MARKING=true
	elseif k=="space"then
		time=max(time-5,0)
	elseif k=="escape"then
		SCN.back()
	end
end
function scene.touchDown()
	if #tc.getTouches()==2 then
		skip=true
	end
end

function scene.update()
	if time==400 then return end
	repeat
		if phase==0 then
		elseif phase==1 then
			VOC.loadOne()
		elseif phase==2 then
			BGM.loadOne()
		elseif phase==3 then
			SFX.loadOne()
		elseif phase==4 then
			IMG.loadOne()
		elseif phase==5 then
			getFont(15+5*loadCur)
		elseif phase==6 then
			SKIN.loadOne()
		elseif phase==7 then
			local m=MODES[loadCur]--Mode template
			local M=require("parts/modes/"..m.name)--Mode file
			MODES[m.name],MODES[loadCur]=M
			for k,v in next,m do
				M[k]=v
			end
			M.records=FILE.load(m.name..".dat")or M.score and{}
			-- M.icon=gc.newImage("media/image/modeIcon/"..m.icon..".png")
			-- M.icon=gc.newImage("media/image/modeIcon/custom.png")
		elseif phase==8 then
			local function C(x,y)
				local _=gc.newCanvas(x,y)
				gc.setCanvas(_)
				return _
			end

			puzzleMark={}
			gc.setLineWidth(3)
			for i=1,17 do
				puzzleMark[i]=C(30,30)
				local _=SKIN.libColor[i]
				gc.setColor(_[1],_[2],_[3],.6)
				gc.rectangle("line",5,5,20,20)
				gc.rectangle("line",10,10,10,10)
			end
			for i=18,24 do
				puzzleMark[i]=C(30,30)
				gc.setColor(SKIN.libColor[i])
				gc.rectangle("line",7,7,16,16)
			end
			local _=C(30,30)
			gc.setColor(1,1,1)
			gc.line(5,5,25,25)
			gc.line(5,25,25,5)
			puzzleMark[-1]=C(30,30)
			gc.setColor(1,1,1,.8)
			gc.draw(_)
			_:release()
			gc.setCanvas()
		elseif phase==9 then
			SKIN.change(SETTING.skinSet)
			STAT.run=STAT.run+1
			LOADED=true
			SFX.play("welcome_sfx")
			VOC.play("welcome_voc")
			httpRequest(tick_httpREQ_launch,PATH.api..PATH.appInfo)
			if USER.auth_token and USER.email then
				httpRequest(
					tick_httpREQ_autoLogin,
					PATH.api..PATH.auth,
					"GET",
					{["Content-Type"]="application/json"},
					json.encode{
						email=USER.email,
						auth_token=USER.auth_token,
					}
				)
			end
		end
		if loadTar then
			loadCur=loadCur+1
			if loadCur>loadTar then
				phase=phase+1
				loadCur=1
				loadTar=stageLenth[phase]
			end
		end
		time=time+1
		if time==400 then
			SCN.swapTo("intro")
			return
		end
	until not skip
end

function scene.draw()
	gc.push("transform")
	gc.translate(640,360)
	gc.scale(2)

	local Y=3250*(sin(-1.5708+min(time,260)/260*3.1416)+1)+200

	--Draw 26F Studio logo
	if time>200 then
		gc.push("transform")
		gc.translate(-220,Y-6840)

		gc.setColor(.4,.4,.4)
		gc.rectangle("fill",0,0,440,260)

		local T=Timer()
		gc.setColor(COLOR.dCyan)
		mDraw(studioLogo,220,Y*.2-1204)
		mDraw(studioLogo,220,-Y*.2+1476)

		gc.setColor(COLOR.cyan)
		mDraw(studioLogo,220+4*sin(T*10),136+4*sin(T*6))
		mDraw(studioLogo,220+4*sin(T*12),136+4*sin(T*8))

		gc.setColor(COLOR.dCyan)
		mDraw(studioLogo,219,137)
		mDraw(studioLogo,219,135)
		mDraw(studioLogo,221,137)
		mDraw(studioLogo,221,135)

		gc.setColor(.2,.2,.2)
		mDraw(studioLogo,220,136)

		gc.pop()
	end

	--Draw floors
	setFont(50)
	gc.setLineWidth(4)
	for i=1,27 do
		if i<26 then
			local r,g,b=COLOR.rainbow(i+3.5)
			gc.setColor(r*.26,g*.26,b*.26)
			gc.rectangle("fill",-220,Y-260*i-80,440,260)
			gc.setColor(r*1.6,g*1.6,b*1.6)
			gc.printf(i.."F",100,Y-260*i-70,100,"right")
			gc.setColor(1,1,1)
			gc.rectangle("line",-160,Y-260*i,80,50)
		end
		gc.line(-220,Y-260*i+180,220,Y-260*i+180)
	end

	--Draw side line
	gc.setColor(1,1,1)
	gc.line(-220,Y-80,-220,Y-6840)
	gc.line(220,Y-80,220,Y-6840)

	gc.pop()
end

return scene