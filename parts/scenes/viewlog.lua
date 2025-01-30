local fullLog,currentLogID
local logTimestampList={}
local currentLogText={}
local colorBarWidth=0

local gc=love.graphics
local min,max=math.min,math.max
local scene={}

local textBox=WIDGET.newTextBox {x= 30,y= 45,w=1000,h=540,font=25,fix=true}
local logList=WIDGET.newSelector{x=305,y=640,w= 550,name='list',color='O',fText='Crash log',list={''},disp=function() return currentLogText[1] or '' end,code=function() end}

local function updateText(noLogFound)
    if noLogFound then
        textBox:setTexts{"Techmino is fun!", "It's good to know that there is nothing to read here! :)"}
    else
        currentLogText=fullLog[currentLogID]:split('\n')
        do
            local _,wt=getFont(25):getWrap(fullLog[currentLogID],975)
            textBox:setTexts(wt)
        end
        logList.select=currentLogID
        logList.selText=currentLogText[1]
        colorBarWidth=(currentLogID-1)/(#fullLog-1)*170+1055 -- 170 is the width of full color bar, 1055 is the X of the beginning of the bar
    end
end

local function noLogFound()
    currentLogID=nil
    local _w=scene.widgetList
    _w.home.hide=true;_w.list.hide=true
    _w.endd.hide=true;_w.del .hide=true
    _w.copy.hide=true;_w.delA.hide=true

    logList.list={''}
    logList.select=false
    updateText(true)
end

local function logFound()
    local _w=scene.widgetList
    _w.home.hide=false;_w.list.hide=false
    _w.endd.hide=false;_w.del .hide=false
    _w.copy.hide=false;_w.delA.hide=false

    logList.list=logTimestampList
    logList.select=false

    logList:reset()
end

function scene.enter()
    logList.code=function(_,s)
        scene.keyDown(s>currentLogID and 'right' or 'left')
        updateText()
    end

    fullLog=FILE.load('/conf/error.log','-string -canskip') or '/conf/error.log not found'

    if fullLog=='/conf/error.log not found' then noLogFound()
    else
        -- Fix data first (there maybe a duplicate 'Traceback' word)
        fullLog=table.concat(fullLog:split('\n\nTraceback'),'\nTraceback'):split('\n\n')

        -- Get timestamps and add into logTimeList for the selector
        TABLE.reverse(fullLog)
        for i,d in pairs(fullLog) do logTimestampList[i]=d:split('\n')[1] end

        currentLogID=1
        updateText()
        logFound()
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
                local temp1=TABLE.sub(TABLE.copy(fullLog),1,25)
                local temp2=table.concat(temp1,'\n\n')..'\n\n'
                fullLog=TABLE.copy(temp1)

                logTimestampList=TABLE.sub(logTimestampList,1,25)
                currentLogID=min(logList.select,25)
                logList.select=currentLogID
                logList.list=logTimestampList
                updateText()

                TASK.removeTask_code(task_redButton)
                FILE.save(temp2,'/conf/error.log','-string')
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
            SCN.swapTo('viewlog','none')
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
    if not currentLogID then return end

    setFont(40)
    gc.printf(currentLogID..'\n'..#fullLog,1055,400,170,'right')
    gc.setColor(1,1,1,0.8)
    gc.setLineWidth(3)
    gc.line(1055,450,1225,450)
    gc.setColor(COLOR.cyan)
    gc.line(1055,450,colorBarWidth,450)
end

scene.widgetList={
    textBox,
    WIDGET.newButton  {name='home',x=1140,y= 90,w=170,h=80,sound='click',font=60,fText=CHAR.key.macHome,code=pressKey('home')},
    WIDGET.newButton  {name='endd',x=1140,y=190,w=170,h=80,sound='click',font=60,fText=CHAR.key.macEnd ,code=pressKey('end')},
    WIDGET.newButton  {name='copy',x=1140,y=290,w=170,h=80,sound='click',font=60,fText=CHAR.icon.copy  ,code=function()CLIPBOARD.set(table.concat(textBox.texts,'\n'))end,color='lC'},

    logList,

    WIDGET.newKey     {name='del' ,x= 710,y=640,w=200,h=80,sound=false,  font=30,fText='Clear old'  ,color='dY',code=deleteOld},
    WIDGET.newKey     {name='delA',x= 930,y=640,w=200,h=80,sound=false,  font=30,fText='DELETE ALL!',color='dR',code=deleteAll},

    WIDGET.newButton  {name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}
return scene