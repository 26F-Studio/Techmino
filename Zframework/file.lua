local fs=love.filesystem
local int,max,min=math.floor,math.max,math.min
local sub,find=string.sub,string.find
local toN,toS=tonumber,tostring
local concat=table.concat

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
local function addToTable(G,base)--Refresh default base with G-values
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
		TEXT.show(text.recSavingError..(mes or"unknown error"),1140,650,20,"sudden",.5)
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
			modeRanks=s()
		end
	end
end
function FILE.saveUnlock()
	local F=files.unlock
	F:open("w")
	local _,mes=F:write(dumpTable(modeRanks))
	F:flush()F:close()
	if not _ then
		TEXT.show(text.unlockSavingError..(mes or"unknown error"),1140,650,20,"sudden",.5)
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
			addToTable(S,stat)
		end
	end
end
function FILE.saveData()
	local F=files.data
	F:open("w")
	local _,mes=F:write(dumpTable(stat))
	F:flush()F:close()
	if not _ then
		TEXT.show(text.statSavingError..(mes or"unknown error"),1140,650,20,"sudden",.5)
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
			addToTable(s(),setting)
		end
	end
end
function FILE.saveSetting()
	local F=files.setting
	F:open("w")
	local _,mes=F:write(dumpTable(setting))
	F:flush()F:close()
	if _ then TEXT.show(text.settingSaved,1140,650,40,"sudden",.5)
	else TEXT.show(text.settingSavingError..(mes or"unknown error"),1140,650,20,"sudden",.5)
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
	if _ then TEXT.show(text.keyMapSaved,1140,650,26,"sudden",.5)
	else TEXT.show(text.keyMapSavingError..(mes or"unknown error"),1140,650,20,"sudden",.5)
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
	if _ then TEXT.show(text.VKSaved,1140,650,26,"sudden",.5)
	else TEXT.show(text.VKSavingError..(mes or"unknown error"),1140,650,20,"sudden",.5)
	end
end
return FILE