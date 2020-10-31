local Tick={}
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
				freeRow.discard(P.field[_])
				freeRow.discard(P.visTime[_])
				P.field[_],P.visTime[_]=nil
			end
			return true
		end
	end
	if not modeEnv.royaleMode and #PLAYERS>1 then
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
		sysFX.newBadge(x1,y1,x2,y2)

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
	local res,err=client.poll(data.task)
	if res then
		if res.code==200 then
			err,res=json.decode(res.body)
			if res then
				LOG.print(res.notice,360,color.sky)
				if gameVersion==res.version then
					LOG.print(text.versionIsNew,360,color.sky)
				else
					LOG.print(string.gsub(text.versionIsOld,"$1",res.version),"warn")
				end
			else
				LOG.print(text.jsonError..": "..err,"warn")
			end
		else
			LOG.print(text.netErrorCode..res.code,"warn")
		end
		return true
	elseif err then
		LOG.print(text.getNoticeFail..": "..err,"warn")
		return true
	end
	data.time=data.time+1
	if data.time==300 then
		LOG.print(text.httpTimeout,"message")
		return true
	end
end
function Tick.httpREQ_register(data)
	local res,err=client.poll(data.task)
	if res then
		if res.code==200 then
			err,res=json.decode(res.body)
			if res then
				if res.status then
					LOG.print(text.registerSuccessed)
				else
					LOG.print(text.registerFailed..": "..res.msg)
				end
			else
				LOG.print(text.jsonError..": "..err,"warn")
			end
		else
			LOG.print(text.netErrorCode..res.code,"warn")
		end
		return true
	elseif err then
		LOG.print(text.registerFailed..": "..err,"warn")
		return true
	end
	data.time=data.time+1
	if data.time==360 then
		LOG.print(text.httpTimeout,"message")
		return true
	end
end
return Tick