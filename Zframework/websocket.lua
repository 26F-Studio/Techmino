-- local host="127.0.0.1"
-- local host="192.168.114.102"
-- local host="krakens.tpddns.cn"
-- local host="hdustea.3322.org"
local host="game.techmino.org"
local port="10026"
local path="/tech/socket/v1"

local debug=false

local wsThread=[[
-- lua + love2d threading websocket client
-- Original pure lua ver. by flaribbit and Particle_G
-- Threading version by MrZ

local triggerCHN,sendCHN,readCHN,threadName=...


local SOCK=require"socket".tcp()
local JSON=require"Zframework.json"

do--Connect
	local host=sendCHN:demand()
	local port=sendCHN:demand()
	local path=sendCHN:demand()
	local body=sendCHN:demand()

	SOCK:settimeout(2.6)
	local res,err=SOCK:connect(host,port)
	if err then readCHN:push(err)return end

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
	res,err=SOCK:receive("*l")
	if not res then readCHN:push(err)return end
	local code,ctLen
	code=res:find(" ")
	code=res:sub(code+1,code+3)

	--Get body length from headers and remove headers
	repeat
		res,err=SOCK:receive("*l")
		if not res then readCHN:push(err)return end
		if not ctLen and res:find"length"then
			ctLen=tonumber(res:match"%d+")
		end
	until res==""

	--Result
	if ctLen then
		if code=="101"then
			readCHN:push("success")
		else
			res,err=SOCK:receive(ctLen)
			if not res then readCHN:push(err)return end
			res=JSON.decode(res)
			readCHN:push((code or"XXX")..":"..(res and res.reason or"Server Error"))
		end
	end
	SOCK:settimeout(0)
end



local byte=string.byte
local band,shl=bit.band,bit.lshift

local _send do
	local char=string.char
	local bor,bxor=bit.bor,bit.bxor
	local shr=bit.rshift

	local mask_key={1,14,5,14}
	local mask_str=char(unpack(mask_key))

	function _send(opcode,message)
		--Message type
		SOCK:send(char(bor(0x80,opcode)))

		if message then
			--Length
			local length=#message
			if length>65535 then
				SOCK:send(char(bor(127,0x80),0,0,0,0,band(shr(length,24),0xff),band(shr(length,16),0xff),band(shr(length,8),0xff),band(length,0xff)))
			elseif length>125 then
				SOCK:send(char(bor(126,0x80),band(shr(length,8),0xff),band(length,0xff)))
			else
				SOCK:send(char(bor(length,0x80)))
			end
			SOCK:send(mask_str)
			local msgbyte={byte(message,1,length)}
			for i=1,length do
				msgbyte[i]=bxor(msgbyte[i],mask_key[(i-1)%4+1])
			end
			return SOCK:send(char(unpack(msgbyte)))
		else
			SOCK:send("\128"..mask_str)
			return 0
		end
	end
end
local res,err
local op,fin
local length
local lBuffer=""--Long multi-data buffer
local UFF--Un-finished-frame mode
local sBuffer=""--Short multi-frame buffer
while true do--Running
	--Send
	triggerCHN:demand()
	while sendCHN:getCount()>=2 do
		local op=sendCHN:pop()
		local message=sendCHN:pop()
		_send(op,message)
	end

	--Read
	while true do
		if not UFF then--UNF process
			--Byte 0-1
			res,err=SOCK:receive(2)
			if err then break end

			op=band(byte(res,1),0x0f)
			fin=band(byte(res,1),0x80)==0x80

			--Calculating data length
			length=band(byte(res,2),0x7f)
			if length==126 then
				res=SOCK:receive(2)
				length=shl(byte(res,1),8)+byte(res,2)
			elseif length==127 then
				local b={byte(SOCK:receive(8),1,8)}
				length=shl(b[5],24)+shl(b[6],16)+shl(b[7],8)+b[8]
			end

			if length>0 then
				--Receive data
				local s,_,p=SOCK:receive(length)
				if s then
					res=s
				elseif p then--UNF head
					]]..(debug==1 and""or"--")..[[print(("%s[%d/%d]:%s"):format(threadName,#p,length,p))
					UFF=true
					sBuffer=sBuffer..p
					length=length-#p
					break
				end
			else
				res=""
			end
		else
			local s,e,p=SOCK:receive(length)
			if s then
				]]..(debug==1 and""or"--")..[[print(("%s<%d>:%s"):format(threadName,length,s))
				sBuffer=sBuffer..s
				length=length-#s
			elseif p then
				]]..(debug==1 and""or"--")..[[print(("%s<%d>:%s"):format(threadName,length,p))
				sBuffer=sBuffer..p
				length=length-#p
			end
			if length==0 then
				res,sBuffer=sBuffer,""
				UFF=false
			else
				break
			end
		end
		]]..(debug==1 and""or"--")..[[print(("%s<[%d]>:%s"):format(threadName,#res,res))

		--React
		if op==8 then--8=close
			readCHN:push(op)
			SOCK:close()
			if type(res)=="string"then
				res=JSON.decode(res)
				readCHN:push(res and res.reason or"WS Error")
			else
				readCHN:push("WS Error")
			end
		elseif op==0 then--0=continue
			lBuffer=lBuffer..res
			if fin then
				]]..(debug==2 and""or"--")..[[print("FIN=1 (c")
				readCHN:push(lBuffer)
				lBuffer=""
			else
				]]..(debug==2 and""or"--")..[[print("FIN=0 (c")
			end
		else
			readCHN:push(op)
			if fin then
				]]..(debug==2 and""or"--")..[[print("OP: "..op.."\tFIN=1")
				readCHN:push(res)
			else
				]]..(debug==2 and""or"--")..[[print("OP: "..op.."\tFIN=0")
				sBuffer=res
				]]..(debug==2 and""or"--")..[[print("START pack: "..res)
			end
		end
	end
end
]]

local timer=love.timer.getTime
local WS={}
local wsList=setmetatable({},{
	__index=function(l,k)
		local ws={
			real=false,
			status="dead",
			lastPongTime=timer(),
			sendTimer=0,
			alertTimer=0,
			pongTimer=0,
		}
		l[k]=ws
		return ws
	end
})

function WS.connect(name,subPath,body)
	local ws={
		real=true,
		thread=love.thread.newThread(wsThread),
		triggerCHN=love.thread.newChannel(),
		sendCHN=love.thread.newChannel(),
		readCHN=love.thread.newChannel(),
		lastPingTime=0,
		lastPongTime=timer(),
		pingInterval=26,
		status="connecting",--connecting, running, dead
		sendTimer=0,
		alertTimer=0,
		pongTimer=0,
	}
	wsList[name]=ws
	ws.thread:start(ws.triggerCHN,ws.sendCHN,ws.readCHN,name)
	ws.sendCHN:push(host)
	ws.sendCHN:push(port)
	ws.sendCHN:push(path..subPath)
	ws.sendCHN:push(body or"")
end

function WS.status(name)
	local ws=wsList[name]
	return ws.status or"dead"
end

function WS.getTimers(name)
	local ws=wsList[name]
	return ws.pongTimer,ws.sendTimer,ws.alertTimer
end

function WS.setPingInterval(name,time)
	local ws=wsList[name]
	ws.pingInterval=math.max(time or 1,2.6)
end

function WS.alert(name)
	local ws=wsList[name]
	ws.alertTimer=2
end

local OPcode={
	continue=0,
	text=1,
	binary=2,
	close=8,
	ping=9,
	pong=10,
}
local OPname={
	[0]="continue",
	[1]="text",
	[2]="binary",
	[8]="close",
	[9]="ping",
	[10]="pong",
}
function WS.send(name,message,op)
	local ws=wsList[name]
	if ws.real then
		ws.sendCHN:push(op and OPcode[op]or 2)--2=binary
		ws.sendCHN:push(message)
		ws.lastPingTime=timer()
		ws.sendTimer=1
	end
end

function WS.read(name)
	local ws=wsList[name]
	if ws.real and ws.readCHN:getCount()>=2 then
		local op=ws.readCHN:pop()
		local message=ws.readCHN:pop()
		if op==8 then ws.status="dead"end--8=close
		ws.lastPongTime=timer()
		ws.pongTimer=1
		return message,OPname[op]or op
	end
end

function WS.close(name)
	local ws=wsList[name]
	if ws.real then
		ws.sendCHN:push(8)--close
		ws.sendCHN:push("")
		ws.status="dead"
	end
end

function WS.update(dt)
	local time=timer()
	for name,ws in next,wsList do
		if ws.real then
			ws.triggerCHN:push(0)
			if ws.status=="connecting"then
				local mes=ws.readCHN:pop()
				if mes then
					if mes=="success"then
						ws.status="running"
						ws.lastPingTime=time
						ws.lastPongTime=time
						ws.pongTimer=1
					else
						ws.status="dead"
						LOG.print(text.wsFailed..": "..(mes=="timeout"and text.netTimeout or mes),"warn")
					end
				end
			elseif ws.status=="running"then
				if time-ws.lastPingTime>ws.pingInterval then
					ws.sendCHN:push(9)
					ws.sendCHN:push("")--ping
					ws.lastPingTime=time
				end
				if time-ws.lastPongTime>10+3*ws.pingInterval then
					WS.close(name)
				end
			end
			if ws.sendTimer>0 then ws.sendTimer=ws.sendTimer-dt end
			if ws.pongTimer>0 then ws.pongTimer=ws.pongTimer-dt end
			if ws.alertTimer>0 then ws.alertTimer=ws.alertTimer-dt end
		end
	end
end

return WS