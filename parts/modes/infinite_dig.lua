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
            SFX.play('clear')
            BG.send(26)
            for _=1,8 do
                P:garbageRise(13,1,generateLine(P.holeRND:random(10)))
            end
        else
            BG.send(#P.clearedRow)
        end
    end
end

return{
    color=COLOR.white,
    env={
        drop=1e99,lock=1e99,
        infHold=true,
        pushSpeed=1.2,
        dropPiece=check_rise,
        mesDisp=function(P)
            setFont(45)
            mStr(P.stat.dig,63,190)
            mStr(P.stat.atk,63,310)
            mStr(("%.2f"):format(P.stat.atk/P.stat.row),63,420)
            mText(drawableText.line,63,243)
            mText(drawableText.atk,63,363)
            mText(drawableText.eff,63,475)
        end,
        bg='wing',bgm='dream',
    },
    load=function()
        PLY.newPlayer(1)
        local P=PLAYERS[1]
        for _=1,8 do
            P:garbageRise(13,1,generateLine(P.holeRND:random(10)))
        end
        P.fieldBeneath=0
    end,
}