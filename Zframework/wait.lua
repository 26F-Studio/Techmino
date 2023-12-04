local WAIT={
    state=false,
    timer=false,
    totalTimer=false,

    enterTime=.2,
    leaveTime=.2,
    timeout=6,
    coverColor={.1,.1,.1},
    coverAlpha=.6,

    arg=false,
}

local arcAlpha={1,.6,.4,.3}
local function defaultDraw(a,t)
    GC.setLineWidth(SCR.h/26)
    t=t*2.6
    for i=1,4 do
        GC.setColor(1,1,1,a*arcAlpha[i])
        GC.arc('line','open',SCR.w/2,SCR.h/2,SCR.h/5,t+MATH.tau*(i/4),t+MATH.tau*((i+1)/4))
    end
end

function WAIT.new(arg)
    if WAIT.state then return end

    assert(type(arg)=='table',"arg must be table")
    assert(arg.init==nil      or type(arg.init)      =='function',"Field 'enter' must be function")
    assert(arg.update==nil    or type(arg.update)    =='function',"Field 'update' must be function")
    assert(arg.quit==nil      or type(arg.quit)      =='function',"Field 'leave' must be function")
    assert(arg.draw==nil      or type(arg.draw)      =='function',"Field 'draw' must be function")
    assert(arg.escapable==nil or type(arg.escapable) =='boolean', "Field 'escapable' must be boolean")
    if arg.init then arg.init() end

    WAIT.arg=arg
    WAIT.state='enter'
    WAIT.timer=0
    WAIT.totalTimer=0
end

function WAIT.interrupt()
    if WAIT.state and WAIT.state~='leave' then
        WAIT.state='leave'
        WAIT.timer=WAIT.leaveTime*WAIT.timer/WAIT.enterTime
    end
end

function WAIT.update(dt)
    if WAIT.state then
        WAIT.totalTimer=WAIT.totalTimer+dt
        if WAIT.arg.update then WAIT.arg.update(dt) end

        if WAIT.state~='leave' and WAIT.totalTimer>=(WAIT.arg.timeout or WAIT.timeout) then
            WAIT.interrupt()
        end

        if WAIT.state=='enter' then
            WAIT.timer=math.min(WAIT.timer+dt,WAIT.enterTime)
            if WAIT.timer>=WAIT.enterTime then WAIT.state='wait' end
        elseif WAIT.state=='leave' then
            WAIT.timer=WAIT.timer-dt
            if WAIT.timer<=0 then
                WAIT.state=false
                if WAIT.arg.quit then WAIT.arg.quit() end
            end
        end
    end
end

function WAIT.draw()
    if WAIT.state then
        local alpha=(
            WAIT.state=='enter' and WAIT.timer/WAIT.enterTime or
            WAIT.state=='wait' and 1 or
            WAIT.state=='leave' and WAIT.timer/WAIT.leaveTime
        )
        GC.setColor(
            WAIT.coverColor[1],
            WAIT.coverColor[2],
            WAIT.coverColor[3],
            alpha*WAIT.coverAlpha
        )
        GC.rectangle('fill',0,0,SCR.w,SCR.h);

        (WAIT.arg.draw or defaultDraw)(alpha,WAIT.totalTimer)
    end
end

function WAIT.setEnterTime(t)
    assert(type(t)=='number' and t>0,"Arg #1 must be number larger then 0")
    WAIT.enterTime=t
end
function WAIT.setLeaveTime(t)
    assert(type(t)=='number' and t>0,"Arg #1 must be number larger then 0")
    WAIT.leaveTime=t
end
function WAIT.setTimeout(t)
    assert(type(t)=='number' and t>0,"Arg #1 must be number larger then 0")
    WAIT.timeout=t
end
function WAIT.setCoverColor(r,g,b)
    if type(r)=='table' then
        r,g,b=r[1],r[2],r[3]
    end
    if
        type(r)=='number' and r>=0 and r<=1 and
        type(g)=='number' and g>=0 and g<=1 and
        type(b)=='number' and b>=0 and b<=1
    then
        WAIT.coverColor[1],WAIT.coverColor[2],WAIT.coverColor[3]=r,g,b
    else
        error("Arg must be r,g,b or {r,g,b}")
    end
end
function WAIT.setCoverAlpha(a)
    assert(type(a)=='number',"Arg #1 must be number between 0~1")
end
function WAIT.setDefaultDraw(f)
    assert(type(f)=='function',"Arg #1 must be function")
    defaultDraw=f
end

setmetatable(WAIT,{__call=function(self,arg)
    self.new(arg)
end,__metatable=true})

return WAIT
