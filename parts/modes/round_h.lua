return {
    env={
        life=1,
        drop=300,lock=300,
        infHold=true,
        pushSpeed=15,
        garbageSpeed=1e99,
        eventSet='checkTurn_7',
        bg='rainbow',bgm='push',
    },
    load=function()
        PLY.newPlayer(1)
        PLY.newAIPlayer(2,BOT.template{type='CC',speedLV=7,next=2,hold=false,node=5000})
    end,
    score=function(P) return {P.stat.piece,P.stat.time} end,
    scoreDisp=function(D) return D[1].." Pieces   "..STRING.time(D[2]) end,
    comp=function(a,b) return a[1]<b[1] or a[1]==b[1] and a[2]<b[2] end,
    getRank=function(P)
        if P.result=='win' then
            local T=P.stat.piece
            return
            T<=7*10 and 5 or
            T<=7*13 and 4 or
            T<=7*18 and 3 or
            T<=7*26 and 2 or
            1
        end
    end,
}
