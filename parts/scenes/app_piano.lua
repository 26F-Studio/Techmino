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

local generateVKey
local showingKey
local pianoVK={}  -- All piano key can be appear on the screen, want to see? Check the end of the code
local touches={}

local keyCount=0  -- Get key count (up to 262, can be larger), used to check if we need to launch Lua's garbage collector or not
local textObj={}  -- We will keep all text objects of note here, only used for virutal keys
local lastKeyTime -- Last time any key pressed

local lastPlayBGM
local scene={}

-- Rename all virtual key's text
local function _renameKeyText(_offset)
    for keyName,K in pairs(pianoVK) do
        if keys[keyName] then
            local keynameoffset=keyName.._offset -- Achivement? Hashtable implemented
            if not textObj[keynameoffset] then
                textObj[keynameoffset]=gc.newText(FONT.get(K.font),SFX.getNoteName(keys[keyName]+_offset))
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
    for tid,t in pairs(touches) do
        local x,y=t[1],t[2]
        for kID,key in pairs(pianoVK) do
            if not (kID=="ctrl" or kID=="shift") then
                if key:isAbove(x,y) then key:code(); key:update(1); touches[tid]=nil end
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

    generateVKey()
    _notHoldCS()
    _showVirtualKey(MOBILE)
end

function scene.leave()
    showingKey=false
    TABLE.clear(textObj)
    TABLE.clear(pianoVK)
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
    -- The implementation is really wild but I hope it will good enough to keep the virtual keys from bugs
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
        for _,key in pairs(pianoVK) do key:draw() end
        gc.setLineWidth(1)
        gc.setColor(COLOR.Z)
        gc.line(685.5,297,685.5,642)
    end
end

function scene.update(dt)
    for _,key in pairs(pianoVK) do key:update(nil,dt) end

    if lastKeyTime and keyCount>262 and TIME()-lastKeyTime>10 then
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

-- Generate virtual keys (seperate from ZFramework, to use only in this scene)
-- Using hashtable to reduce usage time
generateVKey=function()
    local allRow={
        {'1','2','3','4','5','6','7','8','9','0' ,'-','=','backspace'},
        {'q','w','e','r','t','y','u','i','o','p','[' ,']','\\'},
        {'a','s','d','f','g','h','j','k','l',';','\'','return'},
        {'z','x','c','v','b','n','m',',','.','/',},
    }
    local keyColorInHomeRow={'R','W','P','N','Z','Z','O','L','G','C','Z','Z'}

    for row,keysInRow in pairs(allRow) do
        for keyIndex,keyChar in pairs(keysInRow) do
            -- Create the base first
            local K=WIDGET.newKey{
                x=75+90*(keyIndex-1)+50*(keyIndex>7 and 1 or 0),
                y=335+90*(row-1),
                w=75,h=75,

                font=35,fText='',sound=false,
                color=row==3 and keyColorInHomeRow[keyIndex] or 'Z',
                code=function() scene.keyDown(keyChar) end
            }

            -- Then modify the base to get the key we expected
            function K:update(activateState,dt)
                -- activateState: 0=off, 1=on then off, 2=on
                local activationTime=self.ATV or 0
                local maxTime=6.2

                if activateState~=nil then self.activateState=activateState
                elseif (self.activateState==1 and activationTime==maxTime) or not self.activateState then self.activateState=0 end
                -- TODO: when the note can be extended longer, this will need remaking
                if dt then
                    if self.activateState>0 then self.ATV=min(activationTime+dt*60,maxTime)
                    elseif activationTime>0 then self.ATV=max(activationTime-dt*30,0)
                    end
                end
            end
            K.getCenter,K.drag,K.release=nil
            pianoVK[keyChar]=K
            K=nil
        end
    end

    -- Special case
    pianoVK.ctrl =WIDGET.newKey{x=1115,y=605,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() if not tempoffset==-1 then _holdingCtrl()  else _notHoldCS() end end}
    pianoVK.ctrl :setObject(CHAR.key.ctrl )
    pianoVK.shift=WIDGET.newKey{x=1205,y=605,w=75,h=75,sound=false,font=35,fText='',color='Z',code=function() if not tempoffset== 1 then _holdingShift() else _notHoldCS() end end}
    pianoVK.shift:setObject(CHAR.key.shift)
end

return scene
