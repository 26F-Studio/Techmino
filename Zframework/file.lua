local fs=love.filesystem
local FILE={}
function FILE.load(name)
	name=name..".dat"
	local F=fs.newFile(name)
	if F:open("r")then
		local s=F:read()
		F:close()
		if s:sub(1,6)=="return"then
			s=loadstring(s)
			if s then
				setfenv(s,{})
				return s()
			else
				LOG.print(name.." "..text.loadError,COLOR.red)
			end
		else
			local res=json.decode(s)
			if res then
				return res
			else
				LOG.print(name.." "..text.loadError,COLOR.red)
			end
		end
	end
end
function FILE.save(data,name,mode,luacode)
	if not mode then mode="m"end
	name=name..".dat"
	local _,mes
	if not luacode then
		res=json.encode(res)
		if res then
			LOG.print(name.." "..text.saveError..(mes or"json error"),"error")
		end
	else
		data=dumpTable(data)
	end

	local F=fs.newFile(name)
	F:open("w")
	_,mes=F:write(data)
	F:flush()F:close()
	if _ then
		if mode:find("m")then
			LOG.print(text.saveDone,COLOR.green)
		end
	else
		LOG.print(text.saveError..(mes or"unknown error"),"error")
	end
end
return FILE