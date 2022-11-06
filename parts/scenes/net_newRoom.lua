local ROOMENV=ROOMENV

local roomName=WIDGET.newText{name='roomName',       x=40,y=115,align='L'}
local roomNameBox=WIDGET.newInputBox{                x=40,y=160,w=540,h=60,limit=64}
local password=WIDGET.newText{name='password',       x=40,y=255,align='L'}
local passwordBox=WIDGET.newInputBox{                x=40,y=300,w=540,h=60,limit=64}
local description=WIDGET.newText{name='description', x=650,y=55,align='L'}
local descriptionBox=WIDGET.newInputBox{             x=650,y=100,w=550,h=160,font=25,limit=256}

local sList={
    visible={"show","easy","slow","medium","fast","none"},
    freshLimit={0,1,2,4,6,8,10,12,15,30,1e99},
    life={0,1,2,3,5,10,15,26,42,87,500},
    pushSpeed={1,2,3,5,15},
    fieldH={1,2,3,4,6,8,10,15,20,30,50,100},
    heightLimit={2,3,4,6,8,10,15,20,30,40,70,100,150,200,1e99},
    bufferLimit={4,6,10,15,20,40,100,1e99},

    drop={0,.125,.25,.5,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
    lock={0,1,2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,40,60,180,1e99},
    wait={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
    fall={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
    hang={0,1,2,3,4,5,6,7,8,10,15,20,30,60},
    hurry={0,1,2,3,4,5,6,7,8,10,1e99},
    eventSet=EVENTSETS,
    holdMode={'hold','swap'},
}

local scene={}

local function _createRoom()
    if legalGameTime() then
        local pw=passwordBox.value
        if pw=="" then pw=nil end
        local roomname=STRING.trim(roomNameBox.value)
        if #roomname==0 then
            roomname=(USERS.getUsername(USER.uid) or "Anonymous").."'s room"
        end
        NET.room_create{
            capacity=ROOMENV.capacity,
            info={
                name=roomname,
                type="normal",
                version=VERSION.room,
                description=descriptionBox.value,
            },
            data=ROOMENV,
            password=pw,
        }
    end
end

function scene.enter()
    sure=0
    destroyPlayers()
end
function scene.leave()
    BGM.play()
end

scene.widgetScrollHeight=400
scene.widgetList={
    WIDGET.newText{name='title',x=40,y=15,font=70,align='L'},

    -- Room name/password/description
    roomName,
    roomNameBox,
    password,
    passwordBox,
    description,
    descriptionBox,

    -- Selectors
    WIDGET.newSelector{name='life',         x=170,y=410,w=260,color='R',list=sList.life,           disp=ROOMval('life'),         code=ROOMsto('life')},
    WIDGET.newSelector{name='pushSpeed',    x=170,y=520,w=260,color='V',list=sList.pushSpeed,      disp=ROOMval('pushSpeed'),    code=ROOMsto('pushSpeed')},
    WIDGET.newSelector{name='garbageSpeed', x=170,y=600,w=260,color='V',list=sList.pushSpeed,      disp=ROOMval('garbageSpeed'), code=ROOMsto('garbageSpeed')},
    WIDGET.newSelector{name='visible',      x=170,y=710,w=260,color='lB',list=sList.visible,       disp=ROOMval('visible'),      code=ROOMsto('visible')},
    WIDGET.newSelector{name='freshLimit',   x=170,y=790,w=260,color='lB',list=sList.freshLimit,    disp=ROOMval('freshLimit'),   code=ROOMsto('freshLimit')},

    WIDGET.newSelector{name='fieldH',       x=450,y=600,w=260,color='N',list=sList.fieldH,         disp=ROOMval('fieldH'),       code=ROOMsto('fieldH')},
    WIDGET.newSelector{name='heightLimit',  x=450,y=710,w=260,color='S',list=sList.heightLimit,    disp=ROOMval('heightLimit'),  code=ROOMsto('heightLimit')},
    WIDGET.newSelector{name='bufferLimit',  x=450,y=790,w=260,color='B',list=sList.bufferLimit,    disp=ROOMval('bufferLimit'),  code=ROOMsto('bufferLimit')},

    WIDGET.newSelector{name='drop',         x=730,y=330,w=260,color='O',list=sList.drop,disp=ROOMval('drop'),code=ROOMsto('drop')},
    WIDGET.newSelector{name='lock',         x=730,y=410,w=260,color='O',list=sList.lock,disp=ROOMval('lock'),code=ROOMsto('lock')},
    WIDGET.newSelector{name='wait',         x=730,y=520,w=260,color='G',list=sList.wait,disp=ROOMval('wait'),code=ROOMsto('wait')},
    WIDGET.newSelector{name='fall',         x=730,y=600,w=260,color='G',list=sList.fall,disp=ROOMval('fall'),code=ROOMsto('fall')},
    WIDGET.newSelector{name='hurry',        x=730,y=680,w=260,color='G',list=sList.hurry,disp=ROOMval('hurry'),code=ROOMval('hurry')},
    WIDGET.newSelector{name='hang',         x=730,y=760,w=260,color='G',list=sList.hang,disp=ROOMval('hang'),code=ROOMval('hang')},

    -- Capacity & Create & Back
    WIDGET.newSelector{name='capacity',     x=1070,y=330,w=310,color='lY',list={2,3,4,5,7,10,17,31,49,99},disp=ROOMval('capacity'),code=ROOMsto('capacity')},
    WIDGET.newButton{name='create',         x=1070,y=480,w=310,h=140,color='lN',font=40,code=_createRoom},
    WIDGET.newButton{name='back',           x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},

    -- Special rules
    WIDGET.newSwitch{name='ospin',          x=850, y=850, lim=210,disp=ROOMval('ospin'),    code=ROOMrev('ospin')},
    WIDGET.newSwitch{name='fineKill',       x=850, y=910, lim=210,disp=ROOMval('fineKill'), code=ROOMrev('fineKill')},
    WIDGET.newSwitch{name='b2bKill',        x=850, y=970, lim=210,disp=ROOMval('b2bKill'),  code=ROOMrev('b2bKill')},
    WIDGET.newSwitch{name='lockout',        x=850, y=1030,lim=210,disp=ROOMval('lockout'),  code=ROOMrev('lockout')},
    WIDGET.newSwitch{name='easyFresh',      x=1170,y=850, lim=250,disp=ROOMval('easyFresh'),code=ROOMrev('easyFresh')},
    WIDGET.newSwitch{name='deepDrop',       x=1170,y=910, lim=250,disp=ROOMval('deepDrop'), code=ROOMrev('deepDrop')},
    WIDGET.newSwitch{name='bone',           x=1170,y=970, lim=250,disp=ROOMval('bone'),     code=ROOMrev('bone')},

    -- Rule set
    WIDGET.newSelector{name='eventSet',     x=1050,y=760,w=340,color='H',list=sList.eventSet,disp=ROOMval('eventSet'),code=ROOMval('eventSet')},

    -- Next & Hold
    WIDGET.newSelector{name='holdMode',     x=310, y=890, w=300,color='lY',list=sList.holdMode,disp=ROOMval('holdMode'),code=ROOMval('holdMode'),hideF=function() return CUSTOMENV.holdCount==0 end},
    WIDGET.newSlider{name='nextCount',      x=140, y=960, lim=130,w=200,axis={0,6,1},disp=ROOMval('nextCount'),code=ROOMsto('nextCount')},
    WIDGET.newSlider{name='holdCount',      x=140, y=1030,lim=130,w=200,axis={0,6,1},disp=ROOMval('holdCount'),code=ROOMsto('holdCount')},
    WIDGET.newSwitch{name='infHold',        x=560, y=960, lim=200,                   disp=ROOMval('infHold'),code=ROOMrev('infHold'),hideF=function() return ROOMENV.holdCount==0 end},
    WIDGET.newSwitch{name='phyHold',        x=560, y=1030,lim=200,                   disp=ROOMval('phyHold'),code=ROOMrev('phyHold'),hideF=function() return ROOMENV.holdCount==0 end},
}

return scene
