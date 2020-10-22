--LIGHT MODULE(Optimized by MrZ,Original on github/love2d community/simple-love-lights)
--Heavily based on mattdesl's libGDX implementation:
--https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows
local gc=love.graphics
local C=gc.clear
local shadowMapShader=gc.newShader("Zframework/shader/shadowMap.glsl")--Shader for caculating the 1D shadow map.
local lightRenderShader=gc.newShader("Zframework/shader/lightRender.glsl")--Shader for rendering blurred lights and shadows.
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
	gc.setCanvas(L.blackCanvas)C()
	gc.setCanvas(L.shadowCanvas)C()
	gc.setCanvas(L.renderCanvas)C()
	lightRenderShader:send("xresolution",L.size)
	shadowMapShader:send("yresolution",L.size)

	--Get up-left of light
	local X=L.x-L.size*.5
	local Y=L.y-L.size*.5

	--Render solid
	gc.translate(-X,-Y)
	L.blackCanvas:renderTo(L.blackFn)
	gc.translate(X,Y)

	--Render shade canvas by solid
	gc.setShader(shadowMapShader)
	gc.setCanvas(L.shadowCanvas)
	gc.draw(L.blackCanvas)

	--Render light canvas by shade
	gc.setShader(lightRenderShader)
	gc.setCanvas(L.renderCanvas)
	gc.draw(L.shadowCanvas,0,0,0,1,L.size)

	--Ready to final render
	gc.setShader()gc.setCanvas()gc.setBlendMode("add")

	--Render to screes
	gc.setColor(r,g,b,a)
	gc.draw(L.renderCanvas,X,Y+L.size,0,1,-1)

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
		--Methods
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