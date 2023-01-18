local gc,ms=love.graphics,love.mouse
local int,sin=math.floor,math.sin
local VK_ORG=VK_ORG

local scene={}

local defaultSetSelect
local snapUnit=1
local selected-- Button selected

local function _save1()
    saveFile(VK_ORG,'conf/vkSave1')
end
local function _load1()
    local D=loadFile('conf/vkSave1')
    if D then
        TABLE.update(D,VK_ORG)
    else
        MES.new('error',text.noFile)
    end
end
local function _save2()
    saveFile(VK_ORG,'conf/vkSave2')
end
local function _load2()
    local D=loadFile('conf/vkSave2')
    if D then
        TABLE.update(D,VK_ORG)
    else
        MES.new('error',text.noFile)
    end
end

function scene.enter()
    BG.set('rainbow')
    defaultSetSelect=1
    selected=false
end
function scene.leave()
    saveFile(VK_ORG,'conf/virtualkey')
end

local function _onVK_org(x,y)
    local dist,nearest=1e10
    for K=1,#VK_ORG do
        local B=VK_ORG[K]
        if B.ava then
            local d1=(x-B.x)^2+(y-B.y)^2
            if d1<B.r^2 then
                if d1<dist then
                    nearest,dist=K,d1
                end
            end
        end
    end
    return nearest
end
function scene.mouseDown(x,y,k)
    if k==1 then
        scene.touchDown(x,y)
    end
end
function scene.mouseUp()
    scene.touchUp()
end
function scene.mouseMove(_,_,dx,dy)
    if ms.isDown(1) then
        scene.touchMove(nil,nil,dx,dy)
    end
end
function scene.touchDown(x,y)
    selected=_onVK_org(x,y) or selected
end
function scene.touchUp()
    if selected then
        local B=VK_ORG[selected]
        B.x,B.y=int(B.x/snapUnit+.5)*snapUnit,int(B.y/snapUnit+.5)*snapUnit
    end
end
function scene.touchMove(_,_,dx,dy)
    if selected and not WIDGET.isFocus() then
        local B=VK_ORG[selected]
        B.x,B.y=B.x+dx,B.y+dy
    end
end

function scene.draw()
    gc.setColor(COLOR.Z)
    gc.setLineWidth(3)
    gc.draw(TEXTURE.playerBorder,473,63)
    VK.preview(selected)
    local x1,y1=SCR.xOy:inverseTransformPoint(0,0)
    local x2,y2=SCR.xOy:inverseTransformPoint(SCR.w,SCR.h)
    if snapUnit>=10 then
        gc.setLineWidth(3)
        gc.setColor(1,1,1,sin(TIME()*4)*.1+.1)
        for i=x1,x2+snapUnit,snapUnit do
            local x=i-i%snapUnit
            gc.line(x,y1,x,y2)
        end
        for i=y1,y2+snapUnit,snapUnit do
            local y=i-i%snapUnit
            gc.line(x1,y,x2,y)
        end
    end
end

scene.widgetList={
    WIDGET.newButton{name='default',x=530,y=90,w=200,h=80,font=35,
        code=function()
            VK.changeSet(defaultSetSelect)
            MES.new('check',"==[ "..defaultSetSelect.." ]==")
            defaultSetSelect=defaultSetSelect%5+1
            selected=false
        end},
    WIDGET.newSelector{name='snap', x=750,y=90,w=200,h=80,color='Y',list={1,10,20,40,60,80},disp=function() return snapUnit end,code=function(i) snapUnit=i end},
    WIDGET.newButton{name='option', x=530,y=190,w=200,h=80,font=60,fText=CHAR.icon.menu,code=function() SCN.go('setting_touchSwitch') end},
    WIDGET.newButton{name='back',   x=750,y=190,w=200,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
    WIDGET.newKey{name='save1',     x=475,y=290,w=90,h=70,code=_save1,font=45,fText=CHAR.icon.saveOne},
    WIDGET.newKey{name='load1',     x=585,y=290,w=90,h=70,code=_load1,font=45,fText=CHAR.icon.loadOne},
    WIDGET.newKey{name='save2',     x=695,y=290,w=90,h=70,code=_save2,font=45,fText=CHAR.icon.saveTwo},
    WIDGET.newKey{name='load2',     x=805,y=290,w=90,h=70,code=_load2,font=45,fText=CHAR.icon.loadTwo},
    WIDGET.newSlider{name='size',   x=440,y=370,w=460,axis={0,19,1},font=40,show="vkSize",
        disp=function()
            return VK_ORG[selected].r/10-1
        end,
        code=function(v)
            if selected then
                VK_ORG[selected].r=(v+1)*10
            end
        end,
        hideF=function()
            return not selected
        end},
    WIDGET.newKey{name='shape',     x=640,y=600,w=200,h=80,code=function() SETTING.VKSkin=VK.nextShape() end},
}

return scene
