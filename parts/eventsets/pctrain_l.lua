local pc_drop={50,45,40,35,30,26,22,18,15,12}
local pc_lock={55,50,46,42,40,38,36,34,32,30}
local pc_fall={18,16,14,12,10,9,8,7,6,5}
local PCbase=require"parts.modes.PCbase"
local PClist=require"parts.modes.PClist"

local function task_PC(P)
    local difficulty=P.stat.pc<10 and 4 or 5
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
        if P.stat.pc>=100 then
            P:win('finish')
        else
            P:newTask(task_PC)
            if P.frameRun<180 then P.fieldBeneath=0 end

            if P.stat.pc%4==0 and P.stat.pc>0 and P.stat.pc<=40 then
                local s=P.stat.pc/4
                P.gameEnv.drop=pc_drop[s] or 10
                P.gameEnv.lock=pc_lock[s] or 25
                P.gameEnv.fall=pc_fall[s] or 4
                if s==10 then
                    P:_showText(text.maxspeed,0,-140,100,'appear',.6)
                end
            end
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
