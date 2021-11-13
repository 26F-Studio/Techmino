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
    P.control=false
    for _=1,26 do YIELD()end
    P.control=true
    local base=PCbase[P.modeData.type]
    P:pushLineList(base[P.holeRND:random(#base)],P.modeData.symmetry)
end
local function check(P)
    local r=P.field
    if #r>0 then
        if #r+P.stat.row%4>4 then
            P:lose()
        end
    else
        local type=PCtype[P.stat.pc+1]or 3
        local L=PClist[type][P.holeRND:random(#PClist[type])]
        local symmetry=P.holeRND:random()>.5
        P.modeData.type=type
        P.modeData.symmetry=symmetry
        P:pushNextList(L,symmetry)
        P.modeData.counter=P.stat.piece==0 and 20 or 0
        P:newTask(task_PC)
    end
end
return{
    mesDisp=function(P)
        setFont(60)
        mStr(P.stat.pc,63,340)
        mText(TEXTOBJ.pc,63,410)
    end,
    hook_drop=check,
    task=check,
}
