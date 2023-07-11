local ins=table.insert
local yield=coroutine.yield
return {
    env={
        drop=20,lock=60,
        sequence=function(seqRND)
            local field,stat
            for _=1,3 do field,stat=yield(7) end
            while true do
                local height=TABLE.new(0,10)
                local max=#field
                if max>0 then
                    -- Get heights
                    for x=1,10 do
                        local h=max
                        while field[h][x]==0 and h>1 do
                            h=h-1
                        end
                        height[x]=h
                    end
                else
                    for x=1,10 do
                        height[x]=0
                    end
                end
                height[11]=999

                local wei={1,1,2,2,3,4}
                local d=0
                for i=1,10 do
                    d=d+height[i]
                end
                if d<40 or stat.row>2*42 then-- Low field or almost win, give SZO
                    for _=1,4 do
                        ins(wei,1)
                        ins(wei,2)
                        ins(wei,6)
                    end
                else
                    -- Give I when no hole
                    local tempDeltaHei=-999-- Height difference
                    for x=2,11 do
                        local deltaHei=height[x]-height[x-1]
                        if tempDeltaHei<-2 and deltaHei>2 then
                            break
                        elseif x==11 then
                            for _=1,3 do ins(wei,7) end
                        else
                            tempDeltaHei=deltaHei
                        end
                    end

                    -- Give O when no d=0/give T when no d=1
                    local flatCount=0-- d=0 count
                    local stairCount=0-- d=1 count
                    for x=2,10 do
                        local _=height[x]-height[x-1]
                        if _==0 then
                            flatCount=flatCount+1
                        elseif _==1 or _==-1 then
                            stairCount=stairCount+1
                        end
                    end
                    if flatCount<3 then
                        for _=1,3 do ins(wei,6) end
                    end
                    if stairCount<3 then
                        for _=1,4 do ins(wei,5) end
                    end
                end
                field,stat=yield(wei[seqRND:random(#wei)])
            end
        end,
        trueNextCount=1,nextCount=1,holdCount=0,
        ospin=false,
        freshLimit=15,
        eventSet='checkLine_100',
        bg='blockfall',bgm='reason',
    },
    score=function(P) return {math.min(P.stat.row,100),P.stat.time} end,
    scoreDisp=function(D) return D[1].." Lines   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        local L=P.stat.row
        if L>=100 then
            local T=P.stat.time
            return
            T<=110 and 5 or
            T<=126 and 4 or
            T<=160 and 3 or
            T<=240 and 2 or
            1
        else
            return
            L>=50 and 1 or
            L>=10 and 0
        end
    end,
}
