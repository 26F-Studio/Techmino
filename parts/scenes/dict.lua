local gc=love.graphics

local int,abs=math.floor,math.abs
local min,sin=math.min,math.sin
local ins=table.insert
local find=string.find

local scene={}

local dict-- Dict list
local result-- Result Lable

local lastTickInput
local searchWait-- Searching animation timer

local lastSearch-- Last searched string
local lastSelected -- Last selected item
local justSearched -- Just searched or not?

local currentFontSize=25 -- Current font size, default: 25 
local showingHelp=false  -- Help is triggered or not
local zoomWait=0         -- The last time zoom is triggered

local oldScrollPos=0
local lastMouseX,lastMouseY,lastTouchX,lastTouchY

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
        O.keywords=O[2]
        O.type=O[3]
        O.content,O.content_Org=_filter(O[4])
        O.url=O[5]
        cut(O)
    end
end
local function _getList() return result[1] and result or dict end

-- Drawing objects
local infoBox =WIDGET.newTextBox {name='infoBox',x=320,y=180,w=862,h=526,font=25,fix=true}
local inputBox=WIDGET.newInputBox{name='input',  x=20, y=110,w=762,h=60, font=40,limit=32}
local listBox =WIDGET.newListBox {name='listBox',x=20, y=180,w=280,h=526,font=30,lineH=35,drawF=function(item,id,ifSel)
    -- Draw list box
        -- Background
    if ifSel then
        gc.setColor(1,1,1,.4)
        gc.rectangle('fill',0,0,280,35)
    end

        -- Name & color
    local item=_getList()[id]
    GC.shadedPrint(item.title,10,-3,'left',1,COLOR.D,typeColor[item.type])
    -- Draw list box /
end}
-- Drawing object /



-- Necessary local functions
-- Clear the result
local function _clearResult()
    TABLE.cut(result)
    listBox.selected=1
    justSearched=true
    searchWait,lastSearch=0,false
    scene.widgetList.copy.hide=false
end
-- Search through the dictionary
local function _search()
    local input=inputBox:getText():lower()
    _clearResult()
    local first
    for i=1,#dict do
        local pos=find(dict[i].title:lower(),input,nil,true) or find(dict[i].keywords:lower(),input,nil,true)
        if pos==1 and not first then
            ins(result,1,dict[i])
            first=true
        elseif pos then
            ins(result,dict[i])
        end
    end
    if #result>0 then
        SFX.play('reach')
        justSearched=true
    end
    lastSearch=input
end

-- Jump over n items
local function _jumpover(key,n)
    n=n or 1
    if key=='left' or key=='pageup' then
         for _=1,n do scene.widgetList.listBox:arrowKey('up')   end
    else for _=1,n do scene.widgetList.listBox:arrowKey('down') end end
end

-- Copy the content
local function _copy()
    local t=_getList()[listBox.selected]
    t=t.title_Org..":\n"..t.content_Org..(t.url and "\n[ "..t.url.." ]\n" or "\n")..text.dictNote
    love.system.setClipboardText(t)
    scene.widgetList.copy.hide=true
    MES.new('info',text.copyDone)
end

-- Update the infobox
local function _updateInfoBox(c)
    local _t,t
    if c==nil then
        if showingHelp then
            if text.dict.helpText then
                t,_t=text.dict.helpText:repD(
                        CHAR.key.up,           CHAR.key.down,         CHAR.key.left,         CHAR.key.right,
                        CHAR.controller.xboxX, CHAR.controller.xboxY, CHAR.controller.xboxA, CHAR.controller.xboxB,
                        
                        CHAR.icon.help, CHAR.icon.copy,   CHAR.icon.globe,
                        CHAR.icon.toUp, CHAR.icon.toDown, CHAR.key.winMenu
                ),true
            else _t,t=true,{"NO HELP TEXT AVAILABLE!\n","Please switch language to English and try again to read the help text"} end
        else _t,t=pcall(function() return _getList()[listBox.selected].content end) end
        if _t then c=t else c={""} end
        _t,t=nil,nil
    end
    local _w,c=FONT.get(currentFontSize):getWrap(c,840)
    infoBox:setTexts(c)
end

-- Show Help or not
local function _toggleHelp()
    local listBox = scene.widgetList.listBox
    showingHelp   = not showingHelp
    if not showingHelp then
        listBox.selected=lastSelected
        scene.widgetList.copy.hide=false
    end
    _updateInfoBox()
end

-- Zoom and reset zoom
local function _openZoom() zoomWait=2 end
local function _resetZoom()
    currentFontSize,infoBox.font=25,25
    infoBox.lineH,infoBox.capacity=35,math.ceil((infoBox.h-10)/35)
    _updateInfoBox()
    MES.new("check",text.dict.sizeReset,1.26)
end
local function _setZoom(z)
    if z~=0 then
        currentFontSize=MATH.clamp(currentFontSize+z,15,40)
        infoBox.font=currentFontSize
        infoBox.lineH=currentFontSize*7/5   -- Recalculate the line's height
        infoBox.capacity=math.ceil((infoBox.h-10)/infoBox.lineH)
        _updateInfoBox()
        _openZoom()
        MES.new("check",text.dict.sizeChanged:repD(currentFontSize),1.26)
    end
end

-- Checking if waiting countdown reach 0 to run the function.
--
-- currentCountdown: the variable that tracking waiting time
-- timeEndF: run this function if the time reach 0
-- nTimeEndF: run this function if the time has not reached 0
--
-- NOTE: This function will return the modified value of currentcountdown
local function _waitingfor(currentcountdown, timeEndF, nTimeEndF)
    currentcountdown = currentcountdown or 0
    timeEndF = timeEndF  or function() end
    nTimeEndF= nTimeEndF or function() end

    if currentcountdown>0 then
        currentcountdown=currentcountdown-love.timer.getDelta()
        if currentcountdown<=0 then timeEndF() else nTimeEndF() end
    end
    return currentcountdown
end

local function fixScrollingByTouch(x,y,lastX,lastY)
    if WIDGET.isFocus(listBox) then
        if abs(oldScrollPos-listBox.scrollPos)>26 then
            oldScrollPos=listBox.scrollPos
            listBox.selected=lastSelected
            listBox.scrollPos=oldScrollPos
        else
            lastSelected=listBox.selected
            scene.widgetList.copy.hide=false
            _updateInfoBox()
        end
    end
end

-- Reset everything when opening Zictionary
function scene.enter()
    dict=require("parts.language.dict_"..(SETTING.locale:find'zh' and 'zh' or SETTING.locale:find'ja' and 'ja' or SETTING.locale:find'vi' and 'vi' or 'en'))
    _scanDict(dict)

    inputBox:clear()
    result={}

    if showingHelp then _toggleHelp() end

    searchWait=0
    lastSelected=0
    listBox.selected=1
    lastSearch=false

    if not MOBILE then WIDGET.focus(inputBox) end
    BG.set('rainbow')
end

function scene.wheelMoved(_,y)
    WHEELMOV(y)
end
function scene.keyDown(key)
    -- Switching selected items
    if key=='up' or key=='down' then
        if not showingHelp then
            if love.mouse.isDown(2,3) then 
                listBox:arrowKey(key)
                return
            elseif WIDGET.isFocus(listBox) then
                listBox:scroll(key=='up' and -1 or 1)
                return
            end
        end
        infoBox:scroll(key=='up' and -3 or 3)

    elseif (key=='left'  or key=='pageup' or key=='right' or key=='pagedown')
    then
        if love.keyboard.isDown('lctrl','rctrl','lalt','ralt','lshift','rshift')
            then _jumpover(key,12)
            else _jumpover(key,1)
            end

    -- Copy & Zoom
    elseif key=='cC' then _copy()
    elseif love.keyboard.isDown('lctrl','rctrl') then
        if key == 'c' and not showingHelp then _copy() return
        elseif love.keyboard.isDown('-','=','kp-','kp+') then _setZoom((key=='-' or key=='kp-') and -5 or 5)
        elseif love.keyboard.isDown('0','kp0') then _resetZoom() end

    -- Clear search input, open URL
    elseif key=='application' and not showingHelp then
        local url=_getList()[listBox.selected].url
        if url then love.system.openURL(url) end
    elseif key=='delete' and not showingHelp then
        if inputBox:hasText() then
            _clearResult()
            inputBox:clear()
            SFX.play('hold')
        end

    -- Get out of Zictionary
    elseif key=='escape' then
        if inputBox:hasText() then scene.keyDown('delete')
        elseif showingHelp then _toggleHelp()
        else SCN.back()
        end
    -- Calling Help
    elseif key=='f1' then _toggleHelp()
    -- Focus on the search box
    else
        if not WIDGET.isFocus(inputBox) then WIDGET.focus(inputBox) end
        return true
    end
end

function scene.gamepadDown(key)
    local Joystick=love.joystick.getJoysticks()[love.joystick.getJoystickCount()]

    -- Scrolling text & zooming
    if (key=='dpup' or key=='dpdown') then
        if   Joystick:isGamepadDown('a')
        then _setZoom(key=='dpup' and 5 or -5)
        else infoBox:scroll(key=='dpup' and -3 or 3)
        end
    -- Switching selected items
    elseif key=='dpleft' or key=='dpright' then
        _jumpover(key:gsub('dp',''),Joystick:isGamepadDown('a') and 12 or 1)
    -- Activate help
    elseif key=='y' then _toggleHelp()
    -- Exit
    elseif key=='back' then SCN.back()
    end
end

function scene.mouseDown(mx,my)
    lastMouseX,lastMouseY=mx,my
end
function scene.touchDown(mx,my)
    lastTouchX,lastTouchY=mx,my
end

-- Check if left mouse key is released
function scene.mouseUp(mx,my)
    fixScrollingByTouch(mx,my,lastMouseX,lastMouseY)
end
function scene.touchUp(mx,my)
    fixScrollingByTouch(mx,my,lastTouchX,lastTouchY)
end

function scene.update(dt)
    -- It's time to search?
    local input=inputBox:getText()
    if input~=lastTickInput then
        if #input==0 then
            _clearResult()
        else
            searchWait=.8
        end
        lastTickInput=input
    end
    searchWait=_waitingfor(
        searchWait,
        function() if #input>0 and input~=lastSearch then _search() end end
    )
    -- It's time to swap zoom buttons?
    zoomWait=_waitingfor(
        zoomWait,
        function()
            scene.widgetList.openzoom .hide=false
            scene.widgetList.resetzoom.hide=false
            scene.widgetList.zoomin   .hide=true
            scene.widgetList.zoomout  .hide=true
        end,
        function()
            scene.widgetList.openzoom .hide=true
            scene.widgetList.resetzoom.hide=true
            scene.widgetList.zoomin   .hide=false
            scene.widgetList.zoomout  .hide=false
        end
    )
end

local function listStencil()
    GC.rectangle('fill',20,180,280,526)
end
function scene.draw()
    -- Order: list, info, keys
    -- Draw background
    gc.setColor(COLOR.dX)
    gc.rectangle('fill',1194,180,80,526,5)  -- keys
    -- Draw outline
    gc.setLineWidth(2)
    gc.setColor(COLOR.Z)
    gc.rectangle('line',1194,180,80,526,5)  -- keys
    -- Draw key seperating outline
    gc.rectangle('line',1194,260,80,1,0)    -- A | B
    gc.rectangle('line',1194,410,80,1,0)    -- B | C
    gc.rectangle('line',1194,560,80,1,0)    -- C | D

    local list=_getList()
    setFont(30)

    -- Showing Help?
    if showingHelp then
        listBox.selected=0
        scene.widgetList.copy.hide,scene.widgetList.link.hide=true,true
    -- If not then, check the selected item if it is changed or not?
    -- If yes, update lastSelected then update the textbox!
    elseif justSearched then
        listBox:setList(_getList())
        justSearched=false
    elseif lastSelected~=listBox.selected and not love.mouse.isDown(1) then
        _updateInfoBox()
        lastSelected=listBox.selected
        scene.widgetList.copy.hide=false
    end

    if searchWait>0 then
        local r=TIME()*2
        local R=int(r)%7+1
        gc.setColor(1,1,1,1-abs(r%1*2-1))
        gc.draw(TEXTURE.miniBlock[R],821,140,TIME()*10%6.2832,7,7,2*DSCP[R][0][2]+1,2*(#BLOCKS[R][0]-DSCP[R][0][1])-1)
    end
end

scene.widgetList={
    WIDGET.newText   {name='book',    x=20,  y=15, font=70,align='L',fText=CHAR.icon.zBook},
    WIDGET.newText   {name='title',   x=100, y=15, font=70,align='L'},
    listBox,
    inputBox,
    infoBox,
    WIDGET.newKey   {name='link',     x=1234,y=600,w=60,font=45,fText=CHAR.icon.globe, code=pressKey'application',hideF=function() return not ((not (showingHelp or listBox.selected==0)) and _getList()[listBox.selected].url) end},
    WIDGET.newKey   {name='copy',     x=1234,y=670,w=60,font=40,fText=CHAR.icon.copy,  code=pressKey'cC'},
    
    WIDGET.newKey   {name='openzoom', x=1234,y=300,w=60,font=25,fText="aA",            code=function() _openZoom()  end,hide=false},
    WIDGET.newKey   {name='resetzoom',x=1234,y=370,w=60,font=25,fText="100%",          code=function() _resetZoom() end,hide=false},
    WIDGET.newKey   {name='zoomin',   x=1234,y=300,w=60,font=40,fText="A",             code=function() _setZoom(5)  end,hide=true},
    WIDGET.newKey   {name='zoomout',  x=1234,y=370,w=60,font=40,fText="a",             code=function() _setZoom(-5) end,hide=true},

    WIDGET.newKey   {name='pageup',   x=1234,y=450,w=60,font=40,fText=CHAR.icon.toUp,  hideF=function() return love.mouse.isDown(2,3) or showingHelp end,code=function() _jumpover('left')  end},
    WIDGET.newKey   {name='pagedown', x=1234,y=520,w=60,font=40,fText=CHAR.icon.toDown,hideF=function() return love.mouse.isDown(2,3) or showingHelp end,code=function() _jumpover('right') end},

    WIDGET.newKey   {name='pageup1',  x=1234,y=450,w=60,font=40,fText=CHAR.key.up,     hideF=function() return not love.mouse.isDown(2,3) or showingHelp end,color="A"},
    WIDGET.newKey   {name='pagedown1',x=1234,y=520,w=60,font=40,fText=CHAR.key.down,   hideF=function() return not love.mouse.isDown(2,3) or showingHelp end,color="A"},

    WIDGET.newKey   {name='help0',    x=1234,y=220,w=60,font=40,fText=CHAR.icon.help,  code=pressKey'f1',hideF=function() return     showingHelp end},
    WIDGET.newKey   {name='help1',    x=1234,y=220,w=60,font=40,fText=CHAR.icon.help,  code=pressKey'f1',hideF=function() return not showingHelp end,color='lF'},

    WIDGET.newButton{name='back',     x=1165,y=60, w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
    WIDGET.newText  {name='buttontip',x=1274,y=110,w=762,h=60,font=40,align='R',fText=CHAR.controller.xboxY.."/[F1]: "..CHAR.icon.help}
}
-- NOTE: The gap between Link-Copy, Page, Zoom, Help is 60*1.5-10=80 :) The gap between 2 buttons in one group is 60+10=70
return scene
