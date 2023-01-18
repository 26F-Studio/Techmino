local PCbase=require"parts.modes.PCbase"
local PClist=require"parts.modes.PClist"
local PCtype={
    1,1,1,1,2,
    1,1,1,1,3,
    1,1,1,2,
    1,2,1,3,
    1,2,3,
}
local function task_PC(P)
    local difficulty=PCtype[P.stat.pc+1] or 3
    local L=PClist[difficulty][P.holeRND:random(#PClist[difficulty])]
    local symmetry=P.holeRND:random()>.5
    P:pushNextList(L,symmetry)

    P.control=false
    if P.frameRun>180 then for _=1,26 do coroutine.yield() end end
    P.control=true

    local base=PCbase[difficulty]
    P:pushLineList(base[P.holeRND:random(#base)],symmetry)
end
local function _check(P)
    if #P.field>0 then
        if #P.field+P.stat.row%4>4 then
            P:lose()
        end
    else
        if P.stat.pc>=60 then
            P:win('finish')
        else
            P:newTask(task_PC)
            if P.frameRun<180 then P.fieldBeneath=0 end
        end
    end
end
return {
    sequence='none',
    RS="SRS",
    mesDisp=function(P)
        setFont(60)
        GC.mStr(P.stat.pc,63,260)
        mText(TEXTOBJ.pc,63,330)
    end,
    hook_drop=_check,
    task=_check,-- Just run one time at first to start first level
}
