return {
    env={},
    load=function()
        applyCustomGame()

        -- Switch clear sprint mode on
        if #FIELD[1]>0 then
            GAME.modeEnv.hook_drop=require'parts.eventsets.checkClearBoard'.hook_drop
        else
            GAME.modeEnv.hook_drop=NULL
        end
        PLY.newPlayer(1)
        local AItype=GAME.modeEnv.opponent:sub(1,2)
        local AIlevel=tonumber(GAME.modeEnv.opponent:sub(-1))
        if AItype=='9S' then
            PLY.newAIPlayer(2,BOT.template{type='9S',speedLV=2*AIlevel,hold=GAME.modeEnv.holdCount})
        elseif AItype=='CC' then
            PLY.newAIPlayer(2,BOT.template{type='CC',speedLV=2*AIlevel-1,next=math.floor(AIlevel*.5+1),hold=GAME.modeEnv.holdCount,node=20000+5000*AIlevel})
        end

        for _,P in next,PLY_ALIVE do
            setField(P,FIELD[1])
        end
    end,
    savePrivate=function()
        return {
            FIELD=FIELD,
            BAG=BAG,
            MISSION=MISSION,
            CUSTOMENV=CUSTOMENV,
        }
    end,
    loadPrivate=function(private)
        FIELD=private.FIELD
        BAG=private.BAG
        MISSION=private.MISSION
        CUSTOMENV=private.CUSTOMENV
    end,
}
