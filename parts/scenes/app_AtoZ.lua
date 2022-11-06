local gc=love.graphics
local rnd=math.random

local levels={
    A_Z="ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    Z_A="ZYXWVUTSRQPONMLKJIHGFEDCBA",
    Tech1="TECHMINOHAOWAN",
    Tech2="TECHMINOISFUN",
    KeyTest1="THEQUICKBROWNFOXJUMPSOVERALAZYDOG",
    KeyTest2="THEFIVEBOXINGWIZARDSJUMPQUICKLY",
    Hello="HELLOWORLD",
    Roll1="QWERTYUIOPASDFGHJKLZXCVBNM",
    Roll2="QAZWSXEDCRFVTGBYHNUJMIKOLP",
    Roll3="ZAQWSXCDERFVBGTYHNMJUIKLOP",
    ZZZ="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ",
    ZXZX="ZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZXZX",
    ZMZM="ZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZMZM",
    Stair="ZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCVZXCV",
    Stair2="ZXCVCXZXCVCXZXCVCXZXCVCXZXCVCXZXCVCXZXCVCXZXCVCXZXCVCXZXCVCXZXCV",
    Stair3="XZCVXZCVXZCVXZCVXZCVXZCVXZCVXZCVXZCVXZCVXZCVXZCVXZCVXZCVXZCVXZCV",
    BPW="OHOOOOOOOOOAAAAEAAIAUJOOOOOOOOOOOAAEOAAUUAEEEEEEEEEAAAAEAEIEAJOOOOOOOOOOEEEEOAAAAAAA",
}

local scene={}

local levelName="A_Z"
local targetString
local startTime,time
local state,progress
local frameKeyCount,mistake

function scene.enter()
    BG.set('bg2')
    BGM.play('way')
    levelName="A_Z"
    targetString=levels.A_Z
    progress=1
    frameKeyCount=0
    mistake=0
    startTime=0
    time=0
    state=0
end

function scene.keyDown(key,isRep)
    if isRep then return end
    if #key==1 then
        if state<2 and frameKeyCount<3 then
            if key:upper():byte()==targetString:byte(progress) then
                progress=progress+1
                frameKeyCount=frameKeyCount+1
                TEXT.show(key:upper(),rnd(320,960),rnd(100,240),90,'score',2.6)
                SFX.play('touch')
                if progress==2 then
                    state=1
                    startTime=TIME()
                elseif progress>#targetString then
                    time=TIME()-startTime
                    state=2
                    SFX.play('reach')
                end
            elseif progress>1 then
                mistake=mistake+1
                SFX.play('finesseError')
            end
        end
    elseif key=='left' or key=='right' then
        if state==0 then
            scene.widgetList.level:scroll(key=='left' and -1 or 1)
        end
    elseif key=='space' then
        progress=1
        mistake=0
        time=0
        state=0
    elseif key=='escape' then
        SCN.back()
    end
end

function scene.update()
    if state==1 then
        frameKeyCount=0
        time=TIME()-startTime
    end
end

function scene.draw()
    FONT.set(40)
    gc.setColor(COLOR.Z)
    gc.print(("%.3f"):format(time),1026,80)
    gc.print(mistake,1026,150)

    if state>0 then
        gc.print(("%.3f/s"):format((progress-1)/time),1026,220)
    end

    if state==2 then
        gc.setColor(.9,.9,0)-- win
    elseif state==1 then
        gc.setColor(.9,.9,.9)-- game
    elseif state==0 then
        gc.setColor(.2,.8,.2)-- ready
    end

    FONT.set(100)
    GC.mStr(state==1 and #targetString-progress+1 or state==0 and "Ready" or state==2 and "Win",640,200)

    gc.setColor(COLOR.Z)
    gc.print(targetString:sub(progress,progress),120,280,0,2)
    gc.print(targetString:sub(progress+1),310,380)

    gc.setColor(1,1,1,.7)
    FONT.set(40)
    gc.print(targetString,120,520)
end

scene.widgetList={
    WIDGET.newSelector{name='level', x=640,y=640,w=200,list={'A_Z','Z_A','Tech1','Tech2','KeyTest1','KeyTest2','Hello','Roll1','Roll2','Roll3','ZZZ','ZXZX','ZMZM','Stair','Stair2','Stair3','BPW'},disp=function() return levelName end,code=function(i) levelName=i; targetString=levels[i] end,hideF=function() return state>0 end},
    WIDGET.newButton{name='reset',   x=160,y=100,w=180,h=100,color='lG',font=50,fText=CHAR.icon.retry_spin,code=pressKey'space'},
    WIDGET.newButton{name='keyboard',x=160,y=210,w=180,h=100,code=function() love.keyboard.setTextInput(true,0,select(2,SCR.xOy:transformPoint(0,500)),1,1) end,hide=not MOBILE},
    WIDGET.newButton{name='back',    x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
