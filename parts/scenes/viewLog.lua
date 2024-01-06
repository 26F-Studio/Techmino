local fullLog,currentLog

local gc=love.graphics
local scene={}
local textBox=WIDGET.newTextBox{name='texts',x=30,y=45,w=1000,h=540,font=20,fix=true}

function scene.enter()
    fullLog=(FILE.load('/conf/error.log','-string -canskip') or '/conf/error.log not found'):split('\n\n')
    TABLE.reverse(fullLog)

    currentLog=1
    textBox:setTexts(fullLog[1]:split('\n'))

    if fullLog[1]=='/conf/error.log not found' then
        local _w=scene.widgetList
        _w.del .hide=true
        _w.delA.hide=true
        _w.next.hide=true
        _w.prev.hide=true
        _w.home.hide=true
        _w.endd.hide=true
        textBox.font=25
        textBox:reset()
    else
        textBox.font=15
        textBox:reset()
    end
end

local sureTime=-1e99
local function deleteAllExcludeLast10()
    local function task_redButton()
        scene.widgetList.del.color=COLOR.R
        for _=1,120 do coroutine.yield() end
        scene.widgetList.del.color=COLOR.Z
    end

    if TIME()-sureTime<1 then
        sureTime=-1e99
        scene.widgetList.del.color=COLOR.Z
        do
            local temp=TABLE.sub(TABLE.copy(fullLog),1,10)
            fullLog=TABLE.copy(temp)
            temp=table.concat(temp,'\n\n')..'\n\n'
            FILE.save(temp,'/conf/error.log','-string')
            scene.keyDown('home')
            TASK.removeTask_code(task_redButton)
        end
    else
        sureTime=TIME()
        MES.new('warn',text.sureDelete)
        TASK.removeTask_code(task_redButton)
        TASK.new(task_redButton)
    end
end
local function deleteAll()
    local function task_redButton()
        scene.widgetList.delA.color=COLOR.R
        for _=1,120 do coroutine.yield() end
        scene.widgetList.delA.color=COLOR.Z
    end

    if TIME()-sureTime<1 then
        sureTime=-1e99
        scene.widgetList.delA.color=COLOR.Z
        love.filesystem.remove('/conf/error.log')
        TASK.removeTask_code(task_redButton)
        SCN.swapTo('viewLog','none')
    else
        sureTime=TIME()
        MES.new('warn',text.sureDelete)
        TASK.removeTask_code(task_redButton)
        TASK.new(task_redButton)
    end
end

function scene.wheelMoved(_,y)
    WHEELMOV(y)
end

function scene.keyDown(key)
    if     key=='left' then
        currentLog=math.max(1,currentLog-1)
        textBox:setTexts(fullLog[currentLog]:split('\n'))
    elseif key=='right' then
        currentLog=math.min(currentLog+1,#fullLog)
        textBox:setTexts(fullLog[currentLog]:split('\n'))
    elseif key=='home' then
        currentLog=1
        textBox:setTexts(fullLog[1]:split('\n'))
    elseif key=='end' then
        currentLog=#fullLog
        textBox:setTexts(fullLog[#fullLog]:split('\n'))
    elseif key=='up' then
        textBox:scroll(-5)
    elseif key=='down' then
        textBox:scroll(5)
    elseif key=='pageup' then
        textBox:scroll(-20)
    elseif key=='pagedown' then
        textBox:scroll(20)
    elseif key=='escape' then
        SCN.back()
    end
end

function scene.draw()
    setFont(40)
    gc.print(currentLog..' / '..#fullLog,1000,800)
end

scene.widgetList={
    textBox,
    WIDGET.newButton{name='prev',x=1140,y= 90,w=170,h=80,sound='click',font=60,fText=CHAR.key.left   ,code=pressKey('left')},
    WIDGET.newButton{name='next',x=1140,y=190,w=170,h=80,sound='click',font=60,fText=CHAR.key.right  ,code=pressKey('right')},
    WIDGET.newButton{name='home',x=1140,y=290,w=170,h=80,sound='click',font=60,fText=CHAR.key.macHome,code=pressKey('home')},
    WIDGET.newButton{name='endd',x=1140,y=390,w=170,h=80,sound='click',font=60,fText=CHAR.key.macEnd ,code=pressKey('end')},

    WIDGET.newKey   {name='del' ,x= 260,y=640,w=450,h=80,sound=false,  font=30,fText='Delete all log exclude last 10',color='Z',code=deleteAllExcludeLast10},
    WIDGET.newKey   {name='delA',x= 620,y=640,w=250,h=80,sound=false,  font=30,fText='DELETE ALL!',color='Z',code=deleteAll},

    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
