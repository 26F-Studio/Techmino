local gc_setColor,gc_draw=love.graphics.setColor,love.graphics.draw
local ply_applyField=PLY.draw.applyField

return {
    env={
        fkey1=function(P) P.modeData.showMark=1-P.modeData.showMark end,
        hook_drop=function(P)
            local D=P.modeData
            local F=FIELD[D.finished+1]
            for y=1,#F do
                local L=P.field[y]
                for x=1,10 do
                    local a,b=F[y][x],L and L[x] or 0
                    if a~=0 then
                        if a==-1 then if b>0 then return end
                        elseif a<12 then if a~=b then return end
                        elseif a>7 then if b==0 then return end
                        end
                    end
                end
            end
            D.finished=D.finished+1
            if FIELD[D.finished+1] then
                P.waiting=26
                for _=#P.field,1,-1 do
                    P.field[_],P.visTime[_]=nil
                end
                SYSFX.newShade(1.4,P.absFieldX,P.absFieldY,300*P.size,610*P.size,.3,1,.3)
                SFX.play('reach')
                D.showMark=0
            else
                D.showMark=1
                P:win('finish')
            end
        end,
        mesDisp=function(P)
            ply_applyField(P)
            if P.modeData.showMark==0 then
                local mark=TEXTURE.puzzleMark
                local F=FIELD[P.modeData.finished+1]
                gc_setColor(1,1,1)
                for y=1,#F do for x=1,10 do
                    local T=F[y][x]
                    if T~=0 then
                        gc_draw(mark[T],30*x-30,600-30*y)
                    end
                end end
            end
            PLY.draw.cancelField()
        end,
    },
    load=function()
        applyCustomGame()
        local AItype=GAME.modeEnv.opponent:sub(1,2)
        local AIlevel=tonumber(GAME.modeEnv.opponent:sub(-1))
        PLY.newPlayer(1)
        if AItype=='9S' then
            PLY.newAIPlayer(2,BOT.template{type='9S',speedLV=2*AIlevel,hold=true})
        elseif AItype=='CC' then
            PLY.newAIPlayer(2,BOT.template{type='CC',speedLV=2*AIlevel-1,next=math.floor(AIlevel*.5+1),hold=true,node=20000+5000*AIlevel})
        end
    end,
}
