local gc=love.graphics
local kb=love.keyboard

local instList={'lead','bell','bass'}
local keys={
    ['1']=61,['2']=63,['3']=65,['4']=66,['5']=68,['6']=70,['7']=72,['8']=73,['9']=75,['0']=77,['-']=78,['=']=80,['backspace']=82,
    ['q']=49,['w']=51,['e']=53,['r']=54,['t']=56,['y']=58,['u']=60,['i']=61,['o']=63,['p']=65,['[']=66,[']']=68,['\\']=70,
    ['a']=37,['s']=39,['d']=41,['f']=42,['g']=44,['h']=46,['j']=48,['k']=49,['l']=51,[';']=53,["'"]=54,['return']=56,
    ['z']=25,['x']=27,['c']=29,['v']=30,['b']=32,['n']=34,['m']=36,[',']=37,['.']=39,['/']=41,
}
local inst
local offset

local scene={}

function scene.enter()
    inst='lead'
    offset=0
end

function scene.touchDown(x,y,k)
    -- TODO
end
scene.mouseDown=scene.touchDown

function scene.keyDown(key,isRep)
    if not isRep and keys[key] then
        local note=keys[key]+offset
        if kb.isDown('lshift','rshift') then note=note+1 end
        if kb.isDown('lctrl','rctrl') then note=note-1 end
        SFX.playSample(inst,note)
        TEXT.show(SFX.getNoteName(note),math.random(150,1130),math.random(140,500),60,'score',.8)
    elseif key=='tab' then
        inst=TABLE.next(instList,inst)
    elseif key=='lalt' then
        offset=math.max(offset-1,-12)
    elseif key=='ralt' then
        offset=math.min(offset+1,12)
    elseif key=='escape' then
        SCN.back()
    end
end

function scene.draw()
    setFont(30)
    gc.print(inst,40,60)
    gc.print(offset,40,100)
end

scene.widgetList={
    WIDGET.newButton{name='back', x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},

    -- Number row:  01234567890-=
    WIDGET.newKey   {name='key1' ,x= 115,y=231,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='key2' ,x= 210,y=231,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='key3' ,x= 305,y=231,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='key4' ,x= 400,y=231,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='key5' ,x= 495,y=231,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='key6' ,x= 590,y=231,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='key7' ,x= 685,y=231,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='key8' ,x= 780,y=231,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='key9' ,x= 875,y=231,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='key0' ,x= 970,y=231,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='key01',x=1065,y=231,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='key02',x=1160,y=231,w=80 ,h=80 ,sound=false ,fText=''},

    -- Top row:     QWERTYUIOP[]\
    WIDGET.newKey   {name='keyQ' ,x=  65,y=326,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyW' ,x= 160,y=326,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyE' ,x= 255,y=326,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyR' ,x= 350,y=326,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyT' ,x= 445,y=326,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyY' ,x= 540,y=326,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyU' ,x= 635,y=326,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyI' ,x= 730,y=326,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyO' ,x= 825,y=326,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyP' ,x= 920,y=326,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyP1',x=1015,y=326,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyP2',x=1110,y=326,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyP3',x=1205,y=326,w=80 ,h=80 ,sound=false ,fText=''},

    -- Home row     ASDFGHJKL;''<ENTER>
    WIDGET.newKey   {name='keyA' ,x= 115,y=421,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyS' ,x= 210,y=421,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyD' ,x= 305,y=421,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyF' ,x= 400,y=421,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyG' ,x= 495,y=421,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyH' ,x= 590,y=421,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyJ' ,x= 685,y=421,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyK' ,x= 780,y=421,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyL' ,x= 875,y=421,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyL1',x= 970,y=421,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyL2',x=1065,y=421,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyEn',x=1160,y=421,w=80 ,h=80 ,sound=false ,fText=''},

    -- Bottom row   ZXCVBNM,./
    WIDGET.newKey   {name='keyZ' ,x= 196,y=516,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyX' ,x= 291,y=516,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyC' ,x= 386,y=516,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyV' ,x= 481,y=516,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyB' ,x= 576,y=516,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyN' ,x= 671,y=516,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyM' ,x= 766,y=516,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyM1',x= 861,y=516,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyM2',x= 956,y=516,w=80 ,h=80 ,sound=false ,fText=''},
    WIDGET.newKey   {name='keyM3',x=1051,y=516,w=80 ,h=80 ,sound=false ,fText=''},
}
return scene
