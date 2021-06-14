local gc,fs=love.graphics,love.filesystem

local emptyUser={
	username="Stacker",
	motto="",
	hash="",
	new=false,
}
local defaultAvatar={}
for i=1,29 do
	local img=TEXTURE.miniBlock[i]
	defaultAvatar[i]=DOGC{128,128,
		{"clear",.1,.1,.1},
		{"draw",img,63,63,.2,30,30,img:getWidth()/2,img:getHeight()/2},
	}
end
local errorAvatar=DOGC{128,128,
	{'setCL',1,.2,.15},
	{'setLW',10},
	{'line',10,10,117,117},
	{'line',10,117,117,10},
}
local function loadAvatar(path)
	local success,img=pcall(gc.newImage,path)
	if success then
		local canvas=gc.newCanvas(128,128)
		gc.push()
			gc.origin()
			gc.setColor(1,1,1)
			gc.setCanvas(canvas)
			mDraw(img,64,64,nil,128/math.max(img:getWidth(),img:getHeight()))
			gc.setCanvas()
		gc.pop()
		return canvas
	else
		return errorAvatar
	end
end

local db_img={}
local db=setmetatable({},{__index=function(self,uid)
	if not uid then return emptyUser end
	local file="cache/user"..uid..".dat"
	local d=fs.getInfo(file)and JSON.decode(fs.read(file))or TABLE.copy(emptyUser)
	rawset(self,uid,d)
	db_img[uid]=
		type(d.hash)=='string'and #d.hash>0 and fs.getInfo("cache/"..d.hash)and
		loadAvatar("cache/"..d.hash)or
		defaultAvatar[(uid-26)%29+1]
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
		hash=data.hash or db[uid].hash,
	})
	if data.avatar then
		fs.write("cache/"..data.hash,love.data.decode('string','base64',data.avatar:sub(data.avatar:find(",")+1)))
		db_img[uid]=loadAvatar("cache/"..data.hash)
		db[uid].hash=type(data.hash)=='string'and #data.hash>0 and data.hash
	end
end

function USERS.getUsername(uid)return db[uid].username end
function USERS.getMotto(uid)return db[uid].motto end
function USERS.getHash(uid)return db[uid].hash or""end
function USERS.getAvatar(uid)
	if uid then
		if not db[uid].new then
			NET.getUserInfo(uid)
			db[uid].new=true
		end
		return db_img[uid]
	else
		return defaultAvatar[1]
	end
end
function USERS.forceFreshAvatar()
	for _,U in next,db do
		U.new=false
	end
end

return USERS