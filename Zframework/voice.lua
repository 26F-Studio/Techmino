local rnd=math.random
local volume=1
local diversion=0
local voiceQueue={free=0}
local VOC={
    getCount=function() return 0 end,
    getQueueCount=function() return 0 end,
    load=function() error("Cannot load before init!") end,
    getFreeChannel=NULL,
    play=NULL,
    update=NULL,
}
function VOC.setDiversion(n)
    assert(type(n)=='number' and n>0 and n<12,'Wrong div')
    diversion=n
end
function VOC.setVol(v)
    assert(type(v)=='number' and v>=0 and v<=1,'Wrong volume')
    volume=v
    for i=1,#voiceQueue do
        local Q=voiceQueue[i]
        for j=1,#Q do
            local s=Q[j]
            if type(s)=='userdata' then
                s:setVolume(volume)
            end
        end
    end
end
function VOC.init(list)
    VOC.init=nil
    local rem=table.remove
    local bank={}-- {vocName1={SRC1s},vocName2={SRC2s},...}
    local Source={}

    local count=#list function VOC.getCount() return count end
    local function _loadVoiceFile(path,N,vocName)
        local fullPath=path..vocName..'.ogg'
        if love.filesystem.getInfo(fullPath) then
            bank[vocName]={love.audio.newSource(fullPath,'stream')}
            table.insert(Source[N],vocName)
            return true
        end
    end
    -- Load voice with string
    local function _getVoice(str)
        local L=bank[str]
        local n=1
        while L[n]:isPlaying() do
            n=n+1
            if not L[n] then
                L[n]=L[1]:clone()
                L[n]:seek(0)
                break
            end
        end
        return L[n]
    end
    function VOC.load(path)
        for i=1,count do
            Source[list[i]]={}

            local n=0
            repeat n=n+1 until not _loadVoiceFile(path,list[i],list[i]..'_'..n)

            if n==1 then
                if not _loadVoiceFile(path,list[i],list[i]) then
                    LOG("No VOC: "..list[i],.1)
                end
            end
            if not Source[list[i]][1] then
                Source[list[i]]=nil
            end
        end

        function VOC.getQueueCount()
            return #voiceQueue
        end
        function VOC.getQueueLength(chn)
            return voiceQueue[chn] and #voiceQueue[chn]
        end
        function VOC.getFreeChannel()
            local l=#voiceQueue
            for i=1,l do
                if #voiceQueue[i]==0 then return i end
            end
            voiceQueue[l+1]={s=0}
            return l+1
        end

        function VOC.play(s,chn)
            if volume>0 then
                local _=Source[s]
                if not _ then return end
                if chn then
                    local L=voiceQueue[chn]
                    L[#L+1]=_[rnd(#_)]
                    L.s=1
                    -- Add to queue[chn]
                else
                    voiceQueue[VOC.getFreeChannel()]={s=1,_[rnd(#_)]}
                    -- Create new channel & play
                end
            end
        end
        function VOC.update()
            for i=#voiceQueue,1,-1 do
                local Q=voiceQueue[i]
                if Q.s==0 then-- Free channel, auto delete when >3
                    if i>3 then
                        rem(voiceQueue,i)
                    end
                elseif Q.s==1 then-- Waiting load source
                    Q[1]=_getVoice(Q[1])
                    Q[1]:setVolume(volume)
                    Q[1]:setPitch(1.0594630943592953^(diversion*(rnd()*2-1)))
                    Q[1]:play()
                    Q.s=Q[2] and 2 or 4
                elseif Q.s==2 then-- Playing 1,ready 2
                    if Q[1]:getDuration()-Q[1]:tell()<.08 then
                        Q[2]=_getVoice(Q[2])
                        Q[2]:setVolume(volume)
                        Q[1]:setPitch(1.0594630943592953^(diversion*(rnd()*2-1)))
                        Q[2]:play()
                        Q.s=3
                    end
                elseif Q.s==3 then-- Playing 12 same time
                    if not Q[1]:isPlaying() then
                        for j=1,#Q do
                            Q[j]=Q[j+1]
                        end
                        Q.s=Q[2] and 2 or 4
                    end
                elseif Q.s==4 then-- Playing last
                    if not Q[1].isPlaying(Q[1]) then
                        Q[1]=nil
                        Q.s=0
                    end
                end
            end
        end
    end
end
return VOC
