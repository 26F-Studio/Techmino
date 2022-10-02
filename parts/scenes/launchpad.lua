local gc_push,gc_pop=GC.push,GC.pop
local gc_translate=GC.translate
local gc_setColor,gc_setLineWidth=GC.setColor,GC.setLineWidth
local gc_rectangle,gc_circle=GC.rectangle,GC.circle

local isDown=love.keyboard.isDown

local int,max,min=math.floor,math.max,math.min

local mStr=GC.mStr

local scene={}

local pad
pad={x=140,y=65,page=1,
    func={
        function() pad.page=1 end,
        function() pad.page=2 end,
        function() pad.page=3 end,
        function() pad.page=4 end,
        function() pad.page=5 end,
        function() pad.page=6 end,
        function() BGM.set('all','seek',0)BGM.play() end,
        function() BGM.stop() end,
    },
    funcAlpha=TABLE.new(0,8),
    alpha={
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
    },
    {
        {
            {samp={tag='ready3',func=function() playReadySFX(3) end}},
            {samp={tag='ready2',func=function() playReadySFX(2) end}},
            {samp={tag='ready1',func=function() playReadySFX(1) end}},
            {samp={tag='start',func=function() playReadySFX(0) end}},
            {sfx='touch'},{sfx='lock'},{sfx='drop'},{sfx='fall'},
        },
        {
            {sfx='hold'},{sfx='prehold'},
            {samp={tag='clear_1',func=function() playClearSFX(1) end}},
            {samp={tag='clear_2',func=function() playClearSFX(2) end}},
            {samp={tag='clear_3',func=function() playClearSFX(3) end}},
            {samp={tag='clear_4',func=function() playClearSFX(4) end}},
            {samp={tag='clear_7',func=function() playClearSFX(7) end}},
            {samp={tag='clear_10',func=function() playClearSFX(10) end}},
        },
        {{sfx='prerotate'},   {sfx='rotate'},           {sfx='rotatekick'}, {},              {voc='single'}, {voc='double'},   {voc='triple'}, {voc='techrash'}},
        {{sfx='finesseError'},{sfx='finesseError_long'},{sfx='drop_cancel'},{},              {sfx='spin_0'}, {sfx='spin_1'},   {sfx='spin_2'}, {sfx='spin_3'}},
        {{sfx='ren_1'},       {sfx='ren_2'},            {sfx='ren_3'},      {sfx='ren_4'},   {},             {sfx='warn_beep'},{sfx='reach'},  {sfx='pc'}},
        {{sfx='ren_5'},       {sfx='ren_6'},            {sfx='ren_7'},      {sfx='ren_8'},   {},             {sfx='collect'},  {sfx='emit'},   {sfx='warn_1'}},
        {{sfx='ren_9'},       {sfx='ren_10'},           {sfx='ren_11'},     {sfx='ren_mega'},{voc='win'},    {voc='lose'},     {sfx='win'},    {sfx='fail'}},
        {{sfx='spawn_1'},     {sfx='spawn_2'},          {sfx='spawn_3'},    {sfx='spawn_4'}, {sfx='spawn_5'},{sfx='spawn_6'},  {sfx='spawn_7'},{}},
    },
    {
        {{voc='mini'},   {voc='b2b'},   {voc='b3b'},   {voc='perfect_clear'},{voc='half_clear'},{},               {},           {}},
        {{voc='zspin'},  {voc='sspin'}, {voc='jspin'}, {voc='lspin'},        {voc='tspin'},     {voc='ospin'},    {voc='ispin'},{}},
        {{voc='pspin'},  {voc='qspin'}, {voc='fspin'}, {voc='espin'},        {voc='uspin'},     {voc='vspin'},    {voc='wspin'},{voc='xspin'}},
        {{voc='rspin'},  {voc='yspin'}, {voc='nspin'}, {voc='hspin'},        {voc='cspin'},     {},               {},           {}},
        {{voc='single'}, {voc='double'},{voc='triple'},{voc='techrash'},     {voc='pentacrash'},{voc='hexacrash'},{},           {}},
        {{voc='win'},    {voc='lose'},  {},            {},                   {},                {},               {},           {}},
        {{voc='welcome'},{voc='bye'},   {},            {},                   {},                {},               {},           {}},
        {{},             {},            {},            {},                   {},                {},               {},           {}},
    },
    {
        {
            {samp={tag='ready3',func=function() playReadySFX(3) end}},
            {samp={tag='ready2',func=function() playReadySFX(2) end}},
            {samp={tag='ready1',func=function() playReadySFX(1) end}},
            {samp={tag='start',func=function() playReadySFX(0) end}},
            {sfx='touch'},{sfx='lock'},{sfx='drop'},{sfx='fall'},
        },
        {
            {sfx='hold'},{sfx='prehold'},
            {samp={tag='clear_1',func=function() playClearSFX(1) end}},
            {samp={tag='clear_2',func=function() playClearSFX(2) end}},
            {samp={tag='clear_3',func=function() playClearSFX(3) end}},
            {samp={tag='clear_4',func=function() playClearSFX(4) end}},
            {samp={tag='clear_7',func=function() playClearSFX(7) end}},
            {samp={tag='clear_10',func=function() playClearSFX(10) end}},
        },
        {{voc='mini'},   {voc='b2b'},    {voc='b3b'},   {voc='perfect_clear'}, {voc='half_clear'},        {sfx='finesseError'},     {sfx='finesseError_long'}, {sfx='drop_cancel'},},
        {{voc='zspin'},  {voc='sspin'},  {voc='jspin'}, {voc='lspin'},         {voc='tspin'},             {voc='ospin'},            {voc='ispin'},             {}},
        {{voc='single'}, {voc='double'}, {voc='triple'},{voc='techrash'},      {sfx='ren_mega', vol=0.25},{sfx='ren_mega', vol=0.5},{sfx='ren_mega', vol=0.75},{sfx='ren_mega'}},
        {{sfx='ren_1'},  {sfx='ren_2'},  {sfx='ren_3'}, {sfx='ren_4'},         {sfx='warn_1'},            {sfx='warn_beep'},        {sfx='reach'},             {sfx='pc'}},
        {{sfx='ren_5'},  {sfx='ren_6'},  {sfx='ren_7'}, {sfx='ren_8'},         {sfx='warn_2'},            {sfx='collect'},          {sfx='emit'},              {}},
        {{sfx='ren_9'},  {sfx='ren_10'}, {sfx='ren_11'},{sfx='ren_mega'},      {voc='win'},               {voc='lose'},             {sfx='win'},               {sfx='fail'}},
    },
    {
        {
            {samp={tag='clear_1',func=function() playClearSFX(1) end}},
            {samp={tag='clear_2',func=function() playClearSFX(2) end}},
            {samp={tag='clear_3',func=function() playClearSFX(3) end}},
            {samp={tag='clear_4',func=function() playClearSFX(4) end}},
            {samp={tag='clear_5',func=function() playClearSFX(5) end}},
            {samp={tag='clear_6',func=function() playClearSFX(6) end}},
            {samp={tag='clear_7',func=function() playClearSFX(7) end}},
            {samp={tag='clear_8',func=function() playClearSFX(8) end}},
        },
        {
            {samp={tag='clear_9',func=function() playClearSFX(9) end}},
            {samp={tag='clear_10',func=function() playClearSFX(10) end}},
            {samp={tag='clear_11',func=function() playClearSFX(11) end}},
            {samp={tag='clear_12',func=function() playClearSFX(12) end}},
            {samp={tag='clear_13',func=function() playClearSFX(13) end}},
            {samp={tag='clear_14',func=function() playClearSFX(14) end}},
            {samp={tag='clear_15',func=function() playClearSFX(15) end}},
            {samp={tag='clear_16',func=function() playClearSFX(16) end}},
        },
        {
            {samp={tag='clear_17',func=function() playClearSFX(17) end}},
            {samp={tag='clear_18',func=function() playClearSFX(18) end}},
            {samp={tag='clear_19',func=function() playClearSFX(19) end}},
            {samp={tag='clear_20',func=function() playClearSFX(20) end}},
            {samp={tag='clear_20+',func=function() playClearSFX(21) end}},
            {},{},{}
        },
        {{},{},{},{},{},{},{},{}},
        {{},{},{},{},{},{},{},{}},
        {{},{},{},{},{},{},{},{}},
        {{},{},{},{},{},{},{},{}},
        {{},{},{},{},{},{},{},{}},
    },
    {
        {{},{},{},{},{},{},{},{}},
        {{},{},{},{},{},{},{},{}},
        {{},{},{},{},{},{},{},{}},
        {{},{},{},{},{},{},{},{}},
        {{},{},{},{},{},{},{},{}},
        {{},{},{},{},{},{},{},{}},
        {{},{},{},{},{},{},{},{}},
        {{},{},{},{},{},{},{},{}},
    },
    (function()-- BGM page
        local L=BGM.getList()
        local B={}
        for y=1,8 do
            B[y]={}
            for x=1,8 do
                local i=8*(y-1)+x
                B[y][x]=L[i] and{bgm=L[i]} or{}
            end
        end
        return B
    end)(),
}

local showLabel

local function press(x,y)
    if x==0 then
        pad.func[y]()
        pad.funcAlpha[y]=1
    else
        local k=pad[pad.page][y][x]
        if k.samp then k.samp.func() end
        if k.sfx then SFX.play(k.sfx,k.vol) end
        if k.voc then VOC.play(k.voc) end
        if k.bgm then BGM.play(k.bgm) end
        pad.alpha[y][x]=1
    end
end

function scene.touchDown(x,y)
    x,y=int((x-pad.x)/80),int((y-pad.y)/80)
    if x>=0 and x<=8 and y>=0 and y<=7 then
        press(x,y+1)
    end
end
scene.mouseDown=scene.touchDown

function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='z' or key=='x' then
        love.mousepressed(love.mouse.getPosition())
    elseif #key==1 then
        if ("12345678"):find(key,nil,true) then
            press(0,tonumber(key))
        else
            key=("hjkluiop"):find(key,nil,true)
            if key then
                if isDown('q') then press(key,1) end
                if isDown('w') then press(key,2) end
                if isDown('e') then press(key,3) end
                if isDown('r') then press(key,4) end
                if isDown('a') then press(key,5) end
                if isDown('s') then press(key,6) end
                if isDown('d') then press(key,7) end
                if isDown('f') then press(key,8) end
            end
        end
    elseif key=='tab' then
        SCN.swapTo('music','none')
    elseif key=='space' then
        showLabel=not showLabel
    elseif key=='escape' then
        SCN.back()
    end
end

function scene.update(dt)
    for y=1,8 do
        if pad.funcAlpha[y]>0 then
            pad.funcAlpha[y]=max(pad.funcAlpha[y]-dt*2,0)
        end
    end
    for y=1,8 do for x=1,8 do
        if pad.alpha[y][x]>0 then
            pad.alpha[y][x]=max(pad.alpha[y][x]-dt*4,0)
        end
    end end
    for i=1,8 do
        if isDown(("qwerasdf"):sub(i,i)) then
            local L=pad.alpha[i]
            for j=1,8 do
                pad.alpha[i][j]=min(L[j]+dt*10,max(L[j],.4))
            end
        end
    end
end

function scene.draw()
    local white=COLOR.Z

    gc_push('transform')
    gc_translate(pad.x,pad.y)
    gc_setLineWidth(2)

    -- Pad frame
    gc_setColor(COLOR.dX)
    gc_rectangle('fill',-3,-3,726,646,2)
    gc_setColor(white)
    gc_rectangle('line',-3,-3,726,646,2)

    -- Buttons
    for y=1,8 do
            gc_setColor(COLOR.dX)
        gc_circle('fill',40,(y-1)*80+40,34)
        gc_setColor(white)
        gc_circle('line',40,(y-1)*80+40,34)
        if pad.funcAlpha[y]>0 then
            gc_setColor(1,1,1,pad.funcAlpha[y]*.7)
            gc_circle('fill',40,(y-1)*80+40,34)
        end
    end
    setFont(10)
        gc_setColor(COLOR.dX)
    for y=1,8 do for x=1,8 do
        gc_rectangle('fill',x*80+2,(y-1)*80+2,76,76,5)
    end end
    gc_setColor(white)
    for y=1,8 do for x=1,8 do
        gc_rectangle('line',x*80+2,(y-1)*80+2,76,76,5)
        local k=pad[pad.page][y][x]
        if showLabel then
            if k.sfx then mStr(k.sfx,x*80+40,y*80-30)gc_circle('line',x*80+40,(y-1)*80+40,5) end
            if k.voc then mStr(k.voc,x*80+40,y*80-17)gc_rectangle('line',x*80+30,(y-1)*80+30,20,20,1) end
            if k.samp then mStr(k.samp.tag,x*80+40,y*80-30)gc_rectangle('fill',x*80+10,(y-1)*80+35,60,5,1) end
            if k.bgm then mStr(k.bgm,x*80+40,y*80-78)gc_rectangle('fill',x*80+20,(y-1)*80+15,40,5,2) end
        else
            if k.sfx then gc_circle('line',x*80+40,(y-1)*80+40,5) end
            if k.voc then gc_rectangle('line',x*80+30,(y-1)*80+30,20,20,1) end
            if k.samp then gc_rectangle('fill',x*80+10,(y-1)*80+35,60,5,1) end
            if k.bgm then gc_rectangle('fill',x*80+20,(y-1)*80+15,40,5,2) end
        end
        if pad.alpha[y][x]>0 then
            gc_setColor(1,1,1,pad.alpha[y][x]*.7)
            gc_rectangle('fill',x*80+2,(y-1)*80+2,76,76,5)
            gc_setColor(white)
        end
    end end
    gc_pop()
end

scene.widgetList={
    WIDGET.newText{name='title',  x=640, y=-5,font=50},
    WIDGET.newSlider{name='bgm',  x=1000,y=80, lim=130,w=250,disp=SETval('bgm'),code=function(v) SETTING.bgm=v BGM.setVol(SETTING.bgm) end},
    WIDGET.newSlider{name='sfx',  x=1000,y=150,lim=130,w=250,disp=SETval('sfx'),code=function(v) SETTING.sfx=v SFX.setVol(SETTING.sfx) end},
    WIDGET.newSlider{name='voc',  x=1000,y=220,lim=130,w=250,disp=SETval('voc'),code=function(v) SETTING.voc=v VOC.setVol(SETTING.voc) end},
    WIDGET.newSwitch{name='label',x=1200,y=290,lim=160,disp=function() return showLabel end,code=pressKey'space',},
    WIDGET.newButton{name='music',x=1140,y=540,w=170,h=80,font=40,code=pressKey'tab'},
    WIDGET.newButton{name='back', x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
