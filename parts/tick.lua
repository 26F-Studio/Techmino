local yield=coroutine.yield

local Tick={}
function Tick.showMods()
	local time=0
	while true do
		yield()
		time=time+1
		if time%20==0 then
			local M=GAME.mod[time/20]
			if M then
				TEXT.show(M.id,700+(time-20)%120*4,36,45,"spin",.5)
			else
				return
			end
		end
	end
end
function Tick.finish(P)
	while true do
		yield()
		P.endCounter=P.endCounter+1
		if P.endCounter<40 then
			--Make field visible
			for j=1,#P.field do for i=1,10 do
				if P.visTime[j][i]<20 then P.visTime[j][i]=P.visTime[j][i]+.5 end
			end end
		elseif P.endCounter==60 then
			return
		end
	end
end
function Tick.lose(P)
	while true do
		yield()
		P.endCounter=P.endCounter+1
		if P.endCounter<40 then
			--Make field visible
			for j=1,#P.field do for i=1,10 do
				if P.visTime[j][i]<20 then P.visTime[j][i]=P.visTime[j][i]+.5 end
			end end
		elseif P.endCounter>80 then
			for i=1,#P.field do
				for j=1,10 do
					if P.visTime[i][j]>0 then
						P.visTime[i][j]=P.visTime[i][j]-1
					end
				end
			end
			if P.endCounter==120 then
				for _=#P.field,1,-1 do
					FREEROW.discard(P.field[_])
					FREEROW.discard(P.visTime[_])
					P.field[_],P.visTime[_]=nil
				end
				return
			end
		end
		if not GAME.modeEnv.royaleMode and #PLAYERS>1 then
			P.y=P.y+P.endCounter*.26
			P.absFieldY=P.absFieldY+P.endCounter*.26
		end
	end
end
function Tick.throwBadge(ifAI,sender,time)
	while true do
		yield()
		time=time-1
		if time%4==0 then
			local S,R=sender,sender.lastRecv
			local x1,y1,x2,y2
			if S.small then
				x1,y1=S.centerX,S.centerY
			else
				x1,y1=S.x+308*S.size,S.y+450*S.size
			end
			if R.small then
				x2,y2=R.centerX,R.centerY
			else
				x2,y2=R.x+66*R.size,R.y+344*R.size
			end

			--Generate badge object
			SYSFX.newBadge(x1,y1,x2,y2)

			if not ifAI and time%8==0 then
				SFX.play("collect")
			end
		end
		if time<=0 then return end
	end
end
function Tick.autoPause()
	local time=0
	while true do
		yield()
		time=time+1
		if SCN.cur~="play"then
			return
		elseif time==120 then
			pauseGame()
			return
		end
	end
end
function Tick.httpREQ_launch(task)
	local time=0
	while true do
		yield()
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
function Tick.httpREQ_register(task)
	local time=0
	while true do
		yield()
		local response,request_error=client.poll(task)
		if response then
			local res=json.decode(response.body)
			if res then
				if response.code==200 then
					LOG.print(text.registerSuccessed..": "..res.message)
				else
					LOG.print(text.netErrorCode..response.code..": "..res.message,"warn")
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
function Tick.httpREQ_newLogin(task)
	local time=0
	while true do
		yield()
		local response,request_error=client.poll(task)
		if response then
			local res=json.decode(response.body)
			LOGIN=response.code==200
			if res then
				if LOGIN then
					LOG.print(text.loginSuccessed)
					ACCOUNT.email=res.email
					ACCOUNT.auth_token=res.auth_token
					FILE.save(ACCOUNT,"account","")

					httpRequest(
						TICK.httpREQ_getAccessToken,
						PATH.api..PATH.access,
						"POST",
						{["Content-Type"]="application/json"},
						json.encode{
							email=ACCOUNT.email,
							auth_token=ACCOUNT.auth_token,
						}
					)
				else
					LOG.print(text.netErrorCode..response.code..": "..res.message,"warn")
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
function Tick.httpREQ_autoLogin(task)
	local time=0
	while true do
		yield()
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
function Tick.httpREQ_checkAccessToken(task)
	local time=0
	while true do
		yield()
		local response,request_error=client.poll(task)
		if response then
			if response.code==200 then
				LOG.print(text.accessSuccessed)
				SCN.pop()
				SCN.go("netgame")
			elseif response.code==403 or response.code==401 then
				httpRequest(
					TICK.httpREQ_getAccessToken,
					PATH.api..PATH.access,
					"POST",
					{["Content-Type"]="application/json"},
					json.encode{
						email=ACCOUNT.email,
						auth_token=ACCOUNT.auth_token,
					}
				)
			else
				local err=json.decode(response.body)
				if err then
					LOG.print(text.netErrorCode..response.code..": "..err.message,"warn")
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
function Tick.httpREQ_getAccessToken(task)
	local time=0
	while true do
		yield()
		local response,request_error=client.poll(task)
		if response then
			if response.code==200 then
				local res=json.decode(response.body)
				if res then
					LOG.print(text.accessSuccessed)
					ACCOUNT.access_token=res.access_token
					FILE.save(ACCOUNT,"account","")
					SCN.pop()
					SCN.go("netgame")
				else
					LOG.print(text.netErrorCode..response.code..": "..res.message,"warn")
					SCN.pop()
					SCN.go("main")
				end
			else
				LOGIN=false
				ACCOUNT.access_token=nil
				ACCOUNT.auth_token=nil
				local err=json.decode(response.body)
				if err then
					LOG.print(text.loginFailed..": "..text.netErrorCode..response.code.."-"..err.message,"warn")
				else
					LOG.print(text.loginFailed..": "..text.netErrorCode,"warn")
				end
				SCN.pop()
				SCN.go("main")
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
function Tick.wsCONN_connect(task)
	local time=0
	while true do
		yield()
		local wsconn,connErr=client.poll(task)
		if wsconn then
			WSCONN=wsconn
			TASK.new(Tick.wsCONN_read)
			return
		elseif connErr then
			LOG.print(text.wsFailed..": "..connErr,"warn")
			return
		end
		time=time+1
		if time>360 then
			LOG.print(text.httpTimeout,"message")
			return
		end
	end
end
function Tick.wsCONN_read()
	while true do
		yield()
		local messages,readErr=client.read(WSCONN)
		if messages then
			if messages[1]then
				LOG.print(messages[1])
			end
		elseif readErr then
			print("Read error: "..readErr)
			if readErr=="EOF"then
				LOG.print("Socket closed!","warn")
			end
			WSCONN=nil
			return
		end
	end
end
-- function Tick.wsCONN_write()
-- 	while true do
-- 		local message=yield()
-- 		if message then
-- 			local writeErr=client.write(WSCONN,message)
-- 			if writeErr then
-- 				print(writeErr,"warn")
-- 			end
-- 		end
-- 	end
-- end

return Tick