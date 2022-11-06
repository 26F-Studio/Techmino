local gc=love.graphics
local kb=love.keyboard

local keySounds={
    ['1']='C5',['2']='D5',['3']='E5',
    ['4']='F5',['5']='G5',['6']='A5',
    ['7']='B5',['8']='C6',['9']='D6',
    ['0']='E6',['.']='F6',['e']='G6',
    ['+']='C#5',['-']='D#5',['*']='F#5',['/']='G#5',
    ['backspace']='A#5',['return']='C#6',
}

local scene={}

local reg-- register
local val-- result value
local sym-- symbol

local function _autoReturn()
    if reg and sym then
        scene.keyDown('calculate')
    else
        reg=false
    end
end

function scene.enter()
    BG.set('none')
    BGM.stop()
    reg,val,sym=false,"0",false
end
function scene.leave()
    BGM.play()
end

scene.mouseDown=NULL
function scene.keyDown(key)
    if kb.isDown('lshift','rshift') then
        if key=='=' then
            scene.keyDown('+')
            return
        elseif kb.isDown('lshift','rshift') and key=='8' then
            scene.keyDown('*')
            return
        end
    elseif key:sub(1,2)=='kp' then
        scene.keyDown(key:sub(3))
        return
    end
    if keySounds[key] then
        Snd('bell',keySounds[key])
    end
    if key=='.' then
        if sym=="=" then
            sym,reg=false,false
            val="0."
        elseif not (val:find(".",nil,true) or val:find("e")) then
            if sym and not reg then
                reg=val
                val="0."
            else
                val=val.."."
            end
        end
    elseif key=='e' then
        if sym=="=" then
            sym,reg=false
            val="0e"
        elseif not val:find("e") then
            val=val.."e"
        end
    elseif key=='backspace' then
        if sym=="=" then
            val=""
        elseif sym then
            sym=false
        else
            val=val:sub(1,-2)
        end
        if val=="" then
            val="0"
        end
    elseif key=='+' then
        _autoReturn()
        sym="+"
    elseif key=='*' then
        _autoReturn()
        sym="*"
    elseif key=='-' then
        _autoReturn()
        sym="-"
    elseif key=='/' then
        _autoReturn()
        sym="/"
    elseif key:byte()>=48 and key:byte()<=57 then
        if sym=="=" then
            val=key
            sym=false
        elseif sym and not reg then
            reg=val
            val=key
        else
            if #val<14 then
                if val=="0" then
                    val=""
                end
                val=val..key
            end
        end
    elseif key=='return' or key=='kpenter' then
        scene.keyDown('calculate')
    elseif key=='calculate' then
        val=val:gsub("e$","")
        if sym and reg then
            reg=reg:gsub("e$","")
            val=
                sym=="+" and tostring((tonumber(reg) or 0)+tonumber(val)) or
                sym=="-" and tostring((tonumber(reg) or 0)-tonumber(val)) or
                sym=="*" and tostring((tonumber(reg) or 0)*tonumber(val)) or
                sym=="/" and tostring((tonumber(reg) or 0)/tonumber(val)) or
                "-1"
        end
        sym="="
        reg=false
    elseif key=='escape' then
        if val~="0" then
            reg,sym=false,false
            val="0"
        else
            SCN.back()
        end
    elseif key=='delete' then
        val="0"
    end
end

function scene.draw()
    gc.setColor(COLOR.dX)
    gc.rectangle('fill',100,80,650,150,5)
    gc.setColor(COLOR.Z)
    gc.setLineWidth(2)
    gc.rectangle('line',100,80,650,150,5)
    FONT.set(45)
    if reg then gc.printf(reg,0,100,720,'right') end
    if val then gc.printf(val,0,150,720,'right') end
    if sym then FONT.set(50)gc.print(sym,126,150) end
end

scene.widgetList={
    WIDGET.newKey{name='_1',x=145,y=300,w=90,sound=false,fText="1",font=50,code=pressKey'1'},
    WIDGET.newKey{name='_2',x=245,y=300,w=90,sound=false,fText="2",font=50,code=pressKey'2'},
    WIDGET.newKey{name='_3',x=345,y=300,w=90,sound=false,fText="3",font=50,code=pressKey'3'},
    WIDGET.newKey{name='_4',x=145,y=400,w=90,sound=false,fText="4",font=50,code=pressKey'4'},
    WIDGET.newKey{name='_5',x=245,y=400,w=90,sound=false,fText="5",font=50,code=pressKey'5'},
    WIDGET.newKey{name='_6',x=345,y=400,w=90,sound=false,fText="6",font=50,code=pressKey'6'},
    WIDGET.newKey{name='_7',x=145,y=500,w=90,sound=false,fText="7",font=50,code=pressKey'7'},
    WIDGET.newKey{name='_8',x=245,y=500,w=90,sound=false,fText="8",font=50,code=pressKey'8'},
    WIDGET.newKey{name='_9',x=345,y=500,w=90,sound=false,fText="9",font=50,code=pressKey'9'},
    WIDGET.newKey{name='_0',x=145,y=600,w=90,sound=false,fText="0",font=50,code=pressKey'0'},
    WIDGET.newKey{name='.',x=245,y=600,w=90,sound=false,fText=".",color='lM',font=50,code=pressKey'.'},
    WIDGET.newKey{name='e',x=345,y=600,w=90,sound=false,fText="e",color='lM',font=50,code=pressKey'e'},
    WIDGET.newKey{name='+',x=445,y=300,w=90,sound=false,fText="+",color='lB',font=50,code=pressKey'+'},
    WIDGET.newKey{name='-',x=445,y=400,w=90,sound=false,fText="-",color='lB',font=50,code=pressKey'-'},
    WIDGET.newKey{name='*',x=445,y=500,w=90,sound=false,fText="*",color='lB',font=50,code=pressKey'*'},
    WIDGET.newKey{name='/',x=445,y=600,w=90,sound=false,fText="/",color='lB',font=50,code=pressKey'/'},
    WIDGET.newKey{name='<',x=545,y=300,w=90,sound=false,fText=CHAR.key.backspace,color='lR',font=50,code=pressKey'backspace'},
    WIDGET.newKey{name='=',x=545,y=400,w=90,sound=false,fText="=",color='lY',font=50,code=pressKey'return'},
    WIDGET.newKey{name='back',x=1135,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
