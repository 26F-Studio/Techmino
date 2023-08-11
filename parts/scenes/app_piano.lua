local gc=love.graphics
local kb=love.keyboard
local min,max=math.min,math.max

local instList={'lead','bell','bass'}
local keys={
    ['1']=61,['2']=63,['3']=65,['4']=66,['5']=68,['6']=70,['7']=72,['8']=73,['9']=75,['0']=77,['-']=78,['=']=80,['backspace']=82,
    ['q']=49,['w']=51,['e']=53,['r']=54,['t']=56,['y']=58,['u']=60,['i']=61,['o']=63,['p']=65,['[']=66,[']']=68,['\\']=70,
    ['a']=37,['s']=39,['d']=41,['f']=42,['g']=44,['h']=46,['j']=48,['k']=49,['l']=51,[';']=53,["'"]=54,['return']=56,
    ['z']=25,['x']=27,['c']=29,['v']=30,['b']=32,['n']=34,['m']=36,[',']=37,['.']=39,['/']=41,
}
local lastPlayBGM
local inst
local offset
local showingKey
local sharpt,flattt=false,false

-- PREPARE VIRTUAL KEYS
-- PREPARE VIRTUAL KEYS
-- NOTE: I made this list because I want to use WIDGET.draw() and don't need another function
-- I will handling the behavior in an other function
local virtualKeys={
    -- Number row:  01234567890-=           13
    WIDGET.newKey   {name='key1'        ,x=  75,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'1'        },
    WIDGET.newKey   {name='key2'        ,x= 165,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'2'        },
    WIDGET.newKey   {name='key3'        ,x= 255,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'3'        },
    WIDGET.newKey   {name='key4'        ,x= 345,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'4'        },
    WIDGET.newKey   {name='key5'        ,x= 435,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'5'        },
    WIDGET.newKey   {name='key6'        ,x= 525,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'6'        },
    WIDGET.newKey   {name='key7'        ,x= 615,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'7'        },
    WIDGET.newKey   {name='key8'        ,x= 755,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'8'        },
    WIDGET.newKey   {name='key9'        ,x= 845,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'9'        },
    WIDGET.newKey   {name='key0'        ,x= 935,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'0'        },
    WIDGET.newKey   {name='key-'        ,x=1025,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'-'        },
    WIDGET.newKey   {name='key='        ,x=1115,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'='        },
    WIDGET.newKey   {name='keyBACKSPACE',x=1205,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'backspace'},

    -- Top row:     QWERTYUIOP[]\           13
    WIDGET.newKey   {name='keyQ'        ,x=  75,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'q' },
    WIDGET.newKey   {name='keyW'        ,x= 165,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'w' },
    WIDGET.newKey   {name='keyE'        ,x= 255,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'e' },
    WIDGET.newKey   {name='keyR'        ,x= 345,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'r' },
    WIDGET.newKey   {name='keyT'        ,x= 435,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey't' },
    WIDGET.newKey   {name='keyY'        ,x= 525,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'y' },
    WIDGET.newKey   {name='keyU'        ,x= 615,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'u' },
    WIDGET.newKey   {name='keyI'        ,x= 755,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'i' },
    WIDGET.newKey   {name='keyO'        ,x= 845,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'o' },
    WIDGET.newKey   {name='keyP'        ,x= 935,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'p' },
    WIDGET.newKey   {name='key['        ,x=1025,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'[' },
    WIDGET.newKey   {name='key]'        ,x=1115,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey']' },
    WIDGET.newKey   {name='key\\'       ,x=1205,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'\\'},

    -- Home row     ASDFGHJKL;''<ENTER>     12
    WIDGET.newKey   {name='keyA'        ,x=  75,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='R',code=pressKey'a'     },
    WIDGET.newKey   {name='keyS'        ,x= 165,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='W',code=pressKey's'     },
    WIDGET.newKey   {name='keyD'        ,x= 255,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='P',code=pressKey'd'     },
    WIDGET.newKey   {name='keyF'        ,x= 345,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='N',code=pressKey'f'     },
    WIDGET.newKey   {name='keyG'        ,x= 435,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'g'     },
    WIDGET.newKey   {name='keyH'        ,x= 525,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'h'     },
    WIDGET.newKey   {name='keyJ'        ,x= 615,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='O',code=pressKey'j'     },
    WIDGET.newKey   {name='keyK'        ,x= 755,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='L',code=pressKey'k'     },
    WIDGET.newKey   {name='keyL'        ,x= 845,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='G',code=pressKey'l'     },
    WIDGET.newKey   {name='key;'        ,x= 935,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='C',code=pressKey';'     },
    WIDGET.newKey   {name='key\''       ,x=1025,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'\''    },
    WIDGET.newKey   {name='keyRETURN'   ,x=1115,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'return'},

    -- Bottom row   ZXCVBNM,./              10
    WIDGET.newKey   {name='keyZ'        ,x=  75,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'z'},
    WIDGET.newKey   {name='keyX'        ,x= 165,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'x'},
    WIDGET.newKey   {name='keyC'        ,x= 255,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'c'},
    WIDGET.newKey   {name='keyV'        ,x= 345,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'v'},
    WIDGET.newKey   {name='keyB'        ,x= 435,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'b'},
    WIDGET.newKey   {name='keyN'        ,x= 525,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'n'},
    WIDGET.newKey   {name='keyM'        ,x= 615,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'm'},
    WIDGET.newKey   {name='key,'        ,x= 755,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey','},
    WIDGET.newKey   {name='key.'        ,x= 845,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'.'},
    WIDGET.newKey   {name='key/'        ,x= 935,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=pressKey'/'},

    WIDGET.newKey   {name='keyCtrl'     ,x=1115,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() flattt=not flattt;sharpt=false end},
    WIDGET.newKey   {name='keyShift'    ,x=1205,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() sharpt=not sharpt;flattt=false end},
}
setmetatable(virtualKeys,{__index=function(L,k) for i=1,#L do if L[i].name==k then return L[i] end end end})

-- Set objects text
virtualKeys['keyCtrl'] :setObject(CHAR.key.ctrl )
virtualKeys['keyShift']:setObject(CHAR.key.shift)
-- Overwrite some functions
for k=1,#virtualKeys do
    local K=virtualKeys[k]
    -- Overwrite the update function
    function K:update(activateState)
        local dt=love.timer.getDelta()
        local ATV=self.ATV
        local maxTime=6.2

        self.activateState=ATV<maxTime and (self.activateState or activateState)

        -- When I can emulate holding key
        -- self.activateState=activateState and activateState or not ATV>maxTime and self.activateState end

        if self.activateState then
            if ATV<maxTime then self.ATV=min(ATV+dt*60,maxTime) end
        else
            if ATV>0       then self.ATV=max(ATV-dt*30,0)       end
        end
    end
    -- Remove unnecessary function (reduce memory usage)
    function K:getCenter() end
    function K:getInfo()   end
    function K:drag()      end
    function K:release()   end
end
--/ PREPARE VIRTUAL KEYS
--/ PREPARE VIRTUAL KEYS

local scene={}

-- Set all virtual key's text
local function _setNoteName(offset)
    for k=1,#virtualKeys do
        local K=virtualKeys[k]
        local keyName=string.sub(K.name:lower(),4)
        if keys[keyName] then K:setObject(SFX.getNoteName(keys[keyName]+offset)) end
    end
end
-- Show virtual key
local function _showVirtualKey(switch)
    if switch~=nil then showingKey=switch else showingKey=not showingKey end
    for k=1,#virtualKeys do
        virtualKeys[k].hide=not showingKey
    end
end

local function _holdingCtrl()
    virtualKeys['keyCtrl'].color=COLOR.R
    _setNoteName(offset-1)
end
local function _holdingShift()
    virtualKeys['keyShift'].color=COLOR.R
    _setNoteName(offset+1)
end
local function _notHoldCS()
    virtualKeys['keyCtrl'].color,virtualKeys['keyShift'].color=COLOR.Z,COLOR.Z
    _setNoteName(offset)
end



-- Set scene's variables
function scene.enter()
    inst='lead'
    offset=0
    lastPlayBGM=BGM.getPlaying()[1]
    BGM.stop()
    _setNoteName(0)
    _showVirtualKey(MOBILE and true or false)
    _notHoldCS()
end

function scene.touchDown(x,y,k)
    if showingKey then
        for k=1,#virtualKeys do
            local K=virtualKeys[k]
            if K:isAbove(x,y) then K.code(); K:update(true) end end
        -- Change Shift/Ctrl key's color when shift note temproraily
        if flattt or sharpt then
            if flattt then _holdingCtrl() else _holdingShift() end
        else _notHoldCS() end
    end
end
scene.mouseDown=scene.touchDown

function scene.keyDown(key,isRep)
    if not isRep and keys[key] then
        local note=keys[key]+offset
        if kb.isDown('lshift','rshift') or sharpt then note=note+1 end
        if kb.isDown('lctrl','rctrl')   or flattt then note=note-1 end
        SFX.playSample(inst,note)
        if sharpt or flattt then sharpt,flattt=false,false end
        if showingKey then
            virtualKeys['key'..key:upper()]:update(true)
            TEXT.show(SFX.getNoteName(note),math.random(75,1205),math.random(160,260),60,'score',.8)
        else
            TEXT.show(SFX.getNoteName(note),math.random(75,1205),math.random(160,500),60,'score',.8)
        end
    elseif kb.isDown('lctrl','rctrl')   then _holdingCtrl()
    elseif kb.isDown('lshift','rshift') then _holdingShift()
    elseif key=='tab' then
        inst=TABLE.next(instList,inst)
    elseif key=='lalt' then
        offset=math.max(offset-1,-12)
        if showingKey then _setNoteName(offset) end
    elseif key=='ralt' then
        offset=math.min(offset+1,12)
        if showingKey then _setNoteName(offset) end
    elseif key=='escape' then
        BGM.play(lastPlayBGM)
        SCN.back()
    end
end

function scene.keyUp()
    if not kb.isDown('lctrl','rctrl','lshift','rshift') then _notHoldCS() end
end

function scene.draw()
    setFont(30)
    GC.setColor(1,1,1)
    gc.print(inst.." | "..offset,30,40)
    -- gc.print(offset,40,100)

    -- Drawing virtual keys
    if showingKey then
        for k=1,#virtualKeys do
            virtualKeys[k]:draw()
        end
        gc.setLineWidth(1)
        gc.setColor(COLOR.Z)
        gc.line(685.5,297,685.5,642)
    end
end

function scene.update()
    -- Call actions
    for k=1,#virtualKeys do
        virtualKeys[k]:update()
    end
end

scene.widgetList={
    WIDGET.newButton{name='back'        ,x=1180,y=60,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},
    WIDGET.newSwitch{name='showKey'     ,x=1000,y=60,fText='Virtual key',disp=function() return showingKey end,code=function() _showVirtualKey(not showingKey) end},
    WIDGET.newKey   {name='changeIns'   ,x=305 ,y=60,w=280,h=60,fText='Change instrument',code=pressKey"tab" ,hideF=function() return not showingKey end},
    WIDGET.newKey   {name='offset-'     ,x=485 ,y=60,w=60 ,h=60,fText=CHAR.key.left      ,code=pressKey"lalt",hideF=function() return not showingKey end},
    WIDGET.newKey   {name='offset+'     ,x=555 ,y=60,w=60 ,h=60,fText=CHAR.key.right     ,code=pressKey"ralt",hideF=function() return not showingKey end},
}
return scene
