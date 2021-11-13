local gc=love.graphics
local gc_draw,gc_print,gc_setColor=gc.draw,gc.print,gc.setColor
local setFont=setFont

local PLAYERS,PLY_ALIVE=PLAYERS,PLY_ALIVE

return{
    mesDisp=function(P)
        setFont(35)
        mStr(#PLY_ALIVE.."/"..#PLAYERS,63,175)
        mStr(P.modeData.ko,80,215)
        gc_draw(TEXTOBJ.ko,60-TEXTOBJ.ko:getWidth(),222)
        setFont(20)
        gc_setColor(1,.5,0,.6)
        gc_print(P.badge,103,227)
        gc_setColor(.97,.97,.97)
        setFont(25)
        mStr(text.powerUp[P.strength],63,290)
        gc_setColor(1,1,1)
        for i=1,P.strength do
            gc_draw(IMG.badgeIcon,16*i+6,260)
        end
    end,
}
