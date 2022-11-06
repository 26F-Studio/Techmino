local gc=love.graphics

local inputBox=WIDGET.newInputBox{name='input',x=20,y=110,w=762,h=60,font=40,limit=32}
local int,abs=math.floor,math.abs
local min,sin=math.min,math.sin
local ins=table.insert
local find=string.find

local scene={}

local dict-- Dict list
local result-- Result Lable

local lastTickInput
local searchWait-- Searching animation timer
local selected-- Selected option
local scrollPos-- Scroll down length

local lastSearch-- Last searched string

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
local function _filter(word_org)
    local word=word_org
    word=word:gsub("[Tt]etris",CHAR.zChan.thinking)
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
local function _clearResult()
    TABLE.cut(result)
    selected=1
    scrollPos=0
    searchWait,lastSearch=0,false
    scene.widgetList.copy.hide=false
end
local function _search()
    local input=inputBox:getText():lower()
    _clearResult()
    local first
    for i=1,#dict do
        local pos=find(dict[i].title:lower(),input,nil,true) or find(dict[i].keywords,input,nil,true)
        if pos==1 and not first then
            ins(result,1,dict[i])
            first=true
        elseif pos then
            ins(result,dict[i])
        end
    end
    if #result>0 then
        SFX.play('reach')
    end
    lastSearch=input
end

function scene.enter()
    dict=require("parts.language.dict_"..(SETTING.locale:find'zh' and 'zh' or SETTING.locale:find'ja' and 'ja' or 'en'))
    _scanDict(dict)

    inputBox:clear()
    result={}

    searchWait=0
    selected=1
    scrollPos=0

    lastSearch=false
    WIDGET.focus(inputBox)
    BG.set('rainbow')
end

function scene.wheelMoved(_,y)
    WHEELMOV(y)
end
function scene.keyDown(key)
    if key=='up' then
        if selected and selected>1 then
            selected=selected-1
            if selected<scrollPos+1 then
                scrollPos=scrollPos-1
            end
            scene.widgetList.copy.hide=false
        end
    elseif key=='down' then
        if selected and selected<#_getList() then
            selected=selected+1
            if selected>scrollPos+15 then
                scrollPos=selected-15
            end
            scene.widgetList.copy.hide=false
        end
    elseif key=='left' or key=='pageup' then
        for _=1,12 do scene.keyDown('up') end
    elseif key=='right' or key=='pagedown' then
        for _=1,12 do scene.keyDown('down') end
    elseif key=='application' then
        local url=_getList()[selected].url
        if url then love.system.openURL(url) end
    elseif key=='delete' then
        if inputBox:hasText() then
            _clearResult()
            inputBox:clear()
            SFX.play('hold')
        end
    elseif key=='escape' then
        if inputBox:hasText() then
            scene.keyDown('delete')
        else
            SCN.back()
        end
    elseif key=='c' and love.keyboard.isDown('lctrl','rctrl') or key=='cC' then
        local t=_getList()[selected]
        t=t.title_Org..":\n"..t.content_Org..(t.url and "\n[ "..t.url.." ]\n" or "\n")..text.dictNote
        love.system.setClipboardText(t)
        scene.widgetList.copy.hide=true
        MES.new('info',text.copyDone)
        return
    else
        if not WIDGET.isFocus(inputBox) then
            WIDGET.focus(inputBox)
        end
        return true
    end
end

function scene.update(dt)
    local input=inputBox:getText()
    if input~=lastTickInput then
        if #input==0 then
            _clearResult()
        else
            searchWait=.8
        end
        lastTickInput=input
    end
    if searchWait>0 then
        searchWait=searchWait-dt
        if searchWait<=0 then
            if #input>0 and input~=lastSearch then
                _search()
            end
        end
    end
end

function scene.draw()
    gc.setColor(COLOR.dX)
    gc.rectangle('fill',300,180,958,526,5)
    gc.rectangle('fill',20,180,280,526,5)
    gc.setLineWidth(2)
    gc.setColor(COLOR.Z)
    gc.rectangle('line',300,180,958,526,5)
    gc.rectangle('line',20,180,280,526,5)

    local list=_getList()
    gc.setColor(COLOR.Z)
    local t=list[selected].content
    setFont(
        #t>900 and 15 or
        #t>600 and 20 or
        #t>400 and 25 or
        30
    )
    gc.printf(t,306,180,950)

    setFont(30)
    gc.setColor(1,1,1,.4+.05*sin(TIME()*12.6))
    gc.rectangle('fill',20,143+35*(selected-scrollPos),280,35)

    setFont(30)
    for i=1,min(#list,15) do
        local y=142+35*i
        i=i+scrollPos
        local item=list[i]
        gc.setColor(COLOR.D)
        gc.print(item.title,29,y-1)
        gc.print(item.title,29,y+1)
        gc.print(item.title,31,y-1)
        gc.print(item.title,31,y+1)
        gc.setColor(typeColor[item.type])
        gc.print(item.title,30,y)
    end

    if searchWait>0 then
        local r=TIME()*2
        local R=int(r)%7+1
        gc.setColor(1,1,1,1-abs(r%1*2-1))
        gc.draw(TEXTURE.miniBlock[R],821,140,TIME()*10%6.2832,7,7,2*DSCP[R][0][2]+1,2*(#BLOCKS[R][0]-DSCP[R][0][1])-1)
    end
end

scene.widgetList={
    WIDGET.newText{name='book',   x=20,y=15,font=70,align='L',fText=CHAR.icon.zBook},
    WIDGET.newText{name='title',  x=100,y=15,font=70,align='L'},
    inputBox,
    WIDGET.newKey{name='link',    x=1120,y=655,w=80,font=55,fText=CHAR.icon.globe, code=pressKey'application',hideF=function() return not _getList()[selected].url end},
    WIDGET.newKey{name='copy',    x=1210,y=655,w=80,font=50,fText=CHAR.icon.copy,  code=pressKey'cC'},
    WIDGET.newKey{name='up',      x=1120,y=475,w=80,font=50,fText=CHAR.key.up,     code=pressKey'up',hide=not MOBILE},
    WIDGET.newKey{name='down',    x=1120,y=565,w=80,font=50,fText=CHAR.key.down,   code=pressKey'down',hide=not MOBILE},
    WIDGET.newKey{name='pageup',  x=1210,y=475,w=80,font=50,fText=CHAR.icon.toUp,  code=pressKey'pageup',hide=not MOBILE},
    WIDGET.newKey{name='pagedown',x=1210,y=565,w=80,font=50,fText=CHAR.icon.toDown,code=pressKey'pagedown',hide=not MOBILE},
    WIDGET.newButton{name='back', x=1165,y=60,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
