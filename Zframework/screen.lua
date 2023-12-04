local SCR={
    w0=1280,h0=720, -- Default Screen Size
    x=0,y=0,        -- Up-left Coord on screen
    cx=0,cy=0,      -- Center Coord on screen (Center X/Y)
    ex=0,ey=0,      -- Down-right Coord on screen (End X/Y)
    w=0,h=0,        -- Fullscreen w/h for graphic functions
    W=0,H=0,        -- Fullscreen w/h for shader
    safeX=0,safeY=0,-- Safe area
    safeW=0,safeH=0,-- Safe area
    rad=0,          -- Radius
    k=1,            -- Scale size
    dpi=1,          -- DPI from gc.getDPIScale()

    -- Screen transformation objects
    origin=love.math.newTransform(),
    xOy=love.math.newTransform(),
    xOy_m=love.math.newTransform(),
    xOy_ul=love.math.newTransform(),
    xOy_u=love.math.newTransform(),
    xOy_ur=love.math.newTransform(),
    xOy_l=love.math.newTransform(),
    xOy_r=love.math.newTransform(),
    xOy_dl=love.math.newTransform(),
    xOy_d=love.math.newTransform(),
    xOy_dr=love.math.newTransform(),
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

    SCR.origin:setTransformation(0,0)
    SCR.xOy:setTransformation(SCR.x,SCR.y,0,SCR.k)
    SCR.xOy_m:setTransformation(w/2,h/2,0,SCR.k)
    SCR.xOy_ul:setTransformation(0,0,0,SCR.k)
    SCR.xOy_u:setTransformation(w/2,0,0,SCR.k)
    SCR.xOy_ur:setTransformation(w,0,0,SCR.k)
    SCR.xOy_l:setTransformation(0,h/2,0,SCR.k)
    SCR.xOy_r:setTransformation(w,h/2,0,SCR.k)
    SCR.xOy_dl:setTransformation(0,h,0,SCR.k)
    SCR.xOy_d:setTransformation(w/2,h,0,SCR.k)
    SCR.xOy_dr:setTransformation(w,h,0,SCR.k)
end
function SCR.info()
    return {
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
