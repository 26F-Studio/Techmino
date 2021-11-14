local gc=love.graphics
local kb=love.keyboard

local instList={'lead','bell','bass'}
local keys={
    ['1']='C6',['2']='D6',['3']='E6',['4']='F6',['5']='G6',['6']='A6',['7']='B6',['8']='C7',['9']='D7',['0']='E7',['-']='F7',['=']='G7',
    ['q']='C5',['w']='D5',['e']='E5',['r']='F5',['t']='G5',['y']='A5',['u']='B5',['i']='C6',['o']='D6',['p']='E6',['[']='F6',[']']='G6',['\\']='A6',
    ['a']='C4',['s']='D4',['d']='E4',['f']='F4',['g']='G4',['h']='A4',['j']='B4',['k']='C5',['l']='D5',[';']='E5',["'"]='F5',
    ['z']='C3',['x']='D3',['c']='E3',['v']='F3',['b']='G3',['n']='A3',['m']='B3',[',']='C4',['.']='D4',['/']='E4',
}
local inst

local scene={}

function scene.sceneInit()
    inst='lead'
end

function scene.touchDown(x,y,k)

end
scene.mouseDown=scene.touchDown

function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='tab'then
        inst=TABLE.next(instList,inst)
    else
        local note=keys[key]
        if note then
            if kb.isDown('lshift','rshift')then note=note:sub(1,1)..'#'..note:sub(2,2)end
            SFX.playSample(inst,note)
            TEXT.show(note,math.random(150,1130),math.random(140,500),60,'score',.8)
        end
    end
end

function scene.update(dt)

end

function scene.draw()
    setFont(30)
    gc.print(inst,40,60)
end

scene.widgetList={
    WIDGET.newButton{name="back", x=1140,y=640,w=170,h=80,fText=CHAR.icon.back,code=backScene},
}
return scene
