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
local tempoffset=0
local showingKey
local sharpt,flattt=false,false
local pianoVK={} -- Virtual key set is near the end of the file.
local touches={}

local scene={}

-- Set all virtual key's text
local function _setNoteName(_offset)
    for k=1,#pianoVK do
        local K=pianoVK[k]
        local keyName=K.name
        if keys[keyName] then K:setObject(SFX.getNoteName(keys[keyName]+_offset)) end
    end
end
-- Show virtual key
local function _showVirtualKey(switch)
    if switch~=nil then showingKey=switch else showingKey=not showingKey end
    for k=1,#pianoVK do
        pianoVK[k].hide=not showingKey
    end
end

local function _notHoldCS()
    tempoffset=0
    _setNoteName(offset)
    flattt,sharpt=false,false
    pianoVK['ctrl'].color,pianoVK['shift'].color=COLOR.Z,COLOR.Z
end
local function _holdingCtrl()
    _notHoldCS()
    pianoVK['ctrl'].color=COLOR.R
    tempoffset=-1
    _setNoteName(offset-1)
end
local function _holdingShift()
    _notHoldCS()
    pianoVK['shift'].color=COLOR.R
    tempoffset=1
    _setNoteName(offset+1)
end

local function checkMultiTouch() -- Check for every touch
    _notHoldCS()
    for i=1,#touches do
        local x,y=love.touch.getPosition(touches[i])
        for _,key in pairs(pianoVK) do
            if not (key.name=="ctrl" or key.name=="shift") then
                if key:isAbove(x,y) then
                    key:code(); key:update(1)
                end
            end
        end
        if pianoVK.ctrl:isAbove(x,y) then
            _holdingCtrl()
        elseif pianoVK.shift:isAbove(x,y) then
            _holdingShift()
        end
    end
end


-- Set scene's variables
function scene.enter()
    TABLE.cut(touches)
    inst='lead'
    offset=0
    lastPlayBGM=BGM.getPlaying()[1]
    BGM.stop()
    _notHoldCS()
    _showVirtualKey(MOBILE and true or false)
end

function scene.mouseDown(x,y,_)
    -- Behavior for mouse is different than a bit
    -- Detail: Ctrl/Shift state will be reset after a note is clicked!
    local lastK
    if showingKey then
        for k,K in pairs(pianoVK) do
            if K:isAbove(x,y) then
                K.code(); K:update(1); lastK=K.name
            end
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
function scene.touchDown(_,_,id)
    table.insert(touches,id)
    checkMultiTouch()
end
function scene.touchUp(_,_,id)
    table.remove(touches,TABLE.find(touches,id))
    checkMultiTouch()
end

function scene.keyDown(key,isRep)
    if not isRep and keys[key] then
        local note=keys[key]+offset+tempoffset
        SFX.playSample(inst,note)
        if showingKey then
            pianoVK[key]:update(1)
            TEXT.show(SFX.getNoteName(note),math.random(75,1205),math.random(162,260),60,'score',.8)
        else
            TEXT.show(SFX.getNoteName(note),math.random(75,1205),math.random(162,620),60,'score',.8)
        end
    elseif kb.isDown('lctrl','rctrl') and not isRep then
        _holdingCtrl()
    elseif kb.isDown('lshift','rshift') and not isRep then
        _holdingShift()
    elseif key=='tab' then
        inst=TABLE.next(instList,inst)
    elseif key=='lalt' then
        offset=math.max(offset-1,-12)
        if showingKey then _setNoteName(offset) end
    elseif key=='ralt' then
        offset=math.min(offset+1,12)
        if showingKey then _setNoteName(offset) end
    elseif key=='f5' then
        _showVirtualKey(not showingKey)
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
        for _,key in pairs(pianoVK) do
            key:draw()
        end
        gc.setLineWidth(1)
        gc.setColor(COLOR.Z)
        gc.line(685.5,297,685.5,642)
    end
end

function scene.update(dt)
    for _,key in pairs(pianoVK) do
        key:update(dt)
    end
end
scene.widgetList={
    WIDGET.newButton{name='back'        ,x=1150,y=60,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},
    WIDGET.newSwitch{name='showKey'     ,x=970 ,y=60,fText='Virtual key (F5)',disp=function() return showingKey end,code=pressKey'f5'},
    WIDGET.newKey   {name='changeIns'   ,x=305 ,y=60,w=280,h=60,fText='Change instrument',code=pressKey"tab" ,hideF=function() return not showingKey end},
    WIDGET.newKey   {name='offset-'     ,x=485 ,y=60,w=60 ,h=60,fText=CHAR.key.left      ,code=pressKey"lalt",hideF=function() return not showingKey end},
    WIDGET.newKey   {name='offset+'     ,x=555 ,y=60,w=60 ,h=60,fText=CHAR.key.right     ,code=pressKey"ralt",hideF=function() return not showingKey end},
}

-- Set virtual keys (seperate from ZFramework)
pianoVK={
    -- Number row:  01234567890-=           13
    WIDGET.newKey   {name='1'        ,x=  75,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('1'        ) end},
    WIDGET.newKey   {name='2'        ,x= 165,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('2'        ) end},
    WIDGET.newKey   {name='3'        ,x= 255,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('3'        ) end},
    WIDGET.newKey   {name='4'        ,x= 345,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('4'        ) end},
    WIDGET.newKey   {name='5'        ,x= 435,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('5'        ) end},
    WIDGET.newKey   {name='6'        ,x= 525,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('6'        ) end},
    WIDGET.newKey   {name='7'        ,x= 615,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('7'        ) end},
    WIDGET.newKey   {name='8'        ,x= 755,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('8'        ) end},
    WIDGET.newKey   {name='9'        ,x= 845,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('9'        ) end},
    WIDGET.newKey   {name='0'        ,x= 935,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('0'        ) end},
    WIDGET.newKey   {name='-'        ,x=1025,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('-'        ) end},
    WIDGET.newKey   {name='='        ,x=1115,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('='        ) end},
    WIDGET.newKey   {name='backspace',x=1205,y=335,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('backspace') end},

    -- Top row:     QWERTYUIOP[]\           13
    WIDGET.newKey   {name='q'        ,x=  75,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('q' ) end},
    WIDGET.newKey   {name='w'        ,x= 165,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('w' ) end},
    WIDGET.newKey   {name='e'        ,x= 255,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('e' ) end},
    WIDGET.newKey   {name='r'        ,x= 345,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('r' ) end},
    WIDGET.newKey   {name='t'        ,x= 435,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('t' ) end},
    WIDGET.newKey   {name='y'        ,x= 525,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('y' ) end},
    WIDGET.newKey   {name='u'        ,x= 615,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('u' ) end},
    WIDGET.newKey   {name='i'        ,x= 755,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('i' ) end},
    WIDGET.newKey   {name='o'        ,x= 845,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('o' ) end},
    WIDGET.newKey   {name='p'        ,x= 935,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('p' ) end},
    WIDGET.newKey   {name='['        ,x=1025,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('[' ) end},
    WIDGET.newKey   {name=']'        ,x=1115,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown(']' ) end},
    WIDGET.newKey   {name='\\'       ,x=1205,y=425,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('\\') end},

    -- Home row     ASDFGHJKL;''<ENTER>     12
    WIDGET.newKey   {name='a'        ,x=  75,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='R',code=function() scene.keyDown('a'     ) end},
    WIDGET.newKey   {name='s'        ,x= 165,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='W',code=function() scene.keyDown('s'     ) end},
    WIDGET.newKey   {name='d'        ,x= 255,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='P',code=function() scene.keyDown('d'     ) end},
    WIDGET.newKey   {name='f'        ,x= 345,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='N',code=function() scene.keyDown('f'     ) end},
    WIDGET.newKey   {name='g'        ,x= 435,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('g'     ) end},
    WIDGET.newKey   {name='h'        ,x= 525,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('h'     ) end},
    WIDGET.newKey   {name='j'        ,x= 615,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='O',code=function() scene.keyDown('j'     ) end},
    WIDGET.newKey   {name='k'        ,x= 755,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='L',code=function() scene.keyDown('k'     ) end},
    WIDGET.newKey   {name='l'        ,x= 845,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='G',code=function() scene.keyDown('l'     ) end},
    WIDGET.newKey   {name=';'        ,x= 935,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='C',code=function() scene.keyDown(';'     ) end},
    WIDGET.newKey   {name='\''       ,x=1025,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('\''    ) end},
    WIDGET.newKey   {name='return'   ,x=1115,y=515,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('return') end},

    -- Bottom row   ZXCVBNM,./              10
    WIDGET.newKey   {name='z'        ,x=  75,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('z') end},
    WIDGET.newKey   {name='x'        ,x= 165,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('x') end},
    WIDGET.newKey   {name='c'        ,x= 255,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('c') end},
    WIDGET.newKey   {name='v'        ,x= 345,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('v') end},
    WIDGET.newKey   {name='b'        ,x= 435,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('b') end},
    WIDGET.newKey   {name='n'        ,x= 525,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('n') end},
    WIDGET.newKey   {name='m'        ,x= 615,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('m') end},
    WIDGET.newKey   {name=','        ,x= 755,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown(',') end},
    WIDGET.newKey   {name='.'        ,x= 845,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('.') end},
    WIDGET.newKey   {name='/'        ,x= 935,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('/') end},

    WIDGET.newKey   {name='ctrl'     ,x=1115,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() if not flattt then _holdingCtrl()  else _notHoldCS() end end},
    WIDGET.newKey   {name='shift'    ,x=1205,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() if not sharpt then _holdingShift() else _notHoldCS() end end},
}
setmetatable(pianoVK,{__index=function(L,k) for i=1,#L do if L[i].name==k then return L[i] end end end})

-- Set objects text
pianoVK['ctrl'] :setObject(CHAR.key.ctrl )
pianoVK['shift']:setObject(CHAR.key.shift)
-- Overwrite some functions
for k=1,#pianoVK do
    local K=pianoVK[k]
    -- Overwrite the update function
    function K:update(activateState,dt)
        -- activateState
            -- 0 - Off
            -- 1 - On then off
            -- 2 - On
        local ATV=self.ATV
        local maxTime=6.2

        if activateState~=nil then self.activateState=activateState
        elseif (self.activateState==1 and ATV==maxTime) or not self.activateState then self.activateState=0 end

        -- When I can emulate holding key
        -- self.activateState=activateState and activateState or not ATV>maxTime and self.activateState end

        if dt then
            if self.activateState>0 then
                self.ATV=min(ATV+dt*60,maxTime)
            elseif ATV>0 then
                self.ATV=max(ATV-dt*30,0)
            end
        end
    end
    -- Remove unnecessary function (reduce memory usage)
    function K:getCenter() end
    function K:drag()      end
    function K:release()   end
end
return scene
