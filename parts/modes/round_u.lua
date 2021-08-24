local function update_round(P)
    if P.stat.piece%7==0 and #PLY_ALIVE>1 then
        P.control=false
        local ID=P.id
        repeat
            ID=ID+1
            if not PLAYERS[ID]then ID=1 end
        until PLAYERS[ID].alive or ID==P.id
        PLAYERS[ID].control=true
    end
end

return{
    color=COLOR.lYellow,
    env={
        life=1,
        drop=300,lock=300,
        infHold=true,
        dropPiece=update_round,
        pushSpeed=15,
        garbageSpeed=1e99,
        bg='rainbow',bgm='push',
    },
    load=function()
        PLY.newPlayer(1)
        PLY.newAIPlayer(2,BOT.template{type='CC',speedLV=8,next=4,hold=true,node=40000})
    end,
    score=function(P)return{P.stat.piece,P.stat.time}end,
    scoreDisp=function(D)return D[1].." Pieces   "..STRING.time(D[2])end,
    comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]<b[2]end,
    getRank=function(P)
        if P.result=='win'then
            local T=P.stat.piece
            return
            T<=7*8 and 5 or
            T<=7*10 and 4 or
            T<=7*15 and 3 or
            T<=7*26 and 2 or
            1
        end
    end,
}