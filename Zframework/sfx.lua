local type,assert=type,assert
local ins,rem=table.insert,table.remove

local sfxList={}
local packSetting={}
local Sources={}
local volume=1
local stereo=1

local noteName={
    C=1,c=1,
    D=3,d=3,
    E=5,e=5,
    F=6,f=6,
    G=8,g=8,
    A=10,a=10,
    B=12,b=12,
}
local function _getTuneHeight(tune)
    local octave=tonumber(tune:sub(-1,-1))
    if octave then
        local tuneHeight=noteName[tune:sub(1,1)]
        if tuneHeight then
            tuneHeight=tuneHeight+(octave-1)*12
            local s=tune:sub(2,2)
            if s=='s'or s=='#'then
                tuneHeight=tuneHeight+1
            elseif s=='f'or s=='b'then
                tuneHeight=tuneHeight-1
            end
            return tuneHeight
        end
    end
end

local SFX={}

function SFX.init(list)
    assert(type(list)=='table',"Initialize SFX lib with a list of filenames!")
    for i=1,#list do ins(sfxList,list[i])end
end
function SFX.load(path)
    local c=0
    for i=1,#sfxList do
        local fullPath=path..sfxList[i]..'.ogg'
        if love.filesystem.getInfo(fullPath)then
            Sources[sfxList[i]]={love.audio.newSource(fullPath,'static')}
            c=c+1
        else
            LOG("No SFX: "..sfxList[i]..'.ogg',.1)
        end
    end
    LOG(c.."/"..#sfxList.." SFX files loaded")
end
function SFX.loadSample(pack)
    assert(type(pack)=='table',"Usage: SFX.loadsample([table])")
    assert(pack.name,"No field: name")
    assert(pack.path,"No field: path")
    packSetting[pack.name]={
        base=_getTuneHeight(pack.base)or 37,
    }
    local num=1
    while love.filesystem.getInfo(pack.path..'/'..num..'.ogg')do
        Sources[pack.name..num]={love.audio.newSource(pack.path..'/'..num..'.ogg','static')}
        num=num+1
    end
    LOG((num-1).." "..pack.name.." samples loaded")
end

function SFX.getCount()
    return #sfxList
end
function SFX.setVol(v)
    assert(type(v)=='number'and v>=0 and v<=1)
    volume=v
end
function SFX.setStereo(v)
    assert(type(v)=='number'and v>=0 and v<=1)
    stereo=v
end

function SFX.playSample(pack,...)
    if ... then
        local arg={...}
        local vol
        if type(arg[#arg])=='number'then vol=rem(arg)end
        for i=1,#arg do
            if type(arg[i])=='number'then
                vol=arg[i]
            else
                local tune=arg[i]
                tune=_getTuneHeight(tune)-packSetting[pack].base+1
                SFX.play(pack..tune,vol)
            end
        end
    end
end
function SFX.play(name,vol,pos)
    if volume==0 or vol==0 then return end
    local S=Sources[name]--Source list
    if not S then return end
    local n=1
    while S[n]:isPlaying()do
        n=n+1
        if not S[n]then
            S[n]=S[1]:clone()
            S[n]:seek(0)
            break
        end
    end
    S=S[n]--AU_SRC
    if S:getChannelCount()==1 then
        if pos then
            pos=pos*stereo
            S:setPosition(pos,1-pos^2,0)
        else
            S:setPosition(0,0,0)
        end
    end
    S:setVolume(((vol or 1)*volume)^1.626)
    S:play()
end
function SFX.fplay(name,vol,pos)
    local S=Sources[name]--Source list
    if not S then return end
    local n=1
    while S[n]:isPlaying()do
        n=n+1
        if not S[n]then
            S[n]=S[1]:clone()
            S[n]:seek(0)
            break
        end
    end
    S=S[n]--AU_SRC
    if S:getChannelCount()==1 then
        if pos then
            pos=pos*stereo
            S:setPosition(pos,1-pos^2,0)
        else
            S:setPosition(0,0,0)
        end
    end
    S:setVolume(vol^1.626)
    S:play()
end
function SFX.reset()
    for _,L in next,Sources do
        if type(L)=='table'then
            for i=#L,1,-1 do
                if not L[i]:isPlaying()then
                    rem(L,i)
                end
            end
        end
    end
end

return SFX
