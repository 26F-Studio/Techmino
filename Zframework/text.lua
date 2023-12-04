local getColor,setColor=GC.getColor,GC.setColor

local floor,rnd=math.floor,math.random
local ins,rem=table.insert,table.remove
local draw=GC.draw

local texts={}

local textFX={}
function textFX.appear(t)
    draw(
        t.text,t.x,t.y,
        nil,
        nil,nil,
        t.text:getWidth()*.5,t.text:getHeight()*.5
    )
end
function textFX.sudden(t)
    setColor(1,1,1,1-t.c)
    draw(
        t.text,t.x,t.y,
        nil,
        nil,nil,
        t.text:getWidth()*.5,t.text:getHeight()*.5
    )
end
function textFX.fly(t)
    draw(
        t.text,t.x+(t.c-.5)^3*300,t.y,
        nil,
        nil,nil,
        t.text:getWidth()*.5,t.text:getHeight()*.5
    )
end
function textFX.stretch(t)
    draw(
        t.text,t.x,t.y,
        nil,
        t.c<.3 and (.3-t.c)*1.6+1 or 1,1,
        t.text:getWidth()*.5,t.text:getHeight()*.5
    )
end
function textFX.drive(t)
    draw(
        t.text,t.x,t.y,
        nil,
        nil,nil,
        t.text:getWidth()*.5,t.text:getHeight()*.5,
        t.c<.3 and (.3-t.c)*2 or 0,0
    )
end
function textFX.spin(t)
    draw(
        t.text,t.x,t.y,
        t.c<.3 and (.3-t.c)^2*4 or t.c<.8 and 0 or (t.c-.8)^2*-4,
        nil,nil,
        t.text:getWidth()*.5,t.text:getHeight()*.5
    )
end
function textFX.flicker(t)
    local _,_,_,T=getColor()
    setColor(1,1,1,T*(rnd()+.5))
    draw(
        t.text,t.x,t.y,
        nil,
        nil,nil,
        t.text:getWidth()*.5,t.text:getHeight()*.5
    )
end
function textFX.zoomout(t)
    draw(
        t.text,t.x,t.y,
        nil,
        t.c^.5*.1+1,nil,
        t.text:getWidth()*.5,t.text:getHeight()*.5
    )
end
function textFX.beat(t)
    local k=t.c<.3 and 1.3-t.c^2/.3 or 1
    draw(
        t.text,t.x,t.y,
        nil,
        k,k,
        t.text:getWidth()*.5,t.text:getHeight()*.5
    )
end
function textFX.score(t)
    local _,_,_,T=getColor()
    setColor(1,1,1,T*.5)
    draw(
        t.text,t.x,t.y-0-t.c^.2*50,
        nil,
        nil,nil,
        t.text:getWidth()*.5,t.text:getHeight()*.5
    )
end

local TEXT={}
function TEXT.clear()
    texts={}
end
function TEXT.show(text,x,y,font,style,spd,stop)
    ins(texts,{
        c=0,                                                         -- Timer
        text=GC.newText(FONT.get(floor(font/5)*5 or 40),text),         -- String
        x=x or 0,                                                    -- X
        y=y or 0,                                                    -- Y
        spd=(spd or 1),                                              -- Timing speed(1=last 1 sec)
        stop=stop,                                                   -- Stop time(sustained text)
        draw=assert(textFX[style or 'appear'],"no text type:"..style),-- Draw method
    })
end
function TEXT.getText(text,x,y,font,style,spd,stop)-- Another version of TEXT.show(), but only return text object, need manual management
    return {
        c=0,
        text=GC.newText(FONT.get(floor(font/5)*5 or 40),text),
        x=x or 0,
        y=y or 0,
        spd=(spd or 1),
        stop=stop,
        draw=textFX[style or 'appear'] or error("unavailable type:"..style),
    }
end
function TEXT.update(dt,list)
    if not list then
        list=texts
    end
    for i=#list,1,-1 do
        local t=list[i]
        t.c=t.c+t.spd*dt
        if t.stop then
            if t.c>t.stop then
                t.c=t.stop
            end
        end
        if t.c>1 then
            rem(list,i)
        end
    end
end
function TEXT.draw(list)
    if not list then
        list=texts
    end
    for i=1,#list do
        local t=list[i]
        local p=t.c
        setColor(1,1,1,p<.2 and p*5 or p<.8 and 1 or 5-p*5)
        t:draw()
    end
end
return TEXT
