local lastLoaded={}
local maxLoadedCount=3
local nameList={}
local SourceObjList={}
local volume=1

local BGM={
    default=false,
    onChange=NULL,
    --nowPlay=[str:playing ID]
    --playing=[src:playing SRC]
    --lastPlayed=[str:lastPlayed ID]
}

function BGM.getList()return nameList end
function BGM.getCount()return #nameList end
local function _addFile(name,path)
    if not SourceObjList[name]then
        table.insert(nameList,name)
        SourceObjList[name]={path=path,source=false}
    end
end
function BGM.load(name,path)
    if type(name)=='table'then
        for k,v in next,name do
            _addFile(k,v)
        end
    else
        _addFile(name,path)
    end
    table.sort(nameList)
    LOG(BGM.getCount().." BGM files added")
end

local function _tryReleaseSources()
    local n=#lastLoaded
    while #lastLoaded>maxLoadedCount do
        local name=lastLoaded[n]
        if SourceObjList[name].source:isPlaying()then
            n=n-1
            if n<=0 then return end
        else
            SourceObjList[name].source=SourceObjList[name].source:release()and nil
            table.remove(lastLoaded,n)
            return
        end
    end
end
function BGM.setDefault(bgm)
    BGM.default=bgm
end
function BGM.setMaxSources(count)
    maxLoadedCount=count
    _tryReleaseSources()
end
function BGM.setChange(func)
    BGM.onChange=func
end
function BGM.setVol(v)
    assert(type(v)=='number'and v>=0 and v<=1,'Wrong volume')
    volume=v
    if BGM.playing then
        if volume>0 then
            BGM.playing:setVolume(volume)
            BGM.playing:play()
        elseif BGM.nowPlay then
            BGM.playing:pause()
        end
    end
end

local function task_fadeOut(src)
    while true do
        coroutine.yield()
        local v=src:getVolume()-.025*volume
        src:setVolume(v>0 and v or 0)
        if v<=0 then
            src:pause()
            return true
        end
    end
end
local function task_fadeIn(src)
    while true do
        coroutine.yield()
        local v=volume
        v=math.min(v,src:getVolume()+.025*v)
        src:setVolume(v)
        if v>=volume then
            return true
        end
    end
end
local function check_curFadeOut(task,code,src)
    return task.code==code and task.args[1]==src
end
local function _tryLoad(name)
    if SourceObjList[name]then
        if SourceObjList[name].source then
            return true
        elseif love.filesystem.getInfo(SourceObjList[name].path)then
            SourceObjList[name].source=love.audio.newSource(SourceObjList[name].path,'stream')
            SourceObjList[name].source:setVolume(0)
            table.insert(lastLoaded,1,name)
            _tryReleaseSources()
            return true
        else
            LOG("No BGM: "..SourceObjList[name],5)
        end
    elseif name then
        LOG("No BGM: "..name,5)
    end
end
function BGM.play(name,args)
    name=name or BGM.default
    args=args or""
    if not _tryLoad(name)or args:sArg('-preLoad')then return end
    if volume==0 then
        BGM.nowPlay=name
        BGM.playing=SourceObjList[name].source
        return true
    end
    if name and SourceObjList[name].source then
        if BGM.nowPlay~=name then
            if BGM.nowPlay then
                if not args:sArg('-sdout')then
                    TASK.new(task_fadeOut,BGM.playing)
                else
                    BGM.playing:pause()
                end
            end
            TASK.removeTask_iterate(check_curFadeOut,task_fadeOut,SourceObjList[name].source)
            TASK.removeTask_code(task_fadeIn)

            BGM.nowPlay=name
            BGM.playing=SourceObjList[name].source
            if not args:sArg('-sdin')then
                BGM.playing:setVolume(0)
                TASK.new(task_fadeIn,BGM.playing)
            else
                BGM.playing:setVolume(volume)
                BGM.playing:play()
            end
            SourceObjList[name].source:setLooping(not args:sArg('-noloop'))
            BGM.lastPlayed=BGM.nowPlay
            BGM.playing:seek(0)
            BGM.playing:play()
            BGM.onChange(name)
        end
        return true
    end
end
function BGM.seek(t)
    if BGM.playing then
        BGM.playing:seek(t)
    end
end
function BGM.isPlaying()
    return BGM.playing and BGM.playing:isPlaying()
end
function BGM.continue()
    if BGM.lastPlayed then
        BGM.nowPlay,BGM.playing=BGM.lastPlayed,SourceObjList[BGM.lastPlayed].source
        TASK.removeTask_iterate(check_curFadeOut,task_fadeOut,SourceObjList[BGM.nowPlay].source)
        TASK.removeTask_code(task_fadeIn)
        TASK.new(task_fadeIn,BGM.playing)
        BGM.playing:play()
    end
end
function BGM.stop(args)
    args=args or""
    TASK.removeTask_code(task_fadeIn)
    if not args:sArg('-s')then
        if BGM.nowPlay then
            TASK.new(task_fadeOut,BGM.playing)
        end
    elseif BGM.playing then
        BGM.playing:pause()
    end
    BGM.nowPlay,BGM.playing=nil
end
return BGM
