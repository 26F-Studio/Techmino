local Tick={}
function Tick.httpREQ_getAccessToken(task)
	local time=0
	while true do
		coroutine.yield()
		local response,request_error=client.poll(task)
		if response then
			if response.code==200 then
				local res=json.decode(response.body)
				if res then
					LOG.print(text.accessSuccessed)
					ACCOUNT.access_token=res.access_token
					FILE.save(ACCOUNT,"account","")
					SCN.swapTo("netgame")
				else
					LOG.print(text.netErrorCode..response.code..": "..res.message,"warn")
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

local function tick_wsCONN_read()
	while true do
		coroutine.yield()
		if not WSCONN then return end
		local messages,readErr=client.read(WSCONN)
		if messages then
			for i=1,#messages do
				SCN.socketRead(messages[i])
			end
		elseif readErr then
			wsWrite("/quit")
			WSCONN=nil
			LOG.print(text.wsDisconnected,"warn")
			return
		end
	end
end
function Tick.wsCONN_connect(task)
	local time=0
	while true do
		coroutine.yield()
		local wsconn,connErr=client.poll(task)
		if wsconn then
			WSCONN=wsconn
			TASK.new(tick_wsCONN_read)
			LOG.print(text.wsSuccessed,"warn")
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
-- function Tick.wsCONN_write()
-- 	while true do
-- 		local message=coroutine.yield()
-- 		if message then
-- 			local writeErr=client.write(WSCONN,message)
-- 			if writeErr then
-- 				print(writeErr,"warn")
-- 			end
-- 		end
-- 	end
-- end

return Tick