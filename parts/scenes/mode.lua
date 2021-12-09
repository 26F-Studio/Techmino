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

function _setPos(self,x,y,dx,dy)
    self.x0,self.y0=x,y
    self.x,self.y=x+dx,y+dy
end
local function _newItem(item)
    return{
        type=item.folder and'folder'or'mode',
        name=item.name,
        x0=0,y0=0,
        x=0,y=0,
        w=160,h=160,
        alpha=0,
        selTime=0,
        setPos=_setPos,
    }
end

local _backItem={folder=true,name='_back'}
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
        ins(results,_newItem(_backItem))
        count=1
    end
    for i=1,#t do
        local item=t[i]
        if #searchText==0 or item.name:find(searchText)then
            ins(results,_newItem(item))
            count=count+1
        end
    end
    table.sort(results,_comp)
    for i=0,#results-1 do
        results[i+1]:setPos(180*(i%4),200*int(i/4),15*i,i)
    end
end

local scene={}

function scene.sceneInit()
    BG.set()
    _freshPacks()
    searchTimer=0
end

function scene.mouseClick(x,y,k)
    if k==1 then
        local sel=false
        x,y=x-40,y-150
        if x<-40 or x>=765 or y<-40 or y>=570 then return end
        for i=1,#results do
            local item=results[i]
            if x>item.x and x<item.x+item.w and y>item.y and y<item.y+item.h then
                sel=item
                break
            end
        end
        if sel then
            if sel==selectedItem then
                scene.keyDown('return')
            elseif sel then
                SFX.play('click')
            end
        end
        selectedItem=sel
    elseif k==2 then
        if path[1]then
            table.remove(path)
            pathStr="modes/"
            if path[1]then pathStr=pathStr..table.concat(path,'/').."/"end
            _freshPacks()
            SFX.play('uncheck')
        end
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
        if not selectedItem then
            selectedItem=results[1]
        else
            local i=TABLE.find(results,selectedItem)
            if key=='up'then
                i=i-4
            elseif key=='down'then
                i=i+4
            elseif key=='left'then
                i=i-1
            elseif key=='right'then
                i=i+1
            end
            if i<1 then
                i=1
            elseif i>#results then
                i=#results
            end
            selectedItem=results[i]
        end
    elseif key=='f1'then
        SCN.go('mod')
    elseif key=='return'then
        if isRep then return end
        print(selectedItem)
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
    WIDGET.newButton{name='mod',x=930,y=655,w=180,h=80,code=goScene'mod'},
    WIDGET.newButton{name='back',x=1150,y=655,w=180,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}
return scene
