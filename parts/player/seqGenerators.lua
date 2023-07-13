local ins,rem=table.insert,table.remove
local yield=coroutine.yield

local seqGenerators={
    none=function() end,
    bag=function(rndGen,seq0)
        local len=#seq0
        local bag={}
        while true do
            if #bag==0 then
                for i=1,len do
                    bag[i]=seq0[len-i+1]
                end
            end
            yield(rem(bag,rndGen:random(#bag)))
        end
    end,
    bagES=function(rndGen,seq0)
        local len=#seq0
        local bag=TABLE.shift(seq0)
        do-- Get a good first-bag
            -- Shuffle
            for i=1,len-1 do ins(bag,rem(bag,rndGen:random(len-i+1))) end
            -- Skip Uncomfortable minoes
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
            -- Finish
            for i=1,len do yield(bag[i]) end
        end
        bag={}
        while true do
            if #bag==0 then
                for i=1,len do
                    bag[i]=seq0[len-i+1]
                end
            end
            yield(rem(bag,rndGen:random(#bag)))
        end
    end,
    his=function(rndGen,seq0)
        local len=#seq0
        local hisLen=math.ceil(len*.5)
        local history=TABLE.new(0,hisLen)
        while true do
            local r
            for _=1,hisLen do-- Reroll up to [hisLen] times
                r=rndGen:random(len)
                local rollAgain
                for i=1,hisLen do
                    if r==history[i] then
                        rollAgain=true
                        break-- goto CONTINUE_rollAgain
                    end
                end
                if not rollAgain then break end
                -- ::CONTINUE_rollAgain::
            end
            if history[1]~=0 then
                yield(seq0[r])
            end
            rem(history,1)
            ins(history,r)
        end
    end,
    hisPool=function(rndGen,seq0)
        local len=#seq0
        local hisLen=math.ceil(len*.5)
        local history=TABLE.new(0,hisLen)-- Indexes of mino-index

        local poolLen=5*len
        local droughtTimes=TABLE.new(len,len)-- Drought times of seq0
        local pool={} for i=1,len do for _=1,5 do ins(pool,i) end end-- 5 times indexes of seq0
        local function _poolPick()
            local r=rndGen:random(poolLen)
            local res=pool[r]

            -- Find droughtest(s) minoes
            local droughtList={1}-- Droughtst minoes' indexes of seq0
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

            -- Update droughtTimes
            for i=1,len do droughtTimes[i]=droughtTimes[i]+1 end
            droughtTimes[res]=0

            -- Update pool
                -- print("Rem "..res)
            pool[r]=droughtList[rndGen:random(#droughtList)]
                -- print("Add "..pool[r])

            return res
        end

        while true do
                -- print"======================"
            -- Pick a mino from pool
            local tryTime=0
            local r
            repeat-- ::REPEAT_pickAgain::
                local pickAgain
                r=_poolPick()-- Random mino-index in pool
                for i=1,len do
                    if r==history[i] then
                        tryTime=tryTime+1
                        if tryTime<hisLen then
                            pickAgain=true
                            break-- goto REPEAT_pickAgain
                        end
                    end
                end
                if not pickAgain then break end
            until true

            -- Give mino to player & update history
            if history[1]~=0 then
                yield(seq0[r])
            end
            rem(history,1)
            ins(history,r)
                -- print("Player GET: "..r)
                -- print("History: "..table.concat(history,","))
                -- local L=TABLE.new("",len)
                -- for _,v in next,pool do L[v]=L[v].."+" end
                -- for i=1,#L do print(i,droughtTimes[i],L[i]) end
        end
    end,
    c2=function(rndGen,seq0)
        local len=#seq0
        local weight=TABLE.new(0,len)

        while true do
            local maxK=1
            for i=1,len do
                weight[i]=weight[i]*.5+rndGen:random()
                if weight[i]>weight[maxK] then
                    maxK=i
                end
            end
            weight[maxK]=weight[maxK]/3.5
            yield(seq0[maxK])
        end
    end,
    rnd=function(rndGen,seq0)
        if #seq0==1 then
            local i=seq0[1]
            while true do
                yield(i)
            end
        else
            local len=#seq0
            local last=0
            while true do
                local r=rndGen:random(len-1)
                if r>=last then
                    r=r+1
                end
                yield(seq0[r])
                last=r
            end
        end
    end,
    mess=function(rndGen,seq0)
        while true do
            yield(seq0[rndGen:random(#seq0)])
        end
    end,
    reverb=function(rndGen,seq0)
        local bufferSeq,bag={},{}
        while true do
            if #bag==0 then
                for i=1,#seq0 do bufferSeq[i]=seq0[i] end
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
            yield(rem(bag,rndGen:random(#bag)))
        end
    end,
    loop=function(rndGen,seq0)
        local len=#seq0
        local bag={}
        while true do
            if #bag==0 then
                for i=1,len do
                    bag[i]=seq0[len-i+1]
                end
            end
            yield(rem(bag))
        end
    end,
    fixed=function(rndGen,seq0)
        for i=#seq0,1,-1 do
            yield(seq0[i])
        end
    end,
    bagP1inf=function(rndGen,seq0)
        local len=#seq0
        local function new()
            local res={}
            local higher=nil
            local higher_dist={}
            for i=1,len do
                higher_dist[i]=1
            end
            local remaining=len+1
            local unknown={}
            local extra=-1
            local function init()
                for i=1,len do
                    unknown[i]=1
                end
                remaining=len+1
                extra=-1
            end
            init()
            function res.next_dist()
                if extra>=0 then
                    return remaining,unknown
                end
                local temp={}
                local temp_sum=0
                for i=1,len do
                    local item=higher_dist[i]*(2-unknown[i])
                    temp[i]=item
                    temp_sum=temp_sum+item
                end
                local sum=0
                for i=1,len do
                    temp[i]=temp[i]+temp_sum*unknown[i]
                    sum=sum+temp[i]
                end
                return sum,temp
            end
            function res.update(i)
                if unknown[i]==0 then
                    assert(extra<0,"extra should be -1")
                    extra=i
                else
                    unknown[i]=0
                end
                remaining=remaining-1
                if remaining>0 then
                    return
                end
                if higher==nil then
                    higher=new()
                end
                higher.update(extra)
                local _
                _,higher_dist=higher.next_dist()
                init()
            end
            return res
        end
        local dist=new()
        while true do
            local sum,mydist=dist.next_dist()
            local r=rndGen:random(sum)
            for i=1,len do
                r=r-mydist[i]
                if r<=0 then
                    yield(seq0[i])
                    dist.update(i)
                    break
                end
            end
        end
    end,
}
return function(s)-- Return a piece-generating function for player P
    if type(s)=='function' then
        return s
    elseif type(s)=='string' and seqGenerators[s] then
        return seqGenerators[s]
    else
        MES.new('warn',
            type(s)=='string' and
            "No sequence mode called "..s or
            "Wrong sequence generator"
        )
        return seqGenerators.bag
    end
end
