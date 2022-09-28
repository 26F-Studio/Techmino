local yield=coroutine.yield
local function marginTask(P)
    local S=P.stat
    while true do yield()if S.frame>90*60 then P.strength=1;P:setFrameColor(1)break end end
    while true do yield()if S.frame>135*60 then P.strength=2;P:setFrameColor(2)break end end
    while true do yield()if S.frame>180*60 then P.strength=3;P:setFrameColor(3)break end end
    while true do yield()if S.frame>260*60 then P.strength=4;P:setFrameColor(4)break end end
end
return{
    env={
        bg={'bg1','bg2','blockhole','blockfall','blockrain','blockspace','cubes','fan','flink','glow','matrix','rainbow','rainbow2','tunnel'},
        bgm={'battle','beat5th','cruelty','distortion','echo','far','final','here','hope','memory','moonbeam','push','rectification','secret7th remix','secret7th','secret8th remix','secret8th','shift','shining terminal','storm','super7th','there','truth','vapor','waterfall'},
    },
    load=function()
        for k,v in next,NET.roomState.roomData do
            GAME.modeEnv[k]=v
        end
        GAME.modeEnv.allowMod=false
        GAME.modeEnv.task=marginTask

        local L=TABLE.copy(NETPLY.list)
        local N=1
        for i,p in next,L do
            if p.uid==USER.uid then
                if p.connected then
                    PLY.newPlayer(1)
                    PLAYERS[1].sid=NETPLY.getSID(USER.uid)
                    N=2
                end
                table.remove(L,i)
                break
            end
        end
        for _,p in next,L do
            if p.connected then
                PLY.newRemotePlayer(N,false,p)
                N=N+1
            end
        end
    end,
}
