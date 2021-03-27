local host="hdustea.3322.org"
local port="10026"
local path="/tech/socket/v1"

local wsThread=[[
-- lua + love2d threading websocket client
-- Original pure lua ver. by flaribbit and Particle_G and MrZ
-- Threading version by MrZ

local triggerCHN,sendCHN,readCHN=...



local byte,char=string.byte,string.char
local band,bor,bxor=bit.band,bit.bor,bit.bxor
local shl,shr=bit.lshift,bit.rshift

local SOCK=require"socket".tcp()
local JSON=require"Zframework.json"

local mask_key={1,14,5,14}
local function _send(opcode,message)
	--Message type
	SOCK:send(char(bor(0x80,opcode)))

	if not message then
		SOCK:send(char(0x80,unpack(mask_key)))
		return 0
	end

	--Length
	local length=#message
	if length>65535 then
		SOCK:send(char(bor(127,0x80),0,0,0,0,band(shr(length,24),0xff),band(shr(length,16),0xff),band(shr(length,8),0xff),band(length,0xff)))
	elseif length>125 then
		SOCK:send(char(bor(126,0x80),band(shr(length,8),0xff),band(length,0xff)))
	else
		SOCK:send(char(bor(length,0x80)))
	end
	SOCK:send(char(unpack(mask_key)))
	local msgbyte={byte(message,1,length)}
	for i=1,length do
		msgbyte[i]=bxor(msgbyte[i],mask_key[(i-1)%4+1])
	end
	return SOCK:send(char(unpack(msgbyte)))
end



do--Connect
	local host=sendCHN:demand()
	local port=sendCHN:demand()
	local path=sendCHN:demand()
	local body=sendCHN:demand()

	SOCK:settimeout(2.6)
	local res,err=SOCK:connect(host,port)
	if res then
		--WebSocket handshake
		if not body then body=""end
		SOCK:send(
			"GET "..path.." HTTP/1.1\r\n"..
			"Host: "..host..":"..port.."\r\n"..
			"Connection: Upgrade\r\n"..
			"Upgrade: websocket\r\n"..
			"Content-Type: application/json\r\n"..
			"Content-Length: "..#body.."\r\n"..
			"Sec-WebSocket-Version: 13\r\n"..
			"Sec-WebSocket-Key: osT3F7mvlojIvf3/8uIsJQ==\r\n\r\n"..--secKey
			body
		)

		--First line of HTTP
		local l=SOCK:receive("*l")
		local code,ctLen
		if l then
			code=l:find(" "); code=l:sub(code+1,code+3)
			repeat
				l=SOCK:receive("*l")
				if not ctLen and l:find"Length"then
					ctLen=tonumber(l:match"%d+")
				end
			until l==""
		end
		if code=="101"then
			readCHN:push("success")
		else
			local reason=JSON.decode(SOCK:receive(ctLen))
			readCHN:push(code..":"..(reason and reason.message or"Server Error"))
		end
	else
		readCHN:push(err)
	end
	SOCK:settimeout(0)
end



while true do--Running
	triggerCHN:demand()
	while sendCHN:getCount()>=2 do
		local op=sendCHN:pop()
		local message=sendCHN:pop()
		_send(op,message)
	end

	while true do--Read
		--Byte 0-1
		local res,err=SOCK:receive(2)
		if not res then break end

		local op=band(byte(res,1),0x0f)

		--Calculating data length
		local length=band(byte(res,2),0x7f)
		if length==126 then
			res=SOCK:receive(2)
			length=shl(byte(res,1),8)+byte(res,2)
		elseif length==127 then
			res=SOCK:receive(8)
			local b={byte(res,1,8)}
			length=shl(b[5],32)+shl(b[6],24)+shl(b[7],8)+b[8]
		end

		--Receive data
		res=SOCK:receive(length)

		--React
		readCHN:push(op)
		if op==8 then--close
			SOCK:close()
			if res:sub(1,4)=="HTTP"then
				local code=res:find(" ")
				code=res:sub(code+1,code+3)
				local res=res:sub(res:find("\n\n")+1)
				reason=JSON.decode(res)if reason then reason=reason.message end
				readCHN:push(code.."-"..(reason or res))
			else
				readCHN:push(string.format("%d-%s",shl(byte(res,1),8)+byte(res,2),res:sub(3,-3)))
			end
		else
			readCHN:push(res)
		end
	end
end
]]

local timer=love.timer.getTime
local WS={}
local wsList={}

function WS.connect(name,subPath,body)
	local ws={
		thread=love.thread.newThread(wsThread),
		triggerCHN=love.thread.newChannel(),
		sendCHN=love.thread.newChannel(),
		readCHN=love.thread.newChannel(),
		lastPingTime=0,
		lastPongTime=timer(),
		pingInterval=26,
		status="connecting",--connecting, running, dead
	}
	wsList[name]=ws
	ws.thread:start(ws.triggerCHN,ws.sendCHN,ws.readCHN)
	ws.sendCHN:push(host)
	ws.sendCHN:push(port)
	ws.sendCHN:push(path..subPath)
	ws.sendCHN:push(body or"")
end

function WS.status(name)
	return wsList[name]and wsList[name].status or"dead"
end

function WS.setPingInterval(name,time)
	local ws=wsList[name]
	ws.pingInterval=math.max(time or 1,2.6)
end

local OPcode={
	continue=0,
	text=1,
	binary=2,
	close=8,
	ping=9,
	pong=10,
}
function WS.send(name,message,op)
	local ws=wsList[name]
	ws.sendCHN:push(op and OPcode[op]or 2)--2=binary
	ws.sendCHN:push(message)
	ws.lastPingTime=timer()
end

function WS.read(name)
	local ws=wsList[name]
	if ws.readCHN:getCount()>=2 then
		local op=ws.readCHN:pop()
		local message=ws.readCHN:pop()
		if op==8 then ws.status="dead"end
		ws.lastPongTime=timer()
		return message,op
	end
end

function WS.close(name)
	local ws=wsList[name]
	ws.sendCHN:push(8)--close
	ws.sendCHN:push("")
	ws.status="dead"
end

function WS.update()
	local time=timer()
	for name,ws in next,wsList do
		ws.triggerCHN:push(0)
		if ws.status=="connecting"then
			local mes=ws.readCHN:pop()
			if mes then
				if mes=="success"then
					ws.status="running"
					ws.lastPingTime=time
					ws.lastPongTime=time
				else
					ws.status="dead"
					LOG.print(text.wsFailed,"warn")
				end
			end
		elseif time-ws.lastPingTime>ws.pingInterval then
			ws.sendCHN:push(9)
			ws.sendCHN:push("")--ping
			ws.lastPingTime=time
		end
		if time-ws.lastPongTime>10+3*ws.pingInterval then
			WS.close(name)
		end
	end
end

return WS