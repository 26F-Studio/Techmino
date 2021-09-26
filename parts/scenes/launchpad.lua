local gc=love.graphics
local gc_push,gc_pop=gc.push,gc.pop
local gc_translate=gc.translate
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle,gc_circle=gc.rectangle,gc.circle

local isDown=love.keyboard.isDown

local int,max,min=math.floor,math.max,math.min

local scene={}

local pad
pad={x=140,y=65,page=1,
    func={
        function()pad.page=1 end,
        function()pad.page=2 end,
        function()pad.page=3 end,
        function()pad.page=4 end,
        function()pad.page=5 end,
        function()pad.page=6 end,
        function()BGM.seek(0)BGM.play(BGM.nowPlay)end,
        function()BGM.stop()end,
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
        {{sfx='ready'},       {sfx='start'},            {},                 {},              {sfx='move'},   {sfx='lock'},   {sfx='drop'},   {sfx='fall'},},
        {{sfx='hold'},        {sfx='prehold'},          {},                 {},              {sfx='clear_1'},{sfx='clear_2'},{sfx='clear_3'},{sfx='clear_4'}},
        {{sfx='prerotate'},   {sfx='rotate'},           {sfx='rotatekick'}, {},              {voc='single'}, {voc='double'}, {voc='triple'}, {voc='techrash'}},
        {{sfx='finesseError'},{sfx='finesseError_long'},{sfx='drop_cancel'},{},              {sfx='spin_0'}, {sfx='spin_1'}, {sfx='spin_2'}, {sfx='spin_3'}},
        {{sfx='ren_1'},       {sfx='ren_2'},            {sfx='ren_3'},      {sfx='ren_4'},   {},             {sfx='warning'},{sfx='reach'},  {sfx='pc'}},
        {{sfx='ren_5'},       {sfx='ren_6'},            {sfx='ren_7'},      {sfx='ren_8'},   {},             {sfx='collect'},{sfx='emit'},   {sfx='blip_1'}},
        {{sfx='ren_9'},       {sfx='ren_10'},           {sfx='ren_11'},     {sfx='ren_mega'},{voc='win'},    {voc='lose'},   {sfx='win'},    {sfx='fail'}},
        {{sfx='spawn_1'},     {sfx='spawn_2'},          {sfx='spawn_3'},    {sfx='spawn_4'}, {sfx='spawn_5'},{sfx='spawn_6'},{sfx='spawn_7'},{}},
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
        {{},{},{},{},{},{},{},{}},
        {{},{},{},{},{},{},{},{}},
        {{},{},{},{},{},{},{},{}},
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
}

local function press(x,y)
    if x==0 then
        pad.func[y]()
        pad.funcAlpha[y]=1
    else
        local k=pad[pad.page][y][x]
        if k.sfx then
            SFX.play(k.sfx)
        elseif k.voc then
            VOC.play(k.voc)
        end
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
    if key=="z"or key=="x"then
        love.mousepressed(love.mouse.getPosition())
    elseif #key==1 then
        if("12345678"):find(key,nil,true)then
            press(0,tonumber(key))
        else
            key=("hjkluiop"):find(key,nil,true)
            if key then
                if isDown("q")then press(key,1)end
                if isDown("w")then press(key,2)end
                if isDown("e")then press(key,3)end
                if isDown("r")then press(key,4)end
                if isDown("a")then press(key,5)end
                if isDown("s")then press(key,6)end
                if isDown("d")then press(key,7)end
                if isDown("f")then press(key,8)end
            end
        end
    elseif key=="tab"then
        SCN.swapTo('music','none')
    elseif key=="escape"then
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
        if isDown(("qwerasdf"):sub(i,i))then
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

    --Pad frame
    gc_setColor(white)
    gc_rectangle('line',-3,-3,726,646,2)

    --Buttons
    for y=1,8 do
        gc_setColor(white)
        gc_circle('line',40,(y-1)*80+40,34)
        if pad.funcAlpha[y]>0 then
            gc_setColor(1,1,1,pad.funcAlpha[y]*.7)
            gc_circle('fill',40,(y-1)*80+40,34)
        end
    end
    for y=1,8 do for x=1,8 do
        gc_setColor(white)
        gc_rectangle('line',x*80+2,(y-1)*80+2,76,76,5)
        local k=pad[pad.page][y][x]
        if k.sfx then
            gc_circle('line',x*80+40,(y-1)*80+40,6)
        elseif k.voc then
            gc_rectangle('line',x*80+30,(y-1)*80+30,20,20,2)
        end
        if pad.alpha[y][x]>0 then
            gc_setColor(1,1,1,pad.alpha[y][x]*.7)
            gc_rectangle('fill',x*80+2,(y-1)*80+2,76,76,5)
        end
    end end
    gc_pop()
end

scene.widgetList={
    WIDGET.newText{name="title", x=640,y=-5,font=50},
    WIDGET.newSlider{name="bgm", x=1000,y=80,lim=130,w=250,disp=SETval('bgm'),code=function(v)SETTING.bgm=v BGM.freshVolume()end},
    WIDGET.newSlider{name="sfx", x=1000,y=150,lim=130,w=250,disp=SETval('sfx'),code=SETsto('sfx'),change=function()SFX.play('blip_1')end},
    WIDGET.newSlider{name="voc", x=1000,y=220,lim=130,w=250,disp=SETval('voc'),code=SETsto('voc'),change=function()VOC.play('test')end},
    WIDGET.newButton{name="music",x=1140,y=540,w=170,h=80,font=40,code=pressKey"tab"},
    WIDGET.newButton{name="back", x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene
