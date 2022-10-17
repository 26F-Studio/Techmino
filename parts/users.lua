local fs=love.filesystem

local emptyUser={
    username="Stacker",
    motto="",
    hash="",
    new=false,
}
local defaultAvatar={}
for i=1,29 do
    local img=TEXTURE.miniBlock[i]
    defaultAvatar[i]=GC.DO{128,128,
        {'clear',.1,.1,.1},
        {'draw',img,63,63,.2,15,15,img:getWidth()/2,img:getHeight()/2},
    }
end
local errorAvatar=GC.DO{128,128,
    {'setCL',1,.2,.15},
    {'setLW',10},
    {'line',10,10,117,117},
    {'line',10,117,117,10},
}
local function _loadAvatar(path)
    local success,img=pcall(GC.newImage,path)
    if success then
        local canvas=GC.newCanvas(128,128)
        GC.push()
            GC.origin()
            GC.setColor(1,1,1)
            GC.setCanvas(canvas)
            mDraw(img,64,64,nil,128/math.max(img:getWidth(),img:getHeight()))
            GC.setCanvas()
        GC.pop()
        return canvas
    else
        return errorAvatar
    end
end

local db_img={}
local db=setmetatable({},{__index=function(self,uid)
    if not uid then return emptyUser end
    local file="cache/user"..uid..".dat"
    local d=fs.getInfo(file) and JSON.decode(fs.read(file)) or TABLE.copy(emptyUser)
    rawset(self,uid,d)
    db_img[uid]=
        type(d.hash)=='string' and #d.hash>0 and fs.getInfo("cache/"..d.hash) and
        _loadAvatar("cache/"..d.hash) or
        defaultAvatar[(uid-26)%29+1]
    return d
end})

local USERS={}

--[[userdata={
    username="MrZ",
    motto="Techmino 好玩",
    id=26,
    permission="Admin",
    region=0,
    avatar_hash=XXX,
    avatar_frame=0,
}]]
function USERS.updateUserData(data)
    local id=data.id
    db[id].username=data.username
    db[id].motto=data.motto
    if type(data.avatar_hash)=='string' and (db[id].hash~=data.avatar_hash or not fs.getInfo("cache/"..data.avatar_hash)) then
        db[id].hash=data.avatar_hash
        NET.getAvatar(id)
    end
    fs.write("cache/user"..id..".dat",JSON.encode{
        username=data.username,
        motto=data.motto,
        hash=db[id].hash,
    })
end
function USERS.updateAvatar(id,imgData)
    local hash=db[id].hash
    fs.write("cache/"..hash,love.data.decode('string','base64',imgData:sub(imgData:find(",")+1)))
    db_img[id]=_loadAvatar("cache/"..hash)
end

function USERS.getUsername(uid) return db[uid].username end
function USERS.getMotto(uid) return db[uid].motto end
function USERS.getHash(uid) return db[uid].hash or "" end
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
