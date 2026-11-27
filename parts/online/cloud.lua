local Json=require'parts.online.json'
local Protocol=require'parts.online.protocol'
local Cloud={}
Cloud.__index=Cloud
local paths={STAT='conf/data',RANKS='conf/unlock',SETTING='conf/settings',KEY_MAP='conf/key',VK_ORG='conf/virtualkey',vkSave1='conf/vkSave1',vkSave2='conf/vkSave2',customBoards='conf/customBoards',customMissions='conf/customMissions',customSequence='conf/customSequence'}
local statKeys,settingTypes={},{}
for key in pairs(STAT) do statKeys[key]=true end
for key,value in pairs(SETTING) do settingTypes[key]=type(value) end
local numericBounds={
    das={0,60,true},arr={0,60,true},dascut={0,60,true},irscut={0,60,true},dropcut={0,60,true},sddas={0,60,true},sdarr={0,60,true},
    reTime={.5,3},maxFPS={30,1000,true},frameMul={1,1000,true},msaa={0,16,true},VKSkin={1,5,true},
    lockFX={0,10},dropFX={0,10},moveFX={0,10},clearFX={0,10},splashFX={0,10},shakeFX={0,10},atkFX={0,10},
    ghost={0,1},center={0,1},grid={0,1},lineNum={0,1},bgAlpha={0,1},mainVol={0,1},sfx={0,1},sfx_spawn={0,1},sfx_warn={0,1},bgm={0,1},stereo={0,1},vib={0,1},voc={0,1},
    VKSFX={0,1},VKVIB={0,1},VKTchW={0,1},VKCurW={0,1},VKAlpha={0,1},
}
local selectors={RS={'setting_game','RS'},menuPos={'setting_game','menuPos'},ghostType={'setting_video','ghostType'},blockSatur={'setting_video','blockSatur'},fieldSatur={'setting_video','fieldSatur'},defaultBG={'setting_video','defaultBG'},frameMul={'setting_video','frame'}}
local function dense(value,maximum,exact)
    if type(value)~='table' or #value>maximum or exact and #value~=exact then return false end
    local count=0
    for key in pairs(value) do if not Protocol.integer(key,1,#value) then return false end count=count+1 end
    return count==#value
end
local function identifier(value)
    return type(value)=='string' and #value>0 and #value<=64 and value:match('^[%w_.%-]+$')~=nil
end
local function settingChoice(key,value)
    local selector=selectors[key]
    if selector then
        local scene=SCN.scenes[selector[1]]
        local widget=scene and scene.widgetList[selector[2]]
        return widget and TABLE.find(widget.list,value)~=nil
    elseif key=='skinSet' then return TABLE.find(SKIN.getList(),value)~=nil
    elseif key=='sfxPack' then return TABLE.find(SFXPACKS,value)~=nil
    elseif key=='vocPack' then return TABLE.find(VOCPACKS,value)~=nil
    elseif key=='bg' then return value=='on' or value=='off' or value=='custom'
    elseif key=='holdMode' then return value=='hold' or value=='swap' or value=='skip'
    elseif key=='locale' then return identifier(value) and FILE.isSafe('parts/language/lang_'..value..'.lua') end
    return true
end
local function clean(value,depth,budget)
    if depth>16 then error('Cloud nesting limit exceeded') end
    budget.nodes=budget.nodes+1
    if budget.nodes>100000 then error('Cloud node limit exceeded') end
    local kind=type(value)
    if kind=='number' then if value~=value or value==math.huge or value==-math.huge then error('Non-finite cloud value') end return value end
    if kind=='string' then if #value>128 then error('Cloud string limit exceeded') end return value end
    if kind=='boolean' then return value end
    if kind~='table' then error('Cloud values must be JSON data') end
    local result={}
    for key,item in pairs(value) do
        if type(key)~='string' and not Protocol.integer(key,1,4096) then error('Invalid cloud key') end
        if type(key)=='string' and (#key>64 or key:lower():find('token') or key:lower():find('password') or key=='ticket') then error('Credentials are excluded from cloud saves') end
        result[key]=clean(item,depth+1,budget)
    end
    return result
end
local function virtualKeys(value)
    if not dense(value,20) then return false end
    for _,key in ipairs(value) do
        if type(key)~='table' or type(key.ava)~='boolean' or type(key.x)~='number' or key.x< -4096 or key.x>8192 or type(key.y)~='number' or key.y< -4096 or key.y>8192 or type(key.r)~='number' or key.r<1 or key.r>512 then return false end
        for name in pairs(key) do if name~='ava' and name~='x' and name~='y' and name~='r' then return false end end
    end
    return true
end
function Cloud.validate(value)
    if type(value)~='table' or not next(value) then return false,'Cloud save has no recognized sections.' end
    local ok,data=pcall(clean,value,0,{nodes=0})
    if not ok then return false,'Cloud save must contain bounded finite JSON only.' end
    for section,items in pairs(data) do
        if not paths[section] or type(items)~='table' then return false,'Unknown cloud save section.' end
        if section=='STAT' then
            for key,item in pairs(items) do
                if not statKeys[key] then return false,'Unknown offline statistics field.' end
                if key=='clear' or key=='spin' then
                    if not dense(item,29,29) then return false,'Invalid statistics matrix.' end
                    for _,row in ipairs(item) do
                        if not dense(row,7,key=='clear' and 6 or 7) then return false,'Invalid statistics matrix.' end
                        for _,number in ipairs(row) do if type(number)~='number' or number<0 or number>1e15 then return false,'Invalid statistics counter.' end end
                    end
                elseif key=='item' then
                    if type(item)~='table' then return false,'Invalid offline inventory.' end
                    local count=0
                    for name,number in pairs(item) do count=count+1 if not identifier(name) or type(number)~='number' or number<0 or number>1e15 or count>256 then return false,'Invalid offline inventory.' end end
                elseif key=='lastPlay' then if not identifier(item) then return false,'Invalid offline mode name.' end
                elseif key=='date' then if item~=false and (type(item)~='string' or not item:match('^%d%d%d%d/%d%d/%d%d$')) then return false,'Invalid statistics date.' end
                elseif key=='version' then if not Protocol.integer(item,0,9007199254740991) then return false,'Invalid statistics version.' end
                elseif type(item)~='number' or item<0 or item>1e15 then return false,'Invalid statistics counter.' end
            end
        elseif section=='RANKS' then
            local count=0
            for mode,rank in pairs(items) do count=count+1 if count>1024 or not identifier(mode) or not Protocol.integer(rank,0,5) then return false,'Invalid offline rank backup.' end end
        elseif section=='SETTING' then
            for key,item in pairs(items) do
                if not settingTypes[key] or type(item)~=settingTypes[key] then return false,'Unknown or invalid setting.' end
                if key=='skin' or key=='face' then
                    if not dense(item,29,29) then return false,'Invalid piece appearance array.' end
                    for _,number in ipairs(item) do if not Protocol.integer(number,key=='skin' and 1 or 0,key=='skin' and 17 or 3) then return false,'Invalid piece appearance.' end end
                elseif type(item)=='table' then return false,'Unsupported nested setting.'
                elseif type(item)=='number' then
                    local bound=numericBounds[key]
                    if not bound or item<bound[1] or item>bound[2] or bound[3] and item%1~=0 then return false,'A numeric setting exceeds its supported bounds.' end
                    if not settingChoice(key,item) then return false,'The cloud setting is not supported by this source client.' end
                elseif type(item)=='string' and (#item>128 or item:find('%c') or not settingChoice(key,item)) then return false,'The cloud setting is not supported by this source client.' end
            end
        elseif section=='KEY_MAP' then
            for device,map in pairs(items) do
                if device~='keyboard' and device~='joystick' or type(map)~='table' then return false,'Invalid key mapping device.' end
                local count=0
                for key,action in pairs(map) do count=count+1 if type(key)~='string' or #key==0 or #key>64 or not key:match('^[!-~]+$') or count>64 or not Protocol.integer(action,0,20) then return false,'Invalid key binding.' end end
            end
        elseif section=='VK_ORG' or section=='vkSave1' or section=='vkSave2' then
            if not virtualKeys(items) then return false,'Invalid virtual-key layout.' end
        elseif section=='customBoards' then
            if not dense(items,32) then return false,'Too many or malformed custom boards.' end
            for _,board in ipairs(items) do
                if not dense(board,256) then return false,'Invalid custom board height.' end
                for _,row in ipairs(board) do
                    if not dense(row,10,10) then return false,'Invalid custom board row.' end
                    for _,cell in ipairs(row) do if not Protocol.integer(cell,-2,29) then return false,'Invalid custom board cell.' end end
                end
            end
        elseif section=='customMissions' then
            if not dense(items,4096) then return false,'Too many or malformed custom missions.' end
            for _,mission in ipairs(items) do if not Protocol.integer(mission,1,74) or not ENUM_MISSION[mission] then return false,'Invalid custom mission.' end end
        elseif section=='customSequence' then
            if not dense(items,4096) then return false,'Custom sequence exceeds its limit or is malformed.' end
            for _,piece in ipairs(items) do if not Protocol.integer(piece,1,29) then return false,'Invalid custom sequence piece.' end end
        end
    end
    local encoded=Json.encode(data)
    if not encoded or #encoded>1048576 then return false,'Cloud save exceeds 1 MiB.' end
    return true,data
end
function Cloud.new(net)
    return setmetatable({net=net,revision=false,versions={},status='idle',conflict=false,serial=0,epoch=0},Cloud)
end
function Cloud:clear()
    self.epoch=self.epoch+1
    self.revision=false
    self.versions={}
    self.latest=false
    self.conflict=false
    self.status='idle'
    self.serial=self.serial+1
end
function Cloud:collect()
    local data={STAT=STAT,RANKS=RANKS,SETTING=SETTING,KEY_MAP=KEY_MAP,VK_ORG=VK_ORG,vkSave1=loadFile('conf/vkSave1','-canSkip') or {},vkSave2=loadFile('conf/vkSave2','-canSkip') or {}}
    if CUSTOMGAME_LOCAL then
        data.customBoards=CUSTOMGAME_LOCAL.field
        data.customMissions=CUSTOMGAME_LOCAL.mission
        data.customSequence=CUSTOMGAME_LOCAL.bag
    end
    return Cloud.validate(data)
end
function Cloud:list(callback)
    if self.status~='idle' then return end
    self.status='loading'
    local epoch=self.epoch
    self.net.session:request('cadence','/v1/products/techmino/cloud','GET',nil,function(data,err)
        if epoch~=self.epoch then return end
        self.status='idle'
        if err then self.net.session:report(err) if callback then callback(false) end return end
        if type(data)~='table' or not Protocol.integer(data.revision,0,9007199254740991) or type(data.versions)~='table' or #data.versions>5 then self.net.report('INVALID_CLOUD','The cloud version list is invalid.') return end
        for _,version in ipairs(data.versions) do if type(version)~='table' or not Protocol.id(version.id) or not Protocol.integer(version.revision,1,data.revision) or not Protocol.integer(version.bytes,0,1048576) or not Protocol.string(version.createdAt,64) then self.net.report('INVALID_CLOUD','Invalid cloud version metadata.') return end end
        self.revision=data.revision
        self.versions=data.versions
        self.latest=data.latest
        self.serial=self.serial+1
        if callback then callback(true) end
    end,true)
end
function Cloud:upload(expectedRevision)
    if self.status~='idle' then return end
    if not self.revision then self:list(function(ok) if ok then self:upload() end end) return end
    local ok,candidate=self:collect()
    if not ok then self.net.report('INVALID_CLOUD_SAVE',candidate) return end
    self.status='uploading'
    local epoch=self.epoch
    self.net.session:request('cadence','/v1/products/techmino/cloud','POST',{expectedRevision=expectedRevision or self.revision,data=candidate},function(data,err)
        if epoch~=self.epoch then return end
        self.status='idle'
        if err then
            if err.status==409 and err.code=='REVISION_CONFLICT' and type(data)=='table' and Protocol.integer(data.revision,0,9007199254740991) and type(data.versions)=='table' and #data.versions<=5 then
                self.conflict={revision=data.revision,localData=candidate}
                self.versions=data.versions
                self.serial=self.serial+1
                self.net.report('REVISION_CONFLICT','The cloud changed on another device. Choose a cloud version to restore or explicitly keep and upload this local save.')
            else self.net.session:report(err) end
            return
        end
        if type(data)~='table' or not Protocol.integer(data.revision,1,9007199254740991) or type(data.version)~='table' or not Protocol.id(data.version.id) or data.version.revision~=data.revision then self.net.report('INVALID_CLOUD','The cloud write receipt is invalid.') return end
        self.conflict=false
        self.revision=data.revision
        MES.new('check','A new offline backup version was uploaded. It does not create authoritative match rankings.',6)
        self:list()
    end,true)
end
function Cloud:keepLocal()
    if not self.conflict or self.status~='idle' then return end
    local conflict=self.conflict
    self.status='uploading'
    local epoch=self.epoch
    self.net.session:request('cadence','/v1/products/techmino/cloud','POST',{expectedRevision=conflict.revision,data=conflict.localData},function(data,err)
        if epoch~=self.epoch then return end
        self.status='idle'
        if err then
            if err.status==409 and data and Protocol.integer(data.revision,0,9007199254740991) then self.conflict.revision=data.revision self.versions=data.versions or self.versions self.serial=self.serial+1 end
            self.net.session:report(err)
            return
        end
        if type(data)~='table' or not Protocol.integer(data.revision,1,9007199254740991) or type(data.version)~='table' or not Protocol.id(data.version.id) or data.version.revision~=data.revision then self.net.report('INVALID_CLOUD','The cloud write receipt is invalid.') return end
        self.conflict=false
        self.revision=data.revision
        self:list()
    end,true)
end
function Cloud:cancelConflict()
    if self.status~='idle' then return end
    self.conflict=false
    self:list()
end
function Cloud:backup()
    local files={}
    for _,path in pairs(paths) do
        local bytes=love.filesystem.read(path)
        files[path]=bytes and love.data.encode('string','base64',bytes) or false
    end
    love.filesystem.createDirectory('conf/cloud-backups')
    local name='conf/cloud-backups/'..os.date('!%Y%m%dT%H%M%S')..'-'..tostring(math.floor(love.timer.getTime()*1000))..'.json'
    if love.filesystem.getInfo(name) then return nil,'A local backup with this name already exists.' end
    local bytes=Json.encode{schemaVersion=1,createdAt=os.date('!%Y-%m-%dT%H:%M:%SZ'),files=files}
    if not bytes or not love.filesystem.write(name,bytes) then return nil,'The local backup could not be written. No save was restored.' end
    return name,files
end
function Cloud:apply(data)
    if self.net.match:isActive() then return false,'Leave the active match before restoring offline saves.' end
    local valid,value=Cloud.validate(data)
    if not valid then return false,value end
    -- Persist the complete post-merge sections that are also applied in memory.
    if value.STAT then
        local merged=TABLE.copy(STAT)
        TABLE.coverR(value.STAT,merged)
        value.STAT=merged
    end
    if value.SETTING then
        local merged=TABLE.copy(SETTING)
        TABLE.update(value.SETTING,merged)
        value.SETTING=merged
    end
    if value.KEY_MAP then
        local merged=TABLE.copy(KEY_MAP)
        TABLE.cover(value.KEY_MAP,merged)
        value.KEY_MAP=merged
    end
    if value.VK_ORG then
        local merged=TABLE.copy(VK_ORG)
        TABLE.cover(value.VK_ORG,merged)
        value.VK_ORG=merged
    end
    local backup,original=self:backup()
    if not backup then return false,original end
    local writes={}
    for section,items in pairs(value) do
        if section=='customBoards' then
            writes[paths[section]]=require('parts.online.boardStore').encode(items)
        elseif section=='customMissions' then
            writes[paths[section]]=DATA.copyMission(items)
        elseif section=='customSequence' then
            writes[paths[section]]=DATA.copySequence(items)
        elseif section=='vkSave1' or section=='vkSave2' or section=='VK_ORG' then writes[paths[section]]=Json.encode(items,true)
        else writes[paths[section]]=Json.encode(items) end
        if not writes[paths[section]] then return false,'The downloaded section could not be encoded; the local backup is '..backup end
    end
    local changed={}
    local memory=TABLE.copy{STAT=STAT,RANKS=RANKS,SETTING=SETTING,KEY_MAP=KEY_MAP,VK_ORG=VK_ORG,custom=CUSTOMGAME_LOCAL and {field=CUSTOMGAME_LOCAL.field,mission=CUSTOMGAME_LOCAL.mission,bag=CUSTOMGAME_LOCAL.bag}}
    local inventoryMeta=getmetatable(STAT.item)
    local function rollbackFiles()
        local restored=true
        for _,path in ipairs(changed) do
            local ok
            if original[path] then ok=love.filesystem.write(path,love.data.decode('string','base64',original[path])) else ok=not love.filesystem.getInfo(path) or love.filesystem.remove(path) end
            restored=restored and ok
        end
        return restored
    end
    for path,bytes in pairs(writes) do
        changed[#changed+1]=path
        if not love.filesystem.write(path,bytes) then
            local restored=rollbackFiles()
            return false,(restored and 'Save restore failed and the previous files were restored. ' or 'Save restore and rollback failed; restore the recorded backup manually. ')..'The original local backup is '..backup
        end
    end
    local applied=pcall(function()
        if value.STAT then TABLE.coverR(value.STAT,STAT) end
        if value.RANKS then TABLE.clear(RANKS) TABLE.cover(value.RANKS,RANKS) end
        if value.SETTING then TABLE.update(value.SETTING,SETTING) end
        if value.KEY_MAP then
            for device,map in pairs(value.KEY_MAP) do TABLE.clear(KEY_MAP[device]) TABLE.cover(map,KEY_MAP[device]) end
        end
        if value.VK_ORG then TABLE.cover(value.VK_ORG,VK_ORG) end
        if CUSTOMGAME_LOCAL then
            if value.customBoards then
                TABLE.cut(CUSTOMGAME_LOCAL.field)
                for _,board in ipairs(value.customBoards) do CUSTOMGAME_LOCAL.field[#CUSTOMGAME_LOCAL.field+1]=DATA.newBoard(board) end
                if #CUSTOMGAME_LOCAL.field==0 then CUSTOMGAME_LOCAL.field[1]=DATA.newBoard() end
                TABLE.clear(FIELD) TABLE.cover(CUSTOMGAME_LOCAL.field,FIELD)
            end
            if value.customMissions then TABLE.cut(CUSTOMGAME_LOCAL.mission) TABLE.cover(value.customMissions,CUSTOMGAME_LOCAL.mission) TABLE.cut(MISSION) TABLE.cover(value.customMissions,MISSION) end
            if value.customSequence then TABLE.cut(CUSTOMGAME_LOCAL.bag) TABLE.cover(value.customSequence,CUSTOMGAME_LOCAL.bag) TABLE.cut(BAG) TABLE.cover(value.customSequence,BAG) end
        end
        applySettings()
        if PLAYERS[1] then VK.restore() end
    end)
    if not applied then
        for name,target in pairs{STAT=STAT,RANKS=RANKS,SETTING=SETTING,KEY_MAP=KEY_MAP,VK_ORG=VK_ORG} do TABLE.clear(target) TABLE.cover(memory[name],target) end
        setmetatable(STAT.item,inventoryMeta)
        if memory.custom then
            TABLE.cut(CUSTOMGAME_LOCAL.field)
            for _,board in ipairs(memory.custom.field) do CUSTOMGAME_LOCAL.field[#CUSTOMGAME_LOCAL.field+1]=DATA.newBoard(board) end
            TABLE.clear(FIELD) TABLE.cover(CUSTOMGAME_LOCAL.field,FIELD)
            TABLE.cut(CUSTOMGAME_LOCAL.mission) TABLE.cover(memory.custom.mission,CUSTOMGAME_LOCAL.mission)
            TABLE.cut(MISSION) TABLE.cover(memory.custom.mission,MISSION)
            TABLE.cut(CUSTOMGAME_LOCAL.bag) TABLE.cover(memory.custom.bag,CUSTOMGAME_LOCAL.bag)
            TABLE.cut(BAG) TABLE.cover(memory.custom.bag,BAG)
        end
        local filesRestored=rollbackFiles()
        local settingsRestored=pcall(applySettings)
        if PLAYERS[1] then pcall(VK.restore) end
        return false,(filesRestored and settingsRestored and 'The downloaded save could not be applied; the previous save was restored. ' or 'Restore rollback needs manual recovery. ')..'The original backup is '..backup
    end
    self.conflict=false
    self.backupPath=backup
    return true,'Cloud save restored. The previous local save is backed up at '..backup
end
function Cloud:restore(id)
    if self.status~='idle' or not Protocol.id(id) then return end
    self.status='restoring'
    local epoch=self.epoch
    self.net.session:request('cadence','/v1/products/techmino/cloud/'..id,'GET',nil,function(version,err)
        if epoch~=self.epoch then return end
        self.status='idle'
        if err then self.net.session:report(err) return end
        if type(version)~='table' or version.id~=id or type(version.data)~='table' then self.net.report('INVALID_CLOUD','The selected immutable cloud version is invalid.') return end
        local ok,message=self:apply(version.data)
        MES.new(ok and 'check' or 'error',message,8)
    end,true)
end
return Cloud
