client=loadLib("NETlib")
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

	function wsConnect(tick,path,header)
		if TASK.wsConnecting then
			LOG.print(text.waitNetTask,"message")
			return
		end
		local task,err=client.wsraw{
			url="ws://"..PATH.url..":"..PATH.port..path,
			origin=PATH.url,
			header=header,
		}
		if task then
			TASK.newWS(tick,task)
		else
			LOG.print("NETlib error: "..err,"warn")
		end
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
else
	local function noNetLib()
		LOG.print("[NO NETlib for "..SYSTEM.."]",5,COLOR.yellow)
	end
	httpRequest=noNetLib
	wsConnect=noNetLib
	wsWrite=noNetLib
end