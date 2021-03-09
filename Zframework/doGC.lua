local gc=love.graphics
local cmds={
	move="translate",
	zoom="scale",
	rgb="setColor",
	wid="setLineWidth",
	line="line",
	rect="rectangle",
	circ="circle",
	poly="polygon",
}
return function(L)
	gc.push()
		local canvas=gc.newCanvas(L[1],L[2])
		gc.setCanvas(canvas)
			gc.origin()
			gc.setColor(1,1,1)
			gc.setLineWidth(1)
			for i=3,#L do
				gc[cmds[L[i][1]]](unpack(L[i],2))
			end
		gc.setCanvas()
	gc.pop()
	return canvas
end