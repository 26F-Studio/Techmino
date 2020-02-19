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

function loadRecord(N)
	local F=fs.newFile(N..".dat")
	if F:open("r")then
		local s=loadstring(F:read())
		local T={}
		setfenv(s,T)
		T[1]=s()
		return T[1]
	end
end
local function dumpTable(L)
	local s="{\n"
	for k,v in next,L do
		local T
		T=type(k)
			if T=="number"then k="["..k.."]="
			elseif T=="string"then k=k.."="
			else error("Error data type!")
			end
		T=type(v)
			if T=="number"then v=tostring(v)
			elseif T=="string"then v="\""..v.."\""
			elseif T=="table"then v=dumpTable(v)
			else error("Error data type!")
			end
		s=s..k..v..",\n"
	end
	return s.."}"
end
function saveRecord(N,L)
	local F=fs.newFile(N..".dat")
	F:open("w")
	local _=F:write("return"..dumpTable(L))
	F:flush()
	F:close()
	if not _ then
		TEXT(text.recSavingError..mes,640,480,40,"appear",.4)
	end
end
function delRecord(N)
	fs.remove(N..".dat")
end

function saveUnlock()
	local t={}
	local RR=modeRanks
	for i=1,#RR do
		t[i]=RR[i]or"X"
	end
	t=concat(t,",")
	local F=FILE.unlock
	F:open("w")
	local _=F:write(t)
	F:flush()
	F:close()
	if not _ then
		TEXT(text.unlockSavingError..mes,640,480,40,"appear",.4)
	end
end
function loadUnlock()
	local F=FILE.unlock
	F:open("r")
	local t=F:read()
	F:close()
	t=splitS(t,",")
	for i=1,#modeRanks do
		local v=toN(t[i])
		if not v or v<0 or v>6 or v~=int(v)then v=false end
		modeRanks[i]=v
	end
end

local statOpy={
	"run","game","time",
	"extraPiece","extraRate",
	"key","rotate","hold","piece","row",
	"atk","send","recv","pend",
	"clear_1","clear_2","clear_3","clear_4",
	"spin_0","spin_1","spin_2","spin_3",
	"b2b","b3b","pc","score",
}
function loadStat()
	local F=FILE.data
	F:open("r")
	local t=F:read()
	F:close()
	t=splitS(t,"\r\n")
	for i=1,#t do
		local p=find(t[i],"=")
		if p then
			local t,v=sub(t[i],1,p-1),sub(t[i],p+1)
			for i=1,#statOpy do
				if t==statOpy[i]then
					v=toN(v)if not v or v<0 then v=0 end
					stat[t]=v
					break
				end
			end
		end
	end
end
function saveStat()
	local t={}
	for i=1,#statOpy do
		t[i]=statOpy[i].."="..toS(stat[statOpy[i]])
	end

	t=concat(t,"\r\n")
	local F=FILE.data
	F:open("w")
	local _=F:write(t)
	F:flush()
	F:close()
	if not _ then
		TEXT(text.statSavingError..mes,640,480,40,"appear",.4)
	end
end

function loadSetting()
	local F=FILE.setting
	F:open("r")
	local t=F:read()
	F:close()
	t=splitS(t,"\r\n")
	for i=1,#t do
		local p=find(t[i],"=")
		if p then
			local t,v=sub(t[i],1,p-1),sub(t[i],p+1)
			if--10档的设置
				--声音
				t=="sfx"or t=="bgm"or t=="voc"or t=="stereo"or
				--三个触摸设置项
				t=="VKTchW"or t=="VKCurW"or t=="VKAlpha"or
				--重开时间
				t=="reTime"
			then
				v=toN(v)
				if v and v==int(v)and v>=0 and v<=10 then
					setting[t]=v
				end
			elseif t=="vib"then
				setting.vib=toN(v:match("[012345]"))or 0
			elseif t=="fullscreen"then
				setting.fullscreen=v=="true"
				love.window.setFullscreen(setting.fullscreen)
			elseif
				--开关设置们
				t=="bg"or
				t=="ghost"or t=="center"or t=="grid"or t=="swap"or
				t=="quickR"or t=="fine"or t=="bgspace"or t=="smo"or
				t=="VKSwitch"or t=="VKTrack"or t=="VKDodge"or t=="VKIcon"
			then
				setting[t]=v=="true"
			elseif t=="frameMul"then
				setting.frameMul=min(max(toN(v)or 100,0),100)
			elseif t=="das"or t=="arr"or t=="sddas"or t=="sdarr"then
				v=toN(v)if not v or v<0 then v=0 end
				setting[t]=int(v)
			elseif t=="dropFX"or t=="shakeFX"or t=="atkFX"then
				setting[t]=toN(v:match("[012345]"))or 0
			elseif t=="lang"then
				setting[t]=toN(v:match("[123]"))or 1
			elseif t=="skin"then
				setting[t]=toN(v:match("[12345678]"))or 1
			elseif t=="keymap"then
				v=splitS(v,"/")
				for i=1,16 do
					local v1=splitS(v[i],",")
					for j=1,#v1 do
						setting.keyMap[i][j]=v1[j]
					end
				end
			elseif t=="VK"then
				v=splitS(v,"/")
				local SK
				for i=1,#v do
					if v[i]then
						SK=splitS(v[i],",")
						local K=VK_org[i]
						K.ava=SK[1]=="T"
						K.x,K.y,K.r=toN(SK[2]),toN(SK[3]),toN(SK[4])
					end
				end
			elseif t=="lastPlay"then
				v=toN(v)
				mapCam.lastPlay=v and modeRanks[v]and v or 1
			end
		end
	end
end
local saveOpt={
	"das","arr",
	"sddas","sdarr",
	"reTime",
	"quickR",
	"swap",
	"fine",

	"ghost","center",
	"smo","grid",
	"dropFX",
	"shakeFX",
	"atkFX",
	"frameMul",

	"fullscreen",
	"bg",
	"bgspace",
	"lang",
	"skin",

	"sfx","bgm",
	"vib","voc",
	"stereo",

	"VKSwitch",
	"VKTrack",
	"VKDodge",
	"VKTchW",
	"VKCurW",
	"VKIcon",
	"VKAlpha",
}
function saveSetting()
	local vk={}--virtualkey table
	for i=1,#VK_org do
		local V=VK_org[i]
		vk[i]=concat({
			V.ava and"T"or"F",
			int(V.x+.5),
			int(V.y+.5),
			V.r,
		},",")
	end--pre-pack virtualkey setting
	local map={}
	for i=1,16 do
		map[i]=concat(setting.keyMap[i],",")
	end
	local t={
		"keymap="..toS(concat(map,"/")),
		"VK="..toS(concat(vk,"/")),
		"lastPlay="..mapCam.lastPlay,
	}
	for i=1,#saveOpt do
		t[#t+1]=saveOpt[i].."="..toS(setting[saveOpt[i]])
	end
	t=concat(t,"\r\n")
	local F=FILE.setting
	F:open("w")
	local _,mes=F:write(t)
	F:flush()
	F:close()
	if _ then
		TEXT(text.settingSaved,370,330,30,"appear")
	else
		TEXT(text.settingSavingError.."123",370,350,20,"appear",.3)
	end
end