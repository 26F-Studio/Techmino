---@param RND RandomGenerator
local randomizer=function(RND)
    local this=1
    return function()
        -- weights to get 2:2:2:1 steady distribution
        local weights={5,5,5,2}
        local ret=this
        weights[this]=0
        local sum=weights[1]+weights[2]+weights[3]+weights[4]
        local r=RND:random(1,sum)
        for i=1,4 do
            r=r-weights[i]
            if r<=0 then
                this=i
                break
            end
        end
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
            local up=MATH.clamp(20-P.stat.row,0,P.lastPiece.row)
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