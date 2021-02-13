--[[
	websocket client pure lua implement for love2d
	by flaribbit

	usage:
		local client = require("websocket").new()
		client:settimeout(1)
		client:connect("127.0.0.1", 5000)
		client:settimeout(0)
		client:send("hello from love2d")
		res, opcode = client:read()
		print(res)
		client:close()
]]

-- local debug_print=print
local socket = require"socket"
local bit = require"bit"
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local shl, shr = bit.lshift, bit.rshift

local OPCODES = {
	CONTINUE=0,
	TEXT    =1,
	BINARY  =2,
	CLOSE   =8,
	PING    =9,
	PONG    =10,
}

local _M = {
	OPCODES = OPCODES,
}
_M.__index = _M

function _M.new()
	local m = {socket = socket.tcp()}
	setmetatable(m, _M)
	return m
end

local seckey = "osT3F7mvlojIvf3/8uIsJQ=="
function _M:connect(host, port, path)
	local SOCK = self.socket
	local res, err = SOCK:connect(host, port)
	if res~=1 then return res, err end
	-- debug_print("[handshake] connected")

	-- WebSocket handshake
	res, err = SOCK:send("GET "..(path or"/").." HTTP/1.1\r\nHost: "..host..":"..port.."\r\nConnection: Upgrade\r\nUpgrade: websocket\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: "..seckey.."\r\n\r\n")
	repeat res = SOCK:receive("*l") until res==""
	-- debug_print("[handshake] succeed")
end

local mask_key = {1, 14, 5, 14}
local function send(SOCK, opcode, message)
	-- message type
	SOCK:send(string.char(bor(0x80, opcode)))

	if not message then
		SOCK:send(string.char(0x80, unpack(mask_key)))
		return 0
	end

	-- length
	local length = #message
	-- debug_print("[encode] message length: "..length)
	if length>65535 then
		SOCK:send(string.char(bor(127, 0x80), 0, 0, 0, 0,
			band(shr(length, 24), 0xff),
			band(shr(length, 16), 0xff),
			band(shr(length, 8), 0xff),
			band(length, 0xff)))
	elseif length>125 then
		SOCK:send(string.char(bor(126, 0x80),
			band(shr(length, 8), 0xff),
			band(length, 0xff)))
	else
		SOCK:send(string.char(bor(length, 0x80)))
	end
	-- debug_print("[encode] masking")
	SOCK:send(string.char(unpack(mask_key)))
	local msgbyte = {message:byte(1, length)}
	for i = 1, length do
		msgbyte[i] = bxor(msgbyte[i], mask_key[(i-1)%4+1])
	end
	return SOCK:send(string.char(unpack(msgbyte)))
	-- debug_print("[encode] end")
end

function _M:send(message)
	send(self.socket, OPCODES.BINARY, message)
end

function _M:ping(message)
	send(self.socket, OPCODES.PING, message)
end

function _M:pong(message)
	send(self.socket, OPCODES.PONG, message)
end

function _M:read()
	-- byte 0-1
	local SOCK = self.socket
	local res, err = SOCK:receive(2)
	if not res then return res, err end

	local OPCODE = band(res:byte(), 0x0f)
	-- local flag_FIN = res:byte()>=0x80
	-- local flag_MASK = res:byte(2)>=0x80
	-- debug_print("[decode] FIN="..tostring(flag_FIN)..", OPCODE="..OPCODE..", MASK="..tostring(flag_MASK))

	-- length
	local byte = res:byte(2)
	local length = band(byte, 0x7f)
	if length==126 then
		res = SOCK:receive(2)
		local b1, b2 = res:byte(1, 2)
		length = shl(b1, 8) + b2
	elseif length==127 then
		res = SOCK:receive(8)
		local b = {res:byte(1, 8)}
		length = shl(b[5], 32) + shl(b[6], 24) + shl(b[7], 8) + b[8]
	end
	-- debug_print("[decode] message length: "..length)

	-- data
	res = SOCK:receive(length)
	if OPCODE==OPCODES.PING then
		self:pong(res)
	elseif OPCODE==OPCODES.CLOSE then
		self:close()
	end
	-- debug_print("[decode] string length: "..#res)
	-- debug_print("[decode] end")
	return res, OPCODE
end

function _M:close() self.socket:close() end

function _M:settimeout(t) self.socket:settimeout(t) end

return _M