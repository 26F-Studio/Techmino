local rem=table.remove

local sfxList={}
local Sources={}
local volume=1
local stereo=1

local SFX={}

function SFX.init(list)
    assert(type(list)=='table',"Initialize SFX lib with a list of filenames!")
    sfxList=list
end
function SFX.load(path)
    if not sfxList then
        error("Cannot load before init!")
    else
        for i=1,#sfxList do
            local fullPath=path..sfxList[i]..'.ogg'
            if love.filesystem.getInfo(fullPath)then
                Sources[sfxList[i]]={love.audio.newSource(fullPath,'static')}
            else
                LOG("No SFX: "..sfxList[i]..'.ogg',.1)
            end
        end
    end
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
