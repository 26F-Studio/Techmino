return{
    color=COLOR.white,
    env={},
    load=function()
        applyCustomGame()

        for y=1,20 do
            if solidLine(FIELD[1][y])then
                --Switch clear sprint mode on
                GAME.modeEnv.dropPiece=require'parts.eventsets.checkClearBoard'.dropPiece
                goto BREAK_clearMode
            end
        end
        GAME.modeEnv.dropPiece=NULL
        ::BREAK_clearMode::
        PLY.newPlayer(1)
        local AItype=GAME.modeEnv.opponent:sub(1,2)
        local AIlevel=tonumber(GAME.modeEnv.opponent:sub(-1))
        if AItype=='9S'then
            PLY.newAIPlayer(2,BOT.template{type='9S',speedLV=2*AIlevel,hold=true})
        elseif AItype=='CC'then
            PLY.newAIPlayer(2,BOT.template{type='CC',speedLV=2*AIlevel-1,next=math.floor(AIlevel*.5+1),hold=true,node=20000+5000*AIlevel})
        end

        for _,P in next,PLY_ALIVE do
            setField(P,1)
        end
    end,
}
