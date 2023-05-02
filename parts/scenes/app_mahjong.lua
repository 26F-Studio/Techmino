local gc=love.graphics
local gc_translate=gc.translate
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle=gc.rectangle
local gc_print=gc.print

local max,min=math.max,math.min
local ins,rem=table.insert,table.remove

local deck0={}
for i=1,9 do
    for _=1,4 do
        ins(deck0,'m'..i)
        ins(deck0,'p'..i)
        ins(deck0,'s'..i)
        if i<=7 then ins(deck0,'z'..i) end
    end
end
-- deck0[TABLE.find(deck0,'m5')]='m0'
-- deck0[TABLE.find(deck0,'p5')]='p0'
-- deck0[TABLE.find(deck0,'s5')]='s0'
-- cardText['5m+']={COLOR.R,'五'}
-- cardText['5p+']={COLOR.R,'⑤'}
-- cardText['5s+']={COLOR.R,'5'}

local cardText={
    m1={COLOR.D,CHAR.mahjong.m1Base,COLOR.R,CHAR.mahjong.mComb},
    m2={COLOR.D,CHAR.mahjong.m2Base,COLOR.R,CHAR.mahjong.mComb},
    m3={COLOR.D,CHAR.mahjong.m3Base,COLOR.R,CHAR.mahjong.mComb},
    m4={COLOR.D,CHAR.mahjong.m4Base,COLOR.R,CHAR.mahjong.mComb},
    m5={COLOR.D,CHAR.mahjong.m5Base,COLOR.R,CHAR.mahjong.mComb},
    m6={COLOR.D,CHAR.mahjong.m6Base,COLOR.R,CHAR.mahjong.mComb},
    m7={COLOR.D,CHAR.mahjong.m7Base,COLOR.R,CHAR.mahjong.mComb},
    m8={COLOR.D,CHAR.mahjong.m8Base,COLOR.R,CHAR.mahjong.mComb},
    m9={COLOR.D,CHAR.mahjong.m9Base,COLOR.R,CHAR.mahjong.mComb},
    p1={COLOR.D,CHAR.mahjong.p1},
    p2={COLOR.D,CHAR.mahjong.p2Base,COLOR.D,CHAR.mahjong.p2Comb},
    p3={COLOR.D,CHAR.mahjong.p3Base,COLOR.R,CHAR.mahjong.p3Comb1,COLOR.D,CHAR.mahjong.p3Comb2},
    p4={COLOR.D,CHAR.mahjong.p4Base,COLOR.D,CHAR.mahjong.p4Comb},
    p5={COLOR.D,CHAR.mahjong.p5Base,COLOR.D,CHAR.mahjong.p5Comb1,COLOR.R,CHAR.mahjong.p5Comb2},
    p6={COLOR.D,CHAR.mahjong.p6Base,COLOR.R,CHAR.mahjong.p6Comb},
    p7={COLOR.D,CHAR.mahjong.p7Base,COLOR.R,CHAR.mahjong.p7Comb},
    p8={COLOR.D,CHAR.mahjong.p8},
    p9={COLOR.D,CHAR.mahjong.p9Base,COLOR.R,CHAR.mahjong.p9Comb1,COLOR.D,CHAR.mahjong.p9Comb2},
    s1={COLOR.D,CHAR.mahjong.s1jBase,COLOR.G,CHAR.mahjong.s1jComb},
    s2={COLOR.G,CHAR.mahjong.s2},
    s3={COLOR.G,CHAR.mahjong.s3},
    s4={COLOR.G,CHAR.mahjong.s4},
    s5={COLOR.G,CHAR.mahjong.s5Base,COLOR.R,CHAR.mahjong.s5Comb},
    s6={COLOR.G,CHAR.mahjong.s6},
    s7={COLOR.G,CHAR.mahjong.s7Base,COLOR.R,CHAR.mahjong.s7Comb},
    s8={COLOR.G,CHAR.mahjong.s8},
    s9={COLOR.G,CHAR.mahjong.s9Base,COLOR.R,CHAR.mahjong.s9Comb},
    z1={COLOR.D,CHAR.mahjong.ton},
    z2={COLOR.D,CHAR.mahjong.nan},
    z3={COLOR.D,CHAR.mahjong.sha},
    z4={COLOR.D,CHAR.mahjong.pe},
    z5={COLOR.D,CHAR.mahjong.haku},
    z6={COLOR.G,CHAR.mahjong.hatsu},
    z7={COLOR.R,CHAR.mahjong.chun},
} for _,v in next,cardText do ins(v,COLOR.D)ins(v,CHAR.mahjong.frameComb) end

local deck,hand,pool
local selected

local function _getPoolCardArea(i)
    local row=math.floor((i-1)/10)
    local col=i-row*10
    return
    240+70*col,45+95*row,
    60,84
end

local function _getHandCardArea(i)
    return
    20+70*i+(i==14 and 30 or 0),480,
    60,84
end

local function _newGame()
    deck=TABLE.shift(deck0)
    hand={}
    pool={}
    for _=1,14 do ins(hand,(TABLE.popRandom(deck))) end
    table.sort(hand)
end

local function _checkWin()
    if #hand==14 then
        MES.new('info',"Coming soon!")
    end
end

local function _throwCard()
    if hand[selected] and #pool<40 then
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

function scene.enter()
    BG.set('fixColor',.26,.62,.26)
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
scene.touchMove=scene.mouseMove
scene.touchDown=scene.mouseMove
scene.touchClick=scene.mouseDown
function scene.keyDown(key)
    if key=='left' then
        if selected then
            selected=max(selected-1,1)
        else
            selected=1
        end
    elseif key=='right' then
        if selected then
            selected=min(selected+1,#hand)
        else
            selected=#hand
        end
    elseif key=='space' then
        _throwCard()
    elseif key=='r' then
        _newGame()
    elseif key=='return' then
        _checkWin()
    elseif key=='escape' then
        SCN.back()
    end
end

function scene.draw()
    setFont(35)
    gc_setColor(COLOR.D)
    gc_print('余 '..#deck,1060,30)

    gc_setLineWidth(4)
    setFont(85)
    for i=1,#hand do
        local c=hand[i]
        local x,y,w,h=_getHandCardArea(i)
        if i==selected then
            gc_translate(0,-10)
        end
        gc_setColor(COLOR.Z)
        gc_rectangle('fill',x,y,w,h,12)
        if i==selected then
            gc_setColor(1,1,1,.4)
            gc_rectangle('fill',x,y,w,h,12)
        end
        gc_setColor(1,1,1)
        GC.mStr(cardText[c],x+w/2,y-17)
        if i==selected then gc_translate(0,10) end
    end
    for i=1,#pool do
        local c=pool[i]
        local x,y,w,h=_getPoolCardArea(i)
        gc_setColor(COLOR.Z)
        gc_rectangle('fill',x,y,w,h,12)
        if selected and hand[selected]==c then
            gc_setColor(1,.2,.2,.3)
            gc_rectangle('fill',x,y,w,h,12)
        end
        gc_setColor(1,1,1)
        GC.mStr(cardText[c],x+w/2,y-17)
    end
end

scene.widgetList={
    WIDGET.newButton{name='reset',x=160, y=100,w=180,h=100,color='lR',font=50,fText=CHAR.icon.retry_spin,code=pressKey'r'},
    WIDGET.newKey{name="hu",      x=1150,y=370,w=140,h=80,font=45,sound=false,fText='自摸',code=pressKey'return'},
    WIDGET.newButton{name="back", x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}
return scene
