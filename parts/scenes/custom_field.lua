local gc,sys=love.graphics,love.system
local kb=love.keyboard

local max,min,int=math.max,math.min,math.floor
local ins,rem=table.insert,table.remove

local FIELD=FIELD
local scene={}

local curPen
local pens={-2,0,-1,[false]=false}-- Color (air/smart)
local penMode
local penPath={}
local penX,penY
local demo-- If show x
local page

local function isEmpty(L)
    for i=1,#L do
        if L[i]~=0 then return end
    end
    return true
end
local penKey={
    ['1']=1,['2']=2,['3']=3,['4']=4,['5']=5,['6']=6,['7']=7,['8']=8,
    q=9,w=10,e=11,r=12,t=13,y=14,u=15,i=16,
    a=17,s=18,d=19,f=20,g=21,h=22,j=23,k=24,
    z=0,x=-1,c=-2,
}
local minoPosCode={
    [102]=1,[1121]=1,-- Z
    [195]=2,[610]=2,-- S
    [39]=3,[1569]=3,[228]=3,[1091]=3,-- J
    [135]=4,[547]=4,[225]=4,[1602]=4,-- L
    [71]=5,[609]=5,[226]=5,[1122]=5,-- T
    [99]=6,-- O
    [15]=7,[4641]=7,-- I
    [1606]=8,[2273]=8,-- Z5
    [3139]=9,[740]=9,-- S5
    [103]=10,[1633]=10,[230]=10,[1123]=10,-- P
    [199]=11,[611]=11,[227]=11,[1634]=11,-- Q
    [738]=12,[3170]=12,[1252]=12,[1219]=12,-- F
    [2274]=13,[1126]=13,[1249]=13,[1730]=13,-- E
    [1095]=14,[737]=14,[3650]=14,[2276]=14,-- T5
    [167]=15,[1571]=15,[229]=15,[1603]=15,-- U
    [2183]=16,[551]=16,[3617]=16,[3716]=16,-- V
    [614]=17,[3169]=17,[1732]=17,[2243]=17,-- W
    [1250]=18,-- X
    [47]=19,[12833]=19,[488]=19,[9283]=19,-- J5
    [271]=20,[4643]=20,[481]=20,[13378]=20,-- L5
    [79]=21,[5665]=21,[484]=21,[9314]=21,-- R
    [143]=22,[4705]=22,[482]=22,[9794]=22,-- Y
    [110]=23,[9761]=23,[236]=23,[9313]=23,-- N
    [391]=24,[4706]=24,[451]=24,[5698]=24,-- H
    [31]=25,[21025]=25,-- I5
    [7]=26,[545]=26,-- I3
    [67]=27,[35]=27,[97]=27,[98]=27,-- C
    [3]=28,[33]=28,-- I2
    [1]=29,-- O1
}
local function _pTouch(x,y)
    if not curPen then return end
    for i=1,#penPath do
        if x==penPath[i][1] and y==penPath[i][2] then
            return
        end
    end
    if #penPath==0 then
        penMode=
            pens[curPen]>0 and (FIELD[page][y][x]~=pens[curPen] and 0 or 1) or
            pens[curPen]==0 and 1 or
            pens[curPen]==-1 and 0 or
            pens[curPen]==-2 and (FIELD[page][y][x]<=0 and 0 or 1)
    end
    ins(penPath,{x,y})
end
local function _pDraw()
    local l=#penPath
    if l==0 then return end

    local C-- Color
    if penMode==0 then
        if pens[curPen]==-2 then
            if l<=5 then
                local sum=0
                local x,y={},{}
                for i=1,l do
                    ins(x,penPath[i][1])
                    ins(y,penPath[i][2])
                end
                local minY,minX=min(unpack(y)),min(unpack(x))
                for i=1,#y do
                    sum=sum+2^((11-(y[i]-minY))*(y[i]-minY)/2+(x[i]-minX))
                end
                if minoPosCode[sum] then
                    C=SETTING.skin[minoPosCode[sum]]
                end
            else
                C=20
            end
        else
            C=pens[curPen]
        end
    else
        C=0
    end

    local F=FIELD[page]
    if C then
        for i=1,l do
            F[penPath[i][2]][penPath[i][1]]=C
        end
    end
    penPath={}
    penMode=0

    while #F>0 and isEmpty(F[#F]) do rem(F) end
end

function scene.enter()
    curPen=false
    penMode=0
    penX,penY=1,1
    demo=false
    page=1
end
function scene.leave()
    saveFile(DATA.copyBoards(),'conf/customBoards')
end

function scene.mouseMove(x,y)
    local sx,sy=int((x-200)/30)+1,20-int((y-60)/30)
    if sx>=1 and sx<=10 and sy>=1 and sy<=20 then
        penX,penY=sx,sy
        if curPen then
            _pTouch(sx,sy)
        end
    else
        penX,penY=nil
    end
end
function scene.mouseDown(x,y,k)
    if k>3 then return end
    if not curPen then
        curPen=k
    elseif curPen~=k then
        curPen=false
        penPath={}
    end
    scene.mouseMove(x,y)
end
function scene.mouseUp(_,_,k)
    if k>3 then return end
    if curPen==k then
        _pDraw()
        curPen=false
    end
end

function scene.touchDown(x,y) scene.mouseDown(x,y,1) end
function scene.touchUp(x,y) scene.mouseUp(x,y,1) end
scene.touchMove=scene.mouseMove

function scene.keyDown(key)
    if key=='up' or key=='down' or key=='left' or key=='right' then
        if not penX or not penY then penX,penY=1,1 end
        if key=='up' then
            if penY<20 then penY=penY+1 end
        elseif key=='down' then
            if penY>1 then penY=penY-1 end
        elseif key=='left' then
            if penX>1 then penX=penX-1 end
        elseif key=='right' then
            if penX<10 then penX=penX+1 end
        end
        if kb.isDown('space') then
            scene.keyDown('space')
        end
    elseif key=='space' then
        if penX and penY then
            curPen=1
            _pTouch(penX,penY)
        end
    elseif key=='delete' then
        if tryReset() then
            FIELD[page]=DATA.newBoard()
            SFX.play('finesseError',.7)
        end
    elseif key=='j' then
        demo=not demo
    elseif key=='k' then
        ins(FIELD[page],1,{21,21,21,21,21,21,21,21,21,21})
        SFX.play('blip')
    elseif key=='l' then
        local F=FIELD[page]
        local cleared=false
        for i=#F,1,-1 do
            local full
            for j=1,10 do
                if F[i][j]<=0 then full=false break end-- goto CONTINUE_notFull
            end
            if full then
                cleared=true
                SYSFX.newShade(3,200,660-30*i,300,30)
                SYSFX.newRectRipple(3,200,660-30*i,300,30)
                rem(F,i)
            end
            -- ::CONTINUE_notFull::
        end
        if cleared then
            SFX.play('clear_3',.8)
            SFX.play('fall',.8)
        end
    elseif key=='n' then
        ins(FIELD,page+1,DATA.newBoard(FIELD[page]))
        page=page+1
        SFX.play('warn_1',.8)
        SYSFX.newShade(3,200,60,300,600,.5,1,.5)
    elseif key=='m' then
        rem(FIELD,page)
        page=max(page-1,1)
        if not FIELD[1] then
            ins(FIELD,DATA.newBoard())
        end
        SYSFX.newShade(3,200,60,300,600,1,.5,.5)
        SFX.play('clear_4',.8)
        SFX.play('fall',.8)
    elseif key=='c' and kb.isDown('lctrl','rctrl') or key=='cC' then
        sys.setClipboardText("Techmino Field:"..DATA.copyBoard(page))
        MES.new('check',text.exportSuccess)
    elseif key=='v' and kb.isDown('lctrl','rctrl') or key=='cV' then
        local str=sys.getClipboardText()
        local p=str:find(":")-- ptr*
        if p then
            if not str:sub(1,p-1):find("Field") then
                MES.new('error',text.pasteWrongPlace)
            end
            str=str:sub(p+1)
        end
        if DATA.pasteBoard(str,page) then
            MES.new('check',text.importSuccess)
        else
            MES.new('error',text.dataCorrupted)
        end
    elseif key=='pageup' then
        page=max(page-1,1)
    elseif key=='pagedown' then
        page=min(page+1,#FIELD)
    elseif key=='escape' then
        if curPen then
            curPen=false
            penPath={}
        else
            SCN.back()
        end
    elseif penKey[key] then
        pens[1]=penKey[key]
    end
end
function scene.keyUp(key)
    if key=='space' then
        _pDraw()
        curPen=false
    end
end

function scene.draw()
    gc.translate(200,60)

    -- Draw grid
    gc.setColor(1,1,1,.2)
    gc.setLineWidth(1)
    for x=1,9 do gc.line(30*x,0,30*x,600) end
    for y=0,19 do gc.line(0,30*y,300,30*y) end

    -- Draw field
    gc.setColor(COLOR.Z)
    gc.setLineWidth(2)
    gc.rectangle('line',-2,-2,304,604,5)
    gc.setLineWidth(2)
    local cross=TEXTURE.puzzleMark[-1]
    local F=FIELD[page]
    local texture=SKIN.lib[SETTING.skinSet]
    for y=1,#F do for x=1,10 do
        local B=F[y][x]
        if B>0 then
            gc.draw(texture[B],30*x-30,600-30*y)
        elseif B==-1 and not demo then
            gc.draw(cross,30*x-30,600-30*y)
        end
    end end

    -- Draw pen
    if penX and penY then
        local x,y=30*penX,600-30*penY
        if curPen==1 or curPen==2 then
            gc.setLineWidth(5)
            gc.rectangle('line',x-30,y,30,30,4)
        elseif curPen==3 then
            gc.setLineWidth(3)
            gc.line(x-15,y,x-30,y+15)
            gc.line(x,y,x-30,y+30)
            gc.line(x,y+15,x-15,y+30)
        end
        gc.setLineWidth(2)
        gc.rectangle('line',x-30,y,30,30,3)
        gc.setColor(1,1,1,.2)
        gc.rectangle('fill',x-30,y,30,30,3)
    end

    -- Draw smart pen path
    if #penPath>0 then
        gc.setLineWidth(4)
        if penMode==0 then
            if pens[curPen]==-2 then
                if #penPath<=5 then
                    gc.setColor(COLOR.rainbow_light(TIME()*6.2))
                else
                    gc.setColor(.9,.9,.9,.7+.2*math.sin(TIME()*12.6))
                end
                for i=1,#penPath do
                    gc.rectangle('line',30*penPath[i][1]-30+2,600-30*penPath[i][2]+2,30-4,30-4,3)
                end
            elseif pens[curPen]==-1 then
                gc.setColor(1,1,0,.7+.3*math.sin(TIME()*12.6))
                for i=1,#penPath do
                    gc.draw(cross,30*penPath[i][1]-30,600-30*penPath[i][2])
                end
            elseif pens[curPen]==0 then
                gc.setColor(1,0,0)
                for i=1,#penPath do
                    gc.draw(cross,30*penPath[i][1]-30+math.random(-1,1),600-30*penPath[i][2]+math.random(-1,1))
                end
            else
                local c=BLOCK_COLORS[pens[curPen]]
                gc.setColor(c[1],c[2],c[3],.7+.2*math.sin(TIME()*12.6))
                for i=1,#penPath do
                    gc.rectangle('line',30*penPath[i][1]-30+2,600-30*penPath[i][2]+2,30-4,30-4,3)
                end
            end
        else
            gc.setColor(1,0,0)
            for i=1,#penPath do
                gc.draw(cross,30*penPath[i][1]-30+math.random(-1,1),600-30*penPath[i][2]+math.random(-1,1))
            end
        end
    end
    gc.translate(-200,-60)

    -- Draw page
    setFont(55)
    gc.setColor(COLOR.Z)
    GC.mStr(page,100,530)
    GC.mStr(#FIELD,100,600)
    gc.rectangle('fill',50,600,100,6)

    -- Draw mouse & pen color
    gc.translate(560,475)
        -- Mouse
        gc.setLineWidth(2)
        gc.rectangle('line',0,0,80,110,5)
        gc.line(0,40,80,40)
        gc.line(33,0,33,25,47,25,47,0)
        gc.line(40,25,40,40)

        -- Left button
        if pens[1]>0 then
            gc.setColor(BLOCK_COLORS[pens[1]])
            gc.rectangle('fill',5,5,23,30,3)
        elseif pens[1]==-1 then
            gc.setColor(COLOR.Z)
            gc.line(5,5,28,35)
            gc.line(28,5,5,35)
        elseif pens[1]==-2 then
            if penMode==0 then
                gc.setLineWidth(13)
                gc.setColor(COLOR.rainbow(TIME()*12.6))
                gc.rectangle('fill',5,5,23,30,3)
            else
                gc.setLineWidth(3)
                gc.setColor(1,0,0)
                gc.line(5,5,28,35)
                gc.line(28,5,5,35)
            end
        end

        -- Right button
        if pens[2]>0 then
            gc.setColor(BLOCK_COLORS[pens[2]])
            gc.rectangle('fill',52,5,23,30,3)
        elseif pens[2]==-1 then
            gc.setColor(COLOR.Z)
            gc.setLineWidth(3)
            gc.line(52,5,75,35)
            gc.line(75,5,52,35)
        elseif pens[2]==-2 then
            if penMode==0 then
                gc.setLineWidth(13)
                gc.setColor(COLOR.rainbow(TIME()*12.6))
                gc.rectangle('fill',52,5,23,30,3)
            else
                gc.setLineWidth(3)
                gc.setColor(1,0,0)
                gc.line(52,5,75,35)
                gc.line(75,5,52,35)
            end
        end

        -- Middle button
        if pens[3]>0 then
            gc.setColor(BLOCK_COLORS[pens[3]])
            gc.rectangle('fill',35,2,10,21,3)
        elseif pens[3]==-1 then
            gc.setColor(COLOR.Z)
            gc.setLineWidth(2)
            gc.line(35,2,45,23)
            gc.line(45,2,35,23)
        elseif pens[3]==-2 then
            if penMode==0 then
                gc.setLineWidth(13)
                gc.setColor(COLOR.rainbow(TIME()*12.6))
                gc.rectangle('fill',35,2,10,21,3)
            else
                gc.setLineWidth(3)
                gc.setColor(1,0,0)
                gc.line(35,2,45,23)
                gc.line(45,2,35,23)
            end
        end
    gc.translate(-560,-475)

    -- Block name
    setFont(55)
    gc.setColor(1,1,1)
    for i=1,7 do
        local skin=SETTING.skin[i]-1
        GC.mStr(text.block[i],580+(skin%8)*80,90+80*int(skin/8))
    end
end

local function _setPen(i) return function(k) pens[k]=i end end
scene.widgetList={
    WIDGET.newText{name='title',    x=1020,y=5,lim=480,font=70,align='R'},
    WIDGET.newText{name='subTitle', x=1030,y=50,lim=170,font=35,align='L',color='H'},

    WIDGET.newButton{name='b1',     x=580, y=130,w=73,fText="",color='R',code=_setPen(1)},-- B1
    WIDGET.newButton{name='b2',     x=660, y=130,w=73,fText="",color='F',code=_setPen(2)},-- B2
    WIDGET.newButton{name='b3',     x=740, y=130,w=73,fText="",color='O',code=_setPen(3)},-- B3
    WIDGET.newButton{name='b4',     x=820, y=130,w=73,fText="",color='Y',code=_setPen(4)},-- B4
    WIDGET.newButton{name='b5',     x=900, y=130,w=73,fText="",color='L',code=_setPen(5)},-- B5
    WIDGET.newButton{name='b6',     x=980, y=130,w=73,fText="",color='J',code=_setPen(6)},-- B6
    WIDGET.newButton{name='b7',     x=1060,y=130,w=73,fText="",color='G',code=_setPen(7)},-- B7
    WIDGET.newButton{name='b8',     x=1140,y=130,w=73,fText="",color='A',code=_setPen(8)},-- B8

    WIDGET.newButton{name='b9',     x=580, y=210,w=73,fText="",color='C',code=_setPen(9)},-- B9
    WIDGET.newButton{name='b10',    x=660, y=210,w=73,fText="",color='N',code=_setPen(10)},-- B10
    WIDGET.newButton{name='b11',    x=740, y=210,w=73,fText="",color='S',code=_setPen(11)},-- B11
    WIDGET.newButton{name='b12',    x=820, y=210,w=73,fText="",color='B',code=_setPen(12)},-- B12
    WIDGET.newButton{name='b13',    x=900, y=210,w=73,fText="",color='V',code=_setPen(13)},-- B13
    WIDGET.newButton{name='b14',    x=980, y=210,w=73,fText="",color='P',code=_setPen(14)},-- B14
    WIDGET.newButton{name='b15',    x=1060,y=210,w=73,fText="",color='M',code=_setPen(15)},-- B15
    WIDGET.newButton{name='b16',    x=1140,y=210,w=73,fText="",color='W',code=_setPen(16)},-- B16

    WIDGET.newButton{name='b17',    x=580, y=290,w=73,font=40,fText=CHAR.icon.bone,   color='dH',code=_setPen(17)},-- BONE
    WIDGET.newButton{name='b18',    x=660, y=290,w=73,font=40,fText=CHAR.icon.invis,  color='D', code=_setPen(18)},-- HIDE
    WIDGET.newButton{name='b19',    x=740, y=290,w=73,font=40,fText=CHAR.icon.bomb,   color='lY',code=_setPen(19)},-- BOMB
    WIDGET.newButton{name='b20',    x=820, y=290,w=73,font=40,fText=CHAR.icon.garbage,color='H', code=_setPen(20)},-- GB1
    WIDGET.newButton{name='b21',    x=900, y=290,w=73,font=40,fText=CHAR.icon.garbage,color='lH',code=_setPen(21)},-- GB2
    WIDGET.newButton{name='b22',    x=980, y=290,w=73,font=40,fText=CHAR.icon.garbage,color='dV',code=_setPen(22)},-- GB3
    WIDGET.newButton{name='b23',    x=1060,y=290,w=73,font=40,fText=CHAR.icon.garbage,color='dR',code=_setPen(23)},-- GB4
    WIDGET.newButton{name='b24',    x=1140,y=290,w=73,font=40,fText=CHAR.icon.garbage,color='dG',code=_setPen(24)},-- GB5

    WIDGET.newButton{name='any',    x=600, y=400,w=120,color='lH',      font=40,code=_setPen(0)},
    WIDGET.newButton{name='space',  x=730, y=400,w=120,color='H',       font=55,code=_setPen(-1),fText=CHAR.icon.cross_thick},
    WIDGET.newButton{name='smart',  x=860, y=400,w=120,color='lG',      font=30,code=_setPen(-2)},
    WIDGET.newButton{name='push',   x=990, y=400,w=120,h=120,color='lY',font=20,code=pressKey'k'},
    WIDGET.newButton{name='del',    x=1120,y=400,w=120,h=120,color='lY',font=20,code=pressKey'l'},

    WIDGET.newButton{name='copy',   x=730, y=530,w=120,color='lR',font=60,fText=CHAR.icon.export,code=pressKey'cC'},
    WIDGET.newButton{name='paste',  x=860, y=530,w=120,color='lB',font=60,fText=CHAR.icon.import,code=pressKey'cV'},
    WIDGET.newButton{name='clear',  x=990, y=530,w=120,color='Z', font=70,fText=CHAR.icon.trash,code=pressKey'delete'},
    WIDGET.newSwitch{name='demo',   x=755, y=640,lim=220,disp=function() return demo end,code=function() demo=not demo end},

    WIDGET.newButton{name='newPg',  x=100, y=110,w=160,h=110,color='N', font=20,code=pressKey'n'},
    WIDGET.newButton{name='delPg',  x=100, y=230,w=160,h=110,color='lR',font=20,code=pressKey'm'},
    WIDGET.newButton{name='prevPg', x=100, y=350,w=160,h=110,color='lG',font=20,code=pressKey'pageup',hideF=function() return page==1 end},
    WIDGET.newButton{name='nextPg', x=100, y=470,w=160,h=110,color='lG',font=20,code=pressKey'pagedown',hideF=function() return page==#FIELD end},

    WIDGET.newButton{name='back',   x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
