local type,rem=type,table.remove
local floor,rnd=math.floor,math.random

local sfxList={}
local packSetting={}
local Sources={}
local volume=1
local stereo=1

local noteVal={
    C=1,c=1,
    D=3,d=3,
    E=5,e=5,
    F=6,f=6,
    G=8,g=8,
    A=10,a=10,
    B=12,b=12,
}
local noteName={'C','C#','D','D#','E','F','F#','G','G#','A','A#','B'}
local function _getTuneHeight(tune)
    local octave=tonumber(tune:sub(-1,-1))
    if octave then
        local tuneHeight=noteVal[tune:sub(1,1)]
        if tuneHeight then
            tuneHeight=tuneHeight+(octave-1)*12
            local s=tune:sub(2,2)
            if s=='s' or s=='#' then
                tuneHeight=tuneHeight+1
            elseif s=='f' or s=='b' then
                tuneHeight=tuneHeight-1
            end
            return tuneHeight
        end
    end
end

local SFX={}

function SFX.init(list)
    assert(type(list)=='table',"Initialize SFX lib with a list of filenames!")
    for i=1,#list do table.insert(sfxList,list[i]) end
end
function SFX.load(path)
    local c=0
    local missing=0
    for i=1,#sfxList do
        local fullPath=path..sfxList[i]..'.ogg'
        if love.filesystem.getInfo(fullPath) then
            if Sources[sfxList[i]] then
                for j=1,#Sources[sfxList[i]] do
                    Sources[sfxList[i]][j]:release()
                end
            end
            Sources[sfxList[i]]={love.audio.newSource(fullPath,'static')}
            c=c+1
        else
            LOG("No SFX: "..sfxList[i]..'.ogg',.1)
            missing=missing+1
        end
    end
    LOG(c.."/"..#sfxList.." SFX files loaded")
    LOG(missing.." SFX files missing")
    if missing>0 then
        MES.new('info',missing.." SFX files missing")
    end
    collectgarbage()
end
function SFX.loadSample(pack)
    assert(type(pack)=='table',"Usage: SFX.loadsample([table])")
    assert(pack.name,"No field: name")
    assert(pack.path,"No field: path")
    local num=1
    while love.filesystem.getInfo(pack.path..'/'..num..'.ogg') do
        Sources[pack.name..num]={love.audio.newSource(pack.path..'/'..num..'.ogg','static')}
        num=num+1
    end
    local base=(_getTuneHeight(pack.base) or 37)-1
    local top=base+num-1
    packSetting[pack.name]={base=base,top=top}
    LOG((num-1).." "..pack.name.." samples loaded")
end

function SFX.getCount()
    return #sfxList
end
function SFX.setVol(v)
    assert(type(v)=='number' and v>=0 and v<=1,'Wrong volume')
    volume=v
end
function SFX.setStereo(v)
    assert(type(v)=='number' and v>=0 and v<=1,'Wrong stereo')
    stereo=v
end

function SFX.getNoteName(note)
    if note<1 then
        return '---'
    else
        note=note-1
        local octave=floor(note/12)+1
        return noteName[note%12+1]..octave
    end
end
function SFX.playSample(pack,...)-- vol-1, sampSet1, vol-2, sampSet2
    if ... then
        local arg={...}
        local vol
        for i=1,#arg do
            local a=arg[i]
            if type(a)=='number' and a<=1 then
                vol=a
            else
                local base=packSetting[pack].base
                local top=packSetting[pack].top
                local tune=type(a)=='string' and _getTuneHeight(a) or a-- Absolute tune in number
                local playTune=tune+rnd(-2,2)
                if playTune<=base then-- Too low notes
                    playTune=base+1
                elseif playTune>top then-- Too high notes
                    playTune=top
                end
                SFX.play(pack..playTune-base,vol,nil,tune-playTune)
            end
        end
    end
end
local function _play(name,vol,pos,pitch)
    if volume==0 or vol==0 then return end
    local S=Sources[name]-- Source list
    if not S then return end
    local n=1
    while S[n]:isPlaying() do
        n=n+1
        if not S[n] then
            S[n]=S[1]:clone()
            S[n]:seek(0)
            break
        end
    end
    S=S[n]-- AU_SRC
    if S:getChannelCount()==1 then
        if pos then
            pos=MATH.clamp(pos,-1,1)*stereo
            S:setPosition(pos,1-pos^2,0)
        else
            S:setPosition(0,0,0)
        end
    end
    S:setVolume(vol^1.626)
    S:setPitch(pitch and 1.0594630943592953^pitch or 1)
    S:play()
end
SFX.fplay=_play-- Play sounds without apply module's volume setting
function SFX.play(name,vol,pos,pitch)
    _play(name,(vol or 1)*volume,pos,pitch)
end
function SFX.reset()
    for _,L in next,Sources do
        if type(L)=='table' then
            for i=#L,1,-1 do
                if not L[i]:isPlaying() then
                    rem(L,i)
                end
            end
        end
    end
end

return SFX
