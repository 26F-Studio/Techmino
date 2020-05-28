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
		elseif T=="string"then k=k.."="
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
local function addToTable(G,base)--refresh default base with G-values
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

local File={}
function File.loadRecord(N)
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
function File.saveRecord(N,L)
	local F=fs.newFile(N..".dat")
	F:open("w")
	local _,mes=F:write(dumpTable(L))
	F:flush()F:close()
	if not _ then
		TEXT.show(text.recSavingError..(mes or"unknown error"),1140,650,20,"sudden",.5)
	end
end
function File.delRecord(N)
	fs.remove(N..".dat")
end

function File.loadUnlock()
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
function File.saveUnlock()
	local F=files.unlock
	F:open("w")
	local _,mes=F:write(dumpTable(modeRanks))
	F:flush()F:close()
	if not _ then
		TEXT.show(text.unlockSavingError..(mes or"unknown error"),1140,650,20,"sudden",.5)
	end
end

function File.loadData()
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
			if not S.version or S.version=="Alpha V0.8.15"then
				S.clear_S={S.clear_1,S.clear_2,S.clear_3,S.clear_4}
				S.clear={{},{},{},{},{},{},{}}
				local A,B,C,D=int(S.clear_1/7),int(S.clear_2/7),int(S.clear_3/7),S.clear_4
				for i=1,7 do
					S.clear[i][1]=A
					S.clear[i][2]=B
					S.clear[i][3]=C
					S.clear[i][4]=0
				end
				S.clear[7][4]=D
				for i=1,S.clear_1%7 do S.clear[i][1]=S.clear[i][1]+1 end
				for i=1,S.clear_2%7 do S.clear[i][2]=S.clear[i][2]+1 end
				for i=1,S.clear_3%7 do S.clear[i][3]=S.clear[i][3]+1 end
				S.clear_B={}
				for i=1,7 do
					S.clear_B[i]=S.clear[i][1]+S.clear[i][2]+S.clear[i][3]+S.clear[i][4]
				end

				S.spin_S={S.spin_0,S.spin_1,S.spin_2,S.spin_3}
				S.spin={{},{},{},{},{},{},{}}
				A,B,C,D=int(S.spin_0/7),int(S.spin_1/7),int(S.spin_2/7),int(S.spin_3/7)
				for i=1,7 do
					S.spin[i][1]=A
					S.spin[i][2]=B
					S.spin[i][3]=C
					S.spin[i][4]=D
				end
				for i=1,S.spin_0%7 do S.spin[i][1]=S.spin[i][1]+1 end
				for i=1,S.spin_1%7 do S.spin[i][2]=S.spin[i][2]+1 end
				for i=1,S.spin_2%7 do S.spin[i][3]=S.spin[i][3]+1 end
				for i=1,S.spin_3%7 do S.spin[i][4]=S.spin[i][4]+1 end
				S.spin_B={}
				for i=1,7 do
					S.spin_B[i]=S.spin[i][1]+S.spin[i][2]+S.spin[i][3]+S.spin[i][4]
				end

				S.hpc=S.c
			elseif S.version=="Alpha V0.8.16"then
				for i=1,6 do
					S.clear[7][4]=S.clear[7][4]+S.clear[i][4]
					S.clear[i][4]=0
				end
			end
			if not S.clear_B[8]then
				for i=1,7 do
					S.clear[i][5]=0
					S.spin[i][5]=0
				end
				for i=8,25 do
					S.clear[i]={0,0,0,0,0}
					S.spin[i]={0,0,0,0,0}
					S.spin_B[i]=0
					S.clear_B[i]=0
				end
				S.spin_S[5]=0
				S.clear_S[5]=0
			end
			if S.version=="Alpha V0.8.18"or S.version=="Alpha V0.8.19"then
				S.clear[3],S.clear[4]=S.clear[4],S.clear[3]
				S.spin[3],S.spin[4]=S.spin[4],S.spin[3]
				S.clear_B[3],S.clear_B[4]=S.clear_B[4],S.clear_B[3]
				S.spin_B[3],S.spin_B[4]=S.spin_B[4],S.spin_B[3]
			end
			if #modeRanks==76 then
				for i=1,4 do
					table.remove(modeRanks)
				end
			end
			if S.version~=gameVersion then
				S.version=gameVersion
				TEXT.show(text.newVersion,640,200,30,"fly",.3)
			end
			addToTable(S,stat)
		end
	end
end
function File.saveData()
	local F=files.data
	F:open("w")
	local _,mes=F:write(dumpTable(stat))
	F:flush()F:close()
	if not _ then
		TEXT.show(text.statSavingError..(mes or"unknown error"),1140,650,20,"sudden",.5)
	end
end

function File.loadSetting()
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
function File.saveSetting()
	local F=files.setting
	F:open("w")
	local _,mes=F:write(dumpTable(setting))
	F:flush()F:close()
	if _ then TEXT.show(text.settingSaved,1140,650,40,"sudden",.5)
	else TEXT.show(text.settingSavingError..(mes or"unknown error"),1140,650,20,"sudden",.5)
	end
end

function File.loadKeyMap()
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
function File.saveKeyMap()
	local F=files.keyMap
	F:open("w")
	local _,mes=F:write(dumpTable(keyMap))
	F:flush()F:close()
	if _ then TEXT.show(text.keyMapSaved,1140,650,26,"sudden",.5)
	else TEXT.show(text.keyMapSavingError..(mes or"unknown error"),1140,650,20,"sudden",.5)
	end
end

function File.loadVK()
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
function File.saveVK()
	local F=files.VK
	F:open("w")
	local _,mes=F:write(dumpTable(VK_org))
	F:flush()F:close()
	if _ then TEXT.show(text.VKSaved,1140,650,26,"sudden",.5)
	else TEXT.show(text.VKSavingError..(mes or"unknown error"),1140,650,20,"sudden",.5)
	end
end
return File