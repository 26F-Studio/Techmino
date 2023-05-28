local gc=love.graphics
local gc_translate=gc.translate
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw=gc.draw
local gc_rectangle=gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf


local NET=NET
local fetchTimer

local roomList=WIDGET.newListBox{name='roomList',x=50,y=50,w=800,h=440,lineH=40,drawF=function(item,id,ifSel)
    setFont(35)
    if ifSel then
        gc_setColor(1,1,1,.3)
        gc_rectangle('fill',0,0,800,40)
    end

    gc_setColor(.9,.9,1)
    gc_print(id,45,-4)

    if type(item)=='table' then
        gc_setColor(1,1,1)
        if item.private then
            gc_draw(IMG.lock,10,5)
        end
        if item.count then
            gc_printf(
                type(item.count.Spectator)=='number' and item.count.Spectator>0 and
                    ("$1(+$2)/$3"):repD(item.count.Gamer or '?',item.count.Spectator or '?',item.capacity or '?')
                    or
                ("$1/$2"):repD(item.count.Gamer or '?',item.capacity or '?'),600,-4,180,'right')
        end

        if item.info and item.state then
            if item.state=='Standby' then
                gc_setColor(COLOR.Z)
            elseif item.state=='Ready' then
                gc_setColor(COLOR.lB)
            elseif item.state=='Playing' then
                gc_setColor(COLOR.G)
            end
            gc_print(item.info.name,200,-4)
        end
    end
end}
local function _hidePW()
    local R=roomList:getSel()
    return not R or not R.private
end
local passwordBox=WIDGET.newInputBox{name='password',x=350,y=505,w=500,h=50,secret=true,hideF=_hidePW,limit=64}

--[[roomList[n]={
    state='Standby',
    roomId="qwerty",
    count={
        Gamer=0,
        Spectator=1,
    },
    info={
        name="MrZ's room",
        description="123123123",
        type="normal",
        version='ver A-7',
    },
    capacity=5,
}]]
local function _fetchRoom()
    fetchTimer=10
    NET.room_fetch()
end
local scene={}

function scene.enter()
    BG.set()
    _fetchRoom()
end

function scene.keyDown(key)
    if TASK.getLock('enterRoom') then return true end
    if key=='r' then
        if fetchTimer<=7 then
            _fetchRoom()
        end
    elseif roomList:getLen()>0 and (key=='join' or (key=='return' or key=='kpenter') and love.keyboard.isDown('lctrl','rctrl')) then
        local R=roomList:getSel()
        if R and not TASK.getLock('fetchRoom') then
            if R.info.version==VERSION.room then
                NET.room_enter(R.roomId,not _hidePW() and passwordBox.value or nil)
            else
                MES.new('error',text.versionNotMatch)
            end
        end
    else
        return true
    end
end

function scene.update(dt)
    if not TASK.getLock('fetchRoom') then
        fetchTimer=fetchTimer-dt
        if fetchTimer<=0 and _hidePW() then
            _fetchRoom()
        end
    end
end

function scene.draw()
    -- Fetching timer
    if fetchTimer>0 then
        gc_setColor(1,1,1,.12)
        GC.arc('fill','pie',250,630,40,-1.5708,-1.5708-.6283*fetchTimer)
    end

    -- Room list
    local R=roomList:getSel()
    if R then
        gc_translate(870,220)
        gc_setColor(1,1,1)
        gc_setLineWidth(3)
        gc_rectangle('line',0,0,385,335)
        setFont(25)
        gc_print(R.info.type,10,25)
        gc_setColor(1,1,.7)
        gc_printf(R.info.name,10,0,365)
        setFont(20)
        gc_setColor(COLOR.lH)
        gc_printf(R.info.description or "[No description]",10,55,365)
        if R.start then
            gc_setColor(COLOR.lA)
            gc_print(text.started,10,300)
        end
        gc_setColor(COLOR.lN)
        gc_printf(R.info.version,10,300,365,'right')
        gc_translate(-870,-220)
    end

    -- Profile
    drawSelfProfile()

    -- Player count
    drawOnlinePlayerCount()
end

scene.widgetList={
    roomList,
    passwordBox,
    WIDGET.newKey{name='setting',    x=1200,y=160,w=90,h=90,font=60,fText=CHAR.icon.settings,code=goScene'setting_game'},
    WIDGET.newText{name='refreshing',x=450,y=240,font=45,hideF=function() return not TASK.getLock('fetchRoom') end},
    WIDGET.newText{name='noRoom',    x=450,y=245,font=40,hideF=function() return roomList:getLen()>0 or TASK.getLock('fetchRoom') end},
    WIDGET.newKey{name='refresh',    x=250,y=630,w=140,h=120,code=_fetchRoom,hideF=function() return fetchTimer>7 end},
    WIDGET.newKey{name='new',        x=510,y=630,w=260,h=120,code=goScene('net_newRoom','swipeL')},
    WIDGET.newKey{name='join',       x=780,y=630,w=140,h=120,code=pressKey'join',hideF=function() return roomList:getLen()==0 or TASK.getLock('enterRoom') end},
    WIDGET.newButton{name='back',    x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},
}

return scene
