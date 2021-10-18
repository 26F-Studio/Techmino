local gc=love.graphics
local gc_translate=gc.translate
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw,gc_line=gc.draw,gc.line
local gc_print=gc.print

local int,sin=math.floor,math.sin
local mStr=GC.mStr

local scene={}

local form--Form of clear & spins
local item--Detail datas

function scene.sceneInit()
    BG.set()
    local S=STAT
    local X1,X2,Y1,Y2={0,0,0,0},{0,0,0,0},{},{}
    for i=1,7 do
        local s,c=S.spin[i],S.clear[i]
        Y1[i]=s[1]+s[2]+s[3]+s[4]
        Y2[i]=c[1]+c[2]+c[3]+c[4]
        for j=1,4 do
            X1[j]=X1[j]+s[j]
            X2[j]=X2[j]+c[j]
        end
    end
    form={
        A1=S.spin,A2=S.clear,
        X1=X1,X2=X2,
        Y1=Y1,Y2=Y2,
    }
    item={
        S.run,
        S.game,
        STRING.time(S.time),
        S.key.."  "..S.rotate.."  "..S.hold,
        S.piece.."  "..S.row.."  "..int(S.atk),
        S.recv.."  "..S.off.."  "..S.pend,
        S.dig.."  "..int(S.digatk),
        ("%.2f  %.2f"):format(S.atk/S.row,S.digatk/S.dig),
        S.b2b.."  "..S.b3b,
        S.pc.."  "..S.hpc,
        ("%d/%.2f%%"):format(S.extraPiece,S.finesseRate*20/S.piece),
    }
    for i=1,11 do
        item[i]=text.stat[i].."\t"..item[i]
    end
end

function scene.mouseDown(x,y)
    if x>35 and y>515 and x<490 and y<705 then
        loadGame('sprintMD',true)
    end
end
scene.touchDown=scene.mouseDown
function scene.keyDown(key)
    if key=="escape"then
        SCN.back()
    elseif love.keyboard.isDown("m")and love.keyboard.isDown("d")then
        loadGame('sprintMD',true)
    end
end

local spinChars={
    CHAR.icon.num0InSpin,
    CHAR.icon.num1InSpin,
    CHAR.icon.num2InSpin,
    CHAR.icon.num3InSpin,
}

function scene.draw()
    local t=TIME()
    gc_draw(TEXTURE.title,260,615,.2+.04*sin(t*3),.4,nil,580,118)

    gc_setColor(COLOR.Z)
    setFont(20)
    for i=1,11 do
        gc_print(item[i],760,40*i+10)
    end

    local A,B=form.A1,form.A2
    gc_translate(60,80)
    gc_setLineWidth(2)
    gc.rectangle('line',0,0,560,160,5)
    gc.rectangle('line',0,240,560,160,5)
    for x=1,6 do
        x=80*x
        gc_line(x,0,x,160)
        gc_line(x,240,x,400)
    end
    for y=1,3 do
        gc_line(0,40*y,560,40*y)
        gc_line(0,240+40*y,560,240+40*y)
    end

    for x=1,7 do
        gc_setColor(BLOCK_COLORS[SETTING.skin[x]])
        setFont(70)
        mStr(BLOCK_CHARS[x],80*x-40,-70)
        mStr(BLOCK_CHARS[x],80*x-40,170)
        setFont(25)
        for y=1,4 do
            mStr(A[x][y],80*x-40,-37+40*y)
            mStr(B[x][y],80*x-40,203+40*y)
        end
        mStr(form.Y1[x],80*x-40,163)
        mStr(form.Y2[x],80*x-40,403)
    end

    A,B=form.X1,form.X2
    for y=1,4 do
        gc_setColor(COLOR.Z)
        gc_print(spinChars[y],-33,-37+40*y)
        gc_print(y,-28,203+40*y)
        gc_setColor(COLOR.H)
        mStr(A[y],612,-37+40*y)
        mStr(B[y],612,203+40*y)
    end
    gc_translate(-60,-80)
end

scene.widgetList={
    WIDGET.newButton{name="path",x=820,y=540,w=250,h=80,font=25,
        code=function()
            if SYSTEM=="Windows"or SYSTEM=="Linux"then
                love.system.openURL(SAVEDIR)
            else
                MES.new('info',SAVEDIR)
            end
        end
    },
    WIDGET.newButton{name="save",x=820,y=640,w=250,h=80,font=25,code=goScene'savedata'},
    WIDGET.newButton{name="back",x=1140,y=640,w=170,h=80,font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
