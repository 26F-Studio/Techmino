--[[
	websocket client pure lua implement for love2d
	by flaribbit and Particle_G and MrZ_26

	usage:
		local client=require("websocket").new()
		client:settimeout(1)
		client:connect("127.0.0.1:5000","/test",'{"foo":"bar"}')
		client:settimeout(0)
		client:send("hello from love2d","text")
		love.timer.sleep(0.2)
		opcode,res,closeCode=client:read()
		print(res)
		client:send("Goodbye from love2d","close")
]]

local socket=require"socket"
local char,sub=string.char,string.sub
local band,bor,bxor=bit.band,bit.bor,bit.bxor
local shl,shr=bit.lshift,bit.rshift

local WS={}

function WS.new()
	local m={socket=socket.tcp()}
	for k,v in next,WS do m[k]=v end
	return m
end

function WS:connect(server,path,body)
	local host,port=unpack(splitStr(server,":"))
	local SOCK=self.socket
	local res,err=SOCK:connect(host,port or 80)
	if res~=1 then return res,err end

	--WebSocket handshake
	if not body then body=""end
	res,err=SOCK:send(
		"GET "..(path or"/").." HTTP/1.1\r\n"..
		"Host: "..server.."\r\n"..
		"Connection: Upgrade\r\n"..
		"Upgrade: websocket\r\n"..
		"Content-Type: application/json\r\n"..
		"Content-Length: "..#body.."\r\n"..
		"Sec-WebSocket-Version: 13\r\n"..
		"Sec-WebSocket-Key: osT3F7mvlojIvf3/8uIsJQ==\r\n\r\n"..--secKey
		body
	)
	repeat res=SOCK:receive("*l")until res==""
end

local mask_key={1,14,5,14}
local function _send(SOCK,opcode,message)
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
	local msgbyte={message:byte(1,length)}
	for i=1,length do
		msgbyte[i]=bxor(msgbyte[i],mask_key[(i-1)%4+1])
	end
	return SOCK:send(char(unpack(msgbyte)))
end

local OPcode={
	continue=0,
	text=1,
	binary=2,
	close=8,
	ping=9,
	pong=10
}
function WS:send(message,op)
	_send(self.socket,OPcode[op] or 2--[[binary]],message)
end

function WS:read()
	--Byte 0-1
	local SOCK=self.socket
	local res,err=SOCK:receive(2)
	if not res then return res,err end

	local OPCODE=band(res:byte(),0x0f)

	--Length
	local byte=res:byte(2)
	local length=band(byte,0x7f)
	if length==126 then
		res=SOCK:receive(2)
		local b1,b2=res:byte(1,2)
		length=shl(b1,8)+b2
	elseif length==127 then
		res=SOCK:receive(8)
		local b={res:byte(1,8)}
		length=shl(b[5],32)+shl(b[6],24)+shl(b[7],8)+b[8]
	end

	--Data
	res=SOCK:receive(length)
	local closeCode
	if OPCODE==9 then--ping
		self:send(res,10--[[pong]])
	elseif OPCODE==8 then--close
		closeCode=shl(res:byte(1),8)+res:byte(2)
		res=sub(res,3,-3)
		self:close()
	end

	return OPCODE,res,closeCode
end

function WS:close()
	self.socket:close()
end

function WS:settimeout(t)
	self.socket:settimeout(t)
end

return WS