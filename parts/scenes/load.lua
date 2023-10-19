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
    modeIcons.marathon=GC.DO{128,128,
        {'move',6,2},
        {'fRect',40,12,-8,84},
        {'fPoly',40,12,96,40,40,68},
        {'fRect',16,96,40,12},
    }
    modeIcons.infinite=GC.DO{128,128,
        {'setLW',8},
        {'dCirc',64,64,56},
        {'line',64,28,64,64,82,82},
        {'move',1,1},
        {'fRect',60,14,8,8},
        {'fRect',14,60,8,8},
        {'fRect',104,60,8,8},
        {'fRect',60,104,8,8},
    }
    modeIcons.classic=GC.DO{128,128,
        {'setLW',12},
        {'dRect',20,48,24,24},
        {'dRect',52,48,24,24},
        {'dRect',84,48,24,24},
        {'dRect',52,80,24,24},
    }
    modeIcons.tsd=GC.DO{128,128,
        {'fRect',14,14,32,32},
        {'fRect',14,82,32,32},
        {'fRect',82,82,32,32},
        {'move',1,1},
        {'setLW',2},
        {'dPoly',14,48,112,48,112,78,78,78,78,112,48,112,48,78,14,78},
    }
    modeIcons.t49=GC.DO{128,128,
        {'setLW',4},
        {'dRect',10,10,20,40},{'dRect',98,10,20,40},
        {'dRect',10,78,20,40},{'dRect',98,78,20,40},
        {'dRect',40,20,46,86},
        {'setCL',1,1,1,.7},
        {'fRect',40,20,46,86},
    }
    modeIcons.t99=GC.DO{128,128,
        {'setLW',4},
        {'dRect',04,004,12,24},{'dRect',022,004,12,24},
        {'dRect',04,036,12,24},{'dRect',022,036,12,24},
        {'dRect',04,068,12,24},{'dRect',022,068,12,24},
        {'dRect',04,100,12,24},{'dRect',022,100,12,24},
        {'dRect',94,004,12,24},{'dRect',112,004,12,24},
        {'dRect',94,036,12,24},{'dRect',112,036,12,24},
        {'dRect',94,068,12,24},{'dRect',112,068,12,24},
        {'dRect',94,100,12,24},{'dRect',112,100,12,24},
        {'dRect',40,20,46,86},
        {'setCL',1,1,1,.7},
        {'fRect',40,20,46,86},
    }
    modeIcons.secret_grade=GC.DO{128,128,
        {'fRect',048,000,16,16},
        {'fRect',064,016,16,16},
        {'fRect',080,032,16,16},
        {'fRect',096,048,16,16},
        {'fRect',112,064,16,16},
        {'fRect',096,080,16,16},
        {'fRect',080,096,16,16},
        {'fRect',064,112,16,16},
    }
    modeIcons.sprint_pento=GC.DO{256,256,
        {'scale',2.8},
        {'move',-10,-5},
        {'rotate',-.26},
        {'setFT',100},
        {'print',CHAR.mino.F},
    }
    modeIcons.sprint_tri=GC.DO{256,256,
        {'move',72,20},
        {'rotate',.26},
        {'fRect',0,80,160,80},
        {'fRect',80,0,80,80}
    }
    modeIcons.ultra=GC.DO{128,128,
        {'setLW',12},
        {'fRect',46,0,36,12},
        {'dCirc',64,72,48},
        {'fRect',58,42,12,38,4,4},
        {'fRect',58,68,24,12,4,4},
        {'rotate',math.pi/4},
        {'fRect',90,-64,16,24,4,4}
    }
    modeIcons.big=GC.DO{100,100,
        {'setLW',2},
        {'fRect',00,80,60,20},
        {'fRect',20,60,20,20},
        {'setCL',unpack(COLOR.lX)},
        {'dRect',00,80,20,20},
        {'dRect',20,80,20,20},
        {'dRect',40,80,20,20},
        {'dRect',20,60,20,20},

        {'setCL',1,1,1,.5},
        -- Draw grid
        {'fRect',15,20,8,2},{'fRect',35,20,8,2},{'fRect',55,20,8,2},{'fRect',75,20,8,2},
        {'fRect',15,40,8,2},{'fRect',35,40,8,2},{'fRect',55,40,8,2},{'fRect',75,40,8,2},
        {'fRect',15,60,8,2},{'fRect',35,60,8,2},{'fRect',55,60,8,2},{'fRect',75,60,8,2},
        {'fRect',15,80,8,2},{'fRect',35,80,8,2},{'fRect',55,80,8,2},{'fRect',75,80,8,2},

        {'fRect',18,17,2,8},{'fRect',38,17,2,8},{'fRect',58,17,2,8},{'fRect',78,17,2,8},
        {'fRect',18,37,2,8},{'fRect',38,37,2,8},{'fRect',58,37,2,8},{'fRect',78,37,2,8},
        {'fRect',18,57,2,8},{'fRect',38,57,2,8},{'fRect',58,57,2,8},{'fRect',78,57,2,8},
        {'fRect',18,77,2,8},{'fRect',38,77,2,8},{'fRect',58,77,2,8},{'fRect',78,77,2,8},
    }
    modeIcons.zen=GC.DO{128,128,
        {'setLW',8},
        {'dArc',30,74,20,1.45,5.1},
        {'dArc',63,57,29,.2,-3.14},
        {'dArc',101,79,15,-1.8,1.8},
        {'fRect',26,89,78,9},
        {'fRect',86,60,14,8}
    }
    do -- generate tech b2b modeicons
        local base={128,128,
            {'setLW',4},
            {'dPoly',51,12, 75,12, 75,43, 109,117, 17,117, 51,43}, -- draw Erlenmeyer flask
            {'fPoly',42,10, 52,10, 52,20},{'fPoly',74,10, 84,10, 74,20}, -- draw flask rim
            -- draw flask measurement marks
            {'line',42,105, 62,105},{'line',46,91, 62,91},
            {'line',50,75,  62,75}, {'line',54,57, 62,57},
        }
        local plus={
            {'line',105,16, 105,38},
            {'line',94,27,  116,27},
        }
        modeIcons.tech=GC.DO(base)
        modeIcons.tech_plus=GC.DO(TABLE.connect(base,plus))
    end

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
