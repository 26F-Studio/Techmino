return {
    mesDisp=function(P)
        setFont(45)
        GC.mStr(("%d"):format(P.stat.atk),63,190)
        GC.mStr(("%.2f"):format(P.stat.atk/P.stat.row),63,310)
        mText(TEXTOBJ.atk,63,243)
        mText(TEXTOBJ.eff,63,363)

        local opacity=math.max(.4,1-(P.stat.time-P.modeData.lastChange))
        if #P.field>15 then opacity=opacity*.7 end
        setFont(25)
        GC.setColor(1,1,1,opacity)
        GC.mStr(P.modeData.infHeight and text.infHeightOn or text.infHeightOff,300,80)
        setFont(20)
        GC.mStr(text.infHeightHint,300,120)
    end,
    task=function(P)
        P.modeData.infHeight=false
        P.modeData.lastChange=0
    end,
    fkey1=function(P)
        P.modeData.infHeight=not P.modeData.infHeight
        P.modeData.lastChange=P.stat.time
    end,
    hook_drop=function(P)
        local heightTarget=P.field and #P.field+8 or 20
        local env=P.gameEnv
        if P.modeData.infHeight then
            env.fieldH=math.max(env.fieldH,heightTarget)
        elseif env.fieldH~=20 then
            -- if not infHeight, then only decrease height
            env.fieldH=MATH.clamp(env.fieldH,heightTarget,20)
        end
    end
}
