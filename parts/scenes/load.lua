local max,min,sin,cos=math.max,math.min,math.sin,math.cos

local scene={}

local loading
local progress,maxProgress
local t1,t2,animeType
local studioLogo-- Studio logo text object
local logoColor1,logoColor2

local titleTransform={
    function(t) GC.translate(0,max(50-t,0)^2/25) end,
    function(t) GC.translate(0,-max(50-t,0)^2/25) end,
    function(t,i) local d=max(50-t,0)GC.translate(sin(TIME()*3+626*i)*d,cos(TIME()*3+626*i)*d) end,
    function(t,i) local d=max(50-t,0)GC.translate(sin(TIME()*3+626*i)*d,-cos(TIME()*3+626*i)*d) end,
    function(t) GC.setColor(1,1,1,min(t*.02,1)+math.random()*.2) end,
}

local loadingThread=coroutine.wrap(function()
    DAILYLAUNCH=freshDate'q'
    if DAILYLAUNCH then
        logoColor1=COLOR.S
        logoColor2=COLOR.lS
    else
        local r=math.random()*6.2832
        logoColor1={COLOR.rainbow(r)}
        logoColor2={COLOR.rainbow_light(r)}
    end
    coroutine.yield()
    coroutine.yield('loadSFX')SFX.load('media/effect/'..SETTING.sfxPack..'/')
    coroutine.yield('loadSample')SFX.loadSample{name='bass',path='media/sample/bass',base='A2'}-- A2~A4
    coroutine.yield('loadSample')SFX.loadSample{name='lead',path='media/sample/lead',base='A3'}-- A3~A5
    coroutine.yield('loadSample')SFX.loadSample{name='bell',path='media/sample/bell',base='A4'}-- A4~A6
    coroutine.yield('loadVoice')VOC.load('media/vocal/'..SETTING.vocPack..'/')
    coroutine.yield('loadFont') for i=1,17 do getFont(15+5*i)getFont(15+5*i,'mono') end

    coroutine.yield('loadModeIcon')
    local modeIcons={}
    modeIcons.marathon=GC.DO{64,64,
        {'move',3,1},
        {'fRect',20,6,-4,42},
        {'fPoly',20,6,48,20,20,34},
        {'fRect',8,48,20,6},
    }
    modeIcons.infinite=GC.DO{64,64,
        {'setLW',4},
        {'dCirc',32,32,28},
        {'line',32,32,32,14},
        {'line',32,32,41,41},
        {'move',.5,.5},
        {'fRect',30,7,4,4},
        {'fRect',7,30,4,4},
        {'fRect',52,30,4,4},
        {'fRect',30,52,4,4},
    }
    modeIcons.classic=GC.DO{64,64,
        {'setLW',6},
        {'dRect',10,24,12,12},
        {'dRect',26,24,12,12},
        {'dRect',42,24,12,12},
        {'dRect',26,40,12,12},
    }
    modeIcons.tsd=GC.DO{64,64,
        {'fRect',7,7,16,16},
        {'fRect',7,41,16,16},
        {'fRect',41,41,16,16},
        {'move',.5,.5},
        {'setLW',1},
        {'dPoly',7,24,56,24,56,39,39,39,39,56,24,56,24,39,7,39},
    }
    modeIcons.t49=GC.DO{64,64,
        {'setLW',2},
        {'dRect',05,05,10,20},{'dRect',49,05,10,20},
        {'dRect',05,39,10,20},{'dRect',49,39,10,20},
        {'dRect',20,10,23,43},
        {'setCL',1,1,1,.7},
        {'fRect',20,10,23,43},
    }
    modeIcons.t99=GC.DO{64,64,
        {'setLW',2},
        {'dRect',02,02,6,12},{'dRect',11,02,6,12},
        {'dRect',02,18,6,12},{'dRect',11,18,6,12},
        {'dRect',02,34,6,12},{'dRect',11,34,6,12},
        {'dRect',02,50,6,12},{'dRect',11,50,6,12},
        {'dRect',47,02,6,12},{'dRect',56,02,6,12},
        {'dRect',47,18,6,12},{'dRect',56,18,6,12},
        {'dRect',47,34,6,12},{'dRect',56,34,6,12},
        {'dRect',47,50,6,12},{'dRect',56,50,6,12},
        {'dRect',20,10,23,43},
        {'setCL',1,1,1,.7},
        {'fRect',20,10,23,43},
    }

    coroutine.yield('loadMode')
    for _,M in next,MODES do
        M.records=loadFile("record/"..M.name..".rec",'-luaon -canSkip') or M.score and{}
        M.icon=M.icon and (modeIcons[M.icon] or GC.newImage("media/image/modeicon/"..M.icon..".png"))
    end

    coroutine.yield('loadOther')
    STAT.run=STAT.run+1

    SFX.play('enter',.8)
    SFX.play('welcome')
    VOC.play('welcome')
    THEME.set(THEME.calculate())
    LOADED=true
    saveStats()
    Z.setPowerInfo(SETTING.powerInfo)
    return 'finish'
end)

function scene.enter()
    studioLogo=GC.newText(getFont(90),"26F Studio")
    progress=0
    maxProgress=10
    t1,t2=0,0-- Timer
    animeType={} for i=1,#SVG_TITLE_FILL do animeType[i]=math.random(#titleTransform) end-- Random animation type
end
function scene.leave()
    SCN.go('quit','none')
end

function scene.mouseDown()
    if LOADED then
        if FIRSTLAUNCH then
            SCN.push('main')
            SCN.go('lang')
        else
            SCN.go(SETTING.simpMode and 'main_simple' or 'main')
        end
    end
end
scene.touchDown=scene.mouseDown
function scene.keyDown(key)
    if key=='escape' then
        SCN.go('quit','none')
    else
        scene.mouseDown()
    end
end

function scene.update(dt)
    if not LOADED then
        loading=loadingThread()
        progress=progress+1
    else
        t1,t2=t1+dt*60,t2+dt*60
    end
end

local titleColor={COLOR.P,COLOR.F,COLOR.V,COLOR.A,COLOR.M,COLOR.N,COLOR.W,COLOR.Y}
function scene.draw()
    GC.clear(.08,.08,.084)

    local T=(t1+110)%300
    if T<30 then
        GC.setLineWidth(4+(30-T)^1.626/62)
    else
        GC.setLineWidth(4)
    end
    GC.push('transform')
    GC.translate(126,100)
    for i=1,#SVG_TITLE_FILL do
        local triangles=love.math.triangulate(SVG_TITLE_FILL[i])
        local t=t1-i*15
        if t>0 then
            GC.push('transform')
            titleTransform[animeType[i]](t,i)
            local dt=(t1+62-5*i)%300
            if dt<20 then
                GC.translate(0,math.abs(10-dt)-10)
            end
            GC.setColor(titleColor[i][1],titleColor[i][2],titleColor[i][3],min(t*.025,1)*.2)
            for j=1,#triangles do
                GC.polygon('fill',triangles[j])
            end
            GC.setColor(1,1,1,min(t*.025,1))
            GC.polygon('line',SVG_TITLE_LINE[i])
            if i==8 then GC.polygon('line',SVG_TITLE_LINE[9]) end
            GC.pop()
        end
    end
    GC.pop()

    GC.setColor(logoColor1[1],logoColor1[2],logoColor1[3],progress/maxProgress)mDraw(studioLogo,640,400)
    GC.setColor(logoColor2[1],logoColor2[2],logoColor2[3],progress/maxProgress) for dx=-2,2,2 do for dy=-2,2,2 do mDraw(studioLogo,640+dx,400+dy) end end
    GC.setColor(.2,.2,.2,progress/maxProgress)mDraw(studioLogo,640,400)

    GC.setColor(COLOR.Z)
    setFont(30)
    GC.mStr(text.loadText[loading] or "",640,530)
end

return scene
