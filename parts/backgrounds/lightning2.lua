-- Fast lightning + spining tetromino
local int,rnd=math.floor,math.random
local back={}

local t
local colorLib=BLOCK_COLORS
local blocks=BLOCKS
function back.init()
    t=rnd()*2600
end
function back.update(dt)
    t=t+dt
end
function back.draw()
    local R=7-int(t*.5%7)
    local T=1.2-t%15%6%1.8
    if T<.26 then GC.clear(T,T,T)
    else GC.clear(0,0,0)
    end
    local _=colorLib[SETTING.skin[R]]
    GC.setColor(_[1],_[2],_[3],.12)
    GC.draw(TEXTURE.miniBlock[R],SCR.cx,SCR.cy,t%3.1416*6,200*SCR.k,nil,2*DSCP[R][0][2]+1,2*(#blocks[R][0]-DSCP[R][0][1])-1)
end
return back
