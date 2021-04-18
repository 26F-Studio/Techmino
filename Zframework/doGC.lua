local gc=love.graphics
local cmds={
	trans="translate",
	scale="scale",
	setCL="setColor",
	setLW="setLineWidth",
	draw="draw",
	dLine="line",
	fRect=function(...)gc.rectangle("fill",...)end,
	dRect=function(...)gc.rectangle("line",...)end,
	fCirc=function(...)gc.circle("fill",...)end,
	dCirc=function(...)gc.circle("line",...)end,
	fPoly=function(...)gc.polygon("line",...)end,
	dPoly=function(...)gc.polygon("line",...)end,
}
return function(L)
	gc.push()
		local canvas=gc.newCanvas(L[1],L[2])
		gc.setCanvas(canvas)
			gc.origin()
			gc.setColor(1,1,1)
			gc.setLineWidth(1)
			for i=3,#L do
				print(L[i][1])
				local cmd=cmds[L[i][1]]
				print(L[i][1])
				if type(cmd)=="string"then
					gc[cmd](unpack(L[i],2))
				else
					cmd(unpack(L[i],2))
				end
			end
		gc.setCanvas()
	gc.pop()
	return canvas
end