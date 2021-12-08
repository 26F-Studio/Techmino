local gc=love.graphics
local gc_push,gc_pop=gc.push,gc.pop
local gc_translate,gc_scale,gc_rotate,gc_shear=gc.translate,gc.scale,gc.rotate,gc.shear
local gc_setCanvas,gc_setShader,gc_setBlendMode=gc.setCanvas,gc.setShader,gc.setBlendMode
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw,gc_line=gc.draw,gc.line
local gc_rectangle,gc_circle,gc_polygon=gc.rectangle,gc.circle,gc.polygon
local gc_print,gc_printf=gc.print,gc.printf
local gc_stencil,gc_setStencilTest=gc.stencil,gc.setStencilTest

local max,min=math.max,math.min
local int,abs=math.floor,math.abs
local rnd=math.random

local ins=table.insert

local setFont=setFont

local searchText=""
local searchTimer
local results={}
local selectedItem
local path={}
local pathStr="/"

local function _comp(a,b)
    return a.type~=b.type and a.type=='folder'
end

local function _newItem(item,x0,y0)
    return{
        type=item.folder and'folder'or'mode',
        name=item.name,
        x0=x0,y0=y0,
        w=160,h=160,
        x=x0+rnd(-26,26),y=y0+rnd(-26,26),
        alpha=0,
        selTime=0,
    }
end

local function _freshPacks()
    TABLE.cut(results)
    local t=MODETREE
    for i=1,#path do
        for j=1,#t do
            if t[j].name==path[i]then
                t=t[j]
                break
            end
        end
    end
    local count=0
    if path[1]then
        ins(results,_newItem({folder=true,name='_back'},0,0))
        count=1
    end
    for i=1,#t do
        local item=t[i]
        if #searchText==0 or item.name:find(searchText)then
            ins(results,_newItem(item,180*(count%4),200*int(count/4)))
            count=count+1
        end
    end
    table.sort(results,_comp)
end

local scene={}

function scene.sceneInit()
    BG.set()
    _freshPacks()
    searchTimer=0
end

function scene.mouseMove(x,y)
    selectedItem=false
    x,y=x-40,y-150
    if x<-40 or x>=765 or y<-40 or y>=570 then return end
    for i=1,#results do
        local item=results[i]
        if x>item.x0 and x<item.x0+item.w and y>item.y0 and y<item.y0+item.h then
            selectedItem=item
            break
        end
    end
end
function scene.mouseDown(x,y,k)
    scene.mouseMove(x,y)
    if k==1 then
        scene.keyDown('return')
    end
end
function scene.wheelMoved(_,y)print(y)
    if results[1]then
        y=y*126
        if results[1].y0>-y then y=-results[1].y0 end
        local r=results[#results]
        if r.y0+r.h+y<540 then y=540-r.y0-r.h end
        for i=1,#results do
            local item=results[i]
            item.y0=item.y0+y
        end
    end
end
function scene.keyDown(key,isRep)
    if key=='up'or key=='down'or key=='left'or key=='right'then
        --Select mode with arrow keys
    elseif key=='f1'then
        SCN.go('mod')
    elseif key=='return'then
        if isRep then return end
        if selectedItem then
            if selectedItem.type=='mode'then
                loadGame(selectedItem.name)
            elseif selectedItem.type=='folder'then
                if selectedItem.name=='_back'then
                    table.remove(path)
                    SFX.play('uncheck')
                else
                    ins(path,selectedItem.name)
                    SFX.play('check')
                end
                pathStr="modes/"
                if path[1]then pathStr=pathStr..table.concat(path,'/').."/"end
                _freshPacks()
            end
        end
    elseif key=='escape'then
        if isRep then return end
        if #searchText>0 then
            searchText=""
            _freshPacks()
        else
            SCN.back()
        end
    elseif key=='backspace'then
        if #searchText>0 then
            searchText=searchText:sub(1,-2)
            searchTimer=.42
        end
    elseif #key==1 then
        searchText=searchText..key
        searchTimer=.42
    end
end

function scene.update(dt)
    if searchTimer>0 then
        searchTimer=searchTimer-dt
        if searchTimer<=0 then
            _freshPacks()
        end
    end
    for i=1,#results do
        local item=results[i]
        item.x=item.x*.9+item.x0*.1
        item.y=item.y*.9+item.y0*.1
        if item.alpha<1 then
            item.alpha=min(item.alpha+dt*2.6,1)
        end
        if item==selectedItem then
            item.selTime=min(item.selTime+dt,.126)
        elseif item.selTime>0 then
            item.selTime=item.selTime-dt
        end
    end
end

local function _modePannelStencil()
    gc_rectangle('fill',0,0,805,610)
end
function scene.draw()
    gc_setLineWidth(2)

    gc_setColor(COLOR.dX)
    gc_rectangle('fill',0,0,1280,110)
    gc_rectangle('fill',0,110,805,610)
    gc_setColor(COLOR.X)
    gc_rectangle('fill',805,110,475,610)
    gc_setColor(COLOR.Z)
    gc_line(0,110,1280,110)
    gc_line(805,110,805,720)

    setFont(40)
    gc_print(pathStr,60,40)
    gc_print(searchText,800,40)

    gc_push('transform')
    gc_translate(0,110)
    gc_stencil(_modePannelStencil,'replace',1)
    gc_setStencilTest('equal',1)
        gc_translate(40,40)
        setFont(20)
        for i=1,#results do
            local item=results[i]
            if item.type=='folder'then
                gc_setColor(1,.9,.5,item.alpha*.3)
                gc_rectangle('fill',item.x,item.y,item.w,item.h)
            end
            if item.selTime>0 then
                gc_setColor(1,1,1,item.selTime*2)
                gc_rectangle('fill',item.x,item.y,item.w,item.h,6)
            end
            gc_setColor(1,1,1,item.alpha)
            gc_rectangle('line',item.x,item.y,item.w,item.h,6)
            gc_print(item.name,item.x+10,item.y+item.h-28)
        end
    gc_setStencilTest()
    gc_pop()
end

scene.widgetList={
    WIDGET.newButton{name='mod',x=890,y=655,w=140,h=80,font=25,code=goScene'mod'},
    WIDGET.newButton{name='start',x=1040,y=655,w=140,h=80,font=40,code=pressKey'return'},
    WIDGET.newButton{name='back',x=1190,y=655,w=140,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}
return scene
