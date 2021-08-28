--LIGHT MODULE (Optimized by MrZ, Original on github/LÖVE community/simple-love-lights)
--Heavily based on mattdesl's libGDX implementation:
--https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows
local gc=love.graphics
local clear,gc_translate=gc.clear,gc.translate
local gc_setCanvas,gc_setShader=gc.setCanvas,gc.setShader
local gc_setColor,gc_draw=gc.setColor,gc.draw

local shadowMapShader=gc.newShader('Zframework/light/shadowMap.glsl')--Shader for caculating the 1D shadow map.
local lightRenderShader=gc.newShader('Zframework/light/lightRender.glsl')--Shader for rendering blurred lights and shadows.
local Lights={}--Lightsource objects
local function move(L,x,y)
    L.x,L.y=x,y
end
local function setPow(L,pow)
    L.size=pow
end
local function drawLight(L)
    local s=L.size

    --Initialization
    gc_setCanvas(L.blackCanvas)clear()
    gc_setCanvas(L.shadowCanvas)clear()
    gc_setCanvas(L.renderCanvas)clear()
    lightRenderShader:send('xresolution',s)
    shadowMapShader:send('yresolution',s)

    --Get up-left of light
    local X=L.x-s*.5
    local Y=L.y-s*.5

    --Render solid
    gc_translate(-X,-Y)
    L.blackCanvas:renderTo(L.blackFn)
    gc_translate(X,Y)

    --Render shade canvas by solid
    gc_setShader(shadowMapShader)
    gc_setCanvas(L.shadowCanvas)
    gc_draw(L.blackCanvas)

    --Render light canvas by shade
    gc_setShader(lightRenderShader)
    gc_setCanvas(L.renderCanvas)
    gc_draw(L.shadowCanvas,0,0,0,1,s)

    --Ready to final render
    gc_setShader()gc_setCanvas()gc.setBlendMode('add')

    --Render to screen
    gc_draw(L.renderCanvas,X,Y+s,0,1,-1)

    --Reset
    gc.setBlendMode('alpha')
end

local LIGHT={}
function LIGHT.draw()
    gc_setColor(1,1,1)
    for i=1,#Lights do
        drawLight(Lights[i])
    end
end
function LIGHT.clear()
    for i=1,#Lights do
        Lights[i].blackCanvas:release()
        Lights[i].shadowCanvas:release()
        Lights[i].renderCanvas:release()
        Lights[i]=nil
    end
end
function LIGHT.add(x,y,radius,solidFunc)
    local id=#Lights+1
    Lights[id]={
        id=id,
        x=x,y=y,size=radius,
        blackCanvas=gc.newCanvas(radius,radius),--Solid canvas
        shadowCanvas=gc.newCanvas(radius,1),--1D vis-depth canvas
        renderCanvas=gc.newCanvas(radius,radius),--Light canvas
        blackFn=solidFunc,--Solid draw function

        move=move,
        setPow=setPow,
    }
end
return LIGHT
