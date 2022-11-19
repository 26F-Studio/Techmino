local function GetGravity(lvl) -- note: uses G units, not frames per block
    return math.pow(lvl/4+1,.7)
end
local function GetDAS(lvl) -- if these seem random, i was plotting the graph and this seemed like the perfect curve
    return math.max(math.floor(5-math.pow(lvl,0.6)),2)
end
local function GetPlayableARE(lvl) -- delay between the piece spawning and it actually starting to fall. subtracted from actual ARE, hence named "Playable ARE"
    return math.min(math.floor(2+math.pow(3*lvl,0.37)),9)
end
local function LinesUntilNextLife(lvl,lives)
    if lives>=3 then return math.huge end
    if lvl<2 then
        return math.pow(3,lives+1)
    elseif lvl<5 then
        return math.pow(2,lives+1)
    else
        return math.pow(2,lives)
    end
end

return {
    das=5,arr=2,
    sddas=1e99,sdarr=1e99,
    -- also IRS and IHS is enabled because we want it to actually be playable after 1.3G
    drop=1e99,lock=1, -- use custom drop method for classic levels
    wait=8,fall=25,
    freshLimit=0,
    fieldH=19,
    nextCount=1,
    holdCount=0,
    RS='C2_sym', -- for basic finesse and a few basic kicks, no up kicks
    sequence=function(P) -- rndES
        local rndGen=P.seqRND
        do --start without bad pieces
            local goodPieces={3,4,5,7}
            P:getNext(goodPieces[rndGen:random(4)])
        end
        while true do
            while #P.nextQueue<10 do
                P:getNext(rndGen:random(7))
            end
            coroutine.yield()
        end
    end,
    noTele=true,
    keyCancel={6}, -- 180 enabled so you don't have to break your fingers at 2G
    mesDisp=function(P)
        setFont(60)
        GC.mStr(('%.2f'):format(P.modeData.grav),47,220)
        setFont(30)
        GC.mStr("G",120,252)
        mText(TEXTOBJ.speed,63,290)
        PLY.draw.drawProgress(P.stat.row,P.modeData.target)
        if P.modeData.nextLife<1e99 then
            mText(TEXTOBJ.nextLife,63,20)
            GC.mStr(P.modeData.nextLife,63,40)
            mText(TEXTOBJ.line,63,80)
        end
        if P.modeData.drought>7 then
            if P.modeData.drought<=14 then
                GC.setColor(1,1,1,P.modeData.drought/7-1)
            else
                local gb=P.modeData.drought<=21 and 2-P.modeData.drought/14 or .5
                GC.setColor(1,gb,gb)
            end
            setFont(50)
            GC.mStr(P.modeData.drought,63,130)
            mDraw(MODES.drought_l.icon,63,200,nil,.5)
        end
    end,
    task=function(P)
        local D=P.modeData
        D.grav=1
        D.target=10
        D.nextLife=3
        D.gravCounter=0
        D.gravPause=100
        D.areConv=2
        D.plare=0
        local prevY
        while true do
            while not P.cur do coroutine.yield() end
            prevY=P:getCenterY()
            while D.gravPause>0 or D.plare>0 do
                print(D.gravPause,D.plare)
                coroutine.yield()
                if D.gravPause>0 then D.gravPause=D.gravPause-1 end
                if D.plare>0 then D.plare=D.plare-1 end
                if P.cur and P:getCenterY()<prevY then
                    D.gravPause,D.plare=0,0
                    break
                end
            end
            coroutine.yield()
            D.gravCounter=D.gravCounter+D.grav
            if P.curY-math.floor(D.gravCounter)<P.ghoY then -- custom gravity logic since the player's gravity logic doesn't support unusual decimal numbers
                P.curY=P.ghoY
                if P.cur then P:drop(true) end
            else
                if P.gameEnv.moveFX then
                    for i=1,math.floor(D.gravCounter) do
                        P:createMoveFX('down')
                        P.curY=P.curY-1
                    end
                else
                    P.curY=P.curY-math.floor(D.gravCounter)
                end
            end
            D.gravCounter=D.gravCounter%1
        end
    end,
    hook_drop=function(P)
        local D,E=P.modeData,P.gameEnv
        D.drought=P.lastPiece.id==7 and 0 or D.drought+1
        if P.lastPiece.row>0 then
            D.nextLife=D.nextLife-P.lastPiece.row
            if D.nextLife<=0 then
                P.life=P.life+1
                D.nextLife=D.nextLife+LinesUntilNextLife(math.floor(P.stat.row/10),P.life)
            end
        end
        if P.stat.row>=D.target then
            local lvl=math.floor(P.stat.row/10)
            SFX.play('reach')
            D.grav=GetGravity(lvl)
            D.target=D.target+10
            D.nextLife=math.min(D.nextLife,LinesUntilNextLife(lvl,P.life))
            D.areConv=GetPlayableARE(lvl)
            E.das,E.arr=GetDAS(lvl),1
            E.nextCount=math.min(math.ceil(D.grav),6)
            E.wait=10-D.areConv
        end
        D.plare=D.areConv
    end,
    hook_die=function(P)
        if P.life>0 then
            P.modeData.nextLife=math.min(
                P.modeData.nextLife,
                LinesUntilNextLife(math.floor(P.stat.row/10),P.life-1)
            )
            local goodPieces={3,4,5,7}
            local id=P.cur.id
            if id==1 or id==2 or id==6 then
                P.cur=P:getBlock(goodPieces[P.seqRND:random(4)])
                P:resetBlock()
            end
        end
        P.modeData.gravCounter=0
        P.modeData.gravPause=120
    end
}
