local gc,sys=love.graphics,love.system
local kb=love.keyboard

local int,sin=math.floor,math.sin
local ins,rem=table.insert,table.remove

local scene={}

local input-- Input buffer
local cur-- Cursor position

function scene.enter()
    input=""
    cur=#MISSION
end
function scene.leave()
    saveFile(DATA.copyMission(),'conf/customMissions')
end

local ENUM_MISSION=ENUM_MISSION
local legalInput={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,A=true,_=true,P=true}
function scene.keyDown(key)
    if key=='left' then
        local p=cur
        if p==0 then
            cur=#MISSION
        else
            repeat
                p=p-1
            until MISSION[p]~=MISSION[cur]
            cur=p
        end
    elseif key=='right' then
        local p=cur
        if p==#MISSION then
            cur=0
        else
            repeat
                p=p+1
            until MISSION[p+1]~=MISSION[cur+1]
            cur=p
        end
    elseif key=='ten' then
        for _=1,10 do
            local p=cur
            if p==#MISSION then break end
            repeat
                p=p+1
            until MISSION[p+1]~=MISSION[cur+1]
            cur=p
        end
    elseif key=='backspace' then
        if #input>0 then
            input=""
        elseif cur>0 then
            rem(MISSION,cur)
            cur=cur-1
            if cur>0 and MISSION[cur]==MISSION[cur+1] then
                scene.keyDown('right')
            end
        end
    elseif key=='delete' then
        if tryReset() then
            TABLE.cut(MISSION)
            cur=0
            SFX.play('finesseError',.7)
        end
    elseif key=='c' and kb.isDown('lctrl','rctrl') or key=='cC' then
        if #MISSION>0 then
            sys.setClipboardText("Techmino Target:"..DATA.copyMission())
            MES.new('check',text.exportSuccess)
        end
    elseif key=='v' and kb.isDown('lctrl','rctrl') or key=='cV' then
        local str=sys.getClipboardText()
        local p=str:find(":")-- ptr*
        if p then
            if not str:sub(1,p-1):find("Target") then
                MES.new('error',text.pasteWrongPlace)
            end
            str=str:sub(p+1)
        end
        if DATA.pasteMission(str) then
            MES.new('check',text.importSuccess)
            cur=#MISSION
        else
            MES.new('error',text.dataCorrupted)
        end
    elseif key=='escape' then
        SCN.back()
    elseif type(key)=='number' then
        local p=cur+1
        while MISSION[p]==key do p=p+1 end
        ins(MISSION,p,key)
        cur=p
    else
        if key=='space' then
            key="_"
        else
            key=string.upper(key)
        end

        input=input..key
        if ENUM_MISSION[input] then
            cur=cur+1
            ins(MISSION,cur,ENUM_MISSION[input])
            SFX.play('lock')
            input=""
        elseif #input>1 or not legalInput[input] then
            input=""
        end
    end
end

function scene.draw()
    -- Draw frame
    gc.setLineWidth(2)
    gc.setColor(COLOR.Z)
    gc.rectangle('line',58,108,1164,174,5)

    -- Draw inputing target
    setFont(30)
    gc.setColor(.9,.9,.9)
    gc.print(input,1200,275)

    -- Draw targets
    local libColor=BLOCK_COLORS
    local set=SETTING.skin
    local L=MISSION
    local x,y=100,136-- Next block pos
    local cx,cy=100,136-- Cursor-center pos
    local i,j=1,#L
    local count=1
    repeat
        if L[i]==L[i-1] then
            count=count+1
        else
            if count>1 then
                setFont(25)
                gc.setColor(COLOR.Z)
                gc.print("×",x-10,y-14)
                gc.print(count,x+5,y-13)
                x=x+(count<10 and 33 or 45)
                count=1
                if i==cur+1 then
                    cx,cy=x,y
                end
            end
            if x>1140 then
                x,y=100,y+36
                if y>1260 then break end
            end
            if i<=j then
                setFont(35)
                local N=int(L[i]*.1)
                if N>0 then
                    gc.setColor(libColor[set[N]])
                elseif L[i]>4 then
                    gc.setColor(COLOR.rainbow(i+TIME()*6.26))
                else
                    gc.setColor(COLOR.H)
                end
                gc.print(ENUM_MISSION[L[i]],x,y-25)
                x=x+56
            end
        end
        if i==cur then
            cx,cy=x,y
        end
        i=i+1
    until i>j+1

    -- Draw cursor
    gc.setColor(1,1,.4,.6+.4*sin(TIME()*6.26))
    gc.line(cx-5,cy-20,cx-5,cy+20)
end

scene.widgetList={
    WIDGET.newText{name='title',   x=520,y=5,lim=460,font=70,align='R'},
    WIDGET.newText{name='subTitle',x=530,y=50,lim=170,font=35,align='L',color='H'},

    WIDGET.newKey{name='_1',    x=800,y=540,w=90,font=50,code=pressKey(01)},
    WIDGET.newKey{name='_2',    x=900,y=540,w=90,font=50,code=pressKey(02)},
    WIDGET.newKey{name='_3',    x=800,y=640,w=90,font=50,code=pressKey(03)},
    WIDGET.newKey{name='_4',    x=900,y=640,w=90,font=50,code=pressKey(04)},
    WIDGET.newKey{name='any1',  x=100,y=640,w=90,        code=pressKey(05)},
    WIDGET.newKey{name='any2',  x=200,y=640,w=90,        code=pressKey(06)},
    WIDGET.newKey{name='any3',  x=300,y=640,w=90,        code=pressKey(07)},
    WIDGET.newKey{name='any4',  x=400,y=640,w=90,        code=pressKey(08)},
    WIDGET.newKey{name='PC',    x=500,y=640,w=90,font=50,code=pressKey(09)},

    WIDGET.newKey{name='Z1',    x=100,y=340,w=90,font=50,code=pressKey(11)},
    WIDGET.newKey{name='S1',    x=200,y=340,w=90,font=50,code=pressKey(21)},
    WIDGET.newKey{name='J1',    x=300,y=340,w=90,font=50,code=pressKey(31)},
    WIDGET.newKey{name='L1',    x=400,y=340,w=90,font=50,code=pressKey(41)},
    WIDGET.newKey{name='T1',    x=500,y=340,w=90,font=50,code=pressKey(51)},
    WIDGET.newKey{name='O1',    x=600,y=340,w=90,font=50,code=pressKey(61)},
    WIDGET.newKey{name='I1',    x=700,y=340,w=90,font=50,code=pressKey(71)},

    WIDGET.newKey{name='Z2',    x=100,y=440,w=90,font=50,code=pressKey(12)},
    WIDGET.newKey{name='S2',    x=200,y=440,w=90,font=50,code=pressKey(22)},
    WIDGET.newKey{name='J2',    x=300,y=440,w=90,font=50,code=pressKey(32)},
    WIDGET.newKey{name='L2',    x=400,y=440,w=90,font=50,code=pressKey(42)},
    WIDGET.newKey{name='T2',    x=500,y=440,w=90,font=50,code=pressKey(52)},
    WIDGET.newKey{name='O2',    x=600,y=440,w=90,font=50,code=pressKey(62)},
    WIDGET.newKey{name='I2',    x=700,y=440,w=90,font=50,code=pressKey(72)},

    WIDGET.newKey{name='Z3',    x=100,y=540,w=90,font=50,code=pressKey(13)},
    WIDGET.newKey{name='S3',    x=200,y=540,w=90,font=50,code=pressKey(23)},
    WIDGET.newKey{name='J3',    x=300,y=540,w=90,font=50,code=pressKey(33)},
    WIDGET.newKey{name='L3',    x=400,y=540,w=90,font=50,code=pressKey(43)},
    WIDGET.newKey{name='T3',    x=500,y=540,w=90,font=50,code=pressKey(53)},
    WIDGET.newKey{name='O3',    x=600,y=540,w=90,font=50,code=pressKey(63)},
    WIDGET.newKey{name='I3',    x=700,y=540,w=90,font=50,code=pressKey(73)},

    WIDGET.newKey{name='O4',    x=600,y=640,w=90,font=50,code=pressKey(64)},
    WIDGET.newKey{name='I4',    x=700,y=640,w=90,font=50,code=pressKey(74)},

    WIDGET.newKey{name='left',      x=800, y=440,w=90,      color='lG',font=55,code=pressKey'left',     fText=CHAR.key.left},
    WIDGET.newKey{name='right',     x=900, y=440,w=90,      color='lG',font=55,code=pressKey'right',    fText=CHAR.key.right},
    WIDGET.newKey{name='ten',       x=1000,y=440,w=90,      color='lG',font=55,code=pressKey'ten',      fText=CHAR.key.macTab},
    WIDGET.newKey{name='backsp',    x=1000,y=540,w=90,      color='lY',font=55,code=pressKey'backspace',fText=CHAR.key.backspace},
    WIDGET.newKey{name='reset',     x=1000,y=640,w=90,      color='lY',font=50,code=pressKey'delete',   fText=CHAR.icon.trash},
    WIDGET.newButton{name='copy',   x=1140,y=440,w=170,h=80,color='lR',font=50,code=pressKey'cC',       fText=CHAR.icon.export,hideF=function() return #MISSION==0 end},
    WIDGET.newButton{name='paste',  x=1140,y=540,w=170,h=80,color='lB',font=50,code=pressKey'cV',       fText=CHAR.icon.import},
    WIDGET.newSwitch{name='mission',x=1150,y=340,lim=280,disp=CUSval('missionKill'),code=CUSrev('missionKill')},

    WIDGET.newButton{name='back',   x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
