local fs=love.filesystem
local Json=require'parts.online.json'
local Protocol=require'parts.online.protocol'
local emptyUser={name='Stacker',motto='',avatarVersion=false,fetched=false}
local defaults={}
for index=1,29 do
    local image=TEXTURE.miniBlock[index]
    defaults[index]=GC.DO{128,128,{'clear',.1,.1,.1},{'draw',image,63,63,.2,15,15,image:getWidth()/2,image:getHeight()/2}}
end
local errorAvatar=GC.DO{128,128,{'setCL',1,.2,.15},{'setLW',10},{'line',10,10,117,117},{'line',10,117,117,10}}
local profiles,avatars={},{}
local function defaultAvatar(id)
    local hash=0
    for index=1,#id do hash=(hash*31+id:byte(index))%29 end
    return defaults[hash+1]
end
local function imagePath(id,version)
    return 'cache/avatar-'..id..'-'..tostring(version)..'.img'
end
local function validVersion(value)
    return (type(value)=='string' and #value<=64 and value:match('^[%w_-]+$')) or Protocol.integer(value,0,9007199254740991)
end
local function loadAvatar(bytes)
    local ok,image=pcall(love.graphics.newImage,love.filesystem.newFileData(bytes,'avatar.img'))
    if not ok then return errorAvatar end
    if image:getWidth()>512 or image:getHeight()>512 then image:release() return errorAvatar end
    local canvas=GC.newCanvas(128,128)
    GC.push('all')
    GC.origin()
    GC.setCanvas(canvas)
    GC.clear(0,0,0,0)
    GC.setColor(1,1,1)
    mDraw(image,64,64,nil,128/math.max(image:getWidth(),image:getHeight()))
    GC.pop()
    image:release()
    return canvas
end
local function profile(id)
    if not Protocol.id(id) then return emptyUser end
    if not profiles[id] then
        local bytes=fs.read('cache/profile-'..id..'.json')
        local cached=bytes and #bytes<=4096 and Json.decode(bytes)
        local data=type(cached)=='table' and Protocol.string(cached.name,128) and Protocol.string(cached.motto,256) and cached or {name='Stacker',motto='',avatarVersion=false}
        data.fetched=false
        profiles[id]=data
        avatars[id]=defaultAvatar(id)
        if validVersion(data.avatarVersion) then
            local image=fs.read(imagePath(id,data.avatarVersion))
            if image and #image<=262144 then avatars[id]=loadAvatar(image) end
        end
    end
    return profiles[id]
end
local Users={}
function Users.setName(id,name)
    if Protocol.id(id) and Protocol.string(name,128) then profile(id).name=name end
end
function Users.updateProfile(data)
    if type(data)~='table' or not Protocol.id(data.id) or not Protocol.string(data.name,128) or not Protocol.string(data.motto,256) or (data.avatarVersion~=nil and data.avatarVersion~=false and not validVersion(data.avatarVersion)) then return end
    local record=profile(data.id)
    local oldVersion=record.avatarVersion
    record.name=data.name
    record.motto=data.motto
    record.region=data.region
    record.avatarVersion=data.avatarVersion or false
    record.fetched=true
    fs.write('cache/profile-'..data.id..'.json',Json.encode{name=record.name,motto=record.motto,avatarVersion=record.avatarVersion,region=record.region})
    if record.avatarVersion and (oldVersion~=record.avatarVersion or not fs.getInfo(imagePath(data.id,record.avatarVersion))) then NET.getAvatar(data.id,record.avatarVersion) end
end
function Users.updateAvatar(id,version,bytes)
    if not Protocol.id(id) or not validVersion(version) or type(bytes)~='string' or #bytes>262144 or profile(id).avatarVersion~=version then return end
    local image=loadAvatar(bytes)
    if image~=errorAvatar then
        fs.write(imagePath(id,version),bytes)
        if avatars[id] and avatars[id]~=defaults[1] then
            local old=avatars[id]
            local isDefault=false
            for _,item in ipairs(defaults) do if old==item then isDefault=true break end end
            if not isDefault and old~=errorAvatar then old:release() end
        end
        avatars[id]=image
    end
end
function Users.getUsername(id) return profile(id).name end
function Users.getMotto(id) return profile(id).motto end
function Users.getAvatar(id)
    if not Protocol.id(id) then return defaults[1] end
    local record=profile(id)
    if not record.fetched and NET then record.fetched=true NET.getProfile(id) end
    return avatars[id] or defaults[1]
end
function Users.forceFreshProfiles()
    for _,record in pairs(profiles) do record.fetched=false end
end
return Users
