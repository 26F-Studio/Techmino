--[[ControlID:
    1~5:mL,mR,rR,rL,rF,
    6~10:hD,sD,H,A,R,
    11~13:LL,RR,DD
]]
--[[Future:
    HighestBlock
    BlockedCells
    Wells
    FilledLines
    4deepShape
    BlockedWells
]]
local min,abs=math.min,math.abs
local ins,rem=table.insert,table.remove
local yield=coroutine.yield

local dirCount={1,1,3,3,3,0,1}
local FCL={
    [1]={
        {{11},{11,2},{1},{},{2},{2,2},{12,1},{12}},
        {{11,4},{11,3},{1,4},{4},{3},{2,3},{2,2,3},{12,4},{12,3}},
    },
    [3]={
        {{11},{11,2},{1},{},{2},{2,2},{12,1},{12}},
        {{3,11},{11,3},{11,2,3},{1,3},{3},{2,3},{2,2,3},{12,1,3},{12,3}},
        {{11,5},{11,2,5},{1,5},{5},{2,5},{2,2,5},{12,1,5},{12,5}},
        {{11,4},{11,2,4},{1,4},{4},{2,4},{2,2,4},{12,1,4},{12,4},{4,12}},
    },
    [6]={
        {{11},{11,2},{1,1},{1},{},{2},{2,2},{12,1},{12}},
    },
    [7]={
        {{11},{11,2},{1},{},{2},{12,1},{12}},
        {{4,11},{11,4},{11,3},{1,4},{4},{3},{2,3},{12,4},{12,3},{3,12}},
    },
}FCL[2],FCL[4],FCL[5]=FCL[1],FCL[3],FCL[3]
local LclearScore={[0]=0,-200,-150,-100,200}
local HclearScore={[0]=0,100,140,200,500}
local function _ifoverlapAI(f,bk,x,y)
    for i=1,#bk do for j=1,#bk[1] do
        if f[y+i-1] and bk[i][j] and f[y+i-1][x+j-1]>0 then
            return true
        end
    end end
end
local getRow,discardRow=LINE.new,LINE.discard
local function _resetField(f0,f,start)
    for _=#f,start,-1 do
        discardRow(f[_])
        f[_]=nil
    end
    for i=start,#f0 do
        f[i]=getRow(0)
        for j=1,10 do
            f[i][j]=f0[i][j]
        end
    end
end
local function _getScore(field,cb,cy)
    local score=0
    local highest=0
    local height=getRow(0)
    local clear=0
    local hole=0

    for i=cy+#cb-1,cy,-1 do
        local full=true
        for j=1,10 do
            if field[i][j]==0 then
                -- goto CONTINUE_notFull
                full=false
                break
            end
        end
        if full then
            -- ::CONTINUE_notFull::
            discardRow(rem(field,i))
            clear=clear+1
        end
    end
    if #field==0 then-- PC
        return 1e99
    end
    for x=1,10 do
        local h=#field
        while field[h][x]==0 and h>1 do
            h=h-1
        end
        height[x]=h
        if x>3 and x<8 and h>highest then
            highest=h
        end
        if h>1 then
            for h1=h-1,1,-1 do
                if field[h1][x]==0 then
                    hole=hole+1
                    if hole==5 then
                        break
                    end
                end
            end
        end
    end
    local sdh=0
    local h1,mh1=0,0
    for x=1,9 do
        local dh=abs(height[x]-height[x+1])
        if dh==1 then
            h1=h1+1
            if h1>mh1 then
                mh1=h1
            end
        else
            h1=0
        end
        sdh=sdh+min(dh^1.6,20)
    end
    discardRow(height)
    score=
        -#field*30
        -#cb*15
        +(#field>10 and
            HclearScore[clear]-- Clearing
            -hole*70-- Hole
            -cy*50-- Height
            -sdh-- Sum of DeltaH
        or
            LclearScore[clear]
            -hole*100
            -cy*40
            -sdh*3
        )
    if #field>6 then
        score=score-highest*5+20
    end
    if mh1>3 then
        score=score-20-mh1*30
    end
    return score
end

local bot_9s={}
function bot_9s.thread(bot)
    local P,data,keys=bot.P,bot.data,bot.keys
    while true do
        -- Thinking
        yield()
        local Tfield={}-- Test field
        local best={x=1,dir=0,hold=false,score=-1e99}-- Best method
        local field_org=P.field
        for i=1,#field_org do
            Tfield[i]=getRow(0)
            for j=1,10 do
                Tfield[i][j]=field_org[i][j]
            end
        end

        for ifhold=0,data.hold and P.gameEnv.holdCount>0 and 1 or 0 do
            -- Get block id
            local bn
            if ifhold==0 then
                bn=P.cur and P.cur.id
            else
                bn=P.holdQueue[1] and P.holdQueue[1].id or P.nextQueue[1] and P.nextQueue[1].id
            end
            if bn then
                for dir=0,dirCount[bn] do-- Each dir
                    local cb=BLOCKS[bn][dir]
                    for cx=1,11-#cb[1] do-- Each pos
                        local cy=#Tfield+1

                        -- Move to bottom
                        while cy>1 and not _ifoverlapAI(Tfield,cb,cx,cy-1) do
                            cy=cy-1
                        end

                        -- Simulate lock
                        for i=1,#cb do
                            local y=cy+i-1
                            if not Tfield[y] then
                                Tfield[y]=getRow(0)
                            end
                            local L=Tfield[y]
                            for j=1,#cb[1] do
                                if cb[i][j] then
                                    L[cx+j-1]=1
                                end
                            end
                        end
                        local score=_getScore(Tfield,cb,cy)
                        if score>best.score then
                            best={bn=bn,x=cx,dir=dir,hold=ifhold==1,score=score}
                        end
                        _resetField(field_org,Tfield,cy)
                    end
                end
            end
        end
        if not best.bn then return 1 end

        -- Release cache
        while #Tfield>0 do
            discardRow(rem(Tfield,1))
        end
        if best.hold then
            ins(keys,8)
        end
        local l=FCL[best.bn][best.dir+1][best.x]
        for i=1,#l do
            ins(keys,l[i])
        end
        ins(keys,6)

        -- Check if time to change target
        yield()
        if P.aiRND:random()<.00126 then
            P:changeAtkMode(P.aiRND:random()<.85 and 1 or #P.atker>3 and 4 or P.aiRND:random()<.3 and 2 or 3)
        end
    end
end
return bot_9s
