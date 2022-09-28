local ins,rem=table.insert,table.remove
local yield=coroutine.yield

local seqGenerators={
    none=function()while true do yield()end end,
    bag=function(P,seq0)
        local rndGen=P.seqRND
        local len=#seq0
        local bag={}
        while true do
            while #P.nextQueue<10 do
                if #bag==0 then
                    for i=1,len do
                        bag[i]=seq0[len-i+1]
                    end
                end
                P:getNext(rem(bag,rndGen:random(#bag)))
            end
            yield()
        end
    end,
    bagES=function(P,seq0)
        local rndGen=P.seqRND
        local len=#seq0
        local bag=TABLE.shift(seq0)
        do--Get a good first-bag
            --Shuffle
            for i=1,len-1 do ins(bag,rem(bag,rndGen:random(len-i+1)))end
            --Skip Uncomfortable minoes
            for _=1,len-1 do
                if
                    bag[1]==1 or bag[1]==2 or bag[1]==6 or bag[1]==8 or bag[1]==9 or
                    bag[1]==12 or bag[1]==13 or
                    bag[1]==17 or bag[1]==18 or
                    bag[1]==23 or bag[1]==24
                then
                    ins(bag,rem(bag,1))
                else
                    break
                end
            end
            --Finish
            for i=1,len do P:getNext(bag[i])end
        end
        bag={}
        while true do
            while #P.nextQueue<10 do
                if #bag==0 then
                    for i=1,len do
                        bag[i]=seq0[len-i+1]
                    end
                end
                P:getNext(rem(bag,rndGen:random(#bag)))
            end
            yield()
        end
    end,
    his=function(P,seq0)
        local rndGen=P.seqRND
        local len=#seq0
        local hisLen=math.ceil(len*.5)
        local history=TABLE.new(0,hisLen)
        while true do
            while #P.nextQueue<10 do
                local r
                for _=1,hisLen do--Reroll up to [hisLen] times
                    r=rndGen:random(len)
                    for i=1,hisLen do
                        if r==history[i]then
                            goto CONTINUE_rollAgain
                        end
                    end
                    do break end
                    ::CONTINUE_rollAgain::
                end
                if history[1]~=0 then
                    P:getNext(seq0[r])
                end
                rem(history,1)
                ins(history,r)
            end
            yield()
        end
    end,
    hisPool=function(P,seq0)
        local rndGen=P.seqRND
        local len=#seq0
        local hisLen=math.ceil(len*.5)
        local history=TABLE.new(0,hisLen)--Indexes of mino-index

        local poolLen=5*len
        local droughtTimes=TABLE.new(len,len)--Drought times of seq0
        local pool={}for i=1,len do for _=1,5 do ins(pool,i)end end--5 times indexes of seq0
        local function _poolPick()
            local r=rndGen:random(poolLen)
            local res=pool[r]

            --Find droughtest(s) minoes
            local droughtList={1}--Droughtst minoes' indexes of seq0
            local maxTime=droughtTimes[1]
            for i=2,len do
                if droughtTimes[i]>maxTime then
                    maxTime=droughtTimes[i]
                    if #droughtList==1 then
                        droughtList[1]=i
                    else
                        droughtList={i}
                    end
                elseif droughtTimes[i]==maxTime then
                    ins(droughtList,i)
                end
            end

            --Update droughtTimes
            for i=1,len do droughtTimes[i]=droughtTimes[i]+1 end
            droughtTimes[res]=0

            --Update pool
                -- print("Rem "..res)
            pool[r]=droughtList[rndGen:random(#droughtList)]
                -- print("Add "..pool[r])

            return res
        end

        while true do
            while #P.nextQueue<10 do
                    -- print"======================"
                --Pick a mino from pool
                local tryTime=0
                ::REPEAT_pickAgain::
                local r=_poolPick()--Random mino-index in pool
                for i=1,len do
                    if r==history[i]then
                        tryTime=tryTime+1
                        if tryTime<hisLen then
                            goto REPEAT_pickAgain
                        end
                    end
                end

                --Give mino to player & update history
                if history[1]~=0 then
                    P:getNext(seq0[r])
                end
                rem(history,1)
                ins(history,r)
                    -- print("Player GET: "..r)
                    -- print("History: "..table.concat(history,","))
                    -- local L=TABLE.new("",len)
                    -- for _,v in next,pool do L[v]=L[v].."+"end
                    -- for i=1,#L do print(i,droughtTimes[i],L[i])end
            end
            yield()
        end
    end,
    c2=function(P,seq0)
        local rndGen=P.seqRND
        local len=#seq0
        local weight=TABLE.new(0,len)

        while true do
            while #P.nextQueue<10 do
                local maxK=1
                for i=1,len do
                    weight[i]=weight[i]*.5+rndGen:random()
                    if weight[i]>weight[maxK]then
                        maxK=i
                    end
                end
                weight[maxK]=weight[maxK]/3.5
                P:getNext(seq0[maxK])
            end
            yield()
        end
    end,
    rnd=function(P,seq0)
        if #seq0==1 then
            local i=seq0[1]
            while true do
                while #P.nextQueue<10 do P:getNext(i)end
                yield()
            end
        else
            local rndGen=P.seqRND
            local len=#seq0
            local last=0
            while true do
                while #P.nextQueue<10 do
                    local r=rndGen:random(len-1)
                    if r>=last then
                        r=r+1
                    end
                    P:getNext(seq0[r])
                    last=r
                end
                yield()
            end
        end
    end,
    mess=function(P,seq0)
        local rndGen=P.seqRND
        while true do
            while #P.nextQueue<10 do
                P:getNext(seq0[rndGen:random(#seq0)])
            end
            yield()
        end
    end,
    reverb=function(P,seq0)
        local rndGen=P.seqRND
        local bufferSeq,bag={},{}
        while true do
            while #P.nextQueue<10 do
                if #bag==0 then
                    for i=1,#seq0 do bufferSeq[i]=seq0[i]end
                    repeat
                        local r=rem(bufferSeq,rndGen:random(#bag))
                        local p=1
                        repeat
                            ins(bag,r)
                            p=p-.15-rndGen:random()
                        until p<0
                    until #bufferSeq==0
                    for i=1,#bag do
                        bufferSeq[i]=bag[i]
                    end
                end
                P:getNext(rem(bag,rndGen:random(#bag)))
            end
            yield()
        end
    end,
    loop=function(P,seq0)
        local len=#seq0
        local bag={}
        while true do
            while #P.nextQueue<10 do
                if #bag==0 then
                    for i=1,len do
                        bag[i]=seq0[len-i+1]
                    end
                end
                P:getNext(rem(bag))
            end
            yield()
        end
    end,
    fixed=function(P,seq0)
        local seq={}
        for i=#seq0,1,-1 do
            ins(seq,seq0[i])
        end
        while true do
            while #P.nextQueue<10 do
                if seq[1]then
                    P:getNext(rem(seq))
                else
                    break
                end
            end
            yield()
        end
    end,
}
return function(P)--Return a piece-generating function for player P
    local s=P.gameEnv.sequence
    if type(s)=='function'then
        return s
    elseif type(s)=='string'and seqGenerators[s]then
        return seqGenerators[s]
    else
        MES.new('warn',
            type(s)=='string'and
            "No sequence mode called "..s or
            "Wrong sequence generator"
        )
        P.gameEnv.sequence='bag'
        return seqGenerators.bag
    end
end
