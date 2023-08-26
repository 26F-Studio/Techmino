local gc=love.graphics
local kb=love.keyboard
local touch=love.touch
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
local tempoffset=0
local showingKey
local sharpt,flattt=false,false
local virtualKeys={}   -- Virtual key set is near the end of the file.
local touchPosition={}

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

local function _notHoldCS()
    tempoffset=0
    _setNoteName(offset)
    flattt,sharpt=false,false
    virtualKeys['keyCtrl'].color,virtualKeys['keyShift'].color=COLOR.Z,COLOR.Z
end
local function _holdingCtrl()
    _notHoldCS()
    virtualKeys['keyCtrl'].color=COLOR.R
    tempoffset=-1
    _setNoteName(offset-1)
end
local function _holdingShift()
    _notHoldCS()
    virtualKeys['keyShift'].color=COLOR.R
    tempoffset=1
    _setNoteName(offset+1)
end


-- Set scene's variables
function scene.enter()
    inst='lead'
    offset=0
    lastPlayBGM=BGM.getPlaying()[1]
    BGM.stop()
    _notHoldCS()
    _showVirtualKey(MOBILE and true or false)
end

function scene.mouseDown(x,y,_)
    local lastK
    if showingKey then
        for k,K in pairs(virtualKeys) do
            if K:isAbove(x,y) then K.code(); K:update(1); lastK=string.sub(K.name:lower(),4) end
        end
        -- Check if there is a key other than Ctrl/Shift is hold
        -- if yes then automatically swap Ctrl/Shift state
        if keys[lastK] then _notHoldCS() end
        -- Change Shift/Ctrl key's color when shift note temproraily
        if flattt or sharpt then
            if flattt then _holdingCtrl() else _holdingShift() end
        end
    end
end
function scene.multipleTouch()     -- Check for every touch keys
    if next(touchPosition) then
        for _,pos in pairs(touchPosition) do
            local x,y=pos[1],pos[2]
            table.remove(touchPosition,_)
            for i,currentKey in pairs(virtualKeys) do
                if not (currentKey.name=="keyCtrl" or currentKey.name=="keyShift") then
                    if currentKey:isAbove(x,y) then currentKey:code(); currentKey:update(1) end
                end
            end
            if not (virtualKeys.keyCtrl:isAbove(x,y) or virtualKeys.keyShift:isAbove(x,y)) then _notHoldCS() end
        end
    end
end
function scene.touchDown(x,y)
    table.insert(touchPosition,1,{x,y})
end
function scene.touchUp(x,y)
    local pos={x,y}
    table.remove(touchPosition,TABLE.find(touchPosition,pos))
end

function scene.keyDown(key,isRep)
    if not isRep and keys[key] then
        local note=keys[key]+offset+tempoffset
        SFX.playSample(inst,note)
        if showingKey then
            virtualKeys['key'..key:upper()]:update(1)
            TEXT.show(SFX.getNoteName(note),math.random(75,1205),math.random(162,260),60,'score',.8)
        else
            TEXT.show(SFX.getNoteName(note),math.random(75,1205),math.random(162,620),60,'score',.8)
        end
    elseif kb.isDown('lctrl','rctrl')   and not isRep then _holdingCtrl()
    elseif kb.isDown('lshift','rshift') and not isRep then _holdingShift()
    elseif key=='tab' then
        inst=TABLE.next(instList,inst)
    elseif key=='lalt' then
        offset=math.max(offset-1,-12)
        if showingKey then _setNoteName(offset) end
    elseif key=='ralt' then
        offset=math.min(offset+1,12)
        if showingKey then _setNoteName(offset) end
    elseif key=='f5' then _showVirtualKey(not showingKey)
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

    -- Drawing virtual keys
    if showingKey then
        for i,currentKey in pairs(virtualKeys) do
            currentKey:draw()
        end
        gc.setLineWidth(1)
        gc.setColor(COLOR.Z)
        gc.line(685.5,297,685.5,642)
    end
end

function scene.update()
    for i,currentKey in pairs(virtualKeys) do
        currentKey:update()
    end
    scene.multipleTouch()
end

scene.widgetList={
    WIDGET.newButton{name='back'        ,x=1150,y=60,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},
    WIDGET.newSwitch{name='showKey'     ,x=970 ,y=60,fText='Virtual key (F5)',disp=function() return showingKey end,code=pressKey'f5'},
    WIDGET.newKey   {name='changeIns'   ,x=305 ,y=60,w=280,h=60,fText='Change instrument',code=pressKey"tab" ,hideF=function() return not showingKey end},
    WIDGET.newKey   {name='offset-'     ,x=485 ,y=60,w=60 ,h=60,fText=CHAR.key.left      ,code=pressKey"lalt",hideF=function() return not showingKey end},
    WIDGET.newKey   {name='offset+'     ,x=555 ,y=60,w=60 ,h=60,fText=CHAR.key.right     ,code=pressKey"ralt",hideF=function() return not showingKey end},
}

-- Set virtual keys (seperate from ZFramework)
virtualKeys={
    -- Number row:  01234567890-=           13
    WIDGET.newKey   {name='key1'        ,x=  75,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('1'        ) end},
    WIDGET.newKey   {name='key2'        ,x= 165,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('2'        ) end},
    WIDGET.newKey   {name='key3'        ,x= 255,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('3'        ) end},
    WIDGET.newKey   {name='key4'        ,x= 345,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('4'        ) end},
    WIDGET.newKey   {name='key5'        ,x= 435,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('5'        ) end},
    WIDGET.newKey   {name='key6'        ,x= 525,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('6'        ) end},
    WIDGET.newKey   {name='key7'        ,x= 615,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('7'        ) end},
    WIDGET.newKey   {name='key8'        ,x= 755,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('8'        ) end},
    WIDGET.newKey   {name='key9'        ,x= 845,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('9'        ) end},
    WIDGET.newKey   {name='key0'        ,x= 935,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('0'        ) end},
    WIDGET.newKey   {name='key-'        ,x=1025,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('-'        ) end},
    WIDGET.newKey   {name='key='        ,x=1115,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('='        ) end},
    WIDGET.newKey   {name='keyBACKSPACE',x=1205,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('backspace') end},

    -- Top row:     QWERTYUIOP[]\           13
    WIDGET.newKey   {name='keyQ'        ,x=  75,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('q' ) end},
    WIDGET.newKey   {name='keyW'        ,x= 165,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('w' ) end},
    WIDGET.newKey   {name='keyE'        ,x= 255,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('e' ) end},
    WIDGET.newKey   {name='keyR'        ,x= 345,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('r' ) end},
    WIDGET.newKey   {name='keyT'        ,x= 435,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('t' ) end},
    WIDGET.newKey   {name='keyY'        ,x= 525,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('y' ) end},
    WIDGET.newKey   {name='keyU'        ,x= 615,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('u' ) end},
    WIDGET.newKey   {name='keyI'        ,x= 755,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('i' ) end},
    WIDGET.newKey   {name='keyO'        ,x= 845,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('o' ) end},
    WIDGET.newKey   {name='keyP'        ,x= 935,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('p' ) end},
    WIDGET.newKey   {name='key['        ,x=1025,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('[' ) end},
    WIDGET.newKey   {name='key]'        ,x=1115,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown(']' ) end},
    WIDGET.newKey   {name='key\\'       ,x=1205,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('\\') end},

    -- Home row     ASDFGHJKL;''<ENTER>     12
    WIDGET.newKey   {name='keyA'        ,x=  75,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='R',code=function() scene.keyDown('a'     ) end},
    WIDGET.newKey   {name='keyS'        ,x= 165,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='W',code=function() scene.keyDown('s'     ) end},
    WIDGET.newKey   {name='keyD'        ,x= 255,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='P',code=function() scene.keyDown('d'     ) end},
    WIDGET.newKey   {name='keyF'        ,x= 345,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='N',code=function() scene.keyDown('f'     ) end},
    WIDGET.newKey   {name='keyG'        ,x= 435,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('g'     ) end},
    WIDGET.newKey   {name='keyH'        ,x= 525,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('h'     ) end},
    WIDGET.newKey   {name='keyJ'        ,x= 615,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='O',code=function() scene.keyDown('j'     ) end},
    WIDGET.newKey   {name='keyK'        ,x= 755,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='L',code=function() scene.keyDown('k'     ) end},
    WIDGET.newKey   {name='keyL'        ,x= 845,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='G',code=function() scene.keyDown('l'     ) end},
    WIDGET.newKey   {name='key;'        ,x= 935,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='C',code=function() scene.keyDown(';'     ) end},
    WIDGET.newKey   {name='key\''       ,x=1025,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('\''    ) end},
    WIDGET.newKey   {name='keyRETURN'   ,x=1115,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('return') end},

    -- Bottom row   ZXCVBNM,./              10
    WIDGET.newKey   {name='keyZ'        ,x=  75,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('z') end},
    WIDGET.newKey   {name='keyX'        ,x= 165,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('x') end},
    WIDGET.newKey   {name='keyC'        ,x= 255,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('c') end},
    WIDGET.newKey   {name='keyV'        ,x= 345,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('v') end},
    WIDGET.newKey   {name='keyB'        ,x= 435,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('b') end},
    WIDGET.newKey   {name='keyN'        ,x= 525,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('n') end},
    WIDGET.newKey   {name='keyM'        ,x= 615,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('m') end},
    WIDGET.newKey   {name='key,'        ,x= 755,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown(',') end},
    WIDGET.newKey   {name='key.'        ,x= 845,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('.') end},
    WIDGET.newKey   {name='key/'        ,x= 935,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('/') end},

    WIDGET.newKey   {name='keyCtrl'     ,x=1115,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() if not flattt then _holdingCtrl()  else _notHoldCS() end end},
    WIDGET.newKey   {name='keyShift'    ,x=1205,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() if not sharpt then _holdingShift() else _notHoldCS() end end},
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
        -- activateState
            -- 0 - Off
            -- 1 - On then off
            -- 2 - On
        local dt=love.timer.getDelta()
        local ATV=self.ATV
        local maxTime=6.2

        if activateState~=nil then self.activateState=activateState
        elseif (self.activateState==1 and ATV==maxTime) or not self.activateState then self.activateState=0 end

        -- When I can emulate holding key
        -- self.activateState=activateState and activateState or not ATV>maxTime and self.activateState end

        if self.activateState>0 then
            self.ATV=min(ATV+dt*60,maxTime)
        elseif ATV>0 then
            self.ATV=max(ATV-dt*30,0)
        end
    end
    -- Remove unnecessary function (reduce memory usage)
    function K:getCenter() end
    function K:getInfo()   end
    function K:drag()      end
    function K:release()   end
end
return scene
