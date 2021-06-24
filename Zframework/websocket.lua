local host=
	-- "127.0.0.1"
	-- "192.168.114.102"
	"krakens.tpddns.cn"
	-- "game.techmino.org"
local port="10026"
local path="/tech/socket/v1"

local debugMode=""--S:send, R:receive, M=mark

local wsThread=[[
-- lua + LÖVE threading websocket client
-- Original pure lua ver. by flaribbit and Particle_G
-- Threading version by MrZ

local triggerCHN,sendCHN,readCHN,threadName=...

local CHN_demand,CHN_getCount=triggerCHN.demand,triggerCHN.getCount
local CHN_push,CHN_pop=triggerCHN.push,triggerCHN.pop

local SOCK=require"socket".tcp()
local JSON=require"Zframework.json"

do--Connect
	local host=CHN_demand(sendCHN)
	local port=CHN_demand(sendCHN)
	local path=CHN_demand(sendCHN)
	local body=CHN_demand(sendCHN)
	local timeout=CHN_demand(sendCHN)

	SOCK:settimeout(timeout)
	local res,err=SOCK:connect(host,port)
	if err then CHN_push(readCHN,err)return end

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
	if not res then CHN_push(readCHN,err)return end
	local code,ctLen
	code=res:find(" ")
	code=res:sub(code+1,code+3)

	--Get body length from headers and remove headers
	repeat
		res,err=SOCK:receive("*l")
		if not res then CHN_push(readCHN,err)return end
		if not ctLen and res:find("length")then
			ctLen=tonumber(res:match("%d+"))
		end
	until res==""

	--Result
	if ctLen then
		if code=="101"then
			CHN_push(readCHN,'success')
		else
			res,err=SOCK:receive(ctLen)
			if not res then
				CHN_push(readCHN,err)
			else
				res=JSON.decode(res)
				CHN_push(readCHN,(code or"XXX")..":"..(res and res.reason or"Server Error"))
			end
			return
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

	function _send(op,message)
		]]..(debugMode:find'S'and""or"--")..[[print((">> %s[%d]:%s"):format(threadName,#message,message))
		--Message type
		SOCK:send(char(bor(0x80,op)))

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
	CHN_demand(triggerCHN)

	--Send
	while CHN_getCount(sendCHN)>=2 do
		local op=CHN_pop(sendCHN)
		local message=CHN_pop(sendCHN)
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
					]]..(debugMode:find'R'and""or"--")..[[print(("<< %s[%d/%d]:%s"):format(threadName,#p,length,#p<50 and p or p:sub(1,50)))
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
				]]..(debugMode:find'R'and""or"--")..[[print(("<< %s(%d):%s"):format(threadName,length,#s<50 and s or s:sub(1,50)))
				sBuffer=sBuffer..s
				length=length-#s
			elseif p then
				]]..(debugMode:find'R'and""or"--")..[[print(("<< %s(%d):%s"):format(threadName,length,#p<50 and p or p:sub(1,50)))
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
		]]..(debugMode:find'R'and""or"--")..[[print(("<< %s[(%d)]:%s"):format(threadName,#res,#res<800 and res or res:sub(1,150).."\n...\n"..res:sub(-150)))

		--React
		if op==8 then--8=close
			CHN_push(readCHN,op)
			SOCK:close()
			if type(res)=='string'then
				CHN_push(readCHN,res:sub(3))--Warning: with 2 bytes close code
			else
				CHN_push(readCHN,"WS Error")
			end
		elseif op==0 then--0=continue
			lBuffer=lBuffer..res
			if fin then
				]]..(debugMode:find'M'and""or"--")..[[print("FIN=1 (c")
				CHN_push(readCHN,lBuffer)
				lBuffer=""
			else
				]]..(debugMode:find'M'and""or"--")..[[print("FIN=0 (c")
			end
		else
			CHN_push(readCHN,op)
			if fin then
				]]..(debugMode:find'M'and""or"--")..[[print("OP: "..op.."\tFIN=1")
				CHN_push(readCHN,res)
			else
				]]..(debugMode:find'M'and""or"--")..[[print("OP: "..op.."\tFIN=0")
				sBuffer=res
				]]..(debugMode:find'M'and""or"--")..[[print("START pack: "..res)
			end
		end
	end
end
]]

local timer=love.timer.getTime
local CHN=love.thread.newChannel()
local CHN_getCount,CHN_push,CHN_pop=CHN.getCount,CHN.push,CHN.pop

local WS={}
local wsList=setmetatable({},{
	__index=function(l,k)
		local ws={
			real=false,
			status='dead',
			lastPongTime=timer(),
			sendTimer=0,
			alertTimer=0,
			pongTimer=0,
		}
		l[k]=ws
		return ws
	end
})

function WS.switchHost(_1,_2,_3)
	for k in next,wsList do
		WS.close(k)
	end
	host=_1
	port=_2 or port
	path=_3 or path
end

function WS.connect(name,subPath,body,timeout)
	local ws={
		real=true,
		thread=love.thread.newThread(wsThread),
		triggerCHN=love.thread.newChannel(),
		sendCHN=love.thread.newChannel(),
		readCHN=love.thread.newChannel(),
		lastPingTime=0,
		lastPongTime=timer(),
		pingInterval=12,
		status='connecting',--'connecting', 'running', 'dead'
		sendTimer=0,
		alertTimer=0,
		pongTimer=0,
	}
	wsList[name]=ws
	ws.thread:start(ws.triggerCHN,ws.sendCHN,ws.readCHN,name)
	CHN_push(ws.sendCHN,host)
	CHN_push(ws.sendCHN,port)
	CHN_push(ws.sendCHN,path..subPath)
	CHN_push(ws.sendCHN,body or"")
	CHN_push(ws.sendCHN,timeout or 2.6)
end

function WS.status(name)
	local ws=wsList[name]
	return ws.status or'dead'
end

function WS.getTimers(name)
	local ws=wsList[name]
	return ws.pongTimer,ws.sendTimer,ws.alertTimer
end

function WS.setPingInterval(name,time)
	local ws=wsList[name]
	ws.pingInterval=math.max(time or 2.6,2.6)
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
	[0]='continue',
	[1]='text',
	[2]='binary',
	[8]='close',
	[9]='ping',
	[10]='pong',
}
function WS.send(name,message,op)
	local ws=wsList[name]
	if ws.real and ws.status=='running'then
		CHN_push(ws.sendCHN,op and OPcode[op]or 2)--2=binary
		CHN_push(ws.sendCHN,message)
		ws.lastPingTime=timer()
		ws.sendTimer=1
	end
end

function WS.read(name)
	local ws=wsList[name]
	if ws.real and ws.status~='connecting'and CHN_getCount(ws.readCHN)>=2 then
		local op,message=CHN_pop(ws.readCHN),CHN_pop(ws.readCHN)
		if op==8 then ws.status='dead'end--8=close
		ws.lastPongTime=timer()
		ws.pongTimer=1
		return message,OPname[op]or op
	end
end

function WS.close(name)
	local ws=wsList[name]
	if ws.real then
		CHN_push(ws.sendCHN,8)--close
		CHN_push(ws.sendCHN,"")
		ws.status='dead'
	end
end

function WS.update(dt)
	local time=timer()
	for name,ws in next,wsList do
		if ws.real then
			if CHN_getCount(ws.triggerCHN)==0 then
				CHN_push(ws.triggerCHN,0)
			end
			if ws.status=='connecting'then
				local mes=CHN_pop(ws.readCHN)
				if mes then
					if mes=='success'then
						ws.status='running'
						ws.lastPingTime=time
						ws.lastPongTime=time
						ws.pongTimer=1
					else
						ws.status='dead'
						MES.new('warn',text.wsFailed..": "..(mes=="timeout"and text.netTimeout or mes))
					end
				end
			elseif ws.status=='running'then
				if time-ws.lastPingTime>ws.pingInterval then
					CHN_push(ws.sendCHN,9)
					CHN_push(ws.sendCHN,"")--ping
					ws.lastPingTime=time
				end
				if time-ws.lastPongTime>6+2*ws.pingInterval then
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