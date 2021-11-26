local gc=love.graphics
local setColor,printf,draw=gc.setColor,gc.printf,gc.draw
local GC={}
function GC.mStr(obj,x,y)printf(obj,x-626,y,1252,'center')end--Printf a string with 'center'
function GC.simpX(obj,x,y)draw(obj,x-obj:getWidth()*.5,y)end--Simply draw an obj with x=obj:getWidth()/2
function GC.simpY(obj,x,y)draw(obj,x,y-obj:getHeight()*.5)end--Simply draw an obj with y=obj:getWidth()/2
function GC.X(obj,x,y,a,k)draw(obj,x,y,a,k,nil,obj:getWidth()*.5,0)end--Draw an obj with x=obj:getWidth()/2
function GC.Y(obj,x,y,a,k)draw(obj,x,y,a,k,nil,0,obj:getHeight()*.5)end--Draw an obj with y=obj:getWidth()/2
function GC.draw(obj,x,y,a,k)draw(obj,x,y,a,k,nil,obj:getWidth()*.5,obj:getHeight()*.5)end--Draw an obj with both middle X & Y
function GC.outDraw(obj,div,x,y,a,k)
    local w,h=obj:getWidth()*.5,obj:getHeight()*.5
    draw(obj,x-div,y-div,a,k,nil,w,h)
    draw(obj,x-div,y+div,a,k,nil,w,h)
    draw(obj,x+div,y-div,a,k,nil,w,h)
    draw(obj,x+div,y+div,a,k,nil,w,h)
end
function GC.shadedPrint(str,x,y,mode,d,clr1,clr2)
    local w=1280
    if mode=='center'then
        x=x-w*.5
    elseif mode=='right'then
        x=x-w
    end
    if not d then d=1 end
    setColor(clr1 or COLOR.D)
    printf(str,x-d,y-d,w,mode)
    printf(str,x-d,y+d,w,mode)
    printf(str,x+d,y-d,w,mode)
    printf(str,x+d,y+d,w,mode)
    setColor(clr2 or COLOR.Z)
    printf(str,x,y,w,mode)
end
function GC.regularPolygon(mode,x,y,R,segments,r,phase)
    local X,Y={},{}
    local ang=phase or 0
    local angStep=6.283185307179586/segments
    for i=1,segments do
        X[i]=x+R*math.cos(ang)
        Y[i]=y+R*math.sin(ang)
        ang=ang+angStep
    end
    X[segments+1]=x+R*math.cos(ang)
    Y[segments+1]=y+R*math.sin(ang)
    local halfAng=6.283185307179586/segments/2
    local erasedLen=r*math.tan(halfAng)
    if mode=='line'then
        erasedLen=erasedLen+1--Fix 1px cover
        for i=1,segments do
            --Line
            local x1,y1,x2,y2=X[i],Y[i],X[i+1],Y[i+1]
            local dir=math.atan2(y2-y1,x2-x1)
            gc.line(x1+erasedLen*math.cos(dir),y1+erasedLen*math.sin(dir),x2-erasedLen*math.cos(dir),y2-erasedLen*math.sin(dir))

            --Arc
            ang=ang+angStep
            local R2=R-r/math.cos(halfAng)
            local arcCX,arcCY=x+R2*math.cos(ang),y+R2*math.sin(ang)
            gc.arc('line','open',arcCX,arcCY,r,ang-halfAng,ang+halfAng)
        end
    elseif mode=='fill'then
        local L={}
        for i=1,segments do
            --Line
            local x1,y1,x2,y2=X[i],Y[i],X[i+1],Y[i+1]
            local dir=math.atan2(y2-y1,x2-x1)
            table.insert(L,x1+erasedLen*math.cos(dir))
            table.insert(L,y1+erasedLen*math.sin(dir))
            table.insert(L,x2-erasedLen*math.cos(dir))
            table.insert(L,y2-erasedLen*math.sin(dir))

            --Arc
            ang=ang+angStep
            local R2=R-r/math.cos(halfAng)
            local arcCX,arcCY=x+R2*math.cos(ang),y+R2*math.sin(ang)
            gc.arc('fill','open',arcCX,arcCY,r,ang-halfAng,ang+halfAng)
        end
        gc.polygon('fill',L)
    else
        error("Draw mode should be 'line' or 'fill'")
    end
end
do--function GC.DO(L)
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
        rawFT=function(...)FONT.rawset(...)end,
        setFT=function(...)FONT.set(...)end,
        mText=GC.mStr,
        mDraw=GC.draw,
        mDrawX=GC.X,
        mDrawY=GC.Y,
        mOutDraw=GC.outDraw,

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

        fRPol=function(...)GC.regularPolygon('fill',...)end,
        dRPol=function(...)GC.regularPolygon('line',...)end,
    }
    local sizeLimit=gc.getSystemLimits().texturesize
    function GC.DO(L)
        gc.push()
            ::REPEAT_tryAgain::
            local success,canvas=pcall(gc.newCanvas,math.min(L[1],sizeLimit),math.min(L[2],sizeLimit))
            if not success then
                sizeLimit=math.floor(sizeLimit*.8)
                goto REPEAT_tryAgain
            end
            gc.setCanvas(canvas)
                gc.origin()
                gc.clear(1,1,1,0)
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
                        if type(func)=='string'then
                            func=gc[func]
                        end
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
end
return GC
