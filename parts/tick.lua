local function checkTimeout(data,time)
	data.time=data.time+1
	if data.time==time then
		LOG.print(text.httpTimeout,"message")
		return true
	end
end
local Tick={}
function Tick.showMods(data)
	local d=data[1]+1
	if d%20==0 then
		local M=GAME.mod[d/20]
		if M then
			TEXT.show(M.id,700+(d-20)%120*4,36,45,"spin",.5)
		else
			return true
		end
	end
	data[1]=d
end
function Tick.finish(P)
	P.endCounter=P.endCounter+1
	if P.endCounter<40 then
		--Make field visible
		for j=1,#P.field do for i=1,10 do
			if P.visTime[j][i]<20 then P.visTime[j][i]=P.visTime[j][i]+.5 end
		end end
	elseif P.endCounter==60 then
		return true
	end
end
function Tick.lose(P)
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
			return true
		end
	end
	if not GAME.modeEnv.royaleMode and #PLAYERS>1 then
		P.y=P.y+P.endCounter*.26
		P.absFieldY=P.absFieldY+P.endCounter*.26
	end
end
function Tick.throwBadge(data)--{ifAI,Sender,timer}
	data[3]=data[3]-1
	if data[3]%4==0 then
		local S,R=data[2],data[2].lastRecv
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

		if not data[1]and data[3]%8==0 then
			SFX.play("collect")
		end
	end
	if data[3]<=0 then return true end
end
function Tick.autoPause(data)
	data[1]=data[1]+1
	if SCN.cur~="play"then return true end
	if data[1]==120 then
		if SCN.cur=="play"then
			pauseGame()
		end
		return true
	end
end
function Tick.httpREQ_launch(data)
	local response,request_error=client.poll(data.task)
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
		return true
	elseif request_error then
		LOG.print(text.getNoticeFail..": "..request_error,"warn")
		return true
	end
	return checkTimeout(data,260)
end
function Tick.httpREQ_register(data)
	local response,request_error=client.poll(data.task)
	if response then
		local res=json.decode(response.body)
		if res then
			if response.code==200 then
				LOG.print(text.registerSuccessed..": "..res.message)
			else
				LOG.print(text.netErrorCode..response.code..": "..res.message,"warn")
			end
		end
		return true
	elseif request_error then
		LOG.print(text.loginFailed..": "..request_error,"warn")
		return true
	end
	return checkTimeout(data,360)
end
function Tick.httpREQ_newLogin(data)
	local response,request_error=client.poll(data.task)
	if response then
		local res=json.decode(response.body)
		LOGIN=response.code==200
		if res then
			if LOGIN then
				LOG.print(text.loginSuccessed)
				ACCOUNT.email=res.email
				ACCOUNT.auth_token=res.auth_token
				FILE.save(ACCOUNT,"account","")
				SCN.pop()
				SCN.go("netgame")
			else
				LOG.print(text.netErrorCode..response.code..": "..res.message,"warn")
			end
		end
		return true
	elseif request_error then
		LOG.print(text.loginFailed..": "..request_error,"warn")
		return true
	end
	return checkTimeout(data,360)
end
function Tick.httpREQ_autoLogin(data)
	local response,request_error=client.poll(data.task)
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
				LOG.print(text.netErrorCode..response.code..": "..err.message,"warn")
			end
		end
		return true
	elseif request_error then
		LOG.print(text.loginFailed..": "..request_error,"warn")
		return true
	end
	return checkTimeout(data,360)
end
function Tick.wsCONN_connect(data)
	print("Running wsconntask...")
	if data.wsconntask then
		local wsconn,connErr=client.poll(data.wsconntask)
		if wsconn then
			WSCONN = wsconn
			TASK.new(Tick.wsCONN_read,{net=true})
			return true
		elseif connErr then
			LOG.print(text.wsFailed..": "..connErr,"warn")
			return true
		end
	end
	return checkTimeout(data,360)
end
function Tick.wsCONN_read(data)
	if not data.net then
		return true
	end
	local messages,readErr=client.read(WSCONN)
	if messages then
		if messages[1] then
			print(messages[1])
			LOG.print("Message: "..messages[1])
		end
	elseif readErr then
		print("Read error: "..readErr)
		if readErr == "EOF" then
			LOG.print("Socket closed!","warn")
		end
		WSCONN = nil
		return true
	end
end
-- function Tick.wsCONN_write(data)
-- 	if not data.net then
-- 		return true
-- 	end
-- 	local writeErr=client.write(WSCONN,data.message)
-- 	if writeErr then
-- 		print(writeErr, "warn")
-- 	end
-- 	return true
-- end

return Tick