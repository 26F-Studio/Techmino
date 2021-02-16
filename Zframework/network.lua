client=loadLib("NETlib",{
	Windows="client",
	Linux="client",
	Android="client.so",
	libFunc="luaopen_client",
})
if client then
	function httpRequest(tick,path,method,header,body)
		local task,err=client.httpraw{
			url="http://"..PATH.url..":"..PATH.port..path,
			method=method or"GET",
			header=header,
			body=body,
		}
		if task then
			TASK.newNet(tick,task)
		else
			LOG.print("NETlib error: "..err,"warn")
		end
		TASK.netTaskCount=TASK.netTaskCount+1
	end
else
	function httpRequest()
		LOG.print("[NO NETlib for "..SYSTEM.."]",5,COLOR.yellow)
	end
end

function wsConnect(path,body)
	local ws=WS.new()
	ws:settimeout(6.26)
	ws:connect(PATH.url..":"..PATH.port,path,body)
	TASK.netTaskCount=TASK.netTaskCount+1
end

function wsWrite(data)
	if WSCONN then
		local writeErr=client.write(WSCONN,data)
		if writeErr then
			LOG.print(writeErr,"error")
			return
		end
		return true
	else
		LOG.print(text.wsNoConn,"warn")
	end
end