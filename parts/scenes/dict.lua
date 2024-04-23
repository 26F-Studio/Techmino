local gc=love.graphics

local floor,abs=math.floor,math.abs
local ins=table.insert
local find=string.find

local scene={}

local dict       -- Dict list
local result     -- Result Lable
local localeFile -- Language file name, used for force reload

local lastTickInput
local searchWait            -- Searching animation timer

local lastSearch            -- Last searched string
local lastSelected          -- Last selected item

local currentFontSize=25    -- Current font size, default: 25
local utf8postProcess

local typeColor={
    help=COLOR.Y,
    org=COLOR.lF,
    game=COLOR.lC,
    term=COLOR.lR,
    setup=COLOR.lY,
    pattern=COLOR.lJ,
    command=COLOR.lN,
    english=COLOR.B,
    name=COLOR.lV,
}

-- Scan the dictionary and return the list
local function _filter(word_org)
    local word=word_org
    word=word:gsub("[Tt][Ee][Tt][Rr][Ii][Ss]",CHAR.zChan.thinking)
    if FNNS then word=word:gsub("[Pp]\97\116\114\101\111\110",CHAR.zChan.qualified) end
    return word,word_org
end
local function _scanDict(D)
    if not D[1][1] then return end
    local cut=TABLE.cut
    for i=1,#D do
        local O=D[i]
        O.title,O.title_Org=_filter(O[1])
        O.titleLowered=utf8postProcess and STRING.lowerUTF8(O.title) or O.title:lower()
        O.titleNoDiaratics=utf8postProcess and STRING.remDiacritics(O.titleLowered)
        O.keywords=O[2]
        O.keywordsLowered=utf8postProcess and STRING.lowerUTF8(O.keywords) or O.keywords:lower()
        O.keywordsNoDiaratics=utf8postProcess and STRING.remDiacritics(O.keywordsLowered)
        O.type=O[3]
        O.content,O.content_Org=_filter(O[4])
        O.url=O[5]
        cut(O)
    end
end
local function _getList() return result[1] and result or dict end

local contentBox=WIDGET.newTextBox{name='contentBox',x=320,y=180,w=862,h=526,font=25,fix=true}
local inputBox=WIDGET.newInputBox{name='inputBox',x=20,y=110,w=762,h=60,font=40,limit=32}
local listBox=WIDGET.newListBox{name='listBox',x=20,y=180,w=280,h=526,font=30,lineH=35,drawF=function(item,id,ifSel)
    -- Background
    if ifSel then
        gc.setColor(1,1,1,.4)
        gc.rectangle('fill',0,0,280,35)
    end
    setFont(30)
    -- Name & color
    GC.shadedPrint(item.title,10,-3,'left',1,COLOR.D,typeColor[item.type])
end}

-- Necessary local functions
-- Update the infobox
local function _updateContentBox()
    local _t,t
    _t,t=pcall(function() return _getList()[listBox.selected].content end)
    if not _t then t={"???"} end
    local _w,c=getFont(currentFontSize):getWrap(t,840)
    contentBox:setTexts(c)
end
-- Clear the result
local function _clearResult()
    TABLE.cut(result)
    listBox.selected,lastSelected,searchWait,lastSearch=1,1,0,false
    scene.widgetList.copy.hide=false
    _updateContentBox()
end
-- Search through the dictionary
local function _search()
    local input=inputBox:getText()
    local pos
    local first
    _clearResult()
    input=utf8postProcess and STRING.lowerUTF8(input) or input:lower()
    for i=1,#dict do
        pos=find(dict[i].titleLowered,input,nil,true) or find(dict[i].keywordsLowered,input,nil,true) or utf8postProcess and (find(dict[i].titleNoDiaratics,input,nil,true) or find(dict[i].keywordsNoDiaratics,input,nil,true))
        if pos==1 and not first then
            ins(result,1,dict[i])
            first=true
        elseif pos then
            ins(result,dict[i])
        end
    end

    listBox:setList(_getList())

    if #result>0 then SFX.play('reach') end
    lastSearch=input
    _updateContentBox()
end

-- Jump over n items
local function _jumpover(key,n)
    local dir=(key=='left' or key=='pageup') and 'up' or 'down'
    for _=1,n or 1 do scene.widgetList.listBox:arrowKey(dir) end

    _updateContentBox()
    lastSelected=listBox.selected
    scene.widgetList.copy.hide=false
end

-- Copy the content
local function _copy()
    local t=_getList()[listBox.selected]
    t=t.title_Org..":\n"..t.content_Org..(t.url and "\n[ "..t.url.." ]\n" or "\n")..text.dictNote
    love.system.setClipboardText(t)
    scene.widgetList.copy.hide=true
    MES.new('info',text.copyDone)
end

-- Changing font size, z=0 --> reset
local function _setZoom(z)
    currentFontSize=MATH.clamp(z~=0 and currentFontSize+z or 25,15,40)
    contentBox.font=currentFontSize
    contentBox:reset()
    _updateContentBox()
    MES.new("check",z~=0 and text.dict.sizeChanged:repD(currentFontSize) or text.dict.sizeReset,1.26)
end

-- Reset everything when opening Zictionary
function scene.enter()
    localeFile='parts.language.dict_'..(
        SETTING.locale:find'zh' and 'zh' or
        SETTING.locale:find'ja' and 'ja' or
        SETTING.locale:find'vi' and 'vi' or
        'en'
    )
    utf8postProcess=SETTING.locale:find'vi'

    dict=require(localeFile)
    _scanDict(dict)

    inputBox:clear()
    result={}

    searchWait=0
    lastSelected=1
    lastSearch=false
    listBox:setList(_getList())

    _updateContentBox()

    if not MOBILE then WIDGET.focus(inputBox) end
    BG.set('rainbow')
end

function scene.wheelMoved(_,y)
    if WIDGET.sel==listBox then
        listBox:scroll(-y)
    else
        contentBox:scroll(-y)
    end
end
function scene.keyDown(key)
    local inputBoxFocus=WIDGET.isFocus(inputBox)

    -- Switching selected items
    if key=='up' or key=='down' then
        contentBox:scroll(key=='up' and -1 or 1)
    elseif (key=='left' or key=='pageup' or key=='right' or key=='pagedown') then
        _jumpover(key,love.keyboard.isDown('lctrl','rctrl','lalt','ralt','lshift','rshift') and 12)
    elseif key=='cC' or key=='c' and love.keyboard.isDown('lctrl','rctrl') then
        if listBox.selected>0 then
            _copy()
        end
    elseif (key=='-' or key=='=' or key=='0') and (inputBox:getText()=="" or not inputBoxFocus) and not MOBILE then
        WIDGET.unFocus(true)
        _setZoom(key=='0' and 0 or key=='-' and -5 or 5)
    elseif key=='application' and listBox.selected>=0 then
        local url=_getList()[listBox.selected].url
        if url then love.system.openURL(url) end
    elseif key=='delete' then
        if inputBox:hasText() then
            _clearResult()
            inputBox:clear()
            SFX.play('hold')
            _updateContentBox()
        end
    elseif key=='escape' then
        if inputBox:hasText() then
            scene.keyDown('delete')
        else
            SCN.back()
        end
    elseif key=='f1' then
        SCN.go(
            'textReader',nil,
            text.dict.helpText:repD(
                CHAR.key.up,CHAR.key.down,CHAR.key.left,CHAR.key.right,
                CHAR.controller.dpadU,CHAR.controller.dpadD,CHAR.controller.dpadL,CHAR.controller.dpadR,
                CHAR.controller.xboxX,CHAR.controller.xboxY,CHAR.controller.xboxA,CHAR.controller.xboxB,
                CHAR.icon.help,CHAR.icon.copy,CHAR.icon.globe,CHAR.key.winMenu),
            20,
            'rainbow'
        )

    -- ***ONLY USE FOR HOTLOADING ZICTIONARY WHILE IN GAME!***
    -- ***Please commenting out this code if you don't use***
    -- elseif key=='f5' then
    --     local _
    --     local success,_r=pcall(function()
    --         package.loaded[localeFile]=nil
    --         dict=require(localeFile)
    --         _scanDict(dict)
    --     end
    --     )
    --     if not success then
    --         SFX.play('finesseError_long')
    --         _,_r=getFont(30):getWrap(tostring(_r),1000)
    --         MES.new("error","Hotload failed! May need restarting!\n\n"..table.concat(_r,"\n"))
    --     else
    --         local lastLscrollPos=listBox.scrollPos
    --         local lastTscrollPos=contentBox.scrollPos

    --         listBox:setList(_getList())
    --         if #inputBox:getText()>0 then _search() end

    --         listBox.selected=lastSelected<#dict and lastSelected or #dict   -- In case the last item is removed!
    --         listBox.scrollPos=lastLscrollPos

    --         _updateContentBox()
    --         contentBox.scrollPos=lastTscrollPos
    --         SFX.play('pc')
    --     end
    else
        if not inputBoxFocus then WIDGET.focus(inputBox) end
        return true
    end
end

function scene.gamepadDown(key)
    local Joystick=love.joystick.getJoysticks()[love.joystick.getJoystickCount()]

    if key=='dpup' or key=='dpdown' then
        if Joystick:isGamepadDown('a') then
            _setZoom(key=='dpup' and 5 or -5)
        else
            contentBox:scroll(key=='dpup' and -3 or 3)
        end
    elseif key=='dpleft' or key=='dpright' then
        _jumpover(key:gsub('dp',''),Joystick:isGamepadDown('a') and 12)
    elseif key=='y' then
        scene.keyDown('f1')
    elseif key=='back' then
        SCN.back()
    end
end

function scene.update(dt)
    local input=inputBox:getText()
    if input~=lastTickInput then
        if #input==0 then
            _clearResult()
            listBox:setList(_getList())
        else
            searchWait=0.8
        end
        lastTickInput=input
    end
    if searchWait>0 then
        searchWait=searchWait-dt
        if searchWait<=0 and #input>0 and input~=lastSearch then
            _search()
        end
    end
    if listBox.selected~=lastSelected then
        lastSelected=listBox.selected
        _updateContentBox()
    end
end

function scene.draw()
    -- Draw background
    gc.setColor(COLOR.dX)
    gc.rectangle('fill',1194,260,80,370,5)
    -- Draw outline
    gc.setLineWidth(2)
    gc.setColor(COLOR.Z)
    gc.rectangle('line',1194,260,80,370)
    gc.line(1194,480,1274,480)

    if searchWait>0 then
        local r=TIME()*2
        local R=floor(r)%7+1
        gc.setColor(1,1,1,1-abs(r%1*2-1))
        gc.draw(TEXTURE.miniBlock[R],821,140,TIME()*10%6.2832,7,7,2*DSCP[R][0][2]+1,2*(#BLOCKS[R][0]-DSCP[R][0][1])-1)
    end
end

scene.widgetList={
    WIDGET.newText{name='book',x=20,y=15,font=70,align='L',fText=CHAR.icon.zBook},
    WIDGET.newText{name='title',x=100,y=15,font=70,align='L'},
    listBox,
    inputBox,
    contentBox,
    WIDGET.newKey{name='link',x=1234,y=520,w=60,font=45,fText=CHAR.icon.globe,code=pressKey'application',hideF=function() return not (listBox.selected>0 and _getList()[listBox.selected].url) end},
    WIDGET.newKey{name='copy',x=1234,y=590,w=60,font=40,fText=CHAR.icon.copy,code=pressKey'cC',hideF=function() return not (listBox.selected>0) end},

    WIDGET.newKey{name='fontup',x=1234,y=300,w=60,font=40,fText=CHAR.icon.fontUp,code=function() _setZoom(5) end},
    WIDGET.newKey{name='fontdown',x=1234,y=370,w=60,font=40,fText=CHAR.icon.fontDown,code=function() _setZoom(-5) end},
    WIDGET.newKey{name='resetzoom',x=1234,y=440,w=60,font=40,fText=CHAR.icon.zoomDefault,code=function() _setZoom(0) end},

    WIDGET.newButton{name='back',x=1185,y=60,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
    WIDGET.newKey{name='help',x=1170,y=140,w=200,h=60,font=40,fText=CHAR.controller.xboxY.."/[F1]: "..CHAR.icon.help,code=pressKey'f1'},
}
-- NOTE: The gap between Link-Copy, Zoom is 60*1.5-10=80; the gap between 2 buttons in one group is 60+10=70
return scene
