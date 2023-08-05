local gc=love.graphics

local int,abs=math.floor,math.abs
local ins=table.insert
local find=string.find

local scene={}

local dict-- Dict list
local result-- Result Lable

local lastTickInput
local searchWait-- Searching animation timer

local lastSearch-- Last searched string
local lastSelected -- Last selected item

local currentFontSize=25 -- Current font size, default: 25

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

local textBox =WIDGET.newTextBox {name='infoBox',x=320,y=180,w=862,h=526,font=25,fix=true}
local inputBox=WIDGET.newInputBox{name='input',  x=20, y=110,w=762,h=60, font=40,limit=32}
local listBox =WIDGET.newListBox {name='listBox',x=20, y=180,w=280,h=526,font=30,lineH=35,drawF=function(item,id,ifSel)
    -- Background
    if ifSel then
        gc.setColor(1,1,1,.4)
        gc.rectangle('fill',0,0,280,35)
    end
    -- Name & color
    GC.shadedPrint(item.title,10,-3,'left',1,COLOR.D,typeColor[item.type])
end}

-- Necessary local functions
-- Clear the result
local function _clearResult()
    TABLE.cut(result)
    listBox.selected=1
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

    listBox:setList(_getList())

    if #result>0 then SFX.play('reach') end
    lastSearch=input
end

-- Jump over n items
local function _jumpover(key,n)
    local dir=(key=='left' or key=='pageup') and 'up' or 'down'
    for _=1,n or 1 do scene.widgetList.listBox:arrowKey(dir) end
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
local function _updateTextBox(c)
    local _t,t
    if c==nil then
        if listBox.selected==0 then
            if text.dict.helpText then
                _t,t=true,text.dict.helpText:repD(
                    CHAR.key.up,CHAR.key.down,CHAR.key.left,CHAR.key.right,
                    CHAR.controller.dpadU,CHAR.controller.dpadD,CHAR.controller.dpadL,CHAR.controller.dpadR,
                    CHAR.controller.xboxX,CHAR.controller.xboxY,CHAR.controller.xboxA,CHAR.controller.xboxB,
                    CHAR.icon.help,CHAR.icon.copy,CHAR.icon.globe,CHAR.key.winMenu
                )
            else
                _t,t=true,{
                "OUCH! I can't seem to find any translated Help text anywhere.",
                "\nI guess you'll have to switch to English and try again to read it instead!",
                "\n\nOn another note, you could make an issue on GitHub or send this to Techmino's Discord server.",
                "\nThe cause? I'm not sure... My guess is that there's something seriously wrong with the language files or the source code of this scene. BUT all the language files have a callback to English, and the original language - Chinese - has a version of the Help text! I'm not entirely certain if it worked or not, though.",
                "\n\nOh, and it would be nice if you could let us know about it or you can fix it by yourself!",
                "\n\n-- Sea, the one who rewrote the Zictionary scene and left this message just in case."
            } end
        else
            _t,t=pcall(function() return _getList()[listBox.selected].content end)
        end
        if _t then c=t else c={""} end
        _t,t=nil,nil
    end
    local _w,c=FONT.get(currentFontSize):getWrap(c,840)
    textBox:setTexts(c)
end

-- Zoom and reset zoom
local function _resetZoom()
    currentFontSize,textBox.font=25,25
    textBox.lineH,textBox.capacity=35,math.ceil((textBox.h-10)/35)
    _updateTextBox()
    MES.new("check",text.dict.sizeReset,1.26)
end
local function _setZoom(z)
    if z~=0 then
        currentFontSize=MATH.clamp(currentFontSize+z,15,40)
        textBox.font=currentFontSize
        textBox.lineH=currentFontSize*7/5   -- Recalculate the line's height
        textBox.capacity=math.ceil((textBox.h-10)/textBox.lineH)
        _updateTextBox()
        MES.new("check",text.dict.sizeChanged:repD(currentFontSize),1.26)
    end
end

-- Reset everything when opening Zictionary
function scene.enter()
    dict=require("parts.language.dict_"..(SETTING.locale:find'zh' and 'zh' or SETTING.locale:find'ja' and 'ja' or SETTING.locale:find'vi' and 'vi' or 'en'))
    _scanDict(dict)

    inputBox:clear()
    result={}

    searchWait=0
    lastSelected=0
    listBox.selected=1
    listBox.scrollPos=0
    lastSearch=false

    if not MOBILE then WIDGET.focus(inputBox) end
    BG.set('galaxy2')
end

function scene.wheelMoved(_,y)
    if WIDGET.sel==listBox then
        listBox:scroll(-y)
    else
        textBox:scroll(-y)
    end
end
function scene.keyDown(key)
    -- Switching selected items
    if key=='up' or key=='down' then
        textBox:scroll(key=='up' and -1 or 1)

    elseif (key=='left' or key=='pageup' or key=='right' or key=='pagedown') then
        _jumpover(key,love.keyboard.isDown('lctrl','rctrl','lalt','ralt','lshift','rshift') and 12)

    elseif key=='cC' or key=='c' and love.keyboard.isDown('lctrl','rctrl') then
        if listBox.selected>0 then
            _copy()
        end

    elseif key=='-' or key=='=' then
        _setZoom((key=='-' or key=='kp-') and -5 or 5)
    elseif key=='0' then
        _resetZoom()

    elseif key=='application' and listBox.selected>=0 then
        local url=_getList()[listBox.selected].url
        if url then love.system.openURL(url) end
    elseif key=='delete' then
        if inputBox:hasText() then
            _clearResult()
            inputBox:clear()
            SFX.play('hold')
            _updateTextBox()
        end
    elseif key=='escape' then
        if inputBox:hasText() then
            scene.keyDown('delete')
        else
            SCN.back()
        end
    elseif key=='f1' then
        listBox.selected=listBox.selected==0 and lastSelected or 0
        inputBox:clear()
        searchWait=0
        _updateTextBox()
    else
        if not WIDGET.isFocus(inputBox) then WIDGET.focus(inputBox) end
        return true
    end
end

function scene.gamepadDown(key)
    local Joystick=love.joystick.getJoysticks()[love.joystick.getJoystickCount()]

    if key=='dpup' or key=='dpdown' then
        if Joystick:isGamepadDown('a') then
            _setZoom(key=='dpup' and 5 or -5)
        else
            textBox:scroll(key=='dpup' and -3 or 3)
        end
    elseif key=='dpleft' or key=='dpright' then
        _jumpover(key:gsub('dp',''),Joystick:isGamepadDown('a') and 12)
    elseif key=='y' then
        listBox.selected=0
        inputBox:clear()
        searchWait=0
        _updateTextBox()
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
            searchWait=.8
        end
        lastTickInput=input
    end
    if searchWait>0 then
        searchWait=searchWait-dt
        if searchWait<=0 and #input>0 and input~=lastSearch then
            _search()
        end
    end

    if lastSelected~=listBox.selected and listBox.selected>0 then
        _updateTextBox()
        lastSelected=listBox.selected
        scene.widgetList.copy.hide=false
    end
end

function scene.draw()
    -- Order: list, info, keys
    -- Draw background
    gc.setColor(COLOR.dX)
    gc.rectangle('fill',1194,335,80,371,5)
    -- Draw outline
    gc.setLineWidth(2)
    gc.setColor(COLOR.Z)
    gc.rectangle('line',1194,335,80,371,5)
    gc.line(1194,555,1274,555)

    setFont(30)

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
    textBox,
    WIDGET.newKey   {name='link',     x=1234,y=595,w=60,font=45,fText=CHAR.icon.globe,      code=pressKey'application',hideF=function() return not (listBox.selected>0 and _getList()[listBox.selected].url) end},
    WIDGET.newKey   {name='copy',     x=1234,y=665,w=60,font=40,fText=CHAR.icon.copy,       code=pressKey'cC',hideF=function() return not (listBox.selected>0) end},

    WIDGET.newKey   {name='zoomin',   x=1234,y=375,w=60,font=40,fText=CHAR.icon.zoomIn,     code=function() _setZoom(5)  end},
    WIDGET.newKey   {name='zoomout',  x=1234,y=445,w=60,font=40,fText=CHAR.icon.zoomOut,    code=function() _setZoom(-5) end},
    WIDGET.newKey   {name='resetzoom',x=1234,y=515,w=60,font=40,fText=CHAR.icon.zoomDefault,code=function() _resetZoom() end},

    WIDGET.newKey   {name='help',     x=1234,y=220,w=60,font=40,fText=CHAR.icon.help,   code=pressKey'f1'},

    WIDGET.newButton{name='back',     x=1165,y=60, w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
    WIDGET.newText  {name='buttontip',x=1274,y=110,w=762,h=60,font=40,align='R',fText=CHAR.controller.xboxY.."/[F1]: "..CHAR.icon.help}
}
-- NOTE: The gap between Link-Copy, Zoom, is 60*1.5-10=80 :) The gap between 2 buttons in one group is 60+10=70
return scene
