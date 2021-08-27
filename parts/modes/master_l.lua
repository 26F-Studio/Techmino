return{
    color=COLOR.red,
    env={
        noTele=true,
        das=9,arr=3,
        freshLimit=15,
        noInitSZO=true,
        eventSet='master_l',
        bg='bg1',bgm='secret8th',
    },
    slowMark=true,
    score=function(P)return{P.modeData.pt,P.stat.time}end,
    scoreDisp=function(D)return D[1].."P   "..STRING.time(D[2])end,
    comp=function(a,b)
        return a[1]>b[1]or(a[1]==b[1]and a[2]<b[2])
    end,
    getRank=function(P)
        local S=P.modeData.pt
        if S==500 then
            local T=P.stat.time
            return
            T<=170 and 5 or
            T<=200 and 4 or
            3
        else
            return
            S>=460 and 3 or
            S>=350 and 2 or
            S>=200 and 1 or
            S>=50 and 0
        end
    end,
}