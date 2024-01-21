local fullLog,currentLogID
local logTimeList={}
local currentLogText={}

local gc=love.graphics
local min,max=math.min,math.max
local scene={}

local textBox=WIDGET.newTextBox {x= 30,y= 45,w=1000,h=540,font=25,fix=true}
local logList=WIDGET.newSelector{x=305,y=640,w= 550,name='list',color='O',fText='Crash log',list={''},disp=function() return '' end,code=function() end}

local function updateText()
    currentLogText=fullLog[currentLogID]:split('\n')
    do
        local _,wt=getFont(25):getWrap(fullLog[currentLogID],975)
        textBox:setTexts(wt)
    end
    logList.select=currentLogID
    logList.selText=currentLogText[1]
end

local function noLogFound()
    local _w=scene.widgetList
    _w.home.hide=true;_w.list.hide=true
    _w.endd.hide=true;_w.del .hide=true
    _w.copy.hide=true;_w.delA.hide=true

    logList.list={''}
    logList.select=false
    logList.disp=function() return '' end
    logList.code=function() end
    logList:reset()
end

function scene.enter()
    fullLog=FILE.load('/conf/error.log','-string -canskip') or '/conf/error.log not found'

    if fullLog=='/conf/error.log not found' then noLogFound()
    else
        -- Fix data first
        fullLog=table.concat(fullLog:split('\n\nTraceback'),'\nTraceback'):split('\n\n')

        -- Get timestamps and add into logTimeList for the selector
        TABLE.reverse(fullLog)
        for i,d in pairs(fullLog) do logTimeList[i]=d:split('\n')[1] end

        currentLogID=1
        updateText()

        local _w=scene.widgetList
        _w.home.hide=false;_w.list.hide=false
        _w.endd.hide=false;_w.del .hide=false
        _w.copy.hide=false;_w.delA.hide=false

        logList.list=logTimeList
        logList.select=false
        logList.disp=function() return currentLogText[1] end
        logList.code=function(_,s)
            if s>currentLogID
            then scene.keyDown('right')
            else scene.keyDown('left') end
            updateText()
        end
        logList:reset()
    end
end
local deleteOld,deleteAll
do
    local sureTime=-1e99
    function deleteOld()
        local function task_redButton()
            scene.widgetList.del.color=COLOR.Y
            for _=1,120 do coroutine.yield() end
            scene.widgetList.del.color=COLOR.dY
        end

        if TIME()-sureTime<1 then
            sureTime=-1e99
            scene.widgetList.del.color=COLOR.dY
            do
                local temp=TABLE.sub(TABLE.copy(fullLog),1,25)
                fullLog=TABLE.copy(temp)
                temp=table.concat(temp,'\n\n')..'\n\n'

                logTimeList=TABLE.sub(logTimeList,1,25)
                currentLogID=min(logList.select,25)
                logList.select=currentLogID
                logList.list=logTimeList
                updateText()

                TASK.removeTask_code(task_redButton)
                FILE.save(temp,'/conf/error.log','-string')
            end
        else
            sureTime=TIME()
            MES.new('warn',text.sureDelete)
            TASK.removeTask_code(task_redButton)
            TASK.new(task_redButton)
        end
    end
end
do
    local sureTime=-1e99
    function deleteAll()
        local function task_redButton()
            scene.widgetList.delA.color=COLOR.R
            for _=1,120 do coroutine.yield() end
            scene.widgetList.delA.color=COLOR.dR
        end

        if TIME()-sureTime<1 then
            sureTime=-1e99
            scene.widgetList.delA.color=COLOR.dR
            love.filesystem.remove('/conf/error.log')

            noLogFound()
            TASK.removeTask_code(task_redButton)
            SCN.swapTo('viewLog','none')
        else
            sureTime=TIME()
            MES.new('warn',text.sureDelete)
            TASK.removeTask_code(task_redButton)
            TASK.new(task_redButton)
        end
    end
end

function scene.wheelMoved(_,y)
    WHEELMOV(y)
end

function scene.keyDown(key)
    if     key=='left' then
        currentLogID=math.max(1,currentLogID-1)
        updateText()
    elseif key=='right' then
        currentLogID=math.min(currentLogID+1,#fullLog)
        updateText()
    elseif key=='home' then
        currentLogID=1
        updateText()
    elseif key=='end' then
        currentLogID=#fullLog
        updateText()
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
    gc.print(currentLogID..' / '..#fullLog,1000,800)
end

scene.widgetList={
    textBox,
    WIDGET.newButton  {name='home',x=1140,y= 90,w=170,h=80,sound='click',font=60,fText=CHAR.key.macHome,code=pressKey('home')},
    WIDGET.newButton  {name='endd',x=1140,y=190,w=170,h=80,sound='click',font=60,fText=CHAR.key.macEnd ,code=pressKey('end')},
    WIDGET.newButton  {name='copy',x=1140,y=290,w=170,h=80,sound='click',font=60,fText=CHAR.icon.copy  ,code=function()love.system.setClipboardText(table.concat(textBox.texts,'\n'))end,color='lC'},

    logList,

    WIDGET.newKey     {name='del' ,x= 710,y=640,w=200,h=80,sound=false,  font=30,fText='Clear old'  ,color='dY',code=deleteOld},
    WIDGET.newKey     {name='delA',x= 930,y=640,w=200,h=80,sound=false,  font=30,fText='DELETE ALL!',color='dR',code=deleteAll},

    WIDGET.newButton  {name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}
return scene