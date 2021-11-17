local function task_newBoard(P)
    local F,L={},{}
    --TODO
    P:pushNextList(L)

    P.control=false
    if P.frameRun>180 then for _=1,26 do YIELD()end end
    P.control=true

    P:pushLineList(F)
end
local function _check(P)
    if #P.field>0 then
        P.gameEnv.heightLimit=P.gameEnv.heightLimit-P.lastPiece.row
        if #P.field+P.stat.row%4>4 then
            P:lose()
        end
    else
        if P.stat.pc>=100 then
            P:win('finish')
        else
            P:newTask(task_newBoard)
            if P.frameRun<180 then P.fieldBeneath=0 end
        end
    end
end
return{
    pushSpeed=5,
    mesDisp=function(P)
        setFont(60)
        mStr(P.stat.pc,63,340)
        mText(TEXTOBJ.pc,63,410)
    end,
    hook_drop=_check,
    -- task=_check,--Just run one time at first to start first level
    task=function(P)
        P:switchKey(6,false)
        YIELD()
        P:lose()
    end,
}
