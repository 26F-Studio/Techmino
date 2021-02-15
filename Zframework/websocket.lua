--[[
	websocket client pure lua implement for love2d
	by flaribbit and Particle_G

	usage:
		local client = require("websocket").new()
		client:settimeout(1)
		client:connect("127.0.0.1:5000", "/test", '{"foo":"bar"}')
		client:settimeout(0)
		client:send("hello from love2d", OPCODES.TEXT)
        love.timer.sleep(0.2)
		opcode, res, closeCode = client:read()
		print(res)
		client:send("Goodbye from love2d", OPCODES.CLOSE)
]] -- local debug_print=print

local socket = require "socket"
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local shl, shr = bit.lshift, bit.rshift

OPCODES = {
    CONTINUE = 0,
    TEXT = 1,
    BINARY = 2,
    CLOSE = 8,
    PING = 9,
    PONG = 10
}

local _M = {
    OPCODES = OPCODES
}
_M.__index = _M

function splitStr(s, sep)
    local L = {}
    local p1 = 1
    local p2 = nil
    while p1 <= #s do
        p2 = string.find(s, sep, p1) or #s + 1
        L[#L + 1] = string.sub(s, p1, p2 - 1)
        p1 = p2 + #sep
    end
    return L
end

function _M.new()
    local m = {
        socket = socket.tcp()
    }
    setmetatable(m, _M)
    return m
end

local seckey = "osT3F7mvlojIvf3/8uIsJQ=="
function _M:connect(server, path, body)
    local host, port = unpack(splitStr(server, ":"))
    local SOCK = self.socket
    local res, err = SOCK:connect(host, port or 80)
    if res ~= 1 then
        return res, err
    end

    -- WebSocket handshake
    res, err = SOCK:send("GET " .. (path or "/") .. " HTTP/1.1\r\n" .. "Host: " .. host .. ":" .. port .. "\r\n" ..
                             "Connection: Upgrade\r\n" .. "Upgrade: websocket\r\n" ..
                             "Content-Type: application/json\r\n" .. "Content-Length: " .. (body and {#body} or {0})[1] ..
                             "\r\n" .. "Sec-WebSocket-Version: 13\r\n" .. "Sec-WebSocket-Key: " .. seckey .. "\r\n" ..
                             '\r\n' .. (body and {body} or {""})[1])
    repeat
        res = SOCK:receive("*l")
    until res == ""
end

local mask_key = {1, 14, 5, 14}
local function _send(SOCK, opcode, message)
    -- message type
    SOCK:send(string.char(bor(0x80, opcode)))

    if not message then
        SOCK:send(string.char(0x80, unpack(mask_key)))
        return 0
    end

    -- length
    local length = #message
    if length > 65535 then
        SOCK:send(string.char(bor(127, 0x80), 0, 0, 0, 0, band(shr(length, 24), 0xff), band(shr(length, 16), 0xff),
                      band(shr(length, 8), 0xff), band(length, 0xff)))
    elseif length > 125 then
        SOCK:send(string.char(bor(126, 0x80), band(shr(length, 8), 0xff), band(length, 0xff)))
    else
        SOCK:send(string.char(bor(length, 0x80)))
    end
    SOCK:send(string.char(unpack(mask_key)))
    local msgbyte = {message:byte(1, length)}
    for i = 1, length do
        msgbyte[i] = bxor(msgbyte[i], mask_key[(i - 1) % 4 + 1])
    end
    return SOCK:send(string.char(unpack(msgbyte)))
end

function _M:send(message, type)
    local tempType = OPCODES.BINARY
    for _, opcode in pairs(_M.OPCODES) do
        if type == opcode then
            tempType = type
        end
    end
    _send(self.socket, tempType, message)
end

function _M:read()
    -- byte 0-1
    local SOCK = self.socket
    local res, err = SOCK:receive(2)
    if not res then
        return res, err
    end

    local OPCODE = band(res:byte(), 0x0f)
    -- local flag_FIN = res:byte()>=0x80
    -- local flag_MASK = res:byte(2)>=0x80

    -- length
    local byte = res:byte(2)
    local length = band(byte, 0x7f)
    if length == 126 then
        res = SOCK:receive(2)
        local b1, b2 = res:byte(1, 2)
        length = shl(b1, 8) + b2
    elseif length == 127 then
        res = SOCK:receive(8)
        local b = {res:byte(1, 8)}
        length = shl(b[5], 32) + shl(b[6], 24) + shl(b[7], 8) + b[8]
    end

    -- data
    res = SOCK:receive(length)
    local closeCode = nil
    if OPCODE == OPCODES.PING then
        self:pong(res)
    elseif OPCODE == OPCODES.CLOSE then
        closeCode = shl(res:byte(1), 8) + res:byte(2)
        res = string.sub(res, 3, string.len(res) - 2)
        self:close()
    end

    return OPCODE, res, closeCode
end

function _M:close()
    self.socket:close()
end

function _M:settimeout(t)
    self.socket:settimeout(t)
end

return _M
