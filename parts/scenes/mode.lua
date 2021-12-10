local gc=love.graphics
local gc_push,gc_pop=gc.push,gc.pop
local gc_translate=gc.translate
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_line,gc_rectangle,gc_circle=gc.line,gc.rectangle,gc.circle
local gc_draw,gc_print,gc_printf=gc.draw,gc.print,gc.printf
local gc_stencil,gc_setStencilTest=gc.stencil,gc.setStencilTest

local max,min=math.max,math.min
local int=math.floor

local ins=table.insert

local setFont=setFont

local searchText=""
local searchTimer
local results={}
local selectedItem
local path={}
local pathStr="modes/"

function _setPos(self,x,y,dx,dy)
    self.x0,self.y0=x,y
    self.x,self.y=x+dx,y+dy
end
local function _newItem(item)
    local text=gc.newText(getFont(20),item.name)
    local icon=MODEICON[item.icon or item.name]
    return{
        type=item.folder and'folder'or'mode',
        name=item.name,
        author=item.author or'',
        text=text,
        text_scaleX=min(1,150/text:getWidth()),
        icon=icon,
        icon_scale=min(max(160/icon:getWidth(),130/icon:getHeight()),1),
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
    --Change directory
    local t=MODETREE
    for i=1,#path do
        for j=1,#t do
            if t[j].name==path[i]then
                t=t[j]
                break
            end
        end
    end

    --Get items with searchText
    local r={}
    if path[1]then
        ins(r,_newItem(_backItem))
    end
    for i=1,#t do
        local item=t[i]
        if #searchText==0 or item.name:find(searchText)then
            ins(r,_newItem(item))
        end
    end

    --Add items in correct order
    TABLE.cut(results)
    for i=1,#r do
        if r[i].type=='folder'then
            ins(results,r[i])
        end
    end
    for i=1,#r do
        if r[i].type~='folder'then
            ins(results,r[i])
        end
    end

    --Set items' positions
    for i=0,#results-1 do
        results[i+1]:setPos(180*(i%4),200*int(i/4),26+16*i,i)
    end

    selectedItem=false
end

local function _scrollModes(y)
    if not results[1]then return end

    local r=results[#results]
    if r.y0+r.h+y<540 then y=540-r.y0-r.h end
    if results[1].y0>-y then y=-results[1].y0 end

    for i=1,#results do
        local item=results[i]
        item.y0=item.y0+y
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
        if x<-40 or x>765 or y<-40 or y>570 then return end
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
                selectedItem=sel
            end
        end
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
function scene.wheelMoved(_,y)
    if results[1]then
        _scrollModes(y*126)
    end
end

function scene.touchClick(x,y)
    scene.mouseClick(x,y,1)
end
function scene.touchMove(x,y,_,dy)
    x,y=x-40,y-150
    if x<-40 or x>765 or y<-40 or y>570 then return end
    _scrollModes(dy*1.26)
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
            if selectedItem.y0<0 then
                _scrollModes(-selectedItem.y)
            elseif selectedItem.y0+selectedItem.h>540 then
                _scrollModes(540-selectedItem.y0-selectedItem.h)
            end
        end
    elseif key=='f1'then
        SCN.go('mod')
    elseif key=='space'or key=='return'then
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
        else
            selectedItem=results[1]
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
            searchTimer=.26
        end
    elseif #key==1 and #searchText<12 then
        searchText=searchText..key
        searchTimer=.26
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
    gc_rectangle('fill',0,0,810,610)
end
local _unknownModeText={'???','?','?????'}
local _rankName={
    CHAR.icon.rankB,
    CHAR.icon.rankA,
    CHAR.icon.rankS,
    CHAR.icon.rankU,
    CHAR.icon.rankX,
}
function scene.draw()
    --Gray background
    gc_setColor(COLOR.dX)
    gc_rectangle('fill',0,0,1280,110)
    gc_rectangle('fill',0,110,810,610)
    gc_setColor(COLOR.X)
    gc_rectangle('fill',810,110,475,610)

    --Seperating line
    gc_setLineWidth(2)
    gc_setColor(COLOR.Z)
    gc_line(0,110,1280,110)
    gc_line(810,110,810,720)

    --Path
    setFont(35)
    gc_print(pathStr,60,40)

    --SearchText
    gc_print(CHAR.key.right,800,40)
    if searchText==""then
        gc_setColor(COLOR.dH)
        gc_print(text.searchModeHelp,840,40)
    else
        gc_setColor(COLOR.Z)
        gc_print(searchText,840,40)
    end

    --Items
    gc_push('transform')
    gc_translate(0,110)
    gc_stencil(_modePannelStencil,'replace',1)
    gc_setStencilTest('equal',1)
        gc_translate(40,40)
        setFont(50)
        for i=1,#results do
            local item=results[i]

            local rank=RANKS[item.name]
            if rank==0 then rank=nil end

            if item.type=='folder'then
                --Folder's yellow back
                local r,g,b
                if item.name=='_back'then
                    r,g,b=0,0,0
                else
                    r,g,b=1,.8,.5
                end
                gc_setColor(r,g,b,item.alpha*.4)
                gc_rectangle('fill',item.x,item.y,item.w,item.h)
                gc_setColor(1,1,1,item.alpha)
                gc_circle('line',item.x+15,item.y+15,8)
            else
                --Rank background
                if rank then
                    local r,g,b=RANK_BASE_COLORS[rank][1],RANK_BASE_COLORS[rank][2],RANK_BASE_COLORS[rank][3]
                    gc_setColor(r,g,b,item.alpha*.3)
                    gc_rectangle('fill',item.x,item.y,item.w,item.h)
                end
            end

            --Icon
            gc_setColor(1,1,1,item.alpha)
            mDraw(item.icon,item.x+item.w/2,item.y+(item.h-30)/2,0,item.icon_scale)

            --Frame
            gc_rectangle('line',item.x,item.y,item.w,item.h,6)
            gc_draw(item.text,item.x+6,item.y+item.h-28,0,item.text_scaleX,1)

            --Rank
            if rank then
                local rankStr=_rankName[RANKS[item.name]]
                gc_setColor(0,0,0,item.alpha)
                gc_print(rankStr,item.x+item.w-30+2,item.y-26+2)
                local r,g,b=RANK_COLORS[rank][1],RANK_COLORS[rank][2],RANK_COLORS[rank][3]
                gc_setColor(r,g,b,item.alpha)
                gc_print(rankStr,item.x+item.w-30,item.y-26)
            end

            --Selecting glow
            if item.selTime>0 then
                gc_setColor(1,1,1,item.selTime*2)
                gc_rectangle('fill',item.x+8,item.y+8,item.w-16,item.h-36,5)
            end
        end
    gc_setStencilTest()
    gc_pop()

    --Selected item info
    if selectedItem then
        if selectedItem.type=='folder'then
            gc_setColor(1,1,1,selectedItem.alpha)
            setFont(50)mStr(selectedItem.name,1043,110)
            setFont(30)mStr(selectedItem.author,1043,180)
        elseif selectedItem.type=='mode'then
            local M=MODES[selectedItem.name]

            --Slowmark
            if M.slowMark then
                gc_setColor(.6,.9,1,(1-3*TIME()%1*.8)*selectedItem.alpha)
                setFont(20)
                gc_print("CTRL",815,110)
            end

            --Mode title & info
            gc_setColor(1,1,1,selectedItem.alpha)
            local t=text.modes[M.name]or _unknownModeText
            setFont(40)mStr(t[1],1043,110)
            setFont(30)mStr(t[2],1043,153)
            setFont(25)mStr(t[3],1043,200)

            --High scores
            if M.score then
                mText(TEXTOBJ.highScore,1043,293)
                gc_setColor(COLOR.dX)
                gc_rectangle('fill',825,335,440,260,3)
                local L=M.records
                gc_setColor(1,1,1)
                setFont(20)
                if L[1]then
                    for i=1,#L do
                        local res=M.scoreDisp(L[i])
                        gc_print(res,830,310+25*i,0,min(35/#res,1),1)
                        gc_printf(L[i].date or"-/-/-",1100,310+25*i,200,'right',0,.8,1)
                    end
                else
                    mText(TEXTOBJ.noScore,1043,433)
                end
            end
        end
    end
end

scene.widgetList={
    WIDGET.newButton{name='mod',x=920,y=655,w=150,h=80,code=goScene'mod'},
    WIDGET.newButton{name='back',x=1140,y=655,w=220,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}
return scene
