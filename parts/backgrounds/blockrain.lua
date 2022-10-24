-- Block rain
local gc=love.graphics
local rnd=math.random
local ins,rem=table.insert,table.remove
local back={}

local t
local mino
function back.init()
    t=0
    mino={}
end
function back.update()
    t=t+1
    if t%10==0 then
        local r=rnd(29)
        ins(mino,{
            bid=r,
            block=TEXTURE.miniBlock[r],
            color=BLOCK_COLORS[SETTING.skin[r]],
            x=SCR.w*rnd(),
            y=SCR.h*-.05,
            k=SCR.rad/200,
            ang=rnd()*6.2832,
            vy=.5+rnd()*.4,
            vx=rnd()*.4-.2,
            va=rnd()*.04-.02,
        })
    end
    for i=#mino,1,-1 do
        local P=mino[i]
        P.y=P.y+P.vy
        if P.y>SCR.h+25 then
            rem(mino,i)
        else
            P.x=P.x+P.vx
            P.ang=P.ang+P.va
            P.vx=P.vx-.01+rnd()*.02
        end
    end
end
function back.draw()
    gc.clear(.08,.08,.084)
    for i=1,#mino do
        local C=mino[i]
        local c=C.color
        gc.setColor(c[1],c[2],c[3],.2)
        gc.draw(C.block,C.x,C.y,C.ang,C.k,C.k,C.block:getWidth()/2,C.block:getHeight()/2)
    end
end
function back.discard()
    mino=nil
end
return back
