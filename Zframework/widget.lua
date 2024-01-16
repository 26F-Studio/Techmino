local gc=love.graphics
local gc_origin=gc.origin
local gc_translate,gc_replaceTransform=gc.translate,gc.replaceTransform
local gc_stencil,gc_setStencilTest=gc.stencil,gc.setStencilTest
local gc_push,gc_pop=gc.push,gc.pop
local gc_setCanvas,gc_setBlendMode=gc.setCanvas,gc.setBlendMode
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw,gc_line=gc.draw,gc.line
local gc_rectangle=gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf

local kb=love.keyboard
local timer=love.timer.getTime

local next=next
local floor,ceil=math.floor,math.ceil
local max,min=math.max,math.min
local sub,ins,rem=string.sub,table.insert,table.remove
local xOy=SCR.xOy
local FONT=FONT
local mStr=GC.mStr
local approach=MATH.expApproach

local downArrowIcon=GC.DO{40,25,{'fPoly',0,0,20,25,40,0}}
local upArrowIcon=GC.DO{40,25,{'fPoly',0,25,20,0,40,25}}
local clearIcon=GC.DO{40,40,
    {'fRect',16,5,8,3},
    {'fRect',8,8,24,3},
    {'fRect',11,14,18,21},
}
local sureIcon=GC.DO{40,40,
    {'rawFT',35},
    {'mText',"?",20,0},
}
local smallerThen=GC.DO{20,20,
    {'setLW',5},
    {'line',18,2,1,10,18,18},
}
local largerThen=GC.DO{20,20,
    {'setLW',5},
    {'line',2,2,19,10,2,18},
}

local STW,STH-- stencil-wid/hei
local function _rectangleStencil()
    gc.rectangle('fill',1,1,STW-2,STH-2)
end

local onChange=NULL

local WIDGET={}

function WIDGET.setOnChange(func) onChange=assert(type(func)=='function' and func,"WIDGET.setOnChange(func): func must be function") end

local widgetMetatable={
    __tostring=function(self)
        return self:getInfo()
    end,
}

local text={
    type='text',
    mustHaveText=true,
    alpha=0,
}

function text:reset() end
function text:update(dt)
    if self.hideF and self.hideF() then
        if self.alpha>0 then
            self.alpha=max(self.alpha-dt*7.5,0)
        end
    elseif self.alpha<1 then
        self.alpha=min(self.alpha+dt*7.5,1)
    end
end
function text:draw()
    if self.alpha>0 then
        local c=self.color
        gc_setColor(c[1],c[2],c[3],self.alpha)
        local w=self.obj:getWidth()
        local k=min(self.lim/self.obj:getWidth(),1)
        if self.align=='M' then
            gc_draw(self.obj,self.x,self.y,nil,k,1,w*.5,0)
        elseif self.align=='L' then
            gc_draw(self.obj,self.x,self.y,nil,k,1)
        elseif self.align=='R' then
            gc_draw(self.obj,self.x,self.y,nil,k,1,w,0)
        end
    end
end
function WIDGET.newText(D)-- name,x,y[,lim][,fText][,color][,font=30][,fType][,align='M'][,hideF][,hide]
    local _={
        name= D.name or "_",
        x=    D.x,
        y=    D.y,
        lim=  D.lim or 1e99,

        fText=D.fText,
        color=D.color and (COLOR[D.color] or D.color) or COLOR.Z,
        font= D.font or 30,
        fType=D.fType,
        align=D.align or 'M',
        hideF=D.hideF,
    }
    for k,v in next,text do _[k]=v end
    if not _.hideF then _.alpha=1 end
    setmetatable(_,widgetMetatable)
    return _
end

local image={
    type='image',
}
function image:reset()
    if type(self.img)=='string' then
        self.img=IMG[self.img]
    end
end
function image:draw()
    gc_setColor(1,1,1,self.alpha)
    gc_draw(self.img,self.x,self.y,self.ang,self.k)
end
function WIDGET.newImage(D)-- name[,img(name)],x,y[,ang][,k][,hideF][,hide]
    local _={
        name= D.name or "_",
        img=  D.img or D.name or "_",
        alpha=D.alpha,
        x=    D.x,
        y=    D.y,
        ang=  D.ang,
        k=    D.k,
        hideF=D.hideF,
        hide= D.hide,
    }
    for k,v in next,image do _[k]=v end
    setmetatable(_,widgetMetatable)
    return _
end

local button={
    type='button',
    mustHaveText=true,
    ATV=0,-- Activating time(0~8)
}
function button:reset()
    self.ATV=0
end
function button:setObject(obj)
    if type(obj)=='string' or type(obj)=='number' then
        self.obj=gc.newText(FONT.get(self.font,self.fType),obj)
    elseif obj then
        self.obj=obj
    end
end
function button:isAbove(x,y)
    local ATV=self.ATV
    return
        x>self.x-ATV and
        y>self.y and
        x<self.x+self.w+2*ATV and
        y<self.y+self.h
end
function button:getCenter()
    return self.x+self.w*.5,self.y+self.h*.5
end
function button:update(dt)
    local ATV=self.ATV
    if WIDGET.sel==self then
        if ATV<8 then self.ATV=min(ATV+dt*60,8) end
    else
        if ATV>0 then self.ATV=max(ATV-dt*30,0) end
    end
end
function button:draw()
    local x,y,w,h=self.x,self.y,self.w,self.h
    local ATV=self.ATV
    local c=self.color
    local r,g,b=c[1],c[2],c[3]

    -- Button
    gc_setColor(.15+r*.7,.15+g*.7,.15+b*.7,.9)
    gc_rectangle('fill',x-ATV,y,w+2*ATV,h,4)
    gc_setLineWidth(2)
    gc_setColor(.3+r*.7,.3+g*.7,.3+b*.7)
    gc_rectangle('line',x-ATV,y,w+2*ATV,h,5)
    if ATV>0 then
        gc_setColor(.97,.97,.97,ATV*.125)
        gc_rectangle('line',x-ATV,y,w+2*ATV,h,3)
    end

    -- Drawable
    local obj=self.obj
    local ox,oy=obj:getWidth()*.5,obj:getHeight()*.5
    local y0=y+h*.5
    gc_setColor(1,1,1,.2+ATV*.05)
    if self.align=='M' then
        local x0=x+w*.5
        local kx=obj:type()=='Text' and min(w/ox/2,1) or 1
        gc_draw(obj,x0-1,y0-1,nil,kx,1,ox,oy)
        gc_draw(obj,x0-1,y0+1,nil,kx,1,ox,oy)
        gc_draw(obj,x0+1,y0-1,nil,kx,1,ox,oy)
        gc_draw(obj,x0+1,y0+1,nil,kx,1,ox,oy)
        gc_setColor(r*.55,g*.55,b*.55)
        gc_draw(obj,x0,y0,nil,kx,1,ox,oy)
    elseif self.align=='L' then
        local edge=self.edge
        gc_draw(obj,x+edge-1,y0-1-oy)
        gc_draw(obj,x+edge-1,y0+1-oy)
        gc_draw(obj,x+edge+1,y0-1-oy)
        gc_draw(obj,x+edge+1,y0+1-oy)
        gc_setColor(r*.55,g*.55,b*.55)
        gc_draw(obj,x+edge,y0-oy)
    elseif self.align=='R' then
        local x0=x+w-self.edge-ox*2
        gc_draw(obj,x0-1,y0-1-oy)
        gc_draw(obj,x0-1,y0+1-oy)
        gc_draw(obj,x0+1,y0-1-oy)
        gc_draw(obj,x0+1,y0+1-oy)
        gc_setColor(r*.55,g*.55,b*.55)
        gc_draw(obj,x0,y0-oy)
    end
end
function button:getInfo()
    return("x=%d,y=%d,w=%d,h=%d,font=%d"):format(self.x+self.w*.5,self.y+self.h*.5,self.w,self.h,self.font,self.fType)
end
function button:press(_,_,k)
end
function button:drag(x,y)
    if not self:isAbove(x,y) and self==WIDGET.sel then
        WIDGET.unFocus()
    end
end
function button:release(_,_,k)
    self.code(k)
    local ATV=self.ATV
    SYSFX.newRectRipple(
        6,
        self.x-ATV,
        self.y-WIDGET.scrollPos,
        self.w+2*ATV,
        self.h
    )
    if self.sound then
        SFX.play(self.sound)
    end
end
function WIDGET.newButton(D)-- name,x,y,w[,h][,fText][,color][,font=30][,fType][,sound][,align='M'][,edge=0][,code][,hideF][,hide]
    if not D.h then D.h=D.w end
    local w={
        name= D.name or "_",

        x=    D.x-D.w*.5,
        y=    D.y-D.h*.5,
        w=    D.w,
        h=    D.h,

        resCtr={
            D.x,D.y,
            D.x-D.w*.35,D.y-D.h*.35,
            D.x-D.w*.35,D.y+D.h*.35,
            D.x+D.w*.35,D.y-D.h*.35,
            D.x+D.w*.35,D.y+D.h*.35,
        },

        fText=D.fText,
        color=D.color and (COLOR[D.color] or D.color) or COLOR.Z,
        font= D.font or 30,
        fType=D.fType,
        align=D.align or 'M',
        edge= D.edge or 0,
        code= D.code or NULL,
        hideF=D.hideF,
        hide= D.hide,
    }
    if D.sound==false then
        w.sound=false
    elseif type(D.sound)=='string' then
        w.sound=D.sound
    else
        w.sound='button'
    end

    for k,v in next,button do w[k]=v end
    setmetatable(w,widgetMetatable)
    return w
end

local key={
    type='key',
    mustHaveText=true,
    ATV=0,-- Activating time(0~4)
}
function key:reset()
    self.ATV=0
end
function key:setObject(obj)
    if type(obj)=='string' or type(obj)=='number' then
        self.obj=gc.newText(FONT.get(self.font,self.fType),obj)
    elseif obj then
        self.obj=obj
    end
end
function key:isAbove(x,y)
    return
        x>self.x and
        y>self.y and
        x<self.x+self.w and
        y<self.y+self.h
end
function key:getCenter()
    return self.x+self.w*.5,self.y+self.h*.5
end
function key:update(dt)
    local ATV=self.ATV
    if WIDGET.sel==self then
        if ATV<4 then self.ATV=min(ATV+dt*60,4) end
    else
        if ATV>0 then self.ATV=max(ATV-dt*30,0) end
    end
end
function key:draw()
    local x,y,w,h=self.x,self.y,self.w,self.h
    local ATV=self.ATV
    local c=self.color
    local align=self.align
    local r,g,b=c[1],c[2],c[3]

    -- Fill
    if self.fShade then
        gc_setColor(r,g,b,ATV*.25)
        if align=='M' then
            gc_draw(self.fShade,x+w*.5-self.fShade:getWidth()*.5,y+h*.5-self.fShade:getHeight()*.5)
        elseif align=='L' then
            gc_draw(self.fShade,x+self.edge,y+h*.5-self.fShade:getHeight()*.5)
        elseif align=='R' then
            gc_draw(self.fShade,x+w-self.edge-self.fShade:getWidth(),y+h*.5-self.fShade:getHeight()*.5)
        end
    else
        -- Background
        gc_setColor(0,0,0,.3)
        gc_rectangle('fill',x,y,w,h,4)

        -- Frame
        gc_setColor(.2+r*.8,.2+g*.8,.2+b*.8,.7)
        gc_setLineWidth(2)
        gc_rectangle('line',x,y,w,h,3)

        -- Shade
        gc_setColor(1,1,1,ATV*.05)
        gc_rectangle('fill',x,y,w,h,3)
    end

    -- Drawable
    local obj=self.obj
    local ox,oy=obj:getWidth()*.5,obj:getHeight()*.5
    gc_setColor(r,g,b)
    if align=='M' then
        local kx=obj:type()=='Text' and min(w/ox/2,1) or 1
        gc_draw(obj,x+w*.5,y+h*.5,nil,kx,1,ox,oy)
    elseif align=='L' then
        gc_draw(obj,x+self.edge,y-oy+h*.5)
    elseif align=='R' then
        gc_draw(obj,x+w-self.edge-ox*2,y-oy+h*.5)
    end
end
function key:getInfo()
    return("x=%d,y=%d,w=%d,h=%d,font=%d"):format(self.x+self.w*.5,self.y+self.h*.5,self.w,self.h,self.font,self.fType)
end
function key:press()
end
function key:drag(x,y)
    if not self:isAbove(x,y) and self==WIDGET.sel then
        WIDGET.unFocus()
    end
end
function key:release(_,_,k)
    self.code(k)
    if self.sound then
        SFX.play(self.sound)
    end
end
function WIDGET.newKey(D)-- name,x,y,w[,h][,fText][,fShade][,color][,font=30][,fType][,sound][,align='M'][,edge=0][,code][,hideF][,hide]
    if not D.h then D.h=D.w end
    local _={
        name=   D.name or "_",

        x=      D.x-D.w*.5,
        y=      D.y-D.h*.5,
        w=      D.w,
        h=      D.h,

        resCtr={
            D.x,D.y,
            D.x-D.w*.35,D.y-D.h*.35,
            D.x-D.w*.35,D.y+D.h*.35,
            D.x+D.w*.35,D.y-D.h*.35,
            D.x+D.w*.35,D.y+D.h*.35,
        },

        fText=  D.fText,
        fShade= D.fShade,
        color=  D.color and (COLOR[D.color] or D.color) or COLOR.Z,
        font=   D.font or 30,
        fType=  D.fType,
        align=  D.align or 'M',
        edge=   D.edge or 0,
        code=   D.code or NULL,
        hideF=  D.hideF,
        hide=   D.hide,
    }
    if D.sound==false then
        _.sound=false
    elseif type(D.sound)=='string' then
        _.sound=D.sound
    else
        _.sound='key'
    end
    for k,v in next,key do _[k]=v end
    setmetatable(_,widgetMetatable)
    return _
end

local switch={
    type='switch',
    mustHaveText=true,
    ATV=0,-- Activating time(0~8)
    CHK=0,-- Check alpha(0~6)
}
function switch:reset()
    self.ATV=0
    self.CHK=0
end
function switch:isAbove(x,y)
    return x>self.x and x<self.x+50 and y>self.y-25 and y<self.y+25
end
function switch:getCenter()
    return self.x,self.y
end
function switch:update(dt)
    local ATV=self.ATV
    if WIDGET.sel==self then
        if ATV<8 then self.ATV=min(ATV+dt*60,8) end
    else
        if ATV>0 then self.ATV=max(ATV-dt*30,0) end
    end
    local chk=self.CHK
    if self:disp() then
        if chk<6 then self.CHK=min(chk+dt*60,6) end
    else
        if chk>0 then self.CHK=max(chk-dt*60,0) end
    end
end
function switch:draw()
    local x,y=self.x,self.y
    local ATV=self.ATV

    -- Background
    gc_setColor(0,0,0,.3)
    gc_rectangle('fill',x,y-25,50,50,4)

    -- Frame
    gc_setLineWidth(2)
    gc_setColor(1,1,1,.6+ATV*.1)
    gc_rectangle('line',x,y-25,50,50,3)

    -- Checked
    if ATV>0 then
        gc_setColor(1,1,1,ATV*.06)
        gc_rectangle('fill',x,y-25,50,50,3)
    end
    if self.CHK>0 then
        gc_setColor(.9,1,.9,self.CHK/6)
        gc_setLineWidth(5)
        gc_line(x+5,y,x+18,y+13,x+45,y-14)
    end

    -- Drawable
    local obj=self.obj
    gc_setColor(self.color)
    gc_draw(obj,x-12-ATV,y,nil,min(self.lim/obj:getWidth(),1),1,obj:getWidth(),obj:getHeight()*.5)
end
function switch:getInfo()
    return("x=%d,y=%d,font=%d"):format(self.x,self.y,self.font,self.fType)
end
function switch:press()
    self.code()
    if self.sound then
        SFX.play(self.disp() and 'check' or 'uncheck')
    end
end
function WIDGET.newSwitch(D)-- name,x,y[,lim][,fText][,color][,font=30][,fType][,sound=true][,disp][,code][,hideF][,hide]
    local _={
        name= D.name or "_",

        x=    D.x,
        y=    D.y,
        lim=  D.lim or 1e99,

        resCtr={
            D.x+25,D.y,
        },

        fText=D.fText,
        color=D.color and (COLOR[D.color] or D.color) or COLOR.Z,
        font= D.font or 30,
        fType=D.fType,
        sound=D.sound~=false,
        disp= D.disp,
        code= D.code or NULL,
        hideF=D.hideF,
        hide= D.hide,
    }
    for k,v in next,switch do _[k]=v end
    setmetatable(_,widgetMetatable)
    return _
end

local slider={
    type='slider',
    ATV=0,-- Activating time(0~8)
    TAT=0,-- Text activating time(0~180)
    pos=0,-- Position shown
    lastTime=0,-- Last value changing time
}
local sliderShowFunc={
    int=function(S)
        return S.disp()
    end,
    float=function(S)
        return floor(S.disp()*100+.5)*.01
    end,
    percent=function(S)
        return floor(S.disp()*100+.5).."%"
    end,
}
function slider:reset()
    self.ATV=0
    self.TAT=180
    self.pos=0
end
function slider:isAbove(x,y)
    return x>self.x-10 and x<self.x+self.w+10 and y>self.y-25 and y<self.y+25
end
function slider:getCenter()
    return self.x+self.w*((self.pos-self.rangeL)/(self.rangeR-self.rangeL)),self.y
end
function slider:update(dt)
    local ATV=self.ATV
    if self.TAT>0 then
        self.TAT=max(self.TAT-dt*60,0)
    end
    if WIDGET.sel==self then
        if ATV<6 then self.ATV=min(ATV+dt*60,6) end
        self.TAT=180
    else
        if ATV>0 then self.ATV=max(ATV-dt*30,0) end
    end
    if not self.hide then
        self.pos=approach(self.pos,self.disp(),dt*26)
    end
end
function slider:draw()
    local x,y=self.x,self.y
    local ATV=self.ATV
    local x2=x+self.w

    gc_setColor(1,1,1,.5+ATV*.06)

    -- Units
    if not self.smooth then
        gc_setLineWidth(2)
        for p=self.rangeL,self.rangeR,self.unit do
            local X=x+(x2-x)*(p-self.rangeL)/(self.rangeR-self.rangeL)
            gc_line(X,y+7,X,y-7)
        end
    end

    -- Axis
    gc_setLineWidth(4)
    gc_line(x,y,x2,y)

    -- Block
    local cx=x+(x2-x)*(self.pos-self.rangeL)/(self.rangeR-self.rangeL)
    local bx,by,bw,bh=cx-10-ATV*.5,y-16-ATV,20+ATV,32+2*ATV
    gc_setColor(.8,.8,.8)
    gc_rectangle('fill',bx,by,bw,bh,3)

    -- Glow
    if ATV>0 then
        gc_setLineWidth(2)
        gc_setColor(.97,.97,.97,ATV*.16)
        gc_rectangle('line',bx+1,by+1,bw-2,bh-2,3)
    end

    -- Float text
    if self.TAT>0 and self.show then
        FONT.set(25)
        gc_setColor(.97,.97,.97,self.TAT/180)
        mStr(self:show(),cx,by-30)
    end

    -- Drawable
    local obj=self.obj
    if obj then
        gc_setColor(self.color)
        gc_draw(obj,x-12-ATV,y,nil,min(self.lim/obj:getWidth(),1),1,obj:getWidth(),obj:getHeight()*.5)
    end
end
function slider:getInfo()
    return("x=%d,y=%d,w=%d"):format(self.x,self.y,self.w)
end
function slider:press(x)
    self:drag(x)
end
function slider:drag(x)
    if not x then return end
    x=x-self.x
    local newPos=MATH.clamp(x/self.w,0,1)
    local newVal
    if not self.unit then
        newVal=(1-newPos)*self.rangeL+newPos*self.rangeR
    else
        newVal=newPos*(self.rangeR-self.rangeL)
        newVal=self.rangeL+floor(newVal/self.unit+.5)*self.unit
    end
    if newVal~=self.disp() then
        self.code(newVal)
    end
    if self.change and timer()-self.lastTime>.5 then
        self.lastTime=timer()
        self.change()
    end
end
function slider:release(x)
    self:drag(x)
    self.lastTime=0
end
function slider:scroll(n)
    local p=self.disp()
    local u=self.unit or .01
    local P=MATH.clamp(p+u*n,self.rangeL,self.rangeR)
    if p==P or not P then return end
    self.code(P)
    if self.change and timer()-self.lastTime>.18 then
        self.lastTime=timer()
        self.change()
    end
end
function slider:arrowKey(k)
    self:scroll((k=='left' or k=='up') and -1 or 1)
end
function WIDGET.newSlider(D)-- name,x,y,w[,lim][,fText][,color][,axis][,smooth][,font=30][,fType][,change],disp[,show][,code],hide
    if not D.axis then
        D.axis={0,1,false}
        D.smooth=true
    elseif not D.axis[3] then
        D.smooth=true
    end
    local _={
        name=  D.name or "_",

        x=     D.x,
        y=     D.y,
        w=     D.w,
        lim=   D.lim or 1e99,

        resCtr={
            D.x,D.y,
            D.x+D.w*.25,D.y,
            D.x+D.w*.5,D.y,
            D.x+D.w*.75,D.y,
            D.x+D.w,D.y,
        },

        fText= D.fText,
        color= D.color and (COLOR[D.color] or D.color) or COLOR.Z,
        rangeL=D.axis[1],
        rangeR=D.axis[2],
        unit=  D.axis[3],
        smooth=D.smooth,
        font=  D.font or 30,
        fType= D.fType,
        change=D.change,
        disp=  D.disp,
        code=  D.code or NULL,
        hideF= D.hideF,
        hide=  D.hide,
        show=  false,
    }
    if D.show then
        if type(D.show)=='function' then
            _.show=D.show
        else
            _.show=sliderShowFunc[D.show]
        end
    elseif D.show~=false then-- Use default if nil
        if _.unit and _.unit%1==0 then
            _.show=sliderShowFunc.int
        else
            _.show=sliderShowFunc.percent
        end
    end
    for k,v in next,slider do _[k]=v end
    setmetatable(_,widgetMetatable)
    return _
end

local selector={
    type='selector',
    mustHaveText=true,
    ATV=8,-- Activating time(0~4)
    select=false,-- Selected item ID
    selText=false,-- Selected item name
}
function selector:reset()
    self.ATV=0
    local V,L=self.disp(),self.list
    for i=1,#L do
        if L[i]==V then
            self.select=i
            self.selText=self.list[i]
            return
        end
    end
    self.select=0
    self.selText=""
    MES.new('error',"Selector "..self.name.." dead, disp= "..tostring(V))
end
function selector:isAbove(x,y)
    return
        x>self.x and
        x<self.x+self.w+2 and
        y>self.y and
        y<self.y+60
end
function selector:getCenter()
    return self.x+self.w*.5,self.y+30
end
function selector:update(dt)
    local ATV=self.ATV
    if WIDGET.sel==self then
        if ATV<8 then self.ATV=min(ATV+dt*60,8) end
    else
        if ATV>0 then self.ATV=max(ATV-dt*30,0) end
    end
end
function selector:draw()
    local x,y=self.x,self.y
    local w=self.w
    local ATV=self.ATV

    -- Background
    gc_setColor(0,0,0,.3)
    gc_rectangle('fill',x,y,w,60,4)

    -- Frame
    gc_setColor(1,1,1,.6+ATV*.1)
    gc_setLineWidth(2)
    gc_rectangle('line',x,y,w,60,3)

    -- Arrow
    gc_setColor(1,1,1,.2+ATV*.1)
    local t=(timer()%.5)^.5
    if self.select>1 then
        gc_draw(smallerThen,x+6,y+33)
        if ATV>0 then
            gc_setColor(1,1,1,ATV*.4*(.5-t))
            gc_draw(smallerThen,x+6-t*40,y+33)
            gc_setColor(1,1,1,.2+ATV*.1)
        end
    end
    if self.select<#self.list then
        gc_draw(largerThen,x+w-26,y+33)
        if ATV>0 then
            gc_setColor(1,1,1,ATV*.4*(.5-t))
            gc_draw(largerThen,x+w-26+t*40,y+33)
        end
    end

    -- Drawable
    gc_setColor(self.color)
    gc_draw(self.obj,x+w*.5,y-4,nil,min((w-20)/self.obj:getWidth(),1),1,self.obj:getWidth()*.5,0)
    gc_setColor(1,1,1)
    FONT.set(30)
    mStr(self.selText,x+w*.5,y+22)
end
function selector:getInfo()
    return("x=%d,y=%d,w=%d"):format(self.x+self.w*.5,self.y+30,self.w)
end
function selector:press(x)
    if x then
        local s=self.select
        if x<self.x+self.w*.5 then
            if s>1 then
                s=s-1
                SYSFX.newShade(3,self.x,self.y-WIDGET.scrollPos,self.w*.5,60)
            end
        else
            if s<#self.list then
                s=s+1
                SYSFX.newShade(3,self.x+self.w*.5,self.y-WIDGET.scrollPos,self.w*.5,60)
            end
        end
        if self.select~=s then
            self.code(self.list[s],s)
            self.select=s
            self.selText=self.list[s]
            if self.sound then
                SFX.play('selector')
            end
        end
    end
end
function selector:scroll(n)
    local s=self.select
    if n==-1 then
        if s==1 then return end
        s=s-1
        SYSFX.newShade(3,self.x,self.y-WIDGET.scrollPos,self.w*.5,60)
    else
        if s==#self.list then return end
        s=s+1
        SYSFX.newShade(3,self.x+self.w*.5,self.y-WIDGET.scrollPos,self.w*.5,60)
    end
    self.code(self.list[s])
    self.select=s
    self.selText=self.list[s]
    if self.sound then
        SFX.play('selector')
    end
end
function selector:arrowKey(k)
    self:scroll((k=='left' or k=='up') and -1 or 1)
end

function WIDGET.newSelector(D)-- name,x,y,w[,fText][,color][,sound=true],list,disp[,code],hide
    local _={
        name= D.name or "_",

        x=    D.x-D.w*.5,
        y=    D.y-30,
        w=    D.w,

        resCtr={
            D.x,D.y,
            D.x+D.w*.25,D.y,
            D.x+D.w*.5,D.y,
            D.x+D.w*.75,D.y,
            D.x+D.w,D.y,
        },

        fText=D.fText,
        color=D.color and (COLOR[D.color] or D.color) or COLOR.Z,
        sound=D.sound~=false,
        font= 30,
        list= D.list,
        disp= D.disp,
        code= D.code or NULL,
        hideF=D.hideF,
        hide= D.hide,
    }
    for k,v in next,selector do _[k]=v end
    setmetatable(_,widgetMetatable)
    return _
end

local inputBox={
    type='inputBox',
    keepFocus=true,
    ATV=0,-- Activating time(0~4)
    value="",-- Text contained
}
function inputBox:reset()
    self.ATV=0
end
function inputBox:hasText()
    return #self.value>0
end
function inputBox:getText()
    return self.value
end
function inputBox:setText(str)
    if not str then str="" end
    assert(type(str)=='string',"Arg #1 must be string")
    self.value=str
end
function inputBox:addText(str)
    if not str then str="" end
    assert(type(str)=='string',"Arg #1 must be string")
    self.value=self.value..str
end
function inputBox:clear()
    self.value=""
end
function inputBox:isAbove(x,y)
    return
        x>self.x and
        y>self.y and
        x<self.x+self.w and
        y<self.y+self.h
end
function inputBox:getCenter()
    return self.x+self.w*.5,self.y
end
function inputBox:update(dt)
    local ATV=self.ATV
    if WIDGET.sel==self then
        if ATV<3 then self.ATV=min(ATV+dt*60,3) end
    else
        if ATV>0 then self.ATV=max(ATV-dt*15,0) end
    end
end
function inputBox:draw()
    local x,y,w,h=self.x,self.y,self.w,self.h
    local ATV=self.ATV

    -- Background
    gc_setColor(0,0,0,.4)
    gc_rectangle('fill',x,y,w,h,4)

    -- Highlight
    gc_setColor(1,1,1,ATV*.08*(math.sin(timer()*4.2)*.2+.8))
    gc_rectangle('fill',x,y,w,h,4)

    -- Frame
    gc_setColor(1,1,1)
    gc_setLineWidth(3)
    gc_rectangle('line',x,y,w,h,3)

    -- Drawable
    local f=self.font
    FONT.set(f,self.fType)
    if self.obj then
        gc_draw(self.obj,x-12-self.obj:getWidth(),y+h*.5-self.obj:getHeight()*.5)
    end
    if self.secret then
        y=y+h*.5-f*.2
        for i=1,#self.value do
            gc_rectangle("fill",x+f*.6*i,y,f*.4,f*.4)
        end
    else
        gc_printf(self.value,x+10,y,self.w)
        FONT.set(f-10)
        if WIDGET.sel==self then
            gc_print(EDITING,x+10,y+12-f*1.4)
        end
    end
end
function inputBox:getInfo()
    return("x=%d,y=%d,w=%d,h=%d"):format(self.x+self.w*.5,self.y+self.h*.5,self.w,self.h)
end
function inputBox:keypress(k)
    local t=self.value
    if #t>0 and EDITING=="" then
        if k=='backspace' then
            local p=#t
            while t:byte(p)>=128 and t:byte(p)<192 do
                p=p-1
            end
            t=sub(t,1,p-1)
            SFX.play('lock')
        elseif k=='delete' then
            t=""
            SFX.play('hold')
        end
        self.value=t
    end
end
function WIDGET.newInputBox(D)-- name,x,y,w[,h][,font=30][,fType][,secret][,regex][,limit],hide
    local _={
        name=  D.name or "_",

        x=     D.x,
        y=     D.y,
        w=     D.w,
        h=     D.h,

        resCtr={
            D.x+D.w*.2,D.y,
            D.x+D.w*.5,D.y,
            D.x+D.w*.8,D.y,
        },

        font=  D.font or floor(D.h/7-1)*5,
        fType= D.fType,
        secret=D.secret==true,
        regex= D.regex,
        limit= D.limit,
        hideF= D.hideF,
        hide=  D.hide,
    }
    for k,v in next,inputBox do _[k]=v end
    setmetatable(_,widgetMetatable)
    return _
end

local textBox={
    type='textBox',
    scrollPos=0,-- Scroll-down-distance
    sure=0,-- Sure-timer for clear history
}
function textBox:reset()
    self.lineH=self.font*7/5
    self.capacity=ceil((self.h-10)/self.lineH)
end
function textBox:setTexts(t)
    assert(type(t)=='table',"Arg #1 must be table")
    TABLE.clear(self.texts)
    TABLE.connect(self.texts,t)
    self.scrollPos=0
end
function textBox:clear()
    self.texts={}
    self.scrollPos=0
    SFX.play('fall')
end
function textBox:isAbove(x,y)
    return
        x>self.x and
        y>self.y and
        x<self.x+self.w and
        y<self.y+self.h
end
function textBox:getCenter()
    return self.x+self.w*.5,self.y+self.w
end
function textBox:update(dt)
    if self.sure>0 then
        self.sure=max(self.sure-dt,0)
    end
end
function textBox:push(t)
    ins(self.texts,t)
    if self.scrollPos>(#self.texts-1.5)*self.lineH-self.h then-- minus 1 for the new message
        self.scrollPos=max(0,min(self.scrollPos+self.lineH,#self.texts*self.lineH-self.h))
    end
end
function textBox:press(x,y)
    if not (x and y) then return end
    self:drag(0,0,0,0)
    if not self.fix and x>self.x+self.w-40 and y<self.y+40 then
        if self.sure>0 then
            self:clear()
            self.sure=0
        else
            self.sure=1
        end
    end
end
function textBox:drag(_,_,_,dy)
    self.scrollPos=max(0,min(self.scrollPos-dy,#self.texts*self.lineH-self.h))
end
function textBox:scroll(dir)
    if type(dir)=='string' then
        if dir=="up" then
            dir=-1
        elseif dir=="down" then
            dir=1
        else
            return
        end
    end
    self:drag(nil,nil,nil,-dir*self.lineH)
end
function textBox:arrowKey(k)
    if k=='up' then
        self:scroll(-1)
    elseif k=='down' then
        self:scroll(-1)
    end
end
function textBox:draw()
    local x,y,w,h=self.x,self.y,self.w,self.h
    local list=self.texts
    local scrollPos=self.scrollPos
    local lineH=self.lineH
    local H=#list*lineH

    -- Background
    gc_setColor(0,0,0,.3)
    gc_rectangle('fill',x,y,w,h,4)

    -- Frame
    gc_setLineWidth(2)
    gc_setColor(WIDGET.sel==self and COLOR.lN or COLOR.Z)
    gc_rectangle('line',x,y,w,h,3)

    -- Texts
    FONT.set(self.font,self.fType)
    gc_push('transform')
        gc_translate(x,y)

        -- Slider
        gc_setColor(1,1,1)
        if #list>self.capacity then
            local len=h*h/H
            gc_rectangle('fill',-15,(h-len)*scrollPos/(H-h),12,len,3)
        end

        -- Clear button
        if not self.fix then
            gc_rectangle('line',w-40,0,40,40,3)
            gc_draw(self.sure==0 and clearIcon or sureIcon,w-40,0)
        end

        gc_setStencilTest('equal',1)
        STW,STH=w,h
        gc_stencil(_rectangleStencil)
        gc_translate(0,-(scrollPos%lineH))
        local pos=floor(scrollPos/lineH)
        for i=pos+1,min(pos+self.capacity+1,#list) do
            if list[i]~=nil then
                gc_printf(list[i],10,4,w-16)
            end
            gc_translate(0,lineH)
        end
        gc_setStencilTest()
    gc_pop()
end
function textBox:getInfo()
    return("x=%d,y=%d,w=%d,h=%d"):format(self.x+self.w*.5,self.y+self.h*.5,self.w,self.h)
end
function WIDGET.newTextBox(D)-- name,x,y,w,h[,font=30][,fType][,lineH][,fix],hide
    local _={
        name= D.name or "_",

        resCtr={
            D.x+D.w*.5,D.y+D.h*.5,
            D.x+D.w*.5,D.y,
            D.x-D.w*.5,D.y,
            D.x,D.y+D.h*.5,
            D.x,D.y-D.h*.5,
            D.x,D.y,
            D.x+D.w,D.y,
            D.x,D.y+D.h,
            D.x+D.w,D.y+D.h,
        },

        x=    D.x,
        y=    D.y,
        w=    D.w,
        h=    D.h,

        font= D.font or 30,
        lineH=D.lineH,
        capacity=nil,
        fType=D.fType,
        fix=  D.fix,
        texts={},
        hideF=D.hideF,
        hide= D.hide,
    }

    for k,v in next,textBox do _[k]=v end
    setmetatable(_,widgetMetatable)
    return _
end

local listBox={
    type='listBox',
    keepFocus=true,
    scrollPos=0,-- Scroll-down-distance
    selected=0,-- Hidden wheel move value
    _pressX=false,
    _pressY=false,
}
function listBox:reset()
    -- haha nothing here too, techmino is really fun!
end
function listBox:clear()
    self.list={}
    self.scrollPos=0
end
function listBox:setList(t)
    assert(type(t)=='table',"Arg #1 must be table")
    self.list=t
    self.selected=1
    self.scrollPos=0
end
function listBox:getList()
    return self.list
end
function listBox:getLen()
    return #self.list
end
function listBox:getSel()
    return self.list[self.selected]
end
function listBox:isAbove(x,y)
    return
        x>self.x and
        y>self.y and
        x<self.x+self.w and
        y<self.y+self.h
end
function listBox:getCenter()
    return self.x+self.w*.5,self.y+self.h*.5
end
function listBox:push(t)
    ins(self.list,t)
end
function listBox:pop()
    if #self.list>0 then
        rem(self.list)
        listBox:drag(0,0,0,0)
    end
end
function listBox:remove()
    if self.selected then
        rem(self.list,self.selected)
        if not self.list[self.selected] then
            self:arrowKey('up')
        end
        self:drag(0,0,0,0)
    end
end
function listBox:press(x,y)
    self._pressX=x
    self._pressY=y
end
function listBox:release(x,y)
    if not (x and y) then return end
    if self._pressX then
        self._pressX,self._pressY=false,false
        x,y=x-self.x,y-self.y
        if not (x and y and x>0 and y>0 and x<=self.w and y<=self.h) then return end
        y=math.floor((y+self.scrollPos)/self.lineH)+1
        if self.list[y] then
            if self.selected~=y then
                self.selected=y
                self:drag(0,0,0,0)
                SFX.play('selector',.8,0,12)
            end
        end
    end
end
function listBox:drag(x,y,_,dy)
    if x and y and self._pressX and MATH.distance(x,y,self._pressX,self._pressY)>10 then
        self._pressX,self._pressY=false,false
    end
    self.scrollPos=max(0,min(self.scrollPos-dy,#self.list*self.lineH-self.h))
end
function listBox:scroll(n)
    self:drag(nil,nil,nil,-n*self.lineH)
end
function listBox:arrowKey(dir)
    if dir=="up" then
        self.selected=max(self.selected-1,1)
        if self.selected<floor(self.scrollPos/self.lineH)+2 then
            self:drag(nil,nil,nil,self.lineH)
        end
    elseif dir=="down" then
        self.selected=min(self.selected+1,#self.list)
        if self.selected>floor(self.scrollPos/self.lineH)+self.capacity-1 then
            self:drag(nil,nil,nil,-self.lineH)
        end
    end
end
function listBox:select(i)
    self.selected=i
    if self.selected<floor(self.scrollPos/self.lineH)+2 then
        self:drag(nil,nil,nil,1e99)
    elseif self.selected>floor(self.scrollPos/self.lineH)+self.capacity-1 then
        self:drag(nil,nil,nil,-1e99)
    end
end
function listBox:draw()
    local x,y,w,h=self.x,self.y,self.w,self.h
    local list=self.list
    local scrollPos=self.scrollPos
    local lineH=self.lineH
    local H=#list*lineH

    gc_push('transform')
        gc_translate(x,y)

        -- Background
        gc_setColor(0,0,0,.4)
        gc_rectangle('fill',0,0,w,h,4)

        -- Frame
        gc_setColor(WIDGET.sel==self and COLOR.lN or COLOR.Z)
        gc_setLineWidth(2)
        gc_rectangle('line',0,0,w,h,3)

        -- Slider
        if #list>self.capacity then
            gc_setColor(1,1,1)
            local len=h*h/H
            gc_rectangle('fill',-15,(h-len)*scrollPos/(H-h),12,len,3)
        end

        -- List
        gc_setStencilTest('equal',1)
            STW,STH=w,h
            gc_stencil(_rectangleStencil)
            local pos=floor(scrollPos/lineH)
            gc_translate(0,-(scrollPos%lineH))
            for i=pos+1,min(pos+self.capacity+1,#list) do
                if list[i]~=nil then
                    self.drawF(list[i],i,i==self.selected)
                end
                gc_translate(0,lineH)
            end
        gc_setStencilTest()
    gc_pop()
end
function listBox:getInfo()
    return("x=%d,y=%d,w=%d,h=%d"):format(self.x+self.w*.5,self.y+self.h*.5,self.w,self.h)
end
function WIDGET.newListBox(D)-- name,x,y,w,h,lineH,drawF[,hideF][,hide]
    local _={
        name=    D.name or "_",

        resCtr={
            D.x+D.w*.5,D.y+D.h*.5,
            D.x+D.w*.5,D.y,
            D.x-D.w*.5,D.y,
            D.x,D.y+D.h*.5,
            D.x,D.y-D.h*.5,
            D.x,D.y,
            D.x+D.w,D.y,
            D.x,D.y+D.h,
            D.x+D.w,D.y+D.h,
        },

        x=       D.x,
        y=       D.y,
        w=       D.w,
        h=       D.h,

        list=    {},
        lineH=   D.lineH,
        capacity=ceil(D.h/D.lineH),
        drawF=   D.drawF,
        hideF=   D.hideF,
        hide=    D.hide,
    }

    for k,v in next,listBox do _[k]=v end
    setmetatable(_,widgetMetatable)
    return _
end

WIDGET.active={}-- Table contains all active widgets
WIDGET.scrollHeight=0-- Max drag height, not actual container height!
WIDGET.scrollPos=0-- Current scroll position
WIDGET.sel=false-- Selected widget
WIDGET.indexMeta={
    __index=function(L,k)
        for i=1,#L do
            if L[i].name==k then
                return L[i]
            end
        end
    end
}
function WIDGET.setWidgetList(list)
    WIDGET.unFocus(true)
    WIDGET.active=list or NONE
    WIDGET.cursorMove(SCR.xOy:inverseTransformPoint(love.mouse.getPosition()))

    -- Reset all widgets
    if list then
        for i=1,#list do
            list[i]:reset()
        end
        onChange()
    end
end
function WIDGET.setScrollHeight(height)
    WIDGET.scrollHeight=height and height or 0
    WIDGET.scrollPos=0
end
function WIDGET.setLang(widgetText)
    for S,L in next,SCN.scenes do
        if L.widgetList then
            for _,W in next,L.widgetList do
                local t=W.fText or widgetText[S][W.name]
                if not t and W.mustHaveText then
                    t=W.name or "##"
                    W.color=COLOR.dV
                end
                if type(t)=='string' and W.font then
                    t=gc.newText(FONT.get(W.font),t)
                end
                W.obj=t
            end
        end
    end
end
function WIDGET.getSelected()
    return WIDGET.sel
end
function WIDGET.isFocus(W)
    if W then
        return W and WIDGET.sel==W
    else
        return WIDGET.sel~=false
    end
end
function WIDGET.focus(W)
    if WIDGET.sel==W or (W and W.hide) then return end
    if WIDGET.sel and WIDGET.sel.type=='inputBox' then
        kb.setTextInput(false)
        EDITING=""
    end
    WIDGET.sel=W
    if W and W.type=='inputBox' then
        local _,y1=xOy:transformPoint(0,W.y+W.h)
        kb.setTextInput(true,0,y1,1,1)
    end
end
function WIDGET.unFocus(force)
    local W=WIDGET.sel
    if W and (force or not W.keepFocus) then
        if W.type=='inputBox' then
            kb.setTextInput(false)
            EDITING=""
        end
        WIDGET.sel=false
    end
end

function WIDGET.cursorMove(x,y)
    for _,W in next,WIDGET.active do
        if not W.hide and W.resCtr and W:isAbove(x,y+WIDGET.scrollPos) then
            WIDGET.focus(W)
            return
        end
    end
    if WIDGET.sel and not WIDGET.sel.keepFocus then
        WIDGET.unFocus()
    end
end
function WIDGET.press(x,y,k)
    local W=WIDGET.sel
    if W then
        if W.press then
            W:press(x,y and y+WIDGET.scrollPos,k)
        end
        if W.hide then WIDGET.unFocus() end
    end
end
function WIDGET.drag(x,y,dx,dy)
    if WIDGET.sel then
        local W=WIDGET.sel
        if W.drag then
            W:drag(x,y+WIDGET.scrollPos,dx,dy)
        end
    else
        WIDGET.scrollPos=max(min(WIDGET.scrollPos-dy,WIDGET.scrollHeight),0)
    end
end
function WIDGET.release(x,y,k)
    local W=WIDGET.sel
    if W and W.release then
        W:release(x,y+WIDGET.scrollPos,k)
    end
end
function WIDGET.textinput(texts)
    local W=WIDGET.sel
    if W and W.type=='inputBox' then
        if (not W.regex or texts:match(W.regex)) and (not W.limit or #(WIDGET.sel.value..texts)<=W.limit) then
            WIDGET.sel.value=WIDGET.sel.value..texts
            SFX.play('touch')
        else
            SFX.play('drop_cancel')
        end
    end
end

function WIDGET.update(dt)
    for _,W in next,WIDGET.active do
        if W.hideF then
            W.hide=W.hideF()
            if W.hide and W==WIDGET.sel then
                WIDGET.unFocus(true)
            end
        end
        if W.update then W:update(dt) end
    end
end
local widgetCanvas
local widgetCover do
    local L={1,360,{'fRect',0,30,1,300}}
    for i=0,30 do
        ins(L,{'setCL',1,1,1,i/30})
        ins(L,{'fRect',0,i,1,2})
        ins(L,{'fRect',0,360-i,1,2})
    end
    widgetCover=GC.DO(L)
end
local scr_w,scr_h
function WIDGET.resize(w,h)
    scr_w,scr_h=w,h
    widgetCanvas=gc.newCanvas(w,h)
end
function WIDGET.draw()
    gc_setCanvas({stencil=true},widgetCanvas)
        gc_translate(0,-WIDGET.scrollPos)
        for _,W in next,WIDGET.active do
            if not W.hide then W:draw() end
        end
        gc_origin()
        gc_setColor(1,1,1)
        if WIDGET.scrollHeight>0 then
            if WIDGET.scrollPos>0 then
                gc_draw(upArrowIcon,scr_w*.5,10,0,SCR.k,nil,upArrowIcon:getWidth()*.5,0)
            end
            if WIDGET.scrollPos<WIDGET.scrollHeight then
                gc_draw(downArrowIcon,scr_w*.5,scr_h-10,0,SCR.k,nil,downArrowIcon:getWidth()*.5,downArrowIcon:getHeight())
            end
            gc_setBlendMode('multiply','premultiplied')
            gc_draw(widgetCover,nil,nil,nil,scr_w,scr_h/360)
        end
    gc_setCanvas({stencil=false})
    gc_setBlendMode('alpha','premultiplied')
    gc_draw(widgetCanvas)
    gc_setBlendMode('alpha')
    gc_replaceTransform(SCR.xOy)
end

return WIDGET
