local gc=love.graphics
local kbIsDown=love.keyboard.isDown
local moIsDown=love.mouse.isDown
local min,max=math.min,math.max

local instList={'lead','bell','bass'}
local keys={
    ['1']=61,['2']=63,['3']=65,['4']=66,['5']=68,['6']=70,['7']=72,['8']=73,['9']=75,['0']=77,['-']=78,['=']=80,['backspace']=82,
    ['q']=49,['w']=51,['e']=53,['r']=54,['t']=56,['y']=58,['u']=60,['i']=61,['o']=63,['p']=65,['[']=66,[']']=68,['\\']=70,
    ['a']=37,['s']=39,['d']=41,['f']=42,['g']=44,['h']=46,['j']=48,['k']=49,['l']=51,[';']=53,["'"]=54,['return']=56,
    ['z']=25,['x']=27,['c']=29,['v']=30,['b']=32,['n']=34,['m']=36,[',']=37,['.']=39,['/']=41,
}
local inst
local offset
local tempoffset=0

local lastPlayBGM
local showingKey
local pianoVK={}  -- All piano key can be appear on the screen, want to see? Check the end of the code
local touches={}

local keyCount=0  -- Get key count (up to 626, can pass), used to check if we need to launch Lua's garbage collector or not
local textObj={}  -- We will keep all text objects of note here, only used for virutal keys
local lastKeyTime -- Last time any key pressed

local scene={}

-- Rename all virtual key's text
local function _renameKeyText(_offset)
    for keyName,K in pairs(pianoVK) do
        if keys[keyName] then
            local keynameoffset=keyName.._offset -- Achivement? Hashtable implemented
            if not textObj[keynameoffset] then
                textObj[keynameoffset]=gc.newText(FONT.get(K.font,K.fType),SFX.getNoteName(keys[keyName]+_offset))
            end
            K:setObject(textObj[keynameoffset])
        end
    end
end
-- Show virtual key
local function _showVirtualKey(switch)
    if switch~=nil then showingKey=switch else showingKey=not showingKey end
end

local function _notHoldCS(dct) -- dct=don't change (key's) text
    tempoffset=0
    if not dct then _renameKeyText(offset) end
    pianoVK.ctrl.color,pianoVK.shift.color=COLOR.Z,COLOR.Z
end
local function _holdingCtrl()
    _notHoldCS(true)
    tempoffset=-1
    pianoVK.ctrl.color=COLOR.R
    _renameKeyText(offset-1)
end
local function _holdingShift()
    _notHoldCS(true)
    tempoffset=1
    pianoVK.shift.color=COLOR.R
    _renameKeyText(offset+1)
end

local function checkMultiTouch() -- Check for every touch
    if not showingKey then return end
    if not kbIsDown('lctrl','rctrl','lshift','rshift') then _notHoldCS() end
    for id,t in pairs(touches) do
        local x,y=t[1],t[2]
        for _,key in pairs(pianoVK) do
            if not (key.name=="ctrl" or key.name=="shift") then
                if key:isAbove(x,y) then key:code(); key:update(1); touches[id]=nil end
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

    keyCount=0
    lastKeyTime=nil

    _notHoldCS()
    _showVirtualKey(MOBILE and true or false)
end

function scene.leave()
    TABLE.clear(textObj)
    collectgarbage()
    BGM.play(lastPlayBGM)
end

function scene.touchDown(x,y,id)
    touches[id]={x,y}
    checkMultiTouch()
end
function scene.touchUp(_,_,id)
    touches[id]=nil
    checkMultiTouch()
end

function scene.keyDown(key,isRep)
    if not isRep and keys[key] then
        local note=keys[key]+offset+tempoffset
        SFX.playSample(inst,note)
        keyCount=keyCount+1
        lastKeyTime=TIME()

        if showingKey then
            pianoVK[key]:update(1)
            TEXT.show(SFX.getNoteName(note),math.random(75,1205),math.random(162,260),60,'score',.8)
        else
            TEXT.show(SFX.getNoteName(note),math.random(75,1205),math.random(162,620),60,'score',.8)
        end
    elseif kbIsDown('lctrl','rctrl') and not kbIsDown('lshift','rshift') then
        _holdingCtrl()
    elseif kbIsDown('lshift','rshift') and not kbIsDown('lctrl','rctrl') then
        _holdingShift()
    elseif key=='tab' then
        inst=TABLE.next(instList,inst)
    elseif key=='lalt' then
        offset=math.max(offset-1,-12)
        _renameKeyText(offset)
    elseif key=='ralt' then
        offset=math.min(offset+1,12)
        _renameKeyText(offset)
    elseif key=='f5' then
        _showVirtualKey()
    elseif key=='escape' then SCN.back() end
end

function scene.keyUp()
    if (
        not kbIsDown('lctrl','rctrl','lshift','rshift') -- If we are not holding Ctrl or Shift keys
    ) and not moIsDown(1) -- and the left mouse button is not being held
    -- The implementationo is really wild but I hope it will good enough to keep the virtual keys from bugs
    then _notHoldCS() end
end

scene.mouseDown=scene.touchDown -- The ID arg is being used by button, nvm the code still not crash
scene.mouseUp=scene.touchUp     -- Don't need to do anything more complicated here

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
        key:update(nil,dt)
    end

    if lastKeyTime and keyCount>626 and TIME()-lastKeyTime>10 then
        collectgarbage()
        lastKeyTime=nil
        keyCount=0
    end
end
scene.widgetList={
    WIDGET.newButton{name='back'     ,x=1150,y=60,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},
    WIDGET.newSwitch{name='showKey'  ,x=970 ,y=60,fText='Virtual key (F5)',disp=function() return showingKey end,code=pressKey'f5'},
    WIDGET.newKey   {name='changeIns',x=265 ,y=60,w=200,h=60,fText='Instrument'  ,code=pressKey"tab" ,hideF=function() return not showingKey end},
    WIDGET.newKey   {name='offset-'  ,x=405 ,y=60,w=60 ,h=60,fText=CHAR.key.left ,code=pressKey"lalt",hideF=function() return not showingKey end},
    WIDGET.newKey   {name='offset+'  ,x=475 ,y=60,w=60 ,h=60,fText=CHAR.key.right,code=pressKey"ralt",hideF=function() return not showingKey end},
}

-- Set virtual keys (seperate from ZFramework)
-- Using hashtable to reduce usage time
pianoVK={
    -- Number row:  01234567890-=           13
    ['1'        ]=WIDGET.newKey{x=  75,y=335,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('1'        ) end},
    ['2'        ]=WIDGET.newKey{x= 165,y=335,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('2'        ) end},
    ['3'        ]=WIDGET.newKey{x= 255,y=335,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('3'        ) end},
    ['4'        ]=WIDGET.newKey{x= 345,y=335,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('4'        ) end},
    ['5'        ]=WIDGET.newKey{x= 435,y=335,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('5'        ) end},
    ['6'        ]=WIDGET.newKey{x= 525,y=335,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('6'        ) end},
    ['7'        ]=WIDGET.newKey{x= 615,y=335,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('7'        ) end},
    ['8'        ]=WIDGET.newKey{x= 755,y=335,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('8'        ) end},
    ['9'        ]=WIDGET.newKey{x= 845,y=335,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('9'        ) end},
    ['0'        ]=WIDGET.newKey{x= 935,y=335,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('0'        ) end},
    ['-'        ]=WIDGET.newKey{x=1025,y=335,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('-'        ) end},
    ['='        ]=WIDGET.newKey{x=1115,y=335,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('='        ) end},
    ['backspace']=WIDGET.newKey{x=1205,y=335,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('backspace') end},

    -- Top row:     QWERTYUIOP[]\           13
    ['q' ]=WIDGET.newKey{x=  75,y=425,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('q' ) end},
    ['w' ]=WIDGET.newKey{x= 165,y=425,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('w' ) end},
    ['e' ]=WIDGET.newKey{x= 255,y=425,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('e' ) end},
    ['r' ]=WIDGET.newKey{x= 345,y=425,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('r' ) end},
    ['t' ]=WIDGET.newKey{x= 435,y=425,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('t' ) end},
    ['y' ]=WIDGET.newKey{x= 525,y=425,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('y' ) end},
    ['u' ]=WIDGET.newKey{x= 615,y=425,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('u' ) end},
    ['i' ]=WIDGET.newKey{x= 755,y=425,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('i' ) end},
    ['o' ]=WIDGET.newKey{x= 845,y=425,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('o' ) end},
    ['p' ]=WIDGET.newKey{x= 935,y=425,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('p' ) end},
    ['[' ]=WIDGET.newKey{x=1025,y=425,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('[' ) end},
    [']' ]=WIDGET.newKey{x=1115,y=425,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown(']' ) end},
    ['\\']=WIDGET.newKey{x=1205,y=425,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('\\') end},

    -- Home row     ASDFGHJKL;''<ENTER>     12
    ['a'     ]=WIDGET.newKey{x=  75,y=515,w=75,h=75,sound=false,font=35,fText='',color='R',code=function() scene.keyDown('a'     ) end},
    ['s'     ]=WIDGET.newKey{x= 165,y=515,w=75,h=75,sound=false,font=35,fText='',color='W',code=function() scene.keyDown('s'     ) end},
    ['d'     ]=WIDGET.newKey{x= 255,y=515,w=75,h=75,sound=false,font=35,fText='',color='P',code=function() scene.keyDown('d'     ) end},
    ['f'     ]=WIDGET.newKey{x= 345,y=515,w=75,h=75,sound=false,font=35,fText='',color='N',code=function() scene.keyDown('f'     ) end},
    ['g'     ]=WIDGET.newKey{x= 435,y=515,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('g'     ) end},
    ['h'     ]=WIDGET.newKey{x= 525,y=515,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('h'     ) end},
    ['j'     ]=WIDGET.newKey{x= 615,y=515,w=75,h=75,sound=false,font=35,fText='',color='O',code=function() scene.keyDown('j'     ) end},
    ['k'     ]=WIDGET.newKey{x= 755,y=515,w=75,h=75,sound=false,font=35,fText='',color='L',code=function() scene.keyDown('k'     ) end},
    ['l'     ]=WIDGET.newKey{x= 845,y=515,w=75,h=75,sound=false,font=35,fText='',color='G',code=function() scene.keyDown('l'     ) end},
    [';'     ]=WIDGET.newKey{x= 935,y=515,w=75,h=75,sound=false,font=35,fText='',color='C',code=function() scene.keyDown(';'     ) end},
    ['\''    ]=WIDGET.newKey{x=1025,y=515,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('\''    ) end},
    ['return']=WIDGET.newKey{x=1115,y=515,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('return') end},

    -- Bottom row   ZXCVBNM,./              10
    ['z']=WIDGET.newKey{x= 75,y=605,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('z') end},
    ['x']=WIDGET.newKey{x=165,y=605,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('x') end},
    ['c']=WIDGET.newKey{x=255,y=605,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('c') end},
    ['v']=WIDGET.newKey{x=345,y=605,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('v') end},
    ['b']=WIDGET.newKey{x=435,y=605,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('b') end},
    ['n']=WIDGET.newKey{x=525,y=605,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('n') end},
    ['m']=WIDGET.newKey{x=615,y=605,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('m') end},
    [',']=WIDGET.newKey{x=755,y=605,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown(',') end},
    ['.']=WIDGET.newKey{x=845,y=605,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('.') end},
    ['/']=WIDGET.newKey{x=935,y=605,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() scene.keyDown('/') end},

    -- Ctrl and Shift                       2
    ['ctrl' ]=WIDGET.newKey{x=1115,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() if not tempoffset==-1 then _holdingCtrl()  else _notHoldCS() end end},
    ['shift']=WIDGET.newKey{x=1205,y=605,w=75 ,h=75,sound=false,font=35,fText='',color='Z',code=function() if not tempoffset== 1 then _holdingShift() else _notHoldCS() end end},
}

-- Set objects text
pianoVK.ctrl :setObject(CHAR.key.ctrl )
pianoVK.shift:setObject(CHAR.key.shift)
-- Overwrite some functions
for _,K in pairs(pianoVK) do
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

        -- LIKELY NOT POSSIBLE TO DO
        -- Holding key: self.activateState=activateState and activateState or not ATV>maxTime and self.activateState or 0 end

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