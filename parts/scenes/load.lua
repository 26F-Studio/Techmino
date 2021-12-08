local gc=love.graphics

local max,min,sin,cos=math.max,math.min,math.sin,math.cos
local rnd=math.random

local scene={}

local loading
local progress,maxProgress
local t1,t2,animeType
local studioLogo--Studio logo text object
local logoColor1,logoColor2

local titleTransform={
    function(t)gc.translate(0,max(50-t,0)^2/25)end,
    function(t)gc.translate(0,-max(50-t,0)^2/25)end,
    function(t,i)local d=max(50-t,0)gc.translate(sin(TIME()*3+626*i)*d,cos(TIME()*3+626*i)*d)end,
    function(t,i)local d=max(50-t,0)gc.translate(sin(TIME()*3+626*i)*d,-cos(TIME()*3+626*i)*d)end,
    function(t)gc.setColor(1,1,1,min(t*.02,1)+rnd()*.2)end,
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
    YIELD()
    YIELD('loadSFX')SFX.load('media/effect/'..SETTING.sfxPack..'/')
    YIELD('loadSample')SFX.loadSample{name='bass',path='media/sample/bass',base='A2'}--A2~A4
    YIELD('loadSample')SFX.loadSample{name='lead',path='media/sample/lead',base='A3'}--A3~A5
    YIELD('loadSample')SFX.loadSample{name='bell',path='media/sample/bell',base='A4'}--A4~A6
    YIELD('loadVoice')VOC.load('media/vocal/'..SETTING.vocPack..'/')
    YIELD('loadFont')for i=1,17 do getFont(15+5*i)getFont(15+5*i,'mono')end

    YIELD('loadOther')
    STAT.run=STAT.run+1

    --Connect to server
    if SETTING.autoLogin then
        NET.wsconn_app()
    end

    SFX.play('enter',.8)
    SFX.play('welcome')
    VOC.play('welcome')
    THEME.fresh()
    LOADED=true
    return'finish'
end)

function scene.sceneInit()
    studioLogo=gc.newText(getFont(90),"26F Studio")
    progress=0
    maxProgress=10
    t1,t2=0,0--Timer
    animeType={}for i=1,#SVG_TITLE_FILL do animeType[i]=rnd(#titleTransform)end--Random animation type
end
function scene.sceneBack()
    love.event.quit()
end

function scene.mouseDown()
    if LOADED then
        if FIRSTLAUNCH then
            SCN.push('main')
            SCN.swapTo('lang')
        else
            SCN.swapTo(SETTING.simpMode and'main_simple'or'main')
        end
    end
end
scene.touchDown=scene.mouseDown
function scene.keyDown(key)
    if key=='escape'then
        love.event.quit()
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
    gc.clear(.08,.08,.084)

    local T=(t1+110)%300
    if T<30 then
        gc.setLineWidth(4+(30-T)^1.626/62)
    else
        gc.setLineWidth(4)
    end
    gc.push('transform')
    gc.translate(126,100)
    for i=1,#SVG_TITLE_FILL do
        local triangles=love.math.triangulate(SVG_TITLE_FILL[i])
        local t=t1-i*15
        if t>0 then
            gc.push('transform')
            titleTransform[animeType[i]](t,i)
            local dt=(t1+62-5*i)%300
            if dt<20 then
                gc.translate(0,math.abs(10-dt)-10)
            end
            gc.setColor(titleColor[i][1],titleColor[i][2],titleColor[i][3],min(t*.025,1)*.2)
            for j=1,#triangles do
                gc.polygon('fill',triangles[j])
            end
            gc.setColor(1,1,1,min(t*.025,1))
            gc.polygon('line',SVG_TITLE_LINE[i])
            if i==8 then gc.polygon('line',SVG_TITLE_LINE[9])end
            gc.pop()
        end
    end
    gc.pop()

    gc.setColor(logoColor1[1],logoColor1[2],logoColor1[3],progress/maxProgress)mDraw(studioLogo,640,400)
    gc.setColor(logoColor2[1],logoColor2[2],logoColor2[3],progress/maxProgress)for dx=-2,2,2 do for dy=-2,2,2 do mDraw(studioLogo,640+dx,400+dy)end end
    gc.setColor(.2,.2,.2,progress/maxProgress)mDraw(studioLogo,640,400)

    gc.setColor(COLOR.Z)
    setFont(30)
    mStr(text.loadText[loading]or"",640,530)
end

return scene
