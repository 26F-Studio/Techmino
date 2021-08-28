local gc=love.graphics
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw,gc_line=gc.draw,gc.line
local gc_print=gc.print

local abs,int,sin=math.abs,math.floor,math.sin
local mStr=mStr

local scene={}

local form--Form of clear & spins
local item--Detail datas

function scene.sceneInit()
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

function scene.draw()
    local _,__=minoColor,SETTING.skin
    local A,B=form.A1,form.A2

    setFont(25)
    for x=1,7 do
        gc_setColor(_[__[x]])
        mStr(text.block[x],80*x,40)
        mStr(text.block[x],80*x,280)
        for y=1,4 do
            mStr(A[x][y],80*x,40+40*y)
            mStr(B[x][y],80*x,280+40*y)
        end
        mStr(form.Y1[x],80*x,240)
        mStr(form.Y2[x],80*x,480)
    end

    A,B=form.X1,form.X2
    for y=1,4 do
        gc_setColor(.5,.5,.5)
        gc_print(y-1,620,40+40*y)
        gc_print(y,620,280+40*y)
        gc_setColor(1,1,1)
        mStr(A[y],680,40+40*y)
        mStr(B[y],680,280+40*y)
    end

    setFont(20)
    for i=1,11 do
        gc_print(item[i],740,40*i+10)
    end

    gc_setLineWidth(2)
    gc.rectangle('line',40,80,560,160,5)
    gc.rectangle('line',40,320,560,160,5)
    for x=1,6 do
        x=80*x+40
        gc_line(x,80,x,240)
        gc_line(x,320,x,480)
    end
    for y=1,3 do
        gc_line(40,80+40*y,600,80+40*y)
        gc_line(40,320+40*y,600,320+40*y)
    end

    local t=TIME()
    gc_draw(TEXTURE.title,260,615,.2+.04*sin(t*3),.4,nil,580,118)

    local r=t*2
    local R=int(r)%7+1
    gc_setColor(1,1,1,1-abs(r%1*2-1))
    gc_draw(TEXTURE.miniBlock[R],680,50,t*10%6.2832,15,15,DSCP[R][0][2]+.5,#BLOCKS[R][0]-DSCP[R][0][1]-.5)
    gc_draw(TEXTURE.miniBlock[R],680,300,0,15,15,DSCP[R][0][2]+.5,#BLOCKS[R][0]-DSCP[R][0][1]-.5)
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
    WIDGET.newButton{name="back",x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene
