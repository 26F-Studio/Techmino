return {
    env={
        drop=60,lock=60,
        fall=20,
        garbageSpeed=.3,
        pushSpeed=2,
        freshLimit=15,
        eventSet='royale',
        bg='galaxy',bgm='rockblock',
    },
    load=function()
        ROYALEDATA.powerUp={2,6,14,30}
        ROYALEDATA.stage={75,50,35,20,10}
        PLY.newPlayer(1)
        local L={} for i=1,100 do L[i]=true end
        local t=4
        while t>0 do
            local r=math.random(2,99)
            if L[r] then
                L[r]=false
                t=t-1
            end
        end
        local n=2
        for _=1,7 do for _=1,7 do
            if L[n] then
                PLY.newAIPlayer(n,BOT.template{type='9S',speedLV=math.random(4,8),hold=true},true)
            else
                PLY.newAIPlayer(n,BOT.template{type='CC',speedLV=math.random(3,6),next=3,hold=true,node=30000},true)
            end
            n=n+1
        end end
        for _=15,21 do for _=1,7 do
            if L[n] then
                PLY.newAIPlayer(n,BOT.template{type='9S',speedLV=math.random(4,7),hold=true},true)
            else
                PLY.newAIPlayer(n,BOT.template{type='CC',speedLV=math.random(4,6),next=3,hold=true,node=30000},true)
            end
            n=n+1
        end end
    end,
    score=function(P) return {P.modeData.place,P.modeData.ko} end,
    scoreDisp=function(D) return "NO."..D[1].."   KO:"..D[2] end,
    comp=function(a,b) return a[1]<b[1] or a[1]==b[1] and a[2]>b[2] end,
    getRank=function(P)
        local R=P.modeData.place
        return
        R==1 and 5 or
        R<=3 and 4 or
        R<=6 and 3 or
        R<=8 and 2 or
        R<=10 and 1 or
        R<=90 and 0
    end,
}
