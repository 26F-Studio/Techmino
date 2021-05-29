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

	SCR.x,SCR.y=0,0
	if SCR.r>=SCR.h0/SCR.w0 then
		SCR.k=w/SCR.w0
		SCR.y=(h-SCR.h0*SCR.k)/2
	else
		SCR.k=h/SCR.h0
		SCR.x=(w-SCR.w0*SCR.k)/2
	end
	SCR.cx,SCR.cy=SCR.w/2,SCR.h/2
	SCR.ex,SCR.ey=SCR.w-SCR.x,SCR.h-SCR.y
	SCR.safeX,SCR.safeY,SCR.safeW,SCR.safeH=love.window.getSafeArea()
	SCR.xOy:setTransformation(w/2,h/2,nil,SCR.k,nil,SCR.w0/2,SCR.h0/2)
end
function SCR.info()
	return{
		("w0,h0 : %d, %d"):format(SCR.w0,SCR.h0),
		("x,y : %d, %d"):format(SCR.x,SCR.y),
		("cx,cy : %d, %d"):format(SCR.cx,SCR.cy),
		("ex,ey : %d, %d"):format(SCR.ex,SCR.ey),
		("w,h : %d, %d"):format(SCR.w,SCR.h),
		("W,H : %d, %d"):format(SCR.W,SCR.H),
		("safeX,safeY : %d, %d"):format(SCR.safeX,SCR.safeY),
		("safeW,safeH : %d, %d"):format(SCR.safeW,SCR.safeH),
		("k,dpi,rad : %.2f, %d, %.2f"):format(SCR.k,SCR.dpi,SCR.rad),
	}
end
return SCR