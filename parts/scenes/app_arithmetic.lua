local gc=love.graphics
local rnd=math.random
local int,ceil=math.floor,math.ceil
local ins,rem=table.insert,table.remove

local timing,time

local function b2(i) return STRING.toBin(i).."₂" end
local function b8(i) return STRING.toOct(i).."₈" end
local function b16(i) return STRING.toHex(i).."₁₆" end

local charData={
["0"]={5,40, 15,40,20,35,20,5, 15,0, 5,0,  0,5,  0,35, 5,40},
["1"]={2,8, 10,0, 10,40, 2,40, 1,40, 2,40, 18,40},
["2"]={0,5,  5,0,  15,0, 20,5, 20,20,0,39, 0,40, 25,40},
["3"]={0,5,  5,0,  15,0, 20,5, 20,15,15,20,5,20, 4,20, 5,20, 15,20,20,25,20,35,15,40,5,40,0,35},
["4"]={20,20,0,20, 13,0, 13,40},
["5"]={20,0, 0,0,  0,20, 5,15, 15,15,20,20,20,35,15,40,5,40, 0,35},
["6"]={20,5, 15,0, 5,0,  0,5,  0,35, 5,40, 15,40,20,35,20,20,15,15,5,15, 0,20},
["7"]={0,0,  20,0, 5,40},
["8"]={5,0,  15,0, 20,5, 20,15,15,20,5,20, 0,25, 0,35, 5,40, 15,40,20,35,20,25,15,20,5,20,0,15,0,5,5,0},
["9"]={20,15,15,20,5,20, 0,15, 0,5,  5,0,  15,0, 20,5, 20,35,15,40,5,40, 0,35},
    A={0,40, 10,0, 20,40,0,0,  20,40,15,20,5,20},
    B={0,40, 0,0,  15,0, 20,5, 20,15,15,20,0,20, -1,20,0,20, 15,20,20,25,20,35,15,40,0,40},
    C={20,35,15,40,5,40, 0,35, 0,5,  5,0,  15,0, 20,5},
    D={0,40, 0,0,  10,0, 20,10,20,30,10,40,0,40},
    E={20,0, 0,0,  0,20, 15,20,20,20,0,20, 0,40,20,40},
    F={20,0, 0,0,  0,20, 15,20,20,20,0,20, 0,40}
}
local drawing
local drawLines,drawVel,indexes
local autoDraw
-- Draws (by default) 60x120px chars, 15px padding, total 85x120px
local function drawChar(char,x,y,scale,alignLeft)
    if not scale then scale=1 end
    char=tostring(char)
    local index=#drawLines+1
    local l=string.len(char)
    x=alignLeft and x+85*(l-1)*scale or x
    for i=l,1,-1 do
        local n=char:sub(i,i)
        drawLines[index],drawVel[index]={},{}
        for j=1,#charData[n],2 do
            drawLines[index][j]=charData[n][j]*3*scale+x
            drawVel[index][j]=0
            j=j+1
            drawLines[index][j]=charData[n][j]*3*scale+y
            drawVel[index][j]=0
        end
        index=index+1
        x=x+(alignLeft and -85 or -85)*scale
    end
end

local levels={
    function()-- 1~3 <+> [,10] 
        local s=rnd(2,9)
        local a=rnd(1,s)
        return a.."+"..s-a,s,function()
            drawChar(a,600,200)
            drawChar(s-a,600,350)
            ins(drawLines,{530,500,700,500})
            ins(drawLines,{720,500,800,500})
            ins(drawLines,{760,460,760,540})
        end
    end,nil,nil,
    function()-- 4~6 <+> [,20]
        local s=rnd(10,18)
        local a=rnd(s-9,int(s/2))
        return a.."+"..s-a,s,function()
            drawChar(a,600,200)
            drawChar(s-a,600,350)
            ins(drawLines,{430,500,700,500})
            ins(drawLines,{720,500,800,500})
            ins(drawLines,{760,460,760,540})
        end
    end,nil,nil,
    function()-- 7~9 <+> [,100]
        local s=rnd(22,99)
        local a=rnd(11,int(s/2))
        return a.."+"..s-a,s,function()
            drawChar(a,600,200)
            drawChar(s-a,600,350)
            ins(drawLines,{430,500,700,500})
            ins(drawLines,{720,500,800,500})
            ins(drawLines,{760,460,760,540})
        end
    end,nil,nil,
    function()-- 10~12 <-> [,10]
        local s=rnd(2,9)
        local a=rnd(1,s)
        return s.."-"..a,s-a,function()
            drawChar(s,600,200)
            drawChar(a,600,350)
            ins(drawLines,{530,500,700,500})
            ins(drawLines,{720,500,800,500})
        end
    end,nil,nil,
    function()-- 13~15 <-> [,100]
        local s=rnd(22,99)
        local a=rnd(11,int(s/2))
        return s.."-"..a,s-a,function()
            drawChar(s,600,200)
            drawChar(a,600,350)
            ins(drawLines,{430,500,700,500})
            ins(drawLines,{720,500,800,500})
        end
    end,nil,nil,
    function()-- 16~20 <-> [-10,]
        local s=rnd(-8,-1)
        local a=rnd(1,8)
        return a.."-"..a-s,s,function()
            local l=string.len(a-s)
            ins(drawLines,{600-85*l,260,640-85*l,260})
            drawChar(a-s,600,200)
            drawChar(a,600,350)
            ins(drawLines,{530,500,700,500})
            ins(drawLines,{720,500,800,500})
            ins(drawLines,{760,460,760,540})
        end
    end,nil,nil,nil,nil,
    function()-- 21~25 <*> [,100]
        local b=rnd(21,89)
        local a=rnd(ceil(b/10),9)
        b=int(b/a)
        return a.."*"..b,a*b,function()
            drawChar(a>b and a or b,600,200)
            drawChar(a>b and b or a,600,350)
            ins(drawLines,{460,500,700,500})
            ins(drawLines,{720,540,800,460})
            ins(drawLines,{720,460,800,540})
        end
    end,nil,nil,nil,nil,
    function()-- 26~28 <*> [,1000]
        local a,b=rnd(4,8),rnd(42,96)
        return a.."*"..b,a*b,function()
            drawChar(b,600,200)
            drawChar(a,600,350)
            ins(drawLines,{330,500,700,500})
            ins(drawLines,{720,540,800,460})
            ins(drawLines,{720,460,800,540})
        end
    end,nil,nil,
    function()-- 29~33 </> [,100]
        local b=rnd(21,89)
        local a=rnd(ceil(b/10),9)
        b=int(b/a)
        return a*b.."/"..a,b,function()
            drawChar(a*b,560,300,1,true)
            drawChar(a,400,300)
            ins(drawLines,{480,440,530,270,730,270})
        end
    end,nil,nil,nil,nil,
    function()-- 34~36 <%3>
        local s=rnd(5,17)
        return s.."%3",s%3,function()
            drawChar(s,560,300,1,true)
            drawChar(3,400,300)
            ins(drawLines,{480,440,530,270,730,270})
        end
    end,nil,nil,
    function()-- 37~41 <%> [,10]
        local s=rnd(21,62)
        local a=rnd(3,9)
        return s.."%"..a,s%a,function()
            drawChar(s,560,300,1,true)
            drawChar(a,400,300)
            ins(drawLines,{480,440,530,270,730,270})
        end
    end,nil,nil,nil,nil,
    function()-- 42~46 <b> [,10]
        local a=rnd(2,9)
        return {COLOR.N,b2(a)},a,function()
            local b=STRING.toBin(a)
            local l=math.floor(math.log(a,2)+1)
            for i=1,l do
                drawChar(tonumber(string.sub(b,i,i)),320,420-100*(l-i),.5)
                ins(drawLines,{370,480-100*(l-i),410,440-100*(l-i)})
                ins(drawLines,{370,440-100*(l-i),410,480-100*(l-i)})
                drawChar(2,430,420-100*(l-i),.5)
                drawChar(l-i,480,400-100*(l-i),.3)
                ins(drawLines,{520,470-100*(l-i),560,470-100*(l-i)})
                ins(drawLines,{520,450-100*(l-i),560,450-100*(l-i)})
            end
            ins(drawLines,{530,520,750,520})
            ins(drawLines,{770,520,850,520})
            ins(drawLines,{810,480,810,560})
        end
    end,nil,nil,nil,nil,
    function()-- 47~50 <o>
        local a=rnd(9,63)
        return {COLOR.lR,b8(a)},a,function()
        local b=STRING.toOct(a)
        local l=math.floor(math.log(a,8)+1)
        for i=1,l do
            drawChar(tonumber(string.sub(b,i,i)),320,420-100*(l-i),.5)
            ins(drawLines,{370,480-100*(l-i),410,440-100*(l-i)})
            ins(drawLines,{370,440-100*(l-i),410,480-100*(l-i)})
            drawChar(8,430,420-100*(l-i),.5)
            drawChar(l-i,480,400-100*(l-i),.3)
            ins(drawLines,{520,470-100*(l-i),560,470-100*(l-i)})
            ins(drawLines,{520,450-100*(l-i),560,450-100*(l-i)})
        end
        ins(drawLines,{530,520,750,520})
        ins(drawLines,{770,520,850,520})
        ins(drawLines,{810,480,810,560})
    end
    end,nil,nil,nil,
    function()-- 51~53 <h>
        local a=rnd(17,255)
        return {COLOR.J,b16(a)},a,function()
            local b=STRING.toHex(a)
            local l=math.floor(math.log(a,16)+1)
            for i=1,l do
                local c=string.sub(b,i,i)
                if ("0123456789"):find(c,nil,true) then
                    c=tonumber(c)
                else
                    c=tonumber(string.byte(c)-55)
                end
                drawChar(c,280,420-100*(l-i),.5)
                ins(drawLines,{330,480-100*(l-i),370,440-100*(l-i)})
                ins(drawLines,{330,440-100*(l-i),370,480-100*(l-i)})
                drawChar(16,430,420-100*(l-i),.5)
                drawChar(l-i,480,400-100*(l-i),.3)
                ins(drawLines,{520,470-100*(l-i),560,470-100*(l-i)})
                ins(drawLines,{520,450-100*(l-i),560,450-100*(l-i)})
            end
            ins(drawLines,{530,520,750,520})
            ins(drawLines,{770,520,850,520})
            ins(drawLines,{810,480,810,560})
        end
    end,nil,nil,
    function()-- 54~58 <b+>
        local s=rnd(9,31)
        local a=rnd(5,int(s/2))
        return {COLOR.N,b2(a),COLOR.Z,"+",COLOR.N,b2(s-a)},s,function()
            drawChar(tonumber(STRING.toBin(a)),220,200,.6)
            drawChar(tonumber(STRING.toBin(s-a)),220,335,.6)
            ins(drawLines,{0,470,300,470})
            ins(drawLines,{320,470,400,470})
            ins(drawLines,{360,430,360,510})
            local l=math.floor(math.log(s,2)+1)
            for i=1,l do
                ins(drawLines,{620,580-100*(l-i),660,540-100*(l-i)})
                ins(drawLines,{620,540-100*(l-i),660,580-100*(l-i)})
                drawChar(2,680,520-100*(l-i),.5)
                drawChar(l-i,730,500-100*(l-i),.3)
                ins(drawLines,{770,570-100*(l-i),810,570-100*(l-i)})
                ins(drawLines,{770,550-100*(l-i),810,550-100*(l-i)})
            end
            ins(drawLines,{780,620,1000,620})
            ins(drawLines,{1020,620,1100,620})
            ins(drawLines,{1060,580,1060,660})
        end
    end,nil,nil,nil,nil,
    function()-- 59~62 <o+>
        local s=rnd(18,63)
        local a=rnd(9,int(s/2))
        return {COLOR.lR,b8(a),COLOR.Z,"+",COLOR.lR,b8(s-a)},s,function()
            drawChar(tonumber(STRING.toOct(a)),220,200,.6)
            drawChar(tonumber(STRING.toOct(s-a)),220,335,.6)
            ins(drawLines,{0,470,300,470})
            ins(drawLines,{320,470,400,470})
            ins(drawLines,{360,430,360,510})
            local l=math.floor(math.log(s,8)+1)
            for i=1,l do
                ins(drawLines,{620,580-100*(l-i),660,540-100*(l-i)})
                ins(drawLines,{620,540-100*(l-i),660,580-100*(l-i)})
                drawChar(8,680,520-100*(l-i),.5)
                drawChar(l-i,730,500-100*(l-i),.3)
                ins(drawLines,{770,570-100*(l-i),810,570-100*(l-i)})
                ins(drawLines,{770,550-100*(l-i),810,550-100*(l-i)})
            end
            ins(drawLines,{780,620,1000,620})
            ins(drawLines,{1020,620,1100,620})
            ins(drawLines,{1060,580,1060,660})
        end
    end,nil,nil,nil,
    function()-- 63~65 <h+>
        local s=rnd(34,255)
        local a=rnd(17,int(s/2))
        return {COLOR.J,b16(a),COLOR.Z,"+",COLOR.J,b16(s-a)},s,function()
            drawChar(tonumber(STRING.toHex(a)),220,200,.6)
            drawChar(tonumber(STRING.toHex(s-a)),220,335,.6)
            ins(drawLines,{0,470,300,470})
            ins(drawLines,{320,470,400,470})
            ins(drawLines,{360,430,360,510})
            local l=math.floor(math.log(s,16)+1)
            for i=1,l do
                ins(drawLines,{620,580-100*(l-i),660,540-100*(l-i)})
                ins(drawLines,{620,540-100*(l-i),660,580-100*(l-i)})
                drawChar(16,680,520-100*(l-i),.5)
                drawChar(l-i,730,500-100*(l-i),.3)
                ins(drawLines,{770,570-100*(l-i),810,570-100*(l-i)})
                ins(drawLines,{770,550-100*(l-i),810,550-100*(l-i)})
            end
            ins(drawLines,{780,620,1000,620})
            ins(drawLines,{1020,620,1100,620})
            ins(drawLines,{1060,580,1060,660})
        end
    end,nil,nil,
    function() timing=false return "Coming S∞n"..(rnd()<.5 and "" or " "),1e99 end,
}setmetatable(levels,{__index=function(self,k) return self[k-1] end})

local level

local input,inputTime="",0
local question,answer
local numScale

local function newQuestion(lv)
    drawLines,drawVel,indexes={},{},{}
    return levels[lv]()
end

local function drawHelp() MES.new('info',"Drawing controls:\n"..
    "F1 to show this message\n"..
    "D to toggle drawing mode\n"..
    "A to auto-draw calculation\n"..
    "Ctrl+[number] to draw a number\n"..
    "[ and ] to adjust number scale\n"..
    "Ctrl+Z to undo\n"..
    "Backspace or Delete to clear\n",13)
end

local function reset()
    timing=true
    time=0
    input=""
    drawing=false
    drawLines,drawVel,indexes={},{},{}
    inputTime=0
    level=1
    question,answer,autoDraw=newQuestion(1)
end

local function check(val)
    if val==answer then
        level=level+1
        input=""
        inputTime=0
        local newQ
        repeat
            newQ,answer,autoDraw=newQuestion(level)
        until newQ~=question
        question=newQ
        SFX.play('reach')
    end
end

local function isDrawing() return drawing end -- for hiding widgets
local function isntDrawing() return not drawing end
local function drawDrawing()
    gc.setLineWidth(10)
    -- gc.setLineWidth(drawVel[i][(j+1)/2])      (couldn't implement without weird looking disjointed lines)
    gc.setLineJoin('bevel')
    for i=1,#drawLines do
        if #drawLines[i]>=4 then
            gc.line(drawLines[i])
        end
    end
end


local scene={}

function scene.enter()
    reset()
    drawing=false
    numScale=1
    BGM.play('truth')
end

function scene.keyDown(key,isRep)
    if isRep then return end
    if key:sub(1,2)=="kp" then key=key:sub(3) end
    if #key==1 and ("0123456789"):find(key,nil,true) then
        if love.keyboard.isDown('lctrl','rctrl') and drawing then
            drawChar(tonumber(key),love.mouse.getX(),love.mouse.getY(),numScale)
        elseif #input<8 then
            input=input..key
            inputTime=1
            check(tonumber(input))
            SFX.play('touch')
        end
    elseif drawing and key=='[' then numScale = math.max(numScale-.1,.3)
    elseif drawing and key==']' then numScale = math.min(numScale+.1,2)
    elseif drawing and key=='f1' then drawHelp()
    elseif key=='-' then
        if #input<8 then
            if input:find("-") then
                input=input:sub(2)
            else
                input="-"..input
            end
            inputTime=1
            check(tonumber(input))
            SFX.play('hold')
        end
    elseif key=='backspace' or key=='x' or key=='delete' then
        if drawing then
            drawLines,drawVel,indexes={},{},{}
        else
            input=""
            inputTime=0
        end
    elseif key=='r' then
        if drawing then
            drawLines,drawVel,indexes={},{},{}
        else
            reset()
        end
    elseif key=='d' then
        drawing=not drawing
    elseif key=='a' then
        if autoDraw then
            autoDraw()
        else
            MES.new('info',"Auto-drawing not implemented yet for this level.\nL + skill issue + look at this bozo")
        end
    elseif ((key=='z' and love.keyboard.isDown('lctrl','rctrl')) or key=='ctrl_z') and drawing then
        indexes={}
        rem(drawLines)
        rem(drawVel)
    elseif key=='escape' then
        if tryBack() then
            SCN.back()
        end
    end
end

function scene.touchDown(x,y,id)
    if not drawing then return end
    indexes[id]=#drawLines+1
    drawLines[indexes[id]]={x,y}
    drawVel[indexes[id]]={}
end
function scene.touchMove(x,y,dx,dy,id)
    if not drawing or not indexes[id] then return end
    ins(drawLines[indexes[id]],x)
    ins(drawLines[indexes[id]],y)
    ins(drawVel[indexes[id]],math.max(math.sqrt(math.abs(dx)+math.abs(dy)),10))
end
function scene.touchUp(x,y,id)
    if not drawing or not indexes[id] then return end
    if #drawLines[indexes[id]]==2 then -- touch, no movement, so delete line
        local delIndex=indexes[id]+0
        indexes[id]=nil
        rem(drawLines,delIndex)
        rem(drawVel,delIndex)
        for i,_ in next,indexes do -- decrement indexes after the deleted item
            indexes[i]=indexes[i]>delIndex and indexes[i]-1 or indexes[i]
        end
    else
        ins(
            drawVel[indexes[id]],
            math.max(
                math.sqrt( --   |x - prevXPos|  +  |y - prevYPos|
                    math.abs(x-drawLines[indexes[id]][#drawLines[indexes[id]]-1])+
                    math.abs(y-drawLines[indexes[id]][#drawLines[indexes[id]]])
                ),
                10
            )
        )
        ins(drawLines[indexes[id]],x)
        ins(drawLines[indexes[id]],y)

        indexes[id]=nil
    end
end

function scene.mouseDown(x,y) scene.touchDown(x,y,26629999) end
function scene.mouseUp(x,y) scene.touchUp(x,y,26629999) end
function scene.mouseMove(x,y,dx,dy)
    if indexes[26629999] then scene.touchMove(x,y,dx,dy,26629999) end
end

function scene.update(dt)
    if timing then time=time+dt end
    if inputTime>0 then
        inputTime=inputTime-dt
        if inputTime<=0 then
            input=""
        end
    end
end
function scene.draw()
    gc.setColor(drawing and COLOR.Z or COLOR.H)
    drawDrawing()
    gc.setColor(COLOR.Z)
    if not drawing then
        FONT.set(45)
        GC.mStr(STRING.time(time),1026,70)

        FONT.set(35)
        GC.mStr("["..level.."]",640,30)

        FONT.set(80)
        GC.mStr(question,640,60)

        FONT.set(80)
        gc.setColor(1,1,1,inputTime)
        GC.mStr(input,640,160)
    else
        FONT.set(30)
        GC.mStr(STRING.time(time),1160,120)

        FONT.set(80)
        gc.print(question,60,40)

        FONT.set(20)
        gc.print("Scale: "..100*numScale.."%",1150,680)

        if string.len(input)>0 then
            FONT.set(50)
            gc.setColor(1,1,1,inputTime)
            gc.print("= "..input,60,140)
        end

    end
end

scene.widgetList={
    -- TODO: Icons for "Toggle Drawing Mode" button and auto-draw button (waiting for C29H25N3O5 to make the icons in the font)
    WIDGET.newButton{name='reset',x=155,y=100,w=180,h=100,color='lG',font=50,fText=CHAR.icon.retry_spin,code=pressKey'r',hideF=isDrawing},
    WIDGET.newKey{name='X',      x=540, y=620,w=90,font=60,fText=CHAR.key.clear,code=pressKey'backspace',hideF=isDrawing},
    WIDGET.newKey{name='0',      x=640, y=620,w=90,font=60,fText="0",code=pressKey'0',hideF=isDrawing},
    WIDGET.newKey{name='-',      x=740, y=620,w=90,font=60,fText="-",code=pressKey'-',hideF=isDrawing},
    WIDGET.newKey{name='1',      x=540, y=520,w=90,font=60,fText="1",code=pressKey'1',hideF=isDrawing},
    WIDGET.newKey{name='2',      x=640, y=520,w=90,font=60,fText="2",code=pressKey'2',hideF=isDrawing},
    WIDGET.newKey{name='3',      x=740, y=520,w=90,font=60,fText="3",code=pressKey'3',hideF=isDrawing},
    WIDGET.newKey{name='4',      x=540, y=420,w=90,font=60,fText="4",code=pressKey'4',hideF=isDrawing},
    WIDGET.newKey{name='5',      x=640, y=420,w=90,font=60,fText="5",code=pressKey'5',hideF=isDrawing},
    WIDGET.newKey{name='6',      x=740, y=420,w=90,font=60,fText="6",code=pressKey'6',hideF=isDrawing},
    WIDGET.newKey{name='7',      x=540, y=320,w=90,font=60,fText="7",code=pressKey'7',hideF=isDrawing},
    WIDGET.newKey{name='8',      x=640, y=320,w=90,font=60,fText="8",code=pressKey'8',hideF=isDrawing},
    WIDGET.newKey{name='9',      x=740, y=320,w=90,font=60,fText="9",code=pressKey'9',hideF=isDrawing},
    WIDGET.newKey{name='D',      x=440, y=620,w=90,font=60,fText="D",code=pressKey'd',hideF=isDrawing},
    WIDGET.newKey{name='D_d',    x=1200,y=80 ,w=80,font=50,fText="D",code=pressKey'd',hideF=isntDrawing},
    WIDGET.newKey{name='A',      x=1120,y=80 ,w=80,font=50,fText="A",code=pressKey'a',hideF=isntDrawing},
    WIDGET.newKey{name='X_d',    x=1040,y=80 ,w=80,font=50,fText=CHAR.key.clear,code=pressKey'backspace',hideF=isntDrawing},
    WIDGET.newKey{name='undo',   x=960, y=80, w=80,font=50,fText=CHAR.icon.retry_spin,code=pressKey'ctrl_z',hideF=isntDrawing},
    WIDGET.newKey{name='help',   x=880, y=80, w=80,font=50,fText='?',code=pressKey'f1',hideF=isntDrawing},
    WIDGET.newButton{name='back',x=1200,y=660,w=110,h=60,font=45,sound='back',fText=CHAR.icon.back,code=backScene,hideF=isDrawing},
}

return scene
