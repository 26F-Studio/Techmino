local function getHoleCount(P)
    local hole=0
    for x=1,10 do
        for y=1,100 do
            if not P:solid(x,y)then
                hole=hole+1
            end
        end
    end
    return hole
end
return{
    color=COLOR.cyan,
    env={
        drop=60,lock=60,
        fieldH=100,
        highCam=true,
        fillClear=false,
        seqData={1,2,3,4,5,6,7},
        mesDisp=function(P)PLY.draw.drawTargetLine(P,100)end,
        bg='blockrain',bgm='there',
    },
    score=function(P)return{getHoleCount(P),P.stat.time}end,
    scoreDisp=function(D)return D[1].." Holes".."   "..STRING.time(D[2])end,
    comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]<b[2]end,
    getRank=function(P)
        local H=getHoleCount(P)
        return
        H==0 and 5 or
        H<=1 and 4 or
        H<=2 and 3 or
        H<=5 and 2 or
        H<=10 and 1 or
        H<=26 and 0
    end,
}