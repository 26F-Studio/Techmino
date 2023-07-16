local sys=love.system
local kb=love.keyboard

local sin=math.sin
local ins,rem=table.insert,table.remove
local gc_setColor,gc_print=GC.setColor,GC.print

local scene={}

local cur-- Cursor position

function scene.enter()
    cur=#BAG
end
function scene.leave()
    saveFile(DATA.copySequence(),'conf/customSequence')
end

local minoKey={
    ['1']=1,['2']=2,['3']=3,['4']=4,['5']=5,['6']=6,['7']=7,
    z=1,s=2,j=3,l=4,t=5,o=6,i=7,
    p=10,q=11,f=12,e=13,u=15,
    v=16,w=17,x=18,r=21,y=22,n=23,h=24,
    ['/']=26,c=27,[',']=27,['-']=28,[';']=28,['.']=29,
}
local minoKey2={
    ['1']=8,['2']=9,['3']=19,['4']=20,['5']=14,['7']=25,
    z=8,s=9,t=14,j=19,l=20,i=25,['-']=26,o=29,
}
function scene.keyDown(key)
    if key=='left' then
        local p=cur
        if p==0 then
            cur=#BAG
        else
            repeat
                p=p-1
            until BAG[p]~=BAG[cur]
            cur=p
        end
    elseif key=='right' then
        local p=cur
        if p==#BAG then
            cur=0
        else
            repeat
                p=p+1
            until BAG[p+1]~=BAG[cur+1]
            cur=p
        end
    elseif key=='ten' then
        for _=1,10 do
            local p=cur
            if p==#BAG then break end
            repeat
                p=p+1
            until BAG[p+1]~=BAG[cur+1]
            cur=p
        end
    elseif key=='backspace' then
        if cur>0 then
            rem(BAG,cur)
            cur=cur-1
        end
    elseif key=='delete' then
        if tryReset() then
            TABLE.cut(BAG)
            cur=0
            SFX.play('finesseError',.7)
        end
    elseif key=='=' then
        local l={1,2,3,4,5,6,7}
        repeat scene.keyDown(rem(l,math.random(#l))) until not l[1]
    elseif key=='tab' then
        scene.widgetList.sequence:scroll(kb.isDown('lshift','rshift') and -1 or 1)
    elseif key=='c' and kb.isDown('lctrl','rctrl') or key=='cC' then
        if #BAG>0 then
            sys.setClipboardText("Techmino SEQ:"..DATA.copySequence())
            MES.new('check',text.exportSuccess)
        end
    elseif key=='v' and kb.isDown('lctrl','rctrl') or key=='cV' then
        local str=sys.getClipboardText()
        local p=str:find(":")-- ptr*
        if p then
            if not str:sub(1,p-1):find("SEQ") then
                MES.new('error',text.pasteWrongPlace)
            end
            str=str:sub(p+1)
        end
        if DATA.pasteSequence(str) then
            MES.new('check',text.importSuccess)
            cur=#BAG
        else
            TABLE.cut(BAG)
            cur=0
            MES.new('error',text.dataCorrupted)
        end
    elseif key=='escape' then
        SCN.back()
    elseif type(key)=='number' then
        cur=cur+1
        ins(BAG,cur,key)
    elseif #key==1 then
        key=(kb.isDown('lshift','lalt','rshift','ralt') and minoKey2 or minoKey)[key]
        if key then
            local p=cur+1
            while BAG[p]==key do p=p+1 end
            ins(BAG,p,key)
            cur=p
            SFX.play('lock')
        end
    end
end

local blockCharWidth={} for i=1,#BLOCK_CHARS do blockCharWidth[i]=GC.newText(FONT.get(60),BLOCK_CHARS[i]):getWidth() end
function scene.draw()
    -- Draw frame
    gc_setColor(COLOR.Z)
    GC.setLineWidth(2)
    GC.rectangle('line',100,110,1080,260,5)

    -- Draw sequence
    local BLOCK_COLORS=BLOCK_COLORS
    local skinSetting=SETTING.skin
    local BAG=BAG
    local x,y=120,136-- Next block pos
    local cx,cy=120,136-- Cursor-center pos
    local i,j=1,#BAG
    local count=1
    repeat
        if BAG[i]==BAG[i-1] and i-1~=cur then
            count=count+1
        else
            if count>1 then
                setFont(25)
                gc_setColor(COLOR.Z)
                gc_print("×"..count,x,y-14)
                x=x+(count<10 and 34 or count<100 and 47 or 60)
                count=1
                if i==cur+1 then
                    cx,cy=x,y
                end
            end
            if x>1060 then
                x,y=120,y+40
                if y>1290 then break end
            end
            if i<=j then
                setFont(60)
                gc_setColor(BLOCK_COLORS[skinSetting[BAG[i]]])
                gc_print(BLOCK_CHARS[BAG[i]],x,y-40)
                x=x+blockCharWidth[BAG[i]]
            end
        end

        if i==cur then
            cx,cy=x,y
        end
        i=i+1
    until i>j+1

    -- Draw lenth
    setFont(40)
    gc_setColor(COLOR.Z)
    gc_print(#BAG,120,310)

    -- Draw cursor
    gc_setColor(.5,1,.5,.6+.4*sin(TIME()*6.26))
    GC.line(cx-5,cy-20,cx-5,cy+20)
end

scene.widgetList={
    WIDGET.newText{name='title',x=520,y=5,lim=460,font=70,align='R'},
    WIDGET.newText{name='subTitle',x=530,y=50,lim=170,font=35,align='L',color='H'},

    WIDGET.newSelector{name='sequence',x=1080,y=60,w=200,color='Y',
        list={'bag','bagES','his','hisPool','c2','bagP1inf','rnd','mess','reverb','loop','fixed'},
        disp=CUSval('sequence'),code=CUSsto('sequence')
    },

    WIDGET.newKey{name='Z',     x=120,y=460,w=80,font=90,fText=CHAR.mino.Z,code=pressKey(1)},
    WIDGET.newKey{name='S',     x=200,y=460,w=80,font=90,fText=CHAR.mino.S,code=pressKey(2)},
    WIDGET.newKey{name='J',     x=280,y=460,w=80,font=90,fText=CHAR.mino.J,code=pressKey(3)},
    WIDGET.newKey{name='L',     x=360,y=460,w=80,font=90,fText=CHAR.mino.L,code=pressKey(4)},
    WIDGET.newKey{name='T',     x=440,y=460,w=80,font=90,fText=CHAR.mino.T,code=pressKey(5)},
    WIDGET.newKey{name='O',     x=520,y=460,w=80,font=90,fText=CHAR.mino.O,code=pressKey(6)},
    WIDGET.newKey{name='I',     x=600,y=460,w=80,font=90,fText=CHAR.mino.I,code=pressKey(7)},
    WIDGET.newKey{name='left',  x=680,y=460,w=80,color='lG',font=55,fText=CHAR.key.left,    code=pressKey'left'},
    WIDGET.newKey{name='right', x=760,y=460,w=80,color='lG',font=55,fText=CHAR.key.right,   code=pressKey'right'},
    WIDGET.newKey{name='ten',   x=840,y=460,w=80,color='lG',font=55,fText=CHAR.key.macTab,  code=pressKey'ten'},
    WIDGET.newKey{name='backsp',x=920,y=460,w=80,color='lY',font=55,fText=CHAR.key.backspace,code=pressKey'backspace'},
    WIDGET.newKey{name='reset', x=1000,y=460,w=80,color='lY',font=50,fText=CHAR.icon.trash, code=pressKey'delete'},

    WIDGET.newKey{name='Z5',    x=120,y=550,w=80,color='lH',font=65,fText=CHAR.mino.Z5,     code=pressKey(8)},
    WIDGET.newKey{name='S5',    x=200,y=550,w=80,color='lH',font=65,fText=CHAR.mino.S5,     code=pressKey(9)},
    WIDGET.newKey{name='P',     x=280,y=550,w=80,color='lH',font=65,fText=CHAR.mino.P,      code=pressKey(10)},
    WIDGET.newKey{name='Q',     x=360,y=550,w=80,color='lH',font=65,fText=CHAR.mino.Q,      code=pressKey(11)},
    WIDGET.newKey{name='F',     x=440,y=550,w=80,color='lH',font=65,fText=CHAR.mino.F,      code=pressKey(12)},
    WIDGET.newKey{name='E',     x=520,y=550,w=80,color='lH',font=65,fText=CHAR.mino.E,      code=pressKey(13)},
    WIDGET.newKey{name='T5',    x=600,y=550,w=80,color='lH',font=65,fText=CHAR.mino.T5,     code=pressKey(14)},
    WIDGET.newKey{name='U',     x=680,y=550,w=80,color='lH',font=65,fText=CHAR.mino.U,      code=pressKey(15)},
    WIDGET.newKey{name='V',     x=760,y=550,w=80,color='lH',font=65,fText=CHAR.mino.V,      code=pressKey(16)},
    WIDGET.newKey{name='I3',    x=840,y=550,w=80,color='H',font=90,fText=CHAR.mino.I3,      code=pressKey(26)},
    WIDGET.newKey{name='C',     x=920,y=550,w=80,color='H',font=90,fText=CHAR.mino.C,       code=pressKey(27)},
    WIDGET.newKey{name='rnd',   x=1000,y=550,w=80,color='R',font=70,fText=CHAR.icon.onebag, code=pressKey'='},

    WIDGET.newKey{name='W',     x=120,y=640,w=80,color='lH',font=65,fText=CHAR.mino.W,      code=pressKey(17)},
    WIDGET.newKey{name='X',     x=200,y=640,w=80,color='lH',font=65,fText=CHAR.mino.X,      code=pressKey(18)},
    WIDGET.newKey{name='J5',    x=280,y=640,w=80,color='lH',font=65,fText=CHAR.mino.J5,     code=pressKey(19)},
    WIDGET.newKey{name='L5',    x=360,y=640,w=80,color='lH',font=65,fText=CHAR.mino.L5,     code=pressKey(20)},
    WIDGET.newKey{name='R',     x=440,y=640,w=80,color='lH',font=65,fText=CHAR.mino.R,      code=pressKey(21)},
    WIDGET.newKey{name='Y',     x=520,y=640,w=80,color='lH',font=65,fText=CHAR.mino.Y,      code=pressKey(22)},
    WIDGET.newKey{name='N',     x=600,y=640,w=80,color='lH',font=65,fText=CHAR.mino.N,      code=pressKey(23)},
    WIDGET.newKey{name='H',     x=680,y=640,w=80,color='lH',font=65,fText=CHAR.mino.H,      code=pressKey(24)},
    WIDGET.newKey{name='I5',    x=760,y=640,w=80,color='lH',font=65,fText=CHAR.mino.I5,     code=pressKey(25)},
    WIDGET.newKey{name='I2',    x=840,y=640,w=80,color='dH',font=100,fText=CHAR.mino.I2,    code=pressKey(28)},
    WIDGET.newKey{name='O1',    x=920,y=640,w=80,color='dH',font=100,fText=CHAR.mino.O1,    code=pressKey(29)},


    WIDGET.newButton{name='copy', x=1140,y=460,w=170,h=80,color='lR',font=50,fText=CHAR.icon.export,code=pressKey'cC',hideF=function() return #BAG==0 end},
    WIDGET.newButton{name='paste',x=1140,y=550,w=170,h=80,color='lB',font=50,fText=CHAR.icon.import,code=pressKey'cV'},
    WIDGET.newButton{name='back', x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
