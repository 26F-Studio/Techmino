local gc=love.graphics
local gc_translate=gc.translate
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw=gc.draw
local gc_rectangle,gc_arc=gc.rectangle,gc.arc
local gc_print,gc_printf=gc.print,gc.printf


local NET=NET
local fetchTimer

local roomList=WIDGET.newListBox{name='roomList',x=50,y=50,w=800,h=440,lineH=40,drawF=function(item,id,ifSel)
    setFont(35)
    if ifSel then
        gc_setColor(1,1,1,.3)
        gc_rectangle('fill',0,0,800,40)
    end
    gc_setColor(1,1,1)
    if item.private then
        gc_draw(IMG.lock,10,5)
    end
    gc_print(item.count.."/"..item.capacity,670,-4)

    gc_setColor(.9,.9,1)
    gc_print(id,45,-4)

    if item.start then
        gc_setColor(.1,.5,.2)
    else
        gc_setColor(1,1,.7)
    end
    gc_print(item.roomInfo.name,200,-4)
end}
local function _hidePW()
    local R=roomList:getSel()
    return not R or not R.private
end
local passwordBox=WIDGET.newInputBox{name='password',x=350,y=505,w=500,h=50,secret=true,hideF=_hidePW,limit=64}

--[[roomList[n]={
    rid="qwerty",
    roomInfo={
        name="MrZ's room",
        type="classic",
        version=1409,
    },
    private=false,
    start=false,
    count=4,
    capacity=5,
}]]
local function _fetchRoom()
    fetchTimer=10
    NET.room.fetch()
end
local scene={}

function scene.sceneInit()
    BG.set()
    _fetchRoom()
end

function scene.keyDown(key)
    if TASK.getLock('enterRoom')then return true end
    if key=='r'then
        if fetchTimer<=7 then
            _fetchRoom()
        end
    elseif roomList:getLen()>0 and(key=='join'or key=='return'and love.keyboard.isDown('lctrl','rctrl'))then
        local R=roomList:getSel()
        if TASK.getLock('fetchRoom')or not R then return end
        if R.roomInfo.version==VERSION.room then
            NET.room.enter(R,passwordBox.value)
        else
            MES.new('error',text.versionNotMatch)
        end
    else
        return true
    end
end

function scene.update(dt)
    if not TASK.getLock('fetchRoom')and _hidePW()then
        fetchTimer=fetchTimer-dt
        if fetchTimer<=0 then
            _fetchRoom()
        end
    end
end

function scene.draw()
    --Fetching timer
    gc_setColor(1,1,1,.12)
    gc_arc('fill','pie',250,630,40,-1.5708,-1.5708-.6283*fetchTimer)

    --Joining mark
    if TASK.getLock('enterRoom')then
        gc.setColor(COLOR.Z)
        gc.setLineWidth(15)
        local t=TIME()*6.26%6.2832
        gc.arc('line','open',640,360,80,t,t+4.26)
    end

    --Room list
    local R=roomList:getSel()
    if R then
        gc_translate(870,220)
        gc_setColor(1,1,1)
        gc_setLineWidth(3)
        gc_rectangle('line',0,0,385,335)
        setFont(25)
        gc_print(R.roomInfo.type,10,25)
        gc_setColor(1,1,.7)
        gc_printf(R.roomInfo.name,10,0,365)
        setFont(20)
        gc_setColor(COLOR.lH)
        gc_printf(R.roomInfo.description or"[No description]",10,55,365)
        if R.start then
            gc_setColor(COLOR.lA)
            gc_print(text.started,10,300)
        end
        gc_setColor(COLOR.lN)
        gc_printf(R.roomInfo.version,10,300,365,'right')
        gc_translate(-870,-220)
    end

    --Profile
    drawSelfProfile()

    --Player count
    drawOnlinePlayerCount()
end

scene.widgetList={
    roomList,
    passwordBox,
    WIDGET.newKey{name='setting',    x=1200,y=160,w=90,h=90,font=60,fText=CHAR.icon.settings,code=goScene'setting_game'},
    WIDGET.newText{name='refreshing',x=450,y=240,font=45,hideF=function()return not TASK.getLock('fetchRoom')end},
    WIDGET.newText{name='noRoom',    x=450,y=245,font=40,hideF=function()return roomList:getLen()>0 or TASK.getLock('fetchRoom')end},
    WIDGET.newKey{name='refresh',    x=250,y=630,w=140,h=120,code=_fetchRoom,hideF=function()return fetchTimer>7 end},
    WIDGET.newKey{name='new',        x=510,y=630,w=260,h=120,code=goScene'net_newRoom'},
    WIDGET.newKey{name='join',       x=780,y=630,w=140,h=120,code=pressKey'join',hideF=function()return roomList:getLen()==0 or TASK.getLock('enterRoom')end},
    WIDGET.newButton{name='back',    x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},
}

return scene
