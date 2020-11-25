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
		if response.code==200 then
			local success,content=json.decode(response.body)
			if success then
				LOG.print(content.notice,360,COLOR.sky)
				if VERSION_CODE==content.version_code then
					LOG.print(text.versionIsNew,360,COLOR.sky)
				else
					LOG.print(string.gsub(text.versionIsOld,"$1",content.version_name),"warn")
				end
			else
				LOG.print(text.jsonError,"warn")
			end
		else
			local success,content=json.decode(response.body)
			if success then
				LOG.print(text.netErrorCode..response.code..": "..content.message,"warn")
			else
				LOG.print(text.netErrorCode..response.code,"warn")
			end
		end
		return true
	elseif request_error then
		LOG.print(text.getNoticeFail..": "..request_error,"warn")
		return true
	end
	data.time=data.time+1
	if data.time==300 then
		LOG.print(text.httpTimeout,"message")
		return true
	end
end
function Tick.httpREQ_register(data)
	local response,request_error=client.poll(data.task)
	if response then
		if response.code==200 then
			local success,content=json.decode(response.body)
			if success then
				LOG.print(text.registerSuccessed..": "..content.message)
			else
				LOG.print(text.jsonError,"warn")
			end
		else
			local success,content=json.decode(response.body)
			if success then
				LOG.print(text.netErrorCode..response.code..": "..content.message,"warn")
			else
				LOG.print(text.netErrorCode..response.code,"warn")
			end
		end
		return true
	elseif request_error then
		LOG.print(text.registerFailed..": "..request_error,"warn")
		return true
	end
	data.time=data.time+1
	if data.time==360 then
		LOG.print(text.httpTimeout,"message")
		return true
	end
end
function Tick.httpREQ_login(data)
	local response,request_error=client.poll(data.task)
	if response then
		if response.code==200 then
			local success,content=json.decode(response.body)
			if success then
				LOG.print(text.loginSuccessed..": "..content.message)
				-- TODO: save {content.token} to storage and a global variable
				-- TODO: save {content.id} to a global variable
			else
				LOG.print(text.jsonError,"warn")
			end
		else
			local success,content=json.decode(response.body)
			if success then
				LOG.print(text.netErrorCode..response.code..": "..content.message,"warn")
			else
				LOG.print(text.netErrorCode..response.code,"warn")
			end
		end
		return true
	elseif request_error then
		LOG.print(text.registerFailed..": "..request_error,"warn")
		return true
	end
	data.time=data.time+1
	if data.time==360 then
		LOG.print(text.httpTimeout,"message")
		return true
	end
end
return Tick