local lastLoaded={}
local maxLoadedCount=3
local SourceObjList={}
local volume=1

local BGM={
    default=false,
    getList=function()error("Cannot getList before initialize!")end,
    getCount=function()return 0 end,
    play=NULL,
    stop=NULL,
    onChange=NULL,
    --nowPlay=[str:playing ID]
    --playing=[src:playing SRC]
    --lastPlayed=[str:lastPlayed ID]
}
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
function BGM.init(list)
    BGM.init=nil

    local simpList={}
    for _,v in next,list do
        table.insert(simpList,v.name)
        SourceObjList[v.name]={path=v.path,source=false}
    end
    table.sort(simpList)
    function BGM.getList()return simpList end
    local count=#simpList
    LOG(count.." BGM files added")
    function BGM.getCount()return count end

    local function _tryLoad(name)
        if SourceObjList[name]then
            if SourceObjList[name].source then
                return true
            elseif love.filesystem.getInfo(SourceObjList[name].path)then
                SourceObjList[name].source=love.audio.newSource(SourceObjList[name].path,'stream')
                SourceObjList[name].source:setLooping(true)
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
    function BGM.play(name)
        name=name or BGM.default
        if not _tryLoad(name)then return end
        if volume==0 then
            BGM.nowPlay=name
            BGM.playing=SourceObjList[name].source
            return true
        end
        if name and SourceObjList[name].source then
            if BGM.nowPlay~=name then
                if BGM.nowPlay then
                    TASK.new(task_fadeOut,BGM.playing)
                end
                TASK.removeTask_iterate(check_curFadeOut,task_fadeOut,SourceObjList[name].source)
                TASK.removeTask_code(task_fadeIn)

                TASK.new(task_fadeIn,SourceObjList[name].source)
                BGM.nowPlay=name
                BGM.playing=SourceObjList[name].source
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
    function BGM.continue()
        if BGM.lastPlayed then
            BGM.nowPlay,BGM.playing=BGM.lastPlayed,SourceObjList[BGM.lastPlayed].source
            TASK.removeTask_iterate(check_curFadeOut,task_fadeOut,SourceObjList[BGM.nowPlay].source)
            TASK.removeTask_code(task_fadeIn)
            TASK.new(task_fadeIn,BGM.playing)
            BGM.playing:play()
        end
    end
    function BGM.stop()
        TASK.removeTask_code(task_fadeIn)
        if BGM.nowPlay then
            TASK.new(task_fadeOut,BGM.playing)
        end
        BGM.nowPlay,BGM.playing=nil
    end
end
return BGM
