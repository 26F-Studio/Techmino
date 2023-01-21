local scene={}

local form-- Form of clear & spins
local item-- Detail datas

function scene.enter()
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
        S.piece.."  "..S.row.."  "..math.floor(S.atk),
        S.recv.."  "..S.off.."  "..S.pend,
        S.dig.."  "..math.floor(S.digatk),
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
    if x>40 and y>520 and x<440 and y<695 then
        loadGame('sprintMD',true)
    end
end
scene.touchDown=scene.mouseDown
function scene.keyDown()
    if love.keyboard.isDown('m') and love.keyboard.isDown('d') then
        loadGame('sprintMD',true)
    else
        return true
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
    GC.setColor(1,1,1)
    GC.draw(TEXTURE.title,260,615,.2+.04*math.sin(t*3),.4,nil,580,118)

    GC.setColor(COLOR.Z)
    setFont(20)
    for i=1,11 do
        GC.print(item[i],760,40*i+10)
    end

    local A,B=form.A1,form.A2
    GC.translate(60,80)
    GC.setLineWidth(2)
    GC.rectangle('line',0,0,560,160,5)
    GC.rectangle('line',0,240,560,160,5)
    for x=1,6 do
        x=80*x
        GC.line(x,0,x,160)
        GC.line(x,240,x,400)
    end
    for y=1,3 do
        GC.line(0,40*y,560,40*y)
        GC.line(0,240+40*y,560,240+40*y)
    end

    for x=1,7 do
        GC.setColor(BLOCK_COLORS[SETTING.skin[x]])
        setFont(70)
        GC.mStr(BLOCK_CHARS[x],80*x-40,-70)
        GC.mStr(BLOCK_CHARS[x],80*x-40,170)
        setFont(25)
        for y=1,4 do
            GC.mStr(A[x][y],80*x-40,-37+40*y)
            GC.mStr(B[x][y],80*x-40,203+40*y)
        end
        GC.mStr(form.Y1[x],80*x-40,163)
        GC.mStr(form.Y2[x],80*x-40,403)
    end

    A,B=form.X1,form.X2
    for y=1,4 do
        GC.setColor(COLOR.Z)
        GC.print(spinChars[y],-33,-37+40*y)
        GC.print(y,-28,203+40*y)
        GC.setColor(COLOR.H)
        GC.mStr(A[y],612,-37+40*y)
        GC.mStr(B[y],612,203+40*y)
    end
    GC.translate(-60,-80)
end

scene.widgetList={
    WIDGET.newButton{name='path',x=820,y=540,w=250,h=80,font=25,
        code=function()
            if SYSTEM=="Windows" or SYSTEM=="Linux" then
                love.system.openURL(love.filesystem.getSaveDirectory())
            else
                MES.new('info',love.filesystem.getSaveDirectory())
            end
        end
    },
    WIDGET.newButton{name='save',x=820,y=640,w=250,h=80,font=25,code=goScene'savedata'},
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
