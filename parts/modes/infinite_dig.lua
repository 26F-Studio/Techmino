local function check_rise(P)
    local L=P.garbageBeneath
    if #P.clearedRow==0 then
        if L>0 then
            if L<3 then
                P:_showText(text.almost,0,-120,80,'beat',.8)
            elseif L<5 then
                P:_showText(text.great,0,-120,80,'fly',.8)
            end
        end
        for _=1,8-L do
            P:garbageRise(13,1,generateLine(P.holeRND:random(10)))
        end
    else
        if L==0 then
            P:_showText(text.awesome,0,-120,80,'beat',.6)
            SFX.play('pc')
            if BG.cur=='wing' then BG.send(26) end
            for _=1,8 do
                P:garbageRise(13,1,generateLine(P.holeRND:random(10)))
            end
        else
            if BG.cur=='wing' then BG.send(#P.clearedRow) end
        end
    end
end

return {
    env={
        drop=1e99,lock=1e99,
        infHold=true,
        pushSpeed=1.2,
        hook_drop=check_rise,
        mesDisp=function(P)
            setFont(45)
            GC.mStr(P.stat.dig,63,190)
            GC.mStr(P.stat.atk,63,310)
            GC.mStr(("%.2f"):format(P.stat.atk/P.stat.row),63,420)
            mText(TEXTOBJ.line,63,243)
            mText(TEXTOBJ.atk,63,363)
            mText(TEXTOBJ.eff,63,475)
        end,
        bg='wing',bgm='dream',
    },
    load=function()
        PLY.newPlayer(1)
        local P1=PLAYERS[1]
        for _=1,8 do
            P1:garbageRise(13,1,P1:getHolePos())
        end
        P1.fieldBeneath=0
    end,
}
