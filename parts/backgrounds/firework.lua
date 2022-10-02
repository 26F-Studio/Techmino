-- Firework
local gc=love.graphics
local gc_clear=gc.clear
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_line,gc_circle=gc.line,gc.circle

local rnd=math.random
local ins,rem=table.insert,table.remove
local back={}

local t
local firework,particle
function back.init()
    t=26
    firework,particle={},{}
end
function back.update(dt)
    t=t-1
    if t==0 then
        ins(firework,{
            x=nil,y=nil,
            x0=SCR.w*(rnd()*1.2-.1),
            y0=SCR.h*1.5,
            x1=SCR.w*(.15+rnd()*.7),
            y1=SCR.h*(.15+rnd()*.4),
            t=0,
            v=.5+rnd(),
            color=COLOR.random_dark(),
            big=rnd()<.1,
        })
        t=rnd(26,62)
    end
    for i=#firework,1,-1 do
        local F=firework[i]
        local time=F.t^.5
        if time>1 then
            local x,y,color=F.x,F.y,F.color
            if F.big then
                SFX.play('fall',.5)
                for _=1,rnd(62,126) do
                    ins(particle,{
                        x=x,y=y,
                        color=color,
                        vx=rnd()*16-8,
                        vy=rnd()*16-8,
                        t=1,
                    })
                end
            else
                SFX.play('clear_1',.4)
                for _=1,rnd(16,26) do
                    ins(particle,{
                        x=x,y=y,
                        color=color,
                        vx=rnd()*8-4,
                        vy=rnd()*8-4,
                        t=1,
                    })
                end
            end
            rem(firework,i)
        else
            F.t=F.t+dt*F.v
            F.x=F.x0*(1-time)+F.x1*time
            F.y=F.y0*(1-time)+F.y1*time
        end
    end
    for i=#particle,1,-1 do
        local P=particle[i]
        if P.t<0 then
            rem(particle,i)
        else
            P.x=P.x+P.vx
            P.y=P.y+P.vy
            P.vy=P.vy+.04
            P.t=P.t-dt*.6
        end
    end
end
function back.draw()
    gc_clear(.1,.1,.1)
    for i=1,#firework do
        local F=firework[i]
        gc_setColor(F.color)
        gc_circle('fill',F.x,F.y,F.big and 8 or 4)
    end
    gc_setLineWidth(3)
    for i=1,#particle do
        local P=particle[i]
        local c=P.color
        gc_setColor(c[1],c[2],c[3],P.t*.4)
        gc_line(P.x,P.y,P.x-P.vx*4,P.y-P.vy*4)
    end
end
function back.discard()
    firework=nil
end
return back
