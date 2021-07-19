local triggerCHN,sendCHN,readCHN=...

local CHN_demand,CHN_getCount=triggerCHN.demand,triggerCHN.getCount
local CHN_push,CHN_pop=triggerCHN.push,triggerCHN.pop

local SOCK=require'socket'.tcp()
local JSON=require'Zframework.json'

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
	if not body then body=''end
	SOCK:send(
		'GET '..path..' HTTP/1.1\r\n'..
		'Host: '..host..':'..port..'\r\n'..
		'Connection: Upgrade\r\n'..
		'Upgrade: websocket\r\n'..
		'Content-Type: application/json\r\n'..
		'Content-Length: '..#body..'\r\n'..
		'Sec-WebSocket-Version: 13\r\n'..
		'Sec-WebSocket-Key: osT3F7mvlojIvf3/8uIsJQ==\r\n\r\n'..--secKey
		body
	)

	--First line of HTTP
	res,err=SOCK:receive('*l')
	if not res then CHN_push(readCHN,err)return end
	local code,ctLen
	code=res:find(' ')
	code=res:sub(code+1,code+3)

	--Get body length from headers and remove headers
	repeat
		res,err=SOCK:receive('*l')
		if not res then CHN_push(readCHN,err)return end
		if not ctLen and res:find('length')then
			ctLen=tonumber(res:match('%d+'))
		end
	until res==''

	--Result
	if ctLen then
		if code=='101'then
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
			SOCK:send('\128'..mask_str)
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
		op=CHN_pop(sendCHN)
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
				res,err=SOCK:receive(2)
				if res then
					length=shl(byte(res,1),8)+byte(res,2)--!!!!!
				else
					CHN_push(readCHN,8)--close
					CHN_push(readCHN,'{"reason":"'..(err or"error_01")..'"}')
				end
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
					UFF=true
					sBuffer=sBuffer..p
					length=length-#p
					break
				end
			else
				res=""
			end
		else
			local s,_,p=SOCK:receive(length)
			if s then
				sBuffer=sBuffer..s
				length=length-#s
			elseif p then
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
				CHN_push(readCHN,lBuffer)
				lBuffer=""
			else
			end
		else
			CHN_push(readCHN,op)
			if fin then
				CHN_push(readCHN,res)
			else
				sBuffer=res
			end
		end
	end
end