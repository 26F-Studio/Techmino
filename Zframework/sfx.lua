local SFX={
    vol=1,
    stereo=1,
    getCount=function()return 0 end,
    load=function()error("Cannot load before init!")end,
    fieldPlay=NULL,
    play=NULL,
    fplay=NULL,
    reset=NULL,
}
function SFX.setVol(v)
    assert(type(v)=='number'and v>=0 and v<=1)
    SFX.vol=v
end
function SFX.setStereo(v)
    assert(type(v)=='number'and v>=0 and v<=1)
    SFX.stereo=v
end
function SFX.init(list)
    SFX.init=nil
    local rem=table.remove
    local Sources={}

    local count=#list function SFX.getCount()return count end
    function SFX.load(path)
        for i=1,count do
            local fullPath=path..list[i]..'.ogg'
            if love.filesystem.getInfo(fullPath)then
                Sources[list[i]]={love.audio.newSource(fullPath,'static')}
            else
                LOG("No SFX: "..list[i]..'.ogg',.1)
            end
        end

        function SFX.play(s,vol,pos)
            if SFX.vol==0 or vol==0 then return end
            local S=Sources[s]--Source list
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
                    pos=pos*SFX.stereo
                    S:setPosition(pos,1-pos^2,0)
                else
                    S:setPosition(0,0,0)
                end
            end
            S:setVolume(((vol or 1)*SFX.vol)^1.626)
            S:play()
        end
        function SFX.fplay(s,vol,pos)
            local S=Sources[s]--Source list
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
                    pos=pos*SFX.stereo
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
    end
end
return SFX
