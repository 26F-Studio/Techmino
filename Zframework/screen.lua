local SCR={
	w0=1280,h0=720,	--Default Screen Size
	x=0,y=0,		--Up-left Coord on screen
	cx=0,cy=0,		--Center Coord on screen (Center X/Y)
	ex=0,ey=0,		--Down-right Coord on screen (End X/Y)
	w=0,h=0,		--Fullscreen w/h for graphic functions
	W=0,H=0,		--Fullscreen w/h for shader
	safeX=0,safeY=0,--Safe area
	safeW=0,safeH=0,--Safe area
	rad=0,			--Radius
	k=1,			--Scale size
	dpi=1,			--DPI from gc.getDPIScale()
	xOy=love.math.newTransform(),--Screen transformation object
}
function SCR.setSize(w,h)
	SCR.w0,SCR.h0=w,h
end
function SCR.resize(w,h)
	SCR.w,SCR.h,SCR.dpi=w,h,love.graphics.getDPIScale()
	SCR.W,SCR.H=SCR.w*SCR.dpi,SCR.h*SCR.dpi
	SCR.r=h/w
	SCR.rad=(w^2+h^2)^.5

	if SCR.r>=SCR.h0/SCR.w0 then
		SCR.k=w/SCR.w0
		SCR.x,SCR.y=0,(h-w*SCR.h0/SCR.w0)/2
	else
		SCR.k=h/SCR.h0
		SCR.x,SCR.y=(w-h*SCR.w0/SCR.h0)/2,0
	end
	SCR.safeX,SCR.safeY,SCR.safeW,SCR.safeH=love.window.getSafeArea()
	SCR.xOy:setTransformation(w/2,h/2,nil,SCR.k,nil,SCR.w0/2,SCR.h0/2)
end
function SCR.print()
	LOG.print("Screen Info:")
	for k,v in next,SCR do
		if type(v)=="number"then
			LOG.print(k..": "..v)
		end
	end
end
return SCR