-- Flying cubes
local gc=love.graphics
local gc_clear=gc.clear
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle=gc.rectangle

local rnd=math.random
local ins,rem=table.insert,table.remove
local back={}

local t
local squares
function back.init()
    t=26
    squares={}
end
function back.update(dt)
    t=t-1
    if t==0 then
        local size=SCR.rad*(2+rnd()*3)/100
        local S={
            x=(SCR.w-size)*rnd(),
            y=(SCR.h-size)*rnd(),
            vx=0,vy=0,
            size=size,
            color=COLOR.random_dark(),
        }
        local speed=SCR.rad*(1+rnd()*2)/6
        if rnd()<.5 then
            S.vy=26*(.5-rnd())
            S.vx=speed
            if rnd()<.5 then
                S.x=-S.size
            else
                S.x=SCR.w
                S.vx=-S.vx
            end
        else
            S.vx=26*(.5-rnd())
            S.vy=speed
            if rnd()<.5 then
                S.y=-S.size
            else
                S.y=SCR.h
                S.vy=-S.vy
            end
        end
        ins(squares,S)
        t=rnd(6,16)
    end
    for i=#squares,1,-1 do
        local S=squares[i]
        if
            S.vx>0 and S.x>SCR.w or
            S.vx<0 and S.x+S.size<0 or
            S.vy>0 and S.y>SCR.h or
            S.vy<0 and S.y+S.size<0
        then
            rem(squares,i)
        else
            S.x=S.x+S.vx*dt
            S.y=S.y+S.vy*dt
        end
    end
end
function back.draw()
    gc_clear(.1,.1,.1)
    gc_setLineWidth(6)
    for i=1,#squares do
        local S=squares[i]
        local c=S.color
        gc_setColor(c[1],c[2],c[3],.2)
        gc_rectangle('line',S.x,S.y,S.size,S.size)
        gc_setColor(c[1],c[2],c[3],.3)
        gc_rectangle('fill',S.x+3,S.y+3,S.size-6,S.size-6)
    end
end
function back.discard()
    squares=nil
end
return back
