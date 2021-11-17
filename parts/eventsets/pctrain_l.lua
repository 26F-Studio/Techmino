local pc_drop={50,45,40,35,30,26,22,18,15,12}
local pc_lock={55,50,46,42,39,36,33,31,29,27}
local pc_fall={18,16,14,12,10,9,8,7,6,5}
local PCbase=require"parts.modes.PCbase"
local PClist=require"parts.modes.PClist"

local function task_PC(P)
    if P.frameRun>180 then
        P.control=false
        for _=1,26 do YIELD()end
        P.control=true
    end
    local base=PCbase[P.modeData.type]
    P:pushLineList(base[P.holeRND:random(#base)],P.modeData.symmetry)
end
local function _check(P)
    local f=P.field
    if #f>0 then
        if #f+P.stat.row%4>4 then
            P:lose()
        end
    else
        local type=P.stat.pc<10 and 4 or 5
        local L=PClist[type][P.holeRND:random(#PClist[type])]
        local symmetry=P.holeRND:random()>.5
        P.modeData.type=type
        P.modeData.symmetry=symmetry
        P:pushNextList(L,symmetry)
        P:newTask(task_PC)

        local s=P.stat.pc*.25
        if math.floor(s)==s and s>0 then
            P.gameEnv.drop=pc_drop[s]or 10
            P.gameEnv.lock=pc_lock[s]or 25
            P.gameEnv.fall=pc_fall[s]or 4
            if s==10 then
                P:_showText(text.maxspeed,0,-140,100,'appear',.6)
            end
        end
    end
end
return{
    mesDisp=function(P)
        setFont(60)
        mStr(P.stat.pc,63,340)
        mText(TEXTOBJ.pc,63,410)
    end,
    hook_drop=_check,
    task=_check,--Just run one time at first to start first level
}
