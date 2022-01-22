local gc=love.graphics
local gc_translate=gc.translate
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle=gc.rectangle
local gc_print=gc.print

local max,min=math.max,math.min
local ins,rem=table.insert,table.remove

local colorName={
    m={'一','二','三','四','五','六','七','八','九'},
    p={'①','②','③','④','⑤','⑥','⑦','⑧','⑨'},
    s={'1','2','3','4','5','6','7','8','9'},
}
local deck0={}
local cardText={}
for i=1,9 do
    for _=1,4 do
        ins(deck0,'m'..i)
        ins(deck0,'p'..i)
        ins(deck0,'s'..i)
        if i<=7 then ins(deck0,'z'..i)end
    end
    cardText['m'..i]={COLOR.lF,colorName.m[i]}
    cardText['p'..i]={COLOR.lB,colorName.p[i]}
    cardText['s'..i]={COLOR.lG,colorName.s[i]}
end
-- deck0[TABLE.find(deck0,'m5')]='m0'
-- deck0[TABLE.find(deck0,'p5')]='p0'
-- deck0[TABLE.find(deck0,'s5')]='s0'
-- cardText['5m+']={COLOR.R,'五'}
-- cardText['5p+']={COLOR.R,'⑤'}
-- cardText['5s+']={COLOR.R,'5'}

cardText['z1']={COLOR.Z,'東'}
cardText['z2']={COLOR.Z,'南'}
cardText['z3']={COLOR.Z,'西'}
cardText['z4']={COLOR.Z,'北'}
cardText['z5']={COLOR.Z,' '}
cardText['z6']={COLOR.G,'發'}
cardText['z7']={COLOR.R,'中'}

local deck,hand,pool
local selected

local function _getPoolCardArea(i)
    local row=math.floor((i-1)/10)
    local col=i-row*10
    return
    240+70*col,45+95*row,
    65,90
end

local function _getHandCardArea(i)
    return
    20+70*i+(i==14 and 30 or 0),480,
    65,90
end

local function _newGame()
    deck=TABLE.shift(deck0)
    hand={}
    pool={}
    for _=1,14 do ins(hand,(TABLE.popRandom(deck)))end
    table.sort(hand)
end

local function _checkWin()
    if #hand==14 then
        --???
    end
end

local function _throwCard()
    if hand[selected]and #pool<40 then
        ins(pool,rem(hand,selected))
        table.sort(hand)
        SFX.play('hold')
        SFX.play('lock')
        if #pool<40 then
            ins(hand,(TABLE.popRandom(deck)))
        end
    end
end

local scene={}

function scene.sceneInit()
    BG.set('fixColor')
    BG.send(.26,.62,.26)
    _newGame()
    selected=false
end

function scene.mouseMove(x,y)
    selected=false
    for i=1,#hand do
        local cx,cy,cw,ch=_getHandCardArea(i)
        if x>cx and x<cx+cw and y>cy and y<cy+ch then
            selected=i
            return
        end
    end
end
function scene.mouseDown()
    _throwCard()
end
function scene.touchMove(x,y)scene.mouseMove(x,y)end
function scene.touchDown(x,y)scene.mouseMove(x,y)end
function scene.touchClick(x,y)scene.mouseDown(x,y)end
function scene.keyDown(key)
    if key=='left'then
        if selected then
            selected=max(selected-1,1)
        else
            selected=1
        end
    elseif key=='right'then
        if selected then
            selected=min(selected+1,#hand)
        else
            selected=#hand
        end
    elseif key=='space'then
        _throwCard()
    elseif key=='r'then
        _newGame()
    elseif key=='return'then
        _checkWin()
    elseif key=='escape'then
        SCN.back()
    end
end

function scene.draw()
    setFont(35)
    gc_setColor(COLOR.Z)
    gc_print('余: '..#deck,1060,30)

    gc_setLineWidth(4)
    setFont(50)
    for i=1,#hand do
        local c=hand[i]
        local x,y,w,h=_getHandCardArea(i)
        if i==selected then
            gc_translate(0,-10)
            gc_setColor(1,1,1,.4)
            gc_rectangle('fill',x,y,w,h,5)
        end
        gc_setColor(COLOR.Z)
        gc_rectangle('line',x,y,w,h,5)
        gc_setColor(1,1,1)
        mStr(cardText[c],x+w/2,y+10)
        if i==selected then gc_translate(0,10)end
    end
    for i=1,#pool do
        local c=pool[i]
        local x,y,w,h=_getPoolCardArea(i)
        if selected and hand[selected]==c then
            gc_setColor(1,1,1,.4)
            gc_rectangle('fill',x,y,w,h,5)
        end
        gc_setColor(COLOR.Z)
        gc_rectangle('line',x,y,w,h,5)
        gc_setColor(1,1,1)
        mStr(cardText[c],x+w/2,y+10)
    end
end

scene.widgetList={
    WIDGET.newButton{name='reset',x=160, y=100,w=180,h=100,color='lG',font=50,fText=CHAR.icon.retry_spin,code=pressKey'r'},
    WIDGET.newKey{name="hu",      x=1150,y=370,w=140,h=80,font=50,sound=false,fText='自摸',code=pressKey'return'},
    WIDGET.newButton{name="back", x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}
return scene
