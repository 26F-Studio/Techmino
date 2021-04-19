local loadImage=love.graphics.newImage
local fs=love.filesystem

local texture_noImage=DOGC{32,32,
	{"setCL",0,0,0},
	{"fRect",0,0,32,32},
	{"setCL",1,1,1},
	{"setLW",3},
	{"dLine",0,0,31,31},
	{"dLine",0,31,31,0},
}

local function _getEmptyUser()
	return{
		username="[X]",
		motto="Techmino haowan",
		hash="",
		new=false,
	}
end

local db_img={}
local db=setmetatable({},{__index=function(self,k)
	local file="cache/user"..k..".dat"
	local d=fs.getInfo(file)and JSON.decode(fs.read(file))or _getEmptyUser()
	rawset(self,k,d)
	if type(d.hash)=="string"and #d.hash>0 and fs.getInfo(d.hash)then
		db_img[k].avatar=loadImage(d.hash)
	end
	return d
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
		db[uid].hash=type(data.hash)=="string"and data.hash>0 and data.hash
		db[uid].new=true
	end
end

function USERS.getUsername(uid)return db[uid].username end
function USERS.getMotto(uid)return db[uid].motto end
function USERS.getHash(uid)return db[uid].hash end
function USERS.getAvatar(uid)
	if db_img[uid]then
		return db_img[uid]
	else
		if not db[uid].new then
			NET.getUserInfo(uid)
			db[uid].new=true
		end
		return texture_noImage
	end
end

return USERS