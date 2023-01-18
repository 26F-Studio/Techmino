local gc=love.graphics

local scene={}

local das,arr
local pos,dir,wait

function scene.enter()
    das,arr=SETTING.das,SETTING.arr
    pos,dir,wait=0,1,30
    BG.set('bg1')
end

local  trigFrame=0
function scene.update(dt)
    trigFrame=trigFrame+dt*60
    while trigFrame>=1 do
        trigFrame=trigFrame-1
        if wait>0 then
            wait=wait-1
            if wait==0 then
                pos=pos+(das==0 and 2 or 1)*dir
            else
                return
            end
        end
        if das>0 then
            das=das-1
            if das==0 then
                if arr==0 then
                    pos=pos+7*dir
                    das=SETTING.das+1
                    arr=SETTING.arr
                    dir=-dir
                    wait=26
                else
                    pos=pos+dir
                end
            end
        else
            arr=arr-1
            if arr==0 then
                pos=pos+dir
                arr=SETTING.arr
            elseif arr==-1 then
                pos=dir>0 and 8 or 0
                arr=SETTING.arr
            end
            if pos%8==0 then
                dir=-dir
                wait=26
                das=SETTING.das
            end
        end
    end
end

function scene.draw()
    gc.translate(550,600)

    -- Testing grid line
    gc.setLineWidth(4)
    gc.setColor(1,1,1,.4)
    gc.line(0,0,400,0)
    gc.line(0,40,400,40)
    gc.line(0,80,400,80)
    for x=40,360,40 do
        gc.line(x,-10,x,90)
    end
    gc.setColor(COLOR.Z)
    gc.line(0,-10,0,90)
    gc.line(400,-10,400,90)

    -- O mino animation
    gc.setColor(1,1,1)
    local O=SKIN.lib[SETTING.skinSet][SETTING.skin[6]]
    gc.draw(O,40*pos,0,nil,40/30)
    gc.draw(O,40*pos,40,nil,40/30)
    gc.draw(O,40*pos+40,0,nil,40/30)
    gc.draw(O,40*pos+40,40,nil,40/30)
    gc.translate(-550,-600)
end

local function _sliderShow(S)
    S=S.disp()
    return S.."F "..math.floor(S*16.67).."ms"
end
scene.widgetList={
    WIDGET.newText{name='title',    x=100,    y=50,lim=500,font=70,align='L'},
    WIDGET.newText{name='preview',  x=520,    y=610,font=40,align='R'},

    WIDGET.newSlider{name='das',    x=250,    y=190,lim=230,w=600,axis={0,20,1},disp=SETval('das'),    show=_sliderShow,code=SETsto('das')},
    WIDGET.newSlider{name='arr',    x=250,    y=260,lim=230,w=525,axis={0,15,1},disp=SETval('arr'),    show=_sliderShow,code=SETsto('arr')},
    WIDGET.newSlider{name='sddas',  x=250,    y=330,lim=230,w=350,axis={0,10,1},disp=SETval('sddas'),  show=_sliderShow,code=SETsto('sddas')},
    WIDGET.newSlider{name='sdarr',  x=250,    y=400,lim=230,w=140,axis={0,4,1}, disp=SETval('sdarr'),  show=_sliderShow,code=SETsto('sdarr')},
    WIDGET.newSlider{name='dascut', x=250,    y=470,lim=230,w=600,axis={0,20,1},disp=SETval('dascut'), show=_sliderShow,code=SETsto('dascut')},
    WIDGET.newSlider{name='dropcut',x=250,    y=540,lim=230,w=300,axis={0,10,1},disp=SETval('dropcut'),show=_sliderShow,code=SETsto('dropcut')},
    WIDGET.newSwitch{name='ihs',    x=1100,   y=260,lim=300,                    disp=SETval('ihs'),    code=SETrev('ihs')},
    WIDGET.newSwitch{name='irs',    x=1100,   y=330,lim=300,                    disp=SETval('irs'),    code=SETrev('irs')},
    WIDGET.newSwitch{name='ims',    x=1100,   y=400,lim=300,                    disp=SETval('ims'),    code=SETrev('ims')},
    WIDGET.newButton{name='reset',  x=160,    y=640,w=200,h=100,color='lR',font=40,
        code=function()
            local _=SETTING
            _.das,_.arr,_.dascut=10,2,0
            _.sddas,_.sdarr=0,2
            _.ihs,_.irs,_.ims=false,false,false
        end},
    WIDGET.newButton{name='back',   x=1140,   y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
