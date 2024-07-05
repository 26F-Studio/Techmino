---@param RND RandomGenerator
local randomizer=function(RND)
    local ins=table.insert
    local last={1}
    local weights={2,2,1}
    local r=RND:random(1,5)
    for i=1,#weights do
        r=r-weights[i]
        if r<=0 then
            ins(last,i+1)
            break
        end
    end
    return function()
        local ret=last[1]
        local this
        if ret==1 and last[2]==4 or ret==4 and last[2]==1 then
            this=RND:random(1,2)+1
        elseif ret==1 then
            this=5-last[2]
        elseif ret==4 then
            this=1
        elseif last[2]==1 then
            local r=RND:random(1,5)
            this=r==1 and 4 or 5-ret
        elseif last[2]==4 then
            this=RND:random(1,2)==1 and 1 or 5-ret
        else
            this=RND:random(1,5)<3 and 4 or 1
        end
        last={last[2],this}
        return ret
    end
end
local lines={
    {1,2,3,4,0,0,5,6,7,8},
    {7,6,5,0,0,0,4,3,2,1},
    {1,2,3,4,0,0,0,5,6,7},
    {7,6,5,0,0,0,0,4,3,2}
}
local function get_lines(n,f)
    local ret={}
    for _=1,n do
        table.insert(ret,lines[f()])
    end
    return ret
end

return {
    load=function()
        PLY.newPlayer(1)
        local our=PLY_ALIVE[1]
        our.randomizer_spinren=randomizer(our.holeRND)
        our:pushLineList(get_lines(20,our.randomizer_spinren))
    end,
    env={
        lock=1e99,
        drop=1e99,
        infHold=true,
        eventSet='sprintEff_40',
        hook_drop=function(P)
            if P.lastPiece.row==0 then
                P:win('finish')
            end
            local up=MATH.clamp(20-P.stat.row+P.lastPiece.row,0,P.lastPiece.row)
            P:pushLineList(get_lines(up,P.randomizer_spinren))
        end
    },
    score=function(P) return {P.stat.atk/P.stat.row,P.stat.time} end,
    scoreDisp=function(D) return string.format("%.3f",D[1]).." Efficiency   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]>b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        if P.stat.row<10 then return end
        local E=P.stat.atk/P.stat.row
        return math.min(math.floor(E/2),5)
    end
}