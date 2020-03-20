local fs=love.filesystem
local int,max,min=math.floor,math.max,math.min
local sub,find=string.sub,string.find
local toN,toS=tonumber,tostring
local concat=table.concat
local FILE={
	data=	fs.newFile("data.dat"),
	setting=fs.newFile("setting.dat"),
	VK=		fs.newFile("virtualkey.dat"),
	keyMap=	fs.newFile("key.dat"),
	unlock=	fs.newFile("unlock.dat"),
}
local function splitS(s,sep)
	local t,n={},1
	repeat
		local p=find(s,sep)or #s+1
		t[n]=sub(s,1,p-1)
		n=n+1
		s=sub(s,p+#sep)
	until #s==0
	return t
end

local tabs={
    [0]="",
	"\t",
	"\t\t",
	"\t\t\t",
	"\t\t\t\t",
	"\t\t\t\t\t",
}
local function dumpTable(L,t)
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
				k="";count=count+1
			else
				k="["..k.."]="
			end
		elseif T=="string"then k=k.."="
		elseif T=="boolean"then k="["..k.."]="
		else error("Error key type!")
		end
		T=type(v)
		if T=="number"then v=tostring(v)
		elseif T=="string"then v="\""..v.."\""
		elseif T=="table"then v=dumpTable(v,t+1)
		elseif T=="boolean"then v=tostring(v)
		else error("Error data type!")
		end
		s=s..tabs[t]..k..v..",\n"
	end
	return s..tabs[t-1].."}"
end
local function addToTable(G,base)--push all values to base
	for k,v in next,G do
		if type(v)=="table"and type(base[k])=="table"then
			addToTable(v,base[k])
		else
			base[k]=v
		end
	end
end
function loadRecord(N)
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
function saveRecord(N,L)
	local F=fs.newFile(N..".dat")
	F:open("w")
	local _,mes=F:write(dumpTable(L))
	F:flush()F:close()
	if not _ then
		TEXT(text.recSavingError..mes,1140,650,20,"sudden",.5)
	end
end
function delRecord(N)
	fs.remove(N..".dat")
end

function loadUnlock()
	local F=FILE.unlock
	if F:open("r")then
		local s=F:read()
		if s:sub(1,6)~="return"then s="return{"..s.."}"end
		s=loadstring(s)
		F:close()
		if s then
			setfenv(s,{})
			modeRanks=s()
		end
	end
end
function saveUnlock()
	local F=FILE.unlock
	F:open("w")
	local _,mes=F:write(dumpTable(modeRanks))
	F:flush()F:close()
	if not _ then
		TEXT(text.unlockSavingError..mes,1140,650,20,"sudden",.5)
	end
end

function loadData()
	local F=FILE.data
	if F:open("r")then
		local s=F:read()
		if s:sub(1,6)~="return"then
			s="return{"..s:gsub("\n",",").."}"
		end
		s=loadstring(s)
		F:close()
		if s then
			setfenv(s,{})
			addToTable(s(),stat)
		end
	end
end
function saveData()
	local F=FILE.data
	F:open("w")
	local _,mes=F:write(dumpTable(stat))
	F:flush()F:close()
	if not _ then
		TEXT(text.statSavingError..mes,1140,650,20,"sudden",.5)
	end
end

function loadSetting()
	local F=FILE.setting
	if F:open("r")then
		local s=F:read()
		if s:sub(1,6)~="return"then
			s="return{"..s:gsub("\n",",").."}"
		end
		s=loadstring(s)
		F:close()
		if s then
			setfenv(s,{})
			addToTable(s(),setting)
		end
	end
end
function saveSetting()
	local F=FILE.setting
	F:open("w")
	local _,mes=F:write(dumpTable(setting))
	F:flush()F:close()
	if _ then TEXT(text.settingSaved,1140,650,40,"sudden",.5)
	else TEXT(text.settingSavingError..mes,1140,650,20,"sudden",.5)
	end
end

function loadKeyMap()
	local F=FILE.keyMap
	if F:open("r")then
		local s=loadstring(F:read())
		F:close()
		if s then
			setfenv(s,{})
			addToTable(s(),keyMap)
		end
	end
end
function saveKeyMap()
	local F=FILE.keyMap
	F:open("w")
	local _,mes=F:write(dumpTable(keyMap))
	F:flush()F:close()
	if _ then TEXT(text.keyMapSaved,1140,650,26,"sudden",.5)
	else TEXT(text.keyMapSavingError..mes,1140,650,20,"sudden",.5)
	end
end

function loadVK()
	local F=FILE.VK
	if F:open("r")then
		local s=loadstring(F:read())
		F:close()
		if s then
			setfenv(s,{})
			addToTable(s(),VK_org)
		end
	end
end
function saveVK()
	local F=FILE.VK
	F:open("w")
	local _,mes=F:write(dumpTable(VK_org))
	F:flush()F:close()
	if _ then TEXT(text.VKSaved,1140,650,26,"sudden",.5)
	else TEXT(text.VKSavingError..mes,1140,650,20,"sudden",.5)
	end
end

if fs.getInfo("unlock.dat")then loadUnlock()end
if fs.getInfo("data.dat")then loadData()end
if fs.getInfo("key.dat")then loadKeyMap()end
if fs.getInfo("virtualkey.dat")then loadVK()end
if fs.getInfo("setting.dat")then loadSetting()
elseif system=="Android"or system=="iOS" then
	setting.VKSwitch=true
	setting.swap=false
	setting.vib=2
end