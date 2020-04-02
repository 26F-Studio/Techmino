--LIGHT MODULE(Optimized by MrZ,Original on github/love2d community/simple-love-lights)
--Heavily based on mattdesl's libGDX implementation:
--https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows
--Private--
local gc=love.graphics
local C=gc.clear
local shadowMapShader=gc.newShader("shader/shadowMap.cs")--Shader for caculating the 1D shadow map.
local lightRenderShader=gc.newShader("shader/lightRender.cs")--Shader for rendering blurred lights and shadows.
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
	local r,g,b,a=love.graphics.getColor()
	gc.setCanvas(L.blackCanvas)C()
	gc.setCanvas(L.shadowCanvas)C()
	gc.setCanvas(L.renderCanvas)C()
	lightRenderShader:send("xresolution",L.size);
	shadowMapShader:send("yresolution",L.size);
	--初始化数据
	local X=L.x-L.size*.5
	local Y=L.y-L.size*.5
	--整束光的左上角
	gc.translate(-X,-Y)
	L.blackCanvas:renderTo(L.blackFn)
	gc.translate(X,Y)
	--渲染遮光物
	gc.setShader(shadowMapShader)
	gc.setCanvas(L.shadowCanvas)
	gc.draw(L.blackCanvas)
	--根据遮光物渲染阴影画布
	gc.setShader(lightRenderShader)
	gc.setCanvas(L.renderCanvas)
	gc.draw(L.shadowCanvas,0,0,0,1,L.size)
	--根据阴影画布渲染光画布
	gc.setShader()gc.setCanvas()gc.setBlendMode("add")
	--准备渲染
	gc.setColor(r,g,b,a)
	gc.draw(L.renderCanvas,X,Y+L.size,0,1,-1)
	--渲染到屏幕
	gc.setBlendMode("alpha")
	--复位
end
--Public--
function Lights.draw()
	for i=1,#Lights do
		Lights[i]:draw()
	end
end
function Lights.clear(L)
	for i=#Lights,1,-1 do
		Lights[i]:destroy()
		Lights[i]=nil
	end
end
function Lights.add(x,y,R,F)
	local id=#Lights+1
	Lights[id]={
		id=id,
		x=x,y=y,size=R,
		blackCanvas=gc.newCanvas(R,R),--遮挡物画布
		shadowCanvas=gc.newCanvas(R,1),--1D视深画布
		renderCanvas=gc.newCanvas(R,R),--灯光画布
		blackFn=F,--遮挡物绘图函数
		--方法
		move=move,
		setPow=setPow,
		draw=draw,
		destroy=destroy,
	}
end
return Lights