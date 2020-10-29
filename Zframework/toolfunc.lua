local gc=love.graphics
local int=math.floor
local sub,find,format=string.sub,string.find,string.format

do--LOADLIB
	local libs={
		CC={
			Windows="CCloader",
			Linux="CCloader",
			Android="libCCloader.so",
			libFunc="luaopen_CCloader",
		},
		NETlib={
			Windows="client",
			Linux="client",
			Android="client.so",
			libFunc="luaopen_client",
		},
	}
	function LOADLIB(name)
		local libName=libs[name]
		if SYSTEM=="Windows"or SYSTEM=="Linux"then
			local success,message=require(libName[SYSTEM])
			if success then
				return success
			else
				LOG.print("Cannot load "..name..": "..message,"warn",color.red)
			end
		elseif SYSTEM=="Android"then
			local fs=love.filesystem
			local platform={"arm64-v8a","armeabi-v7a"}
			local libFunc
			for i=1,#platform do
				local soFile,size=fs.read("data","libAndroid/"..platform[i].."/"..libName.Android)
				if soFile then
					local success,message=fs.write(libName.Android,soFile,size)
					if success then
						libFunc,message=package.loadlib(table.concat({fs.getSaveDirectory(),libName.Android},"/"),libName.libFunc)
						if libFunc then
							LOG.print(name.." lib loaded","warn",color.green)
							break
						else
							LOG.print("Cannot load "..name..": "..message,"warn",color.red)
						end
					else
						LOG.print("Write "..name.."-"..platform[i].." to saving failed: "..message,"warn",color.red)
					end
				else
					LOG.print("Read "..name.."-"..platform[i].." failed","warn",color.red)
				end
			end
			if not libFunc then
				LOG.print("failed to load "..name,"warn",color.red)
				return
			end
			return libFunc()
		else
			LOG.print("No "..name.." for "..SYSTEM,"warn",color.red)
			return
		end
		return true
	end
end
do--setFont
	local newFont=gc.setNewFont
	local setNewFont=gc.setFont
	local fontCache,currentFontSize={}
	if love.filesystem.getInfo("font.ttf")then
		local fontData=love.filesystem.newFile("font.ttf")
		function setFont(s)
			if s~=currentFontSize then
				if not fontCache[s]then
					fontCache[s]=newFont(fontData,s)
				end
				setNewFont(fontCache[s])
				currentFontSize=s
			end
		end
		function getFont(s)
			if not fontCache[s]then
				fontCache[s]=newFont(fontData,s)
			end
			return fontCache[s]
		end
	else
		function setFont(s)
			if s~=currentFontSize then
				if not fontCache[s]then
					fontCache[s]=newFont(s)
				end
				setNewFont(fontCache[s])
				currentFontSize=s
			end
		end
		function getFont(s)
			if not fontCache[s]then
				fontCache[s]=newFont(s)
			end
			return fontCache[s]
		end
	end
end
do--upperChar
	local upper=string.upper
	upperList={
		["1"]="!",["2"]="@",["3"]="#",["4"]="$",["5"]="%",
		["6"]="^",["7"]="&",["8"]="*",["9"]="(",["0"]=")",
		["`"]="~",["-"]="_",["="]="+",
		["["]="{",["]"]="}",["\\"]="|",
		[";"]=":",["'"]="\"",
		[","]="<",["."]=">",["/"]="?",
	}
	function upperChar(c)
		return upperList[c]or upper(c)
	end
end
do--dumpTable
	local tabs={
		[0]="",
		"\t",
		"\t\t",
		"\t\t\t",
		"\t\t\t\t",
		"\t\t\t\t\t",
	}
	function dumpTable(L,t)
		local s
		if t then
			s="{\n"
		else
			s="return{\n"
			t=1
		end
		local count=1
		for k,v in next,L do
			local T=type(k)
			if T=="number"then
				if k==count then
					k=""
					count=count+1
				else
					k="["..k.."]="
				end
			elseif T=="string"then
				if find(k,"[^0-9a-zA-Z_]")then
					k="[\""..k.."\"]="
				else
					k=k.."="
				end
			elseif T=="boolean"then k="["..k.."]="
			else assert(false,"Error key type!")
			end
			T=type(v)
			if T=="number"then v=tostring(v)
			elseif T=="string"then v="\""..v.."\""
			elseif T=="table"then v=dumpTable(v,t+1)
			elseif T=="boolean"then v=tostring(v)
			else assert(false,"Error data type!")
			end
			s=s..tabs[t]..k..v..",\n"
		end
		return s..tabs[t-1].."}"
	end
end
do--httpRequest
	client=LOADLIB("NETlib")
	httpRequest=
	client and function(tick,api,method,header,body)
		local task,err=client.httpraw{
			url="http://47.103.200.40/"..api,
			method=method or"GET",
			header=header,
			body=body,
		}
		if task then
			TASK.new(tick,{task=task,time=0,net=true})
		else
			LOG.print("NETlib error: "..err,"warn")
		end
		TASK.netTaskCount=TASK.netTaskCount+1
	end or
	function()
		LOG.print("[NO NETlib]",5,color.yellow)
	end
end
do--json
	--
	-- json.lua
	--
	-- Copyright (c) 2020 rxi
	--
	-- Permission is hereby granted, free of charge, to any person obtaining a copy of
	-- this software and associated documentation files (the "Software"), to deal in
	-- the Software without restriction, including without limitation the rights to
	-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
	-- of the Software, and to permit persons to whom the Software is furnished to do
	-- so, subject to the following conditions:
	--
	-- The above copyright notice and this permission notice shall be included in all
	-- copies or substantial portions of the Software.
	--
	-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	-- SOFTWARE.
	--

	local char=string.char
	json = {}

	-------------------------------------------------------------------------------
	-- Encode
	-------------------------------------------------------------------------------

	local encode

	local escape_char_map = {
		["\\"] = "\\",
		["\""] = "\"",
		["\b"] = "b",
		["\f"] = "f",
		["\n"] = "n",
		["\r"] = "r",
		["\t"] = "t"
	}

	local escape_char_map_inv = {["/"] = "/"}
	for k, v in pairs(escape_char_map) do escape_char_map_inv[v] = k end

	local function escape_char(c)
		return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
	end

	local function encode_nil() return "null" end

	local function encode_table(val, stack)
		local res = {}
		stack = stack or {}

		-- Circular reference?
		if stack[val] then error("circular reference") end

		stack[val] = true

		if rawget(val, 1) ~= nil or next(val) == nil then
			-- Treat as array -- check keys are valid and it is not sparse
			local n = 0
			for k in pairs(val) do
				if type(k) ~= "number" then
					error("invalid table: mixed or invalid key types")
				end
				n = n + 1
			end
			if n ~= #val then error("invalid table: sparse array") end
			-- Encode
			for _, v in ipairs(val) do table.insert(res, encode(v, stack)) end
			stack[val] = nil
			return "[" .. table.concat(res, ",") .. "]"

		else
			-- Treat as an object
			for k, v in pairs(val) do
				if type(k) ~= "string" then
					error("invalid table: mixed or invalid key types")
				end
				table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
			end
			stack[val] = nil
			return "{" .. table.concat(res, ",") .. "}"
		end
	end

	local function encode_string(val)
		return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
	end

	local function encode_number(val)
		-- Check for NaN, -inf and inf
		if val ~= val or val <= -math.huge or val >= math.huge then
			error("unexpected number value '" .. tostring(val) .. "'")
		end
		return string.format("%.14g", val)
	end

	local type_func_map = {
		["nil"] = encode_nil,
		["table"] = encode_table,
		["string"] = encode_string,
		["number"] = encode_number,
		["boolean"] = tostring
	}

	encode = function(val, stack)
		local t = type(val)
		local f = type_func_map[t]
		if f then return f(val, stack) end
		error("unexpected type '" .. t .. "'")
	end

	function json.encode(val) return encode(val) end

	-------------------------------------------------------------------------------
	-- Decode
	-------------------------------------------------------------------------------

	local parse

	local function create_set(...)
		local res = {}
		for i = 1, select("#", ...) do res[select(i, ...)] = true end
		return res
	end

	local space_chars = create_set(" ", "\t", "\r", "\n")
	local delim_chars = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
	local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
	local literals = create_set("true", "false", "null")

	local literal_map = {["true"] = true, ["false"] = false, ["null"] = nil}

	local function next_char(str, idx, set, negate)
		for i = idx, #str do if set[str:sub(i, i)] ~= negate then return i end end
		return #str + 1
	end

	local function decode_error(str, idx, msg)
		local line_count = 1
		local col_count = 1
		for i = 1, idx - 1 do
			col_count = col_count + 1
			if str:sub(i, i) == "\n" then
				line_count = line_count + 1
				col_count = 1
			end
		end
		error(string.format("%s at line %d col %d", msg, line_count, col_count))
	end

	local function codepoint_to_utf8(n)
		-- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
		local f = math.floor
		if n <= 0x7f then
			return char(n)
		elseif n <= 0x7ff then
			return char(f(n / 64) + 192, n % 64 + 128)
		elseif n <= 0xffff then
			return char(f(n / 4096) + 224, f(n % 4096 / 64) + 128,
							n % 64 + 128)
		elseif n <= 0x10ffff then
			return char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
							f(n % 4096 / 64) + 128, n % 64 + 128)
		end
		error(string.format("invalid unicode codepoint '%x'", n))
	end

	local function parse_unicode_escape(s)
		local n1 = tonumber(s:sub(1, 4), 16)
		local n2 = tonumber(s:sub(7, 10), 16)
		-- Surrogate pair?
		if n2 then
			return
				codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
		else
			return codepoint_to_utf8(n1)
		end
	end

	local function parse_string(str, i)
		local res = ""
		local j = i + 1
		local k = j

		while j <= #str do
			local x = str:byte(j)

			if x < 32 then
				decode_error(str, j, "control character in string")

			elseif x == 92 then -- `\`: Escape
				res = res .. str:sub(k, j - 1)
				j = j + 1
				local c = str:sub(j, j)
				if c == "u" then
					local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1) or
									str:match("^%x%x%x%x", j + 1) or
									decode_error(str, j - 1,
												"invalid unicode escape in string")
					res = res .. parse_unicode_escape(hex)
					j = j + #hex
				else
					if not escape_chars[c] then
						decode_error(str, j - 1,
									"invalid escape char '" .. c .. "' in string")
					end
					res = res .. escape_char_map_inv[c]
				end
				k = j + 1

			elseif x == 34 then -- `"`: End of string
				res = res .. str:sub(k, j - 1)
				return res, j + 1
			end

			j = j + 1
		end

		decode_error(str, i, "expected closing quote for string")
	end

	local function parse_number(str, i)
		local x = next_char(str, i, delim_chars)
		local s = str:sub(i, x - 1)
		local n = tonumber(s)
		if not n then decode_error(str, i, "invalid number '" .. s .. "'") end
		return n, x
	end

	local function parse_literal(str, i)
		local x = next_char(str, i, delim_chars)
		local word = str:sub(i, x - 1)
		if not literals[word] then
			decode_error(str, i, "invalid literal '" .. word .. "'")
		end
		return literal_map[word], x
	end

	local function parse_array(str, i)
		local res = {}
		local n = 1
		i = i + 1
		while 1 do
			local x
			i = next_char(str, i, space_chars, true)
			-- Empty / end of array?
			if str:sub(i, i) == "]" then
				i = i + 1
				break
			end
			-- Read token
			x, i = parse(str, i)
			res[n] = x
			n = n + 1
			-- Next token
			i = next_char(str, i, space_chars, true)
			local chr = str:sub(i, i)
			i = i + 1
			if chr == "]" then break end
			if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
		end
		return res, i
	end

	local function parse_object(str, i)
		local res = {}
		i = i + 1
		while 1 do
			local key, val
			i = next_char(str, i, space_chars, true)
			-- Empty / end of object?
			if str:sub(i, i) == "}" then
				i = i + 1
				break
			end
			-- Read key
			if str:sub(i, i) ~= '"' then
				decode_error(str, i, "expected string for key")
			end
			key, i = parse(str, i)
			-- Read ':' delimiter
			i = next_char(str, i, space_chars, true)
			if str:sub(i, i) ~= ":" then
				decode_error(str, i, "expected ':' after key")
			end
			i = next_char(str, i + 1, space_chars, true)
			-- Read value
			val, i = parse(str, i)
			-- Set
			res[key] = val
			-- Next token
			i = next_char(str, i, space_chars, true)
			local chr = str:sub(i, i)
			i = i + 1
			if chr == "}" then break end
			if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
		end
		return res, i
	end

	local char_func_map = {
		['"'] = parse_string,
		["0"] = parse_number,
		["1"] = parse_number,
		["2"] = parse_number,
		["3"] = parse_number,
		["4"] = parse_number,
		["5"] = parse_number,
		["6"] = parse_number,
		["7"] = parse_number,
		["8"] = parse_number,
		["9"] = parse_number,
		["-"] = parse_number,
		["t"] = parse_literal,
		["f"] = parse_literal,
		["n"] = parse_literal,
		["["] = parse_array,
		["{"] = parse_object
	}

	function parse(str, idx)
		local chr = str:sub(idx, idx)
		local f = char_func_map[chr]
		if f then return f(str, idx) end
		decode_error(str, idx, "unexpected character '" .. chr .. "'")
	end

	function json.decode(str)
		if type(str) ~= "string" then
			error("expected argument of type string, got " .. type(str))
		end
		local res, idx = parse(str, next_char(str, 1, space_chars, true))
		idx = next_char(str, idx, space_chars, true)
		if idx <= #str then decode_error(str, idx, "trailing garbage") end
		return res
	end
end
function copyList(org)
	local L={}
	for i=1,#org do
		L[i]=org[i]
	end
	return L
end
function copyTable(org)
	local L={}
	for k,v in next,org do
		if type(v)~="table"then
			L[k]=v
		else
			L[k]=copyTable(v)
		end
	end
	return L
end
function addToTable(G,base)--For all things in G if same type in base, push to base
	for k,v in next,G do
		if type(v)==type(base[k])then
			if type(v)=="table"then
				addToTable(v,base[k])
			else
				base[k]=v
			end
		end
	end
end
function splitStr(s,sep)
	local L={}
	local p1,p2=1--start,target
	while p1<=#s do
		p2=find(s,sep,p1)or #s+1
		L[#L+1]=sub(s,p1,p2-1)
		p1=p2+#sep
	end
	return L
end
function toTime(s)
	if s<60 then
		return format("%.3fs",s)
	elseif s<3600 then
		return format("%d:%.2f",int(s/60),s%60)
	else
		local h=int(s/3600)
		return format("%d:%d:%.2f",h,int(s/60%60),s%60)
	end
end
function mStr(s,x,y)
	gc.printf(s,x-450,y,900,"center")
end
function mText(s,x,y)
	gc.draw(s,x-s:getWidth()*.5,y)
end
function mDraw(s,x,y,a,k)
	gc.draw(s,x,y,a,k,nil,s:getWidth()*.5,s:getHeight()*.5)
end