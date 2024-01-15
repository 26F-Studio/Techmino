local triggerCHN,sendCHN,readCHN=...

local CHN_demand,CHN_getCount=triggerCHN.demand,triggerCHN.getCount
local CHN_push,CHN_pop=triggerCHN.push,triggerCHN.pop

local SOCK=require'socket'.tcp()
local JSON=require'Zframework.json'

do-- Connect
    local host=CHN_demand(sendCHN)
    local port=CHN_demand(sendCHN)
    local path=CHN_demand(sendCHN)
    local head=CHN_demand(sendCHN)
    local timeout=CHN_demand(sendCHN)

    SOCK:settimeout(timeout)
    local res,err=SOCK:connect(host,port)
    assert(res,err)

    -- WebSocket handshake
    SOCK:send(
        'GET '..path..' HTTP/1.1\r\n'..
        'Host: '..host..':'..port..'\r\n'..
        'Connection: Upgrade\r\n'..
        'Upgrade: websocket\r\n'..
        'Sec-WebSocket-Version: 13\r\n'..
        'Sec-WebSocket-Key: osT3F7mvlojIvf3/8uIsJQ==\r\n'..-- secKey
        head..
        '\r\n'
    )

    -- First line of HTTP
    res,err=SOCK:receive('*l')
    assert(res,err)
    local code,ctLen
    code=res:find(' ')
    code=res:sub(code+1,code+3)

    -- Get body length from headers and remove headers
    repeat
        res,err=SOCK:receive('*l')
        assert(res,err)
        if not ctLen and res:find('length') then
            ctLen=tonumber(res:match('%d+'))
        end
    until res==''

    -- Result
    if ctLen then
        if code=='101' then
            CHN_push(readCHN,'success')
        else
            res,err=SOCK:receive(ctLen)
            res=JSON.decode(assert(res,err))
            error((code or "XXX")..":"..(res and res.reason or "Server Error"))
        end
    end
    SOCK:settimeout(0)
end

local yield=coroutine.yield
local byte,char=string.byte,string.char
local band,bor,bxor=bit.band,bit.bor,bit.bxor
local shl,shr=bit.lshift,bit.rshift

local mask_key={1,14,5,14}
local mask_str=char(unpack(mask_key))
local function _send(op,message)
    -- Message type
    SOCK:send(char(bor(op,0x80)))

    if message then
        -- Length
        local length=#message
        if length>65535 then
            SOCK:send(char(bor(127,0x80),0,0,0,0,band(shr(length,24),0xff),band(shr(length,16),0xff),band(shr(length,8),0xff),band(length,0xff)))
        elseif length>125 then
            SOCK:send(char(bor(126,0x80),band(shr(length,8),0xff),band(length,0xff)))
        else
            SOCK:send(char(bor(length,0x80)))
        end
        local msgbyte={byte(message,1,length)}
        for i=1,length do
            msgbyte[i]=bxor(msgbyte[i],mask_key[(i-1)%4+1])
        end
        return SOCK:send(mask_str..char(unpack(msgbyte)))
    else
        SOCK:send('\128'..mask_str)
        return 0
    end
end
local sendThread=coroutine.wrap(function()
    while true do
        while CHN_getCount(sendCHN)>=2 do
            _send(CHN_pop(sendCHN),CHN_pop(sendCHN))
        end
        yield()
    end
end)

local function _receive(sock,len)
    local buffer=""
    while true do
        local r,e,p=sock:receive(len)
        if r then
            buffer=buffer..r
            len=len-#r
        elseif p then
            buffer=buffer..p
            len=len-#p
        elseif e then
            return nil,e
        end
        if len==0 then
            return buffer
        end
        yield()
    end
end
local readThread=coroutine.wrap(function()
    local res,err
    local op,fin
    local lBuffer=""-- Long multi-pack buffer
    while true do
        -- Byte 0-1
        res,err=_receive(SOCK,2)
        assert(res,err)

        op=band(byte(res,1),0x0f)
        fin=band(byte(res,1),0x80)==0x80

        -- Calculating data length
        local length=band(byte(res,2),0x7f)
        if length==126 then
            res,err=_receive(SOCK,2)
            assert(res,err)
            length=shl(byte(res,1),8)+byte(res,2)
        elseif length==127 then
            local lenData
            lenData,err=_receive(SOCK,8)
            assert(res,err)
            local _,_,_,_,_5,_6,_7,_8=byte(lenData,1,8)
            length=shl(_5,24)+shl(_6,16)+shl(_7,8)+_8
        end
        res,err=_receive(SOCK,length)
        assert(res,err)

        -- React
        if op==8 then-- 8=close
            CHN_push(readCHN,8)-- close
            if type(res)=='string' then
                CHN_push(readCHN,res:sub(3))--[Warning] 2 bytes close code at start so :sub(3)
            else
                CHN_push(readCHN,"WS closed")
            end
            return
        elseif op==0 then-- 0=continue
            lBuffer=lBuffer..res
            if fin then
                CHN_push(readCHN,lBuffer)
                lBuffer=""
            end
        else
            CHN_push(readCHN,op)
            if fin then
                CHN_push(readCHN,res)
                lBuffer=""
            else
                lBuffer=res
            end
        end
        yield()
    end
end)

local success,err

while true do-- Running
    CHN_demand(triggerCHN)
    success,err=pcall(sendThread)
    if not success or err then break end
    success,err=pcall(readThread)
    if not success or err then break end
end

SOCK:close()
CHN_push(readCHN,8)-- close
CHN_push(readCHN,err or "Disconnected")
error()
