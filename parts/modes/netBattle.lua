local yield=coroutine.yield
local function marginTask(P)
    local S=P.stat
    while true do yield() if S.frame>90*60 then P.strength=1;P:setFrameColor(1)break end end
    while true do yield() if S.frame>135*60 then P.strength=2;P:setFrameColor(2)break end end
    while true do yield() if S.frame>180*60 then P.strength=3;P:setFrameColor(3)break end end
    while true do yield() if S.frame>260*60 then P.strength=4;P:setFrameColor(4)break end end
end
return {
    env={
        bg={'bg1','bg2','blockhole','blockfall','blockrain','blockspace','cubes','fan','flink','glow','matrix','rainbow','rainbow2','tunnel'},
        bgm={'battle','beat5th','cruelty','distortion','echo','far','final','here','hope','memory','moonbeam','push','rectification','secret7th remix','secret7th','secret8th remix','secret8th','shift','shining terminal','storm','super7th','there','truth','vapor','waterfall'},
    },
    load=function()
        for k,v in next,NET.roomState.data do
            GAME.modeEnv[k]=v
        end
        GAME.modeEnv.allowMod=false
        GAME.modeEnv.task=marginTask

        local L=TABLE.shift(NETPLY.list,0)
        table.sort(L,function(a,b) return a.uid<b.uid end)
        math.randomseed(GAME.seed)
        for i=#L,1,-1 do
            table.insert(NETPLY.list,table.remove(NETPLY.list,math.random(i)))
        end
        TABLE.clear(NET.uid_sid)
        for i=1,#L do NET.uid_sid[L[i].uid]=i end

        local N=1
        for i,p in next,L do
            if p.uid==USER.uid then
                if p.playMode=='Gamer' then
                    PLY.newPlayer(1,false,p)
                    N=2
                end
                table.remove(L,i)
                break
            end
        end
        for _,p in next,L do
            if p.playMode=='Gamer' then
                PLY.newRemotePlayer(N,false,p)
                N=N+1
            end
        end
    end,
}
