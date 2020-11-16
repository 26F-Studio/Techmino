local SCR={
	w0=1280,h0=720,--Default Screen Size
	x=0,y=0,--Up-left Coord on screen
	w=0,h=0,--Fullscreen w/h in gc
	W=0,H=0,--Fullscreen w/h in shader
	rad=0,--Radius
	k=1,--Scale size
	dpi=1,--DPI from gc.getDPIScale()
	xOy=love.math.newTransform(),--Screen transformation object
}
function SCR.setSize(w,h)
	SCR.w0,SCR.h0=w,h
end
return SCR