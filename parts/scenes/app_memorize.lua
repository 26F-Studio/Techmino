local gc=love.graphics

local state-- 0=playing, 1=gameover
local timeUsed
local level
local showNum
local showTime
local input
local inputTime

local scene={}

local function newNum(lv)
    local num=""
    for _=1,4+lv^.66 do num=num..math.random(0,9) end
    return num
end

local function freshLevel()
    showNum=newNum(level)
    showTime=math.max(4-level,0)+#showNum*math.max(.5-#showNum*.01,.3)
    inputTime=2+#showNum*math.max(1-#showNum*.01,.626)
    input=''
end
local function _reset()
    state=0
    timeUsed=0
    level=1
    freshLevel()
end

function scene.enter()
    state=1
    timeUsed=0
    level=0
    input=''
    showNum='memoriZe'
    BGM.play('reason')
end

function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='escape' then
        if tryBack() then
            SCN.back()
        end
    elseif key=='r' then
        _reset()
    elseif state==0 then
        if key:sub(1,2)=="kp" then key=key:sub(3) end
        if #key==1 and ("0123456789"):find(key,nil,true) then
            input=input..key
            showTime=math.min(showTime,0)
            if input==showNum then
                level=level+1
                freshLevel()
                SFX.play('reach')
            end
        elseif key=='space' or key=='backspace' then
            input=""
        end
    end
end

function scene.update(dt)
    if state==0 then
        showTime=showTime-dt
        if showTime<=0 then
            timeUsed=timeUsed+dt
            inputTime=inputTime-dt
            if inputTime<=0 then
                inputTime=0
                state=1
                SFX.play('finesseError_long',.6)
            end
        end
    end
end

function scene.draw()
    gc.setColor(COLOR.Z)
    FONT.set(45)
    gc.print(("%.3f"):format(timeUsed),1026,70)

    FONT.set(35)
    GC.mStr("["..level.."]",640,30)

    FONT.set(60)
    GC.mStr(input,640,160)

    if state==0 then
        if showTime<=0 then
            FONT.set(30)
            gc.setColor(1,.7,.7,-3*showTime)
            GC.mStr(("%.1f"):format(inputTime),640,230)
        end
        gc.setColor(1,1,1,showTime/1.26)
    else
        gc.setColor(1,.4,.4)
    end
    if #showNum<=10 then
        FONT.set(100)
        GC.mStr(showNum,640,60)
    else
        FONT.set(60)
        GC.mStr(showNum,640,90)
    end
end

scene.widgetList={
    WIDGET.newButton{name='reset',x=155,y=100,w=180,h=100,color='lG',font=50,fText=CHAR.icon.retry_spin,code=pressKey'r'},
    WIDGET.newKey{name='X',x=540,y=620,w=90,font=60,fText=CHAR.key.clear,code=pressKey'backspace'},
    WIDGET.newKey{name='0',x=640,y=620,w=90,font=60,fText="0",code=pressKey'0'},
    WIDGET.newKey{name='1',x=540,y=520,w=90,font=60,fText="1",code=pressKey'1'},
    WIDGET.newKey{name='2',x=640,y=520,w=90,font=60,fText="2",code=pressKey'2'},
    WIDGET.newKey{name='3',x=740,y=520,w=90,font=60,fText="3",code=pressKey'3'},
    WIDGET.newKey{name='4',x=540,y=420,w=90,font=60,fText="4",code=pressKey'4'},
    WIDGET.newKey{name='5',x=640,y=420,w=90,font=60,fText="5",code=pressKey'5'},
    WIDGET.newKey{name='6',x=740,y=420,w=90,font=60,fText="6",code=pressKey'6'},
    WIDGET.newKey{name='7',x=540,y=320,w=90,font=60,fText="7",code=pressKey'7'},
    WIDGET.newKey{name='8',x=640,y=320,w=90,font=60,fText="8",code=pressKey'8'},
    WIDGET.newKey{name='9',x=740,y=320,w=90,font=60,fText="9",code=pressKey'9'},
    WIDGET.newButton{name='back',x=1200,y=660,w=110,h=60,font=45,sound='back',fText=CHAR.icon.back,code=backScene},
}

return scene
