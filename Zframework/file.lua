local fs=love.filesystem

local files={
	data=	fs.newFile("data.dat"),
	setting=fs.newFile("settings.dat"),
	VK=		fs.newFile("virtualkey.dat"),
	keyMap=	fs.newFile("key.dat"),
	unlock=	fs.newFile("unlock.dat"),
}

local FILE={}
function FILE.loadRecord(N)
	local F=fs.newFile(N..".dat")
	if F:open("r")then
		local s=loadstring(F:read())
		F:close()
		if s then
			setfenv(s,{})
			return s()
		else
			return{}
		end
	end
end
function FILE.saveRecord(N,L)
	local F=fs.newFile(N..".dat")
	F:open("w")
	local _,mes=F:write(dumpTable(L))
	F:flush()F:close()
	if not _ then
		LOG.print(text.recSavingError..(mes or"unknown error"),COLOR.red)
	end
end
function FILE.delRecord(N)
	fs.remove(N..".dat")
end

function FILE.loadUnlock()
	local F=files.unlock
	if F:open("r")then
		local s=F:read()
		if s:sub(1,6)~="return"then s="return{"..s.."}"end
		s=loadstring(s)
		F:close()
		if s then
			setfenv(s,{})
			RANKS=s()
		end
	end
end
function FILE.saveUnlock()
	local F=files.unlock
	F:open("w")
	local _,mes=F:write(dumpTable(RANKS))
	F:flush()F:close()
	if not _ then
		LOG.print(text.unlockSavingError..(mes or"unknown error"),COLOR.red)
	end
end

function FILE.loadData()
	local F=files.data
	if F:open("r")then
		local s=F:read()
		if s:sub(1,6)~="return"then
			s="return{"..s:gsub("\n",",").."}"
		end
		s=loadstring(s)
		F:close()
		if s then
			setfenv(s,{})
			local S=s()
			addToTable(S,STAT)
		end
	end
end
function FILE.saveData()
	local F=files.data
	F:open("w")
	local _,mes=F:write(dumpTable(STAT))
	F:flush()F:close()
	if not _ then
		LOG.print(text.statSavingError..(mes or"unknown error"),COLOR.red)
	end
end

function FILE.loadSetting()
	local F=files.setting
	if F:open("r")then
		local s=F:read()
		if s:sub(1,6)~="return"then
			s="return{"..s:gsub("\n",",").."}"
		end
		s=loadstring(s)
		F:close()
		if s then
			setfenv(s,{})
			addToTable(s(),SETTING)
		end
	end
end
function FILE.saveSetting()
	local F=files.setting
	F:open("w")
	local _,mes=F:write(dumpTable(SETTING))
	F:flush()F:close()
	if _ then LOG.print(text.settingSaved,COLOR.green)
	else LOG.print(text.settingSavingError..(mes or"unknown error"),COLOR.red)
	end
end

function FILE.loadKeyMap()
	local F=files.keyMap
	if F:open("r")then
		local s=loadstring(F:read())
		F:close()
		if s then
			setfenv(s,{})
			addToTable(s(),keyMap)
		end
	end
end
function FILE.saveKeyMap()
	local F=files.keyMap
	F:open("w")
	local _,mes=F:write(dumpTable(keyMap))
	F:flush()F:close()
	if _ then LOG.print(text.keyMapSaved,COLOR.green)
	else LOG.print(text.keyMapSavingError..(mes or"unknown error"),COLOR.red)
	end
end

function FILE.loadVK()
	local F=files.VK
	if F:open("r")then
		local s=loadstring(F:read())
		F:close()
		if s then
			setfenv(s,{})
			addToTable(s(),VK_org)
		end
	end
end
function FILE.saveVK()
	local F=files.VK
	F:open("w")
	local _,mes=F:write(dumpTable(VK_org))
	F:flush()F:close()
	if _ then LOG.print(text.VKSaved,COLOR.green)
	else LOG.print(text.VKSavingError..(mes or"unknown error"),COLOR.red)
	end
end
return FILE