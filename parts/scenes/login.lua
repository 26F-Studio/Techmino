local scene={}

local gc=love.graphics
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw,gc_rectangle=gc.draw,gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf
local gc_push,gc_pop=gc.push,gc.pop
local gc_replaceTransform=gc.replaceTransform
local gc_line=gc.line
local setFont=FONT.set

local function _goCasual()
    SCN.go('net_rooms')
end
local function _goRanked()
    SCN.go('net_rooms')
end

local function _refreshOnline()
    NET.online_getPlayers()
end

local onlineList=WIDGET.newListBox{name='onlineList',x=680,y=230,w=500,h=340,lineH=40,drawF=function(item,id,ifSel)
    setFont(30)
    if ifSel then
        gc_setColor(1,1,1,.3)
        gc_rectangle('fill',0,0,500,40)
    end
    gc_setColor(1,1,1)
    gc_print(id,10,-4)
    if type(item)=='table' then
        gc_setColor(.9,.9,1)
        gc_print(item.username or "Unknown",60,-4)
        if type(item.elo)=='number' then
            gc_setColor(COLOR.lY)
            gc_printf(tostring(item.elo),280,-4,120,'right')
        end
    end
end}

function scene.enter()
    NET.online_getPlayers()
end

function scene.keyDown(key,rep)
    if key=='escape' and not rep then
        SCN.back()
    elseif key=='return' or key=='kpenter' then
        _submit()
    elseif key=='v' and love.keyboard.isDown('lctrl','rctrl') then
        local t=CLIPBOARD.get()
        if t then
            t=STRING.trim(t)
            if #t==128 and t:match("^[0-9A-Z]+$") then
                scene.widgetList.ticket:setText(t)
            end
        end
    elseif key=='r' and love.keyboard.isDown('lctrl','rctrl') then
        _refreshOnline()
    else
        return true
    end
end

function scene.update(dt)
    local list={}
    if NET.onlinePlayers then
        for _,p in next,NET.onlinePlayers do
            table.insert(list,p)
        end
    end
    onlineList:setList(list)
end

local playerName=""
local nameTextObj,nameScaleK,nameWidth,nameOffY

function scene.draw()
    -- Player tab (top-right)
    gc_push('transform')
    gc_replaceTransform(SCR.xOy_ur)
        gc_setColor(.15,.15,.15,.85)
        gc_rectangle('fill',-320,10,310,100,6)
        gc_setColor(1,1,1)
        gc_setLineWidth(2)
        gc_rectangle('line',-320,10,310,100,6)

        gc_setColor(1,1,1)
        gc_rectangle('line',-308,20,74,74,3)
        gc_draw(USERS.getAvatar(USER.uid),-306,22,nil,.58)

        local username=USERS.getUsername(USER.uid)
        if username~=playerName then
            playerName=username
            nameTextObj=GC.newText(getFont(25),username)
            nameWidth=nameTextObj:getWidth()
            nameScaleK=170/math.max(nameWidth,170)
            nameOffY=nameTextObj:getHeight()/2
        end
        gc_setColor(COLOR.Z)
        gc_draw(nameTextObj,-222,32,nil,nameScaleK,nil,nameWidth,nameOffY)

        setFont(18)
        gc_setColor(COLOR.lH)
        local rankStr=STAT.globalRank>0 and ("#"..STAT.globalRank) or "Unranked"
        gc_print(text.globalRank.." "..rankStr,-222,58)

        gc_setColor(COLOR.lY)
        gc_print(text.elo.." "..(STAT.elo or 1200),-222,80)
    gc_pop()

    -- Online players label
    setFont(35)
    gc_setColor(COLOR.Z)
    gc_print(text.onlinePlayers or "Online Players",680,150)
    gc_setColor(1,1,1,.5)
    setFont(20)
    gc_print(text.onlinePlayerCount:repD(NET.onlineCount),680,192)

    gc_setColor(1,1,1,.2)
    gc_setLineWidth(1)
    gc_line(680,225,1180,225)
end

scene.widgetList={
    WIDGET.newText{name='title',        x=80,  y=50,font=70,align='L'},

    WIDGET.newKey{name='Casual Mode',   x=200, y=600,w=240,h=80,font=35,color='lG',code=_goCasual},
    WIDGET.newKey{name='Ranked Mode',    x=450, y=600,w=240,h=80,font=35,color='lY',code=_goRanked},

    WIDGET.newKey{name='refresh',       x=1120,y=150,w=60, h=40,font=20,code=_refreshOnline},

    WIDGET.newButton{name='back',       x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},

    onlineList,
}

return scene