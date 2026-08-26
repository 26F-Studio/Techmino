local gc=love.graphics
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle=gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf
local gc_push,gc_pop=gc.push,gc.pop
local gc_replaceTransform=gc.replaceTransform
local gc_setScissor=gc.setScissor

local WINDOW={}
WINDOW.list={}

function WINDOW.new(id)
    local win={
        id=id,
        x=0,y=0,w=400,h=300,
        title="Window",
        visible=false,
        alpha=0,
        drag=false,
        dragX=0,dragY=0,
        content={},
        buttons={},
        inputBoxes={},
        focusedInput=nil,
        onClose=NULL,
    }
    
    function win:setPosition(x,y)
        self.x,self.y=x,y
    end
    
    function win:setSize(w,h)
        self.w,self.h=w,h
    end
    
    function win:setTitle(title)
        self.title=title
    end
    
    function win:show()
        self.visible=true
    end
    
    function win:hide()
        self.visible=false
        self.alpha=0
    end
    
    function win:toggle()
        if self.visible then
            self:hide()
        else
            self:show()
        end
    end
    
    function win:addButton(label,x,y,w,h,callback)
        table.insert(self.buttons,{
            label=label,x=x,y=y,w=w,h=h,callback=callback or NULL
        })
    end
    
    function win:addInputBox(x,y,w,h,placeholder,secret)
        table.insert(self.inputBoxes,{
            x=x,y=y,w=w,h=h,
            text="",
            placeholder=placeholder or "",
            secret=secret or false,
            focused=false
        })
        return self.inputBoxes[#self.inputBoxes]
    end
    
    function win:clearContent()
        self.content={}
        self.buttons={}
        self.inputBoxes={}
        self.focusedInput=nil
    end
    
    function win:close()
        self:hide()
        if self.onClose then self.onClose() end
    end
    
    function win:update(dt)
        if self.visible then
            self.alpha=math.min(self.alpha+dt*10,1)
        else
            self.alpha=math.max(self.alpha-dt*10,0)
        end
    end
    
    function win:draw()
        if self.alpha<=0 then return end
        
        gc_push('transform')
        gc_replaceTransform(SCR.xOy)
        
        gc_setColor(.1,.1,.1,.95*self.alpha)
        gc_rectangle('fill',self.x,self.y,self.w,self.h,8)
        gc_setColor(.4,.4,.4,self.alpha)
        gc_setLineWidth(2)
        gc_rectangle('line',self.x,self.y,self.w,self.h,8)
        
        gc_setColor(.2,.2,.2,self.alpha)
        gc_rectangle('fill',self.x,self.y,self.w,35,8,8)
        
        setFont(22)
        gc_setColor(1,1,1,self.alpha)
        gc_print(self.title,self.x+10,self.y+7)
        
        gc_setColor(.6,.6,.6,self.alpha)
        gc_rectangle('fill',self.x+self.w-30,self.y+5,22,22,4)
        setFont(18)
        gc_setColor(1,1,1,self.alpha)
        gc_print("×",self.x+self.w-24,self.y+6)
        
        for _,btn in ipairs(self.buttons) do
            local bx,by,bw,bh=self.x+btn.x,self.y+btn.y,btn.w,btn.h
            gc_setColor(.2,.5,.2,self.alpha)
            gc_rectangle('fill',bx,by,bw,bh,4)
            gc_setColor(.4,.8,.4,self.alpha)
            gc_setLineWidth(1)
            gc_rectangle('line',bx,by,bw,bh,4)
            setFont(18)
            gc_setColor(1,1,1,self.alpha)
            gc_printf(btn.label,bx,by+(bh-18)/2,bw,'center')
        end
        
        for i,input in ipairs(self.inputBoxes) do
            local ix,iy,iw,ih=self.x+input.x,self.y+input.y,input.w,input.h
            gc_setColor(.15,.15,.15,self.alpha)
            gc_rectangle('fill',ix,iy,iw,ih,4)
            gc_setColor(input.focused and .8 or .5,input.focused and .8 or .5,input.focused and .8 or .5,self.alpha)
            gc_setLineWidth(1)
            gc_rectangle('line',ix,iy,iw,ih,4)
            
            setFont(18)
            local displayText=input.secret and string.rep('*',#input.text) or input.text
            if #displayText==0 and not input.focused then
                gc_setColor(.5,.5,.5,self.alpha)
                gc_print(input.placeholder,ix+5,iy+(ih-18)/2)
            else
                gc_setColor(1,1,1,self.alpha)
                gc_print(displayText,ix+5,iy+(ih-18)/2)
            end
        end
        
        gc_pop()
    end
    
    function win:mouseClick(mx,my)
        if not self.visible or self.alpha<0.5 then return false end
        
        local screenX,screenY=SCR.xOy:transformPoint(mx,my)
        
        if screenX>=self.x+self.w-30 and screenX<=self.x+self.w-8 and
           screenY>=self.y+5 and screenY<=self.y+27 then
            self:close()
            return true
        end
        
        if screenX<self.x or screenX>self.x+self.w or screenY<self.y or screenY>self.y+self.h then
            return false
        end
        
        if screenY<self.y+35 then
            self.drag=true
            self.dragX=screenX-self.x
            self.dragY=screenY-self.y
            return true
        end
        
        for _,btn in ipairs(self.buttons) do
            local bx,by,bw,bh=self.x+btn.x,self.y+btn.y,btn.w,btn.h
            if screenX>=bx and screenX<=bx+bw and screenY>=by and screenY<=by+bh then
                btn.callback()
                return true
            end
        end
        
        for i,input in ipairs(self.inputBoxes) do
            local ix,iy,iw,ih=self.x+input.x,self.y+input.y,input.w,input.h
            if screenX>=ix and screenX<=ix+iw and screenY>=iy and screenY<=iy+ih then
                if self.focusedInput then self.focusedInput.focused=false end
                input.focused=true
                self.focusedInput=input
                return true
            end
        end
        
        if self.focusedInput then
            self.focusedInput.focused=false
            self.focusedInput=nil
        end
        
        return true
    end
    
    function win:mouseRelease(mx,my)
        self.drag=false
    end
    
    function win:mouseMove(mx,my)
        if self.drag then
            local screenX,screenY=SCR.xOy:transformPoint(mx,my)
            self.x=screenX-self.dragX
            self.y=screenY-self.dragY
        end
    end
    
    function win:keyDown(key)
        if not self.visible then return false end
        
        if key=='escape' then
            self:close()
            return true
        elseif key=='backspace' and self.focusedInput then
            self.focusedInput.text=self.focusedInput.text:sub(1,-2)
            return true
        elseif (key=='return' or key=='kpenter') and self.focusedInput then
            return true
        elseif key=='tab' then
            if self.focusedInput then
                self.focusedInput.focused=false
            end
            local inputs=self.inputBoxes
            if #inputs>0 then
                local found=false
                for i,input in ipairs(inputs) do
                    if input==self.focusedInput then
                        self.focusedInput=inputs[(i%#inputs)+1]
                        found=true
                        break
                    end
                end
                if not found then
                    self.focusedInput=inputs[1]
                end
                self.focusedInput.focused=true
            end
            return true
        end
        return false
    end
    
    function win:textInput(t)
        if not self.visible or not self.focusedInput then return false end
        if #self.focusedInput.text<256 then
            self.focusedInput.text=self.focusedInput.text..t
        end
        return true
    end
    
    function win:getInputText(index)
        return self.inputBoxes[index] and self.inputBoxes[index].text or ""
    end
    
    function win:setInputText(index,text)
        if self.inputBoxes[index] then
            self.inputBoxes[index].text=text or ""
        end
    end
    
    WINDOW.list[id]=win
    return win
end

function WINDOW.get(id)
    return WINDOW.list[id]
end

function WINDOW.update(dt)
    for _,win in pairs(WINDOW.list) do
        win:update(dt)
    end
end

function WINDOW.draw()
    for _,win in pairs(WINDOW.list) do
        win:draw()
    end
end

function WINDOW.mouseClick(x,y)
    for _,win in pairs(WINDOW.list) do
        if win:mouseClick(x,y) then return true end
    end
    return false
end

function WINDOW.mouseRelease(x,y)
    for _,win in pairs(WINDOW.list) do
        win:mouseRelease(x,y)
    end
end

function WINDOW.mouseMove(x,y)
    for _,win in pairs(WINDOW.list) do
        win:mouseMove(x,y)
    end
end

function WINDOW.keyDown(key)
    for _,win in pairs(WINDOW.list) do
        if win:keyDown(key) then return true end
    end
    return false
end

function WINDOW.textInput(t)
    for _,win in pairs(WINDOW.list) do
        if win:textInput(t) then return true end
    end
    return false
end

return WINDOW
