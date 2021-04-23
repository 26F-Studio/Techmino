local gc=love.graphics
local cmds={
	reset="origin",
	trans="translate",
	scale="scale",
	rotat="rotate",
	clear="clear",

	setCL="setColor",
	setCM="setColorMask",
	setLW="setLineWidth",
	setLS="setLineStyle",
	setLJ="setLineJoin",

	draw="draw",
	dLine="line",
	fRect=function(...)gc.rectangle("fill",...)end,
	dRect=function(...)gc.rectangle("line",...)end,
	fCirc=function(...)gc.circle("fill",...)end,
	dCirc=function(...)gc.circle("line",...)end,
	fPoly=function(...)gc.polygon("fill",...)end,
	dPoly=function(...)gc.polygon("line",...)end,

	drArc=function(...)gc.arc("line",...)end,
	flArc=function(...)gc.arc("fill",...)end,
	dpArc=function(...)gc.arc("line","pie",...)end,
	doArc=function(...)gc.arc("line","open",...)end,
	dcArc=function(...)gc.arc("line","closed",...)end,
	fpArc=function(...)gc.arc("fill","pie",...)end,
	foArc=function(...)gc.arc("fill","open",...)end,
	fcArc=function(...)gc.arc("fill","closed",...)end,
}
return function(L)
	gc.push()
		local canvas=gc.newCanvas(L[1],L[2])
		gc.setCanvas(canvas)
			gc.origin()
			gc.setColor(1,1,1)
			gc.setLineWidth(1)
			for i=3,#L do
				local cmd=cmds[L[i][1]]
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