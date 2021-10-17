local BGM={
    vol=1,
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
        local v=src:getVolume()-.025*BGM.vol
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
        local v=BGM.vol
        v=math.min(v,src:getVolume()+.025*v)
        src:setVolume(v)
        if v>=BGM.vol then
            return true
        end
    end
end
local function check_curFadeOut(task,code,src)
    return task.code==code and task.args[1]==src
end
function BGM.setDefault(bgm)
    BGM.default=bgm
end
function BGM.setChange(func)
    BGM.onChange=func
end
function BGM.setVol(v)
    assert(type(v)=='number'and v>=0 and v<=1)
    BGM.vol=v
end
function BGM.init(list)
    BGM.init=nil
    local Sources={}

    local simpList={}
    for _,v in next,list do
        table.insert(simpList,v.name)
        Sources[v.name]=v.path
    end
    table.sort(simpList)
    function BGM.getList()return simpList end
    local count=#simpList
    function BGM.getCount()return count end

    local function _load(name)
        if type(Sources[name])=='string'then
            if love.filesystem.getInfo(Sources[name])then
                Sources[name]=love.audio.newSource(Sources[name],'stream')
                Sources[name]:setLooping(true)
                Sources[name]:setVolume(0)
                return true
            else
                LOG("No BGM: "..Sources[name],5)
            end
        elseif Sources[name]then
            return true
        elseif name then
            LOG("No BGM: "..name,5)
        end
    end
    function BGM.setVol(v)
        assert(type(v)=='number'and v>=0 and v<=1)
        BGM.vol=v
        if BGM.playing then
            if BGM.vol>0 then
                BGM.playing:setVolume(BGM.vol)
                BGM.playing:play()
            elseif BGM.nowPlay then
                BGM.playing:pause()
            end
        end
    end
    function BGM.loadAll()--Not neccessary, unless you want avoid the lag when playing something for the first time
        for name in next,Sources do
            _load(name)
        end
    end
    function BGM.play(name)
        name=name or BGM.default
        if not _load(name)then return end
        if BGM.vol==0 then
            BGM.nowPlay=name
            BGM.playing=Sources[name]
            return true
        end
        if name and Sources[name]then
            if BGM.nowPlay~=name then
                if BGM.nowPlay then
                    TASK.new(task_fadeOut,BGM.playing)
                end
                TASK.removeTask_iterate(check_curFadeOut,task_fadeOut,Sources[name])
                TASK.removeTask_code(task_fadeIn)

                TASK.new(task_fadeIn,Sources[name])
                BGM.nowPlay=name
                BGM.playing=Sources[name]
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
            BGM.nowPlay,BGM.playing=BGM.lastPlayed,Sources[BGM.lastPlayed]
            TASK.removeTask_iterate(check_curFadeOut,task_fadeOut,Sources[BGM.nowPlay])
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
