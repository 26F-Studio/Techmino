-- Space with stars
local back={}

local upCover do
    local L={1,64}
    for i=0,63 do
        table.insert(L,{'setCL',.6,1,1,i*.01})
        table.insert(L,{'fRect',0,63-i,1,1})
    end
    upCover=GC.DO(L)
end
local downCover do
    local L={1,64}
    for i=0,63 do
        table.insert(L,{'setCL',1,.5,.8,i*.01})
        table.insert(L,{'fRect',0,i,1,1})
    end
    downCover=GC.DO(L)
end

local W,H
function back.init()
    BG.resize(SCR.w,SCR.h)
end
function back.resize(w,h)
    W,H=w,h
end
function back.update()
end
function back.draw()
    GC.clear(.08,.08,.084)
    GC.draw(upCover,0,0,0,W,H*.3/64)
    GC.draw(downCover,0,H*.7,0,W,H*.3/64)
end
return back
