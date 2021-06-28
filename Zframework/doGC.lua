local gc=love.graphics
local cmds={
	origin="origin",
	move="translate",
	scale="scale",
	rotate="rotate",
	shear="shear",
	clear="clear",

	setCL="setColor",
	setCM="setColorMask",
	setLW="setLineWidth",
	setLS="setLineStyle",
	setLJ="setLineJoin",

	print="print",
	setFT=setFont,
	mText=ADRAW.str,
	mDraw=ADRAW.draw,
	mOutDraw=ADRAW.outDraw,

	draw="draw",
	line="line",
	fRect=function(...)gc.rectangle('fill',...)end,
	dRect=function(...)gc.rectangle('line',...)end,
	fCirc=function(...)gc.circle('fill',...)end,
	dCirc=function(...)gc.circle('line',...)end,
	fElps=function(...)gc.ellipse('fill',...)end,
	dElps=function(...)gc.ellipse('line',...)end,
	fPoly=function(...)gc.polygon('fill',...)end,
	dPoly=function(...)gc.polygon('line',...)end,

	dPie=function(...)gc.arc('line',...)end,
	dArc=function(...)gc.arc('line','open',...)end,
	dBow=function(...)gc.arc('line','closed',...)end,
	fPie=function(...)gc.arc('fill',...)end,
	fArc=function(...)gc.arc('fill','open',...)end,
	fBow=function(...)gc.arc('fill','closed',...)end,
}
local sizeLimit=gc.getSystemLimits().texturesize
return function(L)
	gc.push()
		::REPEAT_tryAgain::
		local success,canvas=pcall(gc.newCanvas,math.min(L[1],sizeLimit),math.min(L[2],sizeLimit))
		if not success then
			sizeLimit=math.floor(sizeLimit*.8)
			goto REPEAT_tryAgain
		end
		gc.setCanvas(canvas)
			gc.origin()
			gc.setColor(1,1,1)
			gc.setLineWidth(1)
			for i=3,#L do
				local cmd=L[i][1]
				if type(cmd)=='boolean'and cmd then
					table.remove(L[i],1)
					cmd=L[i][1]
				end
				if type(cmd)=='string'then
					local func=cmds[cmd]
					if type(func)=='string'then func=gc[func]end
					if func then
						func(unpack(L[i],2))
					else
						error("No gc command: "..cmd)
					end
				end
			end
		gc.setCanvas()
	gc.pop()
	return canvas
end