local skip
---@param RND love.RandomGenerator
local function randomizer(RND)
    local last=RND:random(2)==1 and 1 or 4
    local function get_next()
        local list={1,2,3,1,3,2}
        local ret=list[last]
        last=last+1
        if last>6 then last=1 end
        return ret
    end
    local bag={}
    local function fill_bag()
        local weights=0
        while weights<24 do
            local x=get_next()
            table.insert(bag,x)
            weights=weights+(x==1 and 2 or 3)
        end
        local pos=RND:random(#bag)+1
        table.insert(bag,pos,4)
        if skip==1 then skip=0 end
    end
    return function()
        if #bag==0 then fill_bag() end
        return table.remove(bag,1)
    end
end
local lines={
    {1,1,1,1,0,0,1,1,1,1},
    {1,1,1,0,0,0,1,1,1,1},
    {1,1,1,1,0,0,0,1,1,1},
    {1,1,1,0,0,0,0,1,1,1}
}
local function get_lines(n,P)
    local ret={}
    for _=1,n do
        local L=TABLE.shift(lines[P.randomizer_spinren()])
        for i=1,#L do
            if L[i]==1 then
                L[i]=P.modeData.colorSet[P.holeRND:random(4)]
            end
        end
        table.insert(ret,L)
    end
    return ret
end

return {
    load=function()
        PLY.newPlayer(1)
        local P=PLY_ALIVE[1]
        P.modeData.colorSet={}
        for i=1,4 do
            P.modeData.colorSet[i]=P.holeRND:random(25)
        end
        P.randomizer_spinren=randomizer(P.holeRND)
        P:pushLineList(get_lines(18,P))
        P.fieldBeneath=0
    end,
    env={
        lock=1e99,
        drop=1e99,
        minsdarr=3,
        infHold=true,
        highCam=false,
        bgm='lounge',
        eventSet='sprintEff_40',
        hook_drop=function(P)
            if P.lastPiece.row==0 then
                if P.stat.row<10 then
                    P:lose()
                else
                    P:win('finish')
                end
            end
            local up=MATH.clamp(22-P.stat.row+P.lastPiece.row,0,P.lastPiece.row)
            P:pushLineList(get_lines(up,P))
        end
    },
    score=function(P) return {P.stat.atk/P.stat.row,P.stat.time} end,
    scoreDisp=function(D) return ("%.2f"):format(D[1]).." Efficiency   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        if P.stat.row<10 then return end
        local E=P.stat.atk/P.stat.row
        return
            E>=10 and 5 or
            E>=9 and 4 or
            E>=8 and 3 or
            E>=6 and 2 or
            E>=3 and 1 or
            0
    end
}
