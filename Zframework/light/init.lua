--LIGHT MODULE (Optimized by MrZ, Original on github/love2d community/simple-love-lights)
--Heavily based on mattdesl's libGDX implementation:
--https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows
local gc=love.graphics
local clear,translate=gc.clear,gc.translate
local setCanvas,setShader=gc.setCanvas,gc.setShader
local render=gc.draw

local shadowMapShader=gc.newShader("Zframework/light/shadowMap.glsl")--Shader for caculating the 1D shadow map.
local lightRenderShader=gc.newShader("Zframework/light/lightRender.glsl")--Shader for rendering blurred lights and shadows.
local Lights={}--Lightsource objects
local function move(L,x,y)
	L.x,L.y=x,y
end
local function setPow(L,pow)
	L.size=pow
end
local function destroy(L)
	L.blackCanvas:release()
	L.shadowCanvas:release()
	L.renderCanvas:release()
end
local function draw(L)
	--Initialization
	local r,g,b,a=love.graphics.getColor()
	setCanvas(L.blackCanvas)clear()
	setCanvas(L.shadowCanvas)clear()
	setCanvas(L.renderCanvas)clear()
	lightRenderShader:send("xresolution",L.size)
	shadowMapShader:send("yresolution",L.size)

	--Get up-left of light
	local X=L.x-L.size*.5
	local Y=L.y-L.size*.5

	--Render solid
	translate(-X,-Y)
	L.blackCanvas:renderTo(L.blackFn)
	translate(X,Y)

	--Render shade canvas by solid
	setShader(shadowMapShader)
	setCanvas(L.shadowCanvas)
	render(L.blackCanvas)

	--Render light canvas by shade
	setShader(lightRenderShader)
	setCanvas(L.renderCanvas)
	render(L.shadowCanvas,0,0,0,1,L.size)

	--Ready to final render
	setShader()setCanvas()gc.setBlendMode("add")

	--Render to screes
	gc.setColor(r,g,b,a)
	render(L.renderCanvas,X,Y+L.size,0,1,-1)

	--Reset
	gc.setBlendMode("alpha")
end

local LIGHT={}
function LIGHT.draw()
	for i=1,#Lights do
		Lights[i]:draw()
	end
end
function LIGHT.clear()
	for i=#Lights,1,-1 do
		Lights[i]:destroy()
		Lights[i]=nil
	end
end
function LIGHT.add(x,y,R,F)
	local id=#Lights+1
	Lights[id]={
		id=id,
		x=x,y=y,size=R,
		blackCanvas=gc.newCanvas(R,R),--Solid canvas
		shadowCanvas=gc.newCanvas(R,1),--1D vis-depth canvas
		renderCanvas=gc.newCanvas(R,R),--Light canvas
		blackFn=F,--Solid draw funcion

		move=move,
		setPow=setPow,
		draw=draw,
		destroy=destroy,
	}
end
return LIGHT