return {
    env={
        life=2,
        drop=60,lock=60,
        freshLimit=15,
        bg='quarks',bgm='battle',
    },
    load=function()
        PLY.newPlayer(1)
        PLY.newAIPlayer(2,BOT.template{type='CC',speedLV=7,next=3,hold=true,node=50000})
    end,
    score=function(P) return {P.stat.time} end,
    scoreDisp=function(D) return STRING.time(D[1]) end,
    comp=function(a,b) return a[1]<b[1] end,
    getRank=function(P)
        if P.result=='win' then
            local L=P.life
            return
            L>=2 and 5 or
            L>=1 and 4 or
            3
        end
    end,
}
