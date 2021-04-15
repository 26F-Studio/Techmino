local loadImage=love.graphics.newImage
local fs=love.filesystem

local ins=table.insert

local texture_noImage=DOGC{32,32,
	{"setc",0,0,0},
	{"rect","fill",0,0,32,32},
	{"setc",1,1,1},
	{"lwid",3},
	{"line",0,0,31,31},
	{"line",0,31,31,0},
}

local function _getEmptyUser()
	return{
		uid=-1,
		username="[X]",
		motto="Techmino haowan",
		hash=false,
		new=false,
	}
end

local imgReqSeq={}
local db_img={}
local db=setmetatable({},{__index=function(self,k)
	local file="cache/user"..k..".dat"
	if fs.getInfo(file)then
		rawset(self,k,JSON.decode(fs.read(file)))
		if fs.getInfo(self[k].hash)then
			db_img[k].avatar=loadImage(self[k].hash)
		end
	else
		rawset(self,k,_getEmptyUser())
	end
	return self[k]
end})

local USERS={}

function USERS.updateUserData(data)
	local uid=data.uid
	db[uid].username=data.username
	db[uid].motto=data.motto
	fs.write("cache/user"..uid..".dat",JSON.encode{
		username=data.username,
		motto=data.motto,
		hash=data.hash,
	})
	if data.avatar then
		fs.write("cache/"..data.hash,data.avatar:sub(data.avatar:find","+1))
		db_img[uid].avatar=loadImage("cache/"..data.hash)
		db[uid].hash=data.hash
		db[uid].new=true
	end
	needSave=true
end

function USERS.getUsername(uid)return db[uid].username end
function USERS.getMotto(uid)return db[uid].motto end
function USERS.getAvatar(uid)
	if db_img[uid]then
		return db_img[uid]
	else
		if not db[uid].new then
			ins(imgReqSeq,uid)
			db[uid].new=true
		end
		return texture_noImage
	end
end

function USERS.update()
	if #imgReqSeq>0 and WS.status("user")=="running"then
		NET.getUserInfo(imgReqSeq[#imgReqSeq],true)
		imgReqSeq[#imgReqSeq]=nil
	end
end

return USERS