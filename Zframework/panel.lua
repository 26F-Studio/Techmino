local gc=love.graphics
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle=gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf
local gc_push,gc_pop=gc.push,gc.pop
local gc_replaceTransform=gc.replaceTransform
local gc_translate=gc.translate
local gc_line=gc.line
local setFont=FONT.set
local approach=MATH.expApproach

local PANEL={}
PANEL.list={}

function PANEL.new(id,side)
    local panel={
        id=id,
        side=side or 'left',
        x=side=='left' and -400 or 1280,
        targetX=side=='left' and -400 or 1280,
        w=400,h=720,
        alpha=0,
        visible=false,
        title="Panel",
        content={},
    }
    
    function panel:setSize(w,h)
        self.w,self.h=w or self.w,h or self.h
        if self.side=='left' then
            self.x=-self.w
            self.targetX=-self.w
        else
            self.x=1280
            self.targetX=1280
        end
    end
    
    function panel:setTitle(title)
        self.title=title
    end
    
    function panel:show()
        self.visible=true
        self.targetX=self.side=='left' and 0 or 1280-self.w
    end
    
    function panel:hide()
        self.visible=false
        self.targetX=self.side=='left' and -self.w or 1280
    end
    
    function panel:toggle()
        if self.visible then self:hide() else self:show() end
    end
    
    function panel:update(dt)
        self.x=approach(self.x,self.targetX,dt*12)
        if self.side=='left' then
            self.alpha=math.min((self.w+self.x)/self.w,1)
        else
            self.alpha=math.min((1280-self.x)/self.w,1)
        end
    end
    
    function panel:draw()
        if self.alpha<=0 then return end
        
        gc_push('transform')
        gc_replaceTransform(SCR.xOy)
        gc_translate(self.x,0)
        
        if self.side=='left' then
            gc_setColor(.1,.1,.1,.95*self.alpha)
            gc_rectangle('fill',0,0,self.w,self.h,0,8,8,0)
            gc_setColor(.4,.4,.4,self.alpha)
            gc_setLineWidth(2)
            gc_rectangle('line',0,0,self.w,self.h,0,8,8,0)
        else
            gc_setColor(.1,.1,.1,.95*self.alpha)
            gc_rectangle('fill',0,0,self.w,self.h,8,0,0,8)
            gc_setColor(.4,.4,.4,self.alpha)
            gc_setLineWidth(2)
            gc_rectangle('line',0,0,self.w,self.h,8,0,0,8)
        end
        
        gc_setColor(.2,.2,.2,self.alpha)
        gc_rectangle('fill',0,0,self.w,35,self.side=='left' and 0 or 8,0,0,self.side=='right' and 0 or 8)
        
        setFont(22)
        gc_setColor(1,1,1,self.alpha)
        gc_print(self.title,10,7)
        
        if self.drawContent then
            self:drawContent()
        end
        
        gc_pop()
    end
    
    function panel:drawToggleButton()
        local btnW,btnH=30,100
        local btnY=310
        
        gc_push('transform')
        gc_replaceTransform(SCR.xOy)
        
        if self.side=='left' then
            local btnX=self.visible and self.w or 0
            gc_setColor(.3,.3,.3,.8)
            gc_rectangle('fill',btnX,btnY,btnW,btnH,self.visible and 6 or 0,6,6,self.visible and 0 or 6)
            gc_setColor(1,1,1,1)
            setFont(24)
            gc_printf(self.visible and "◀" or "▶",btnX,btnY+35,btnW,'center')
        else
            local btnX=self.visible and 1280-self.w-btnW or 1250
            gc_setColor(.3,.3,.3,.8)
            gc_rectangle('fill',btnX,btnY,btnW,btnH,self.visible and 0 or 6,6,6,self.visible and 6 or 0)
            gc_setColor(1,1,1,1)
            setFont(24)
            gc_printf(self.visible and "▶" or "◀",btnX,btnY+35,btnW,'center')
        end
        
        gc_pop()
    end
    
    function panel:checkToggleButtonClick(mx,my)
        local btnW,btnH=30,100
        local btnY=310
        
        if self.side=='left' then
            local btnX=self.visible and self.w or 0
            if mx>=btnX and mx<=btnX+btnW and my>=btnY and my<=btnY+btnH then
                self:toggle()
                return true
            end
        else
            local btnX=self.visible and 1280-self.w-btnW or 1250
            if mx>=btnX and mx<=btnX+btnW and my>=btnY and my<=btnY+btnH then
                self:toggle()
                return true
            end
        end
        return false
    end
    
    function panel:isInside(mx,my)
        if self.alpha<0.5 then return false end
        return mx>=self.x and mx<=self.x+self.w and my>=0 and my<=self.h
    end
    
    PANEL.list[id]=panel
    return panel
end

function PANEL.get(id)
    return PANEL.list[id]
end

function PANEL.update(dt)
    for _,panel in pairs(PANEL.list) do
        panel:update(dt)
    end
end

function PANEL.draw()
    for _,panel in pairs(PANEL.list) do
        panel:draw()
    end
end

function PANEL.drawToggleButtons()
    for _,panel in pairs(PANEL.list) do
        panel:drawToggleButton()
    end
end

function PANEL.mouseClick(x,y)
    for _,panel in pairs(PANEL.list) do
        if panel:checkToggleButtonClick(x,y) then return true end
    end
    return false
end

return PANEL
