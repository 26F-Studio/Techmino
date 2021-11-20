local function task_newBoard(P,init)
    local targetLine
    local F,L={},{1}
    --TODO
    P:pushNextList(L)

    P.control=false
    if not init then for _=1,26 do YIELD()end end
    P.control=true

    P.gameEnv.heightLimit=targetLine or #F
    P:pushLineList(F)
end
local function _check(P)
    P.gameEnv.heightLimit=P.gameEnv.heightLimit-P.lastPiece.row
    if P.gameEnv.heightLimit==0 then
        P.modeData.stage=P.modeData.stage+1
        if P.modeData.stage>=100 then
            P:win('finish')
        else
            P:newTask(task_newBoard)
        end
    end
end
return{
    sequence='none',
    RS="TRS",
    pushSpeed=5,
    mesDisp=function(P)
        setFont(60)
        mStr(P.modeData.stage,63,280)
        mText(TEXTOBJ.wave,63,350)
    end,
    hook_drop=_check,
    task=function(P)task_newBoard(P,true)P.fieldBeneath=0 end,--Just run one time at first to start first level
}
