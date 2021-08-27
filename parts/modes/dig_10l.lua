local function check_rise(P)
    if P.stat.dig==10 then
        P:win('finish')
    end
end

return{
    color=COLOR.cyan,
    env={
        pushSpeed=6,
        dropPiece=check_rise,
        mesDisp=function(P)
            setFont(55)
            mStr(10-P.stat.dig,63,265)
        end,
        eventSet='digBase',
        bg='bg1',bgm='way',
    },
    score=function(P)return{P.stat.time,P.stat.piece}end,
    scoreDisp=function(D)return STRING.time(D[1]).."   "..D[2].." Pieces"end,
    comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]<b[2]end,
    getRank=function(P)
        if P.stat.dig<10 then return end
        local T=P.stat.time
        return
        T<=7 and 5 or
        T<=12 and 4 or
        T<=20 and 3 or
        T<=40 and 2 or
        T<=60 and 1 or
        0
    end,
}