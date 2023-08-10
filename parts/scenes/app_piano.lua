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
local showingKey

-- PREPARE VIRTUAL KEYS
-- PREPARE VIRTUAL KEYS
-- NOTE: I made this list because I want to use WIDGET.draw() and don't need another function
-- I will handling the behavior in an other function
local virtualKeys={
    -- Number row:  01234567890-=           13
    WIDGET.newKey   {name='key1'        ,x=  65,y=231,w=75 ,h=80,sound=false ,font=40,fText='',color='R',code=pressKey'1'        },
    WIDGET.newKey   {name='key2'        ,x= 160,y=231,w=75 ,h=80,sound=false ,font=40,fText='',color='M',code=pressKey'2'        },
    WIDGET.newKey   {name='key3'        ,x= 255,y=231,w=75 ,h=80,sound=false ,font=40,fText='',color='V',code=pressKey'3'        },
    WIDGET.newKey   {name='key4'        ,x= 350,y=231,w=75 ,h=80,sound=false ,font=40,fText='',color='S',code=pressKey'4'        },
    WIDGET.newKey   {name='key5'        ,x= 445,y=231,w=75 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey'5'        },
    WIDGET.newKey   {name='key6'        ,x= 540,y=231,w=75 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey'6'        },
    WIDGET.newKey   {name='key7'        ,x= 635,y=231,w=75 ,h=80,sound=false ,font=40,fText='',color='O',code=pressKey'7'        },
    WIDGET.newKey   {name='key8'        ,x= 730,y=231,w=75 ,h=80,sound=false ,font=40,fText='',color='L',code=pressKey'8'        },
    WIDGET.newKey   {name='key9'        ,x= 825,y=231,w=75 ,h=80,sound=false ,font=40,fText='',color='G',code=pressKey'9'        },
    WIDGET.newKey   {name='key0'        ,x= 920,y=231,w=75 ,h=80,sound=false ,font=40,fText='',color='C',code=pressKey'0'        },
    WIDGET.newKey   {name='key-'        ,x=1015,y=231,w=75 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey'-'        },
    WIDGET.newKey   {name='key='        ,x=1110,y=231,w=75 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey'='        },
    WIDGET.newKey   {name='keyBACKSPACE',x=1205,y=231,w=75 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey'backspace'},

    -- Top row:     QWERTYUIOP[]\           13
    WIDGET.newKey   {name='keyQ'        ,x=  65,y=326,w=75 ,h=80,sound=false ,font=40,fText='',color='R',code=pressKey'q' },
    WIDGET.newKey   {name='keyW'        ,x= 160,y=326,w=75 ,h=80,sound=false ,font=40,fText='',color='M',code=pressKey'w' },
    WIDGET.newKey   {name='keyE'        ,x= 255,y=326,w=75 ,h=80,sound=false ,font=40,fText='',color='V',code=pressKey'e' },
    WIDGET.newKey   {name='keyR'        ,x= 350,y=326,w=75 ,h=80,sound=false ,font=40,fText='',color='S',code=pressKey'r' },
    WIDGET.newKey   {name='keyT'        ,x= 445,y=326,w=75 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey't' },
    WIDGET.newKey   {name='keyY'        ,x= 540,y=326,w=75 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey'y' },
    WIDGET.newKey   {name='keyU'        ,x= 635,y=326,w=75 ,h=80,sound=false ,font=40,fText='',color='O',code=pressKey'u' },
    WIDGET.newKey   {name='keyI'        ,x= 730,y=326,w=75 ,h=80,sound=false ,font=40,fText='',color='L',code=pressKey'i' },
    WIDGET.newKey   {name='keyO'        ,x= 825,y=326,w=75 ,h=80,sound=false ,font=40,fText='',color='G',code=pressKey'o' },
    WIDGET.newKey   {name='keyP'        ,x= 920,y=326,w=75 ,h=80,sound=false ,font=40,fText='',color='C',code=pressKey'p' },
    WIDGET.newKey   {name='key['        ,x=1015,y=326,w=75 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey'[' },
    WIDGET.newKey   {name='key]'        ,x=1110,y=326,w=75 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey']' },
    WIDGET.newKey   {name='key\\'       ,x=1205,y=326,w=75 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey'\\'},

    -- Home row     ASDFGHJKL;''<ENTER>     12
    WIDGET.newKey   {name='keyA'        ,x= 110,y=421,w=80 ,h=80,sound=false ,font=40,fText='',color='R',code=pressKey'a'     },
    WIDGET.newKey   {name='keyS'        ,x= 205,y=421,w=80 ,h=80,sound=false ,font=40,fText='',color='M',code=pressKey's'     },
    WIDGET.newKey   {name='keyD'        ,x= 300,y=421,w=80 ,h=80,sound=false ,font=40,fText='',color='V',code=pressKey'd'     },
    WIDGET.newKey   {name='keyF'        ,x= 395,y=421,w=80 ,h=80,sound=false ,font=40,fText='',color='S',code=pressKey'f'     },
    WIDGET.newKey   {name='keyG'        ,x= 490,y=421,w=80 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey'g'     },
    WIDGET.newKey   {name='keyH'        ,x= 585,y=421,w=80 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey'h'     },
    WIDGET.newKey   {name='keyJ'        ,x= 680,y=421,w=80 ,h=80,sound=false ,font=40,fText='',color='O',code=pressKey'j'     },
    WIDGET.newKey   {name='keyK'        ,x= 775,y=421,w=80 ,h=80,sound=false ,font=40,fText='',color='L',code=pressKey'k'     },
    WIDGET.newKey   {name='keyL'        ,x= 870,y=421,w=80 ,h=80,sound=false ,font=40,fText='',color='G',code=pressKey'l'     },
    WIDGET.newKey   {name='key;'        ,x= 965,y=421,w=80 ,h=80,sound=false ,font=40,fText='',color='C',code=pressKey';'     },
    WIDGET.newKey   {name='key\''       ,x=1060,y=421,w=80 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey'\''    },
    WIDGET.newKey   {name='keyRETURN'   ,x=1155,y=421,w=80 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey'return'},

    -- Bottom row   ZXCVBNM,./              10
    WIDGET.newKey   {name='keyZ'        ,x= 205,y=516,w=80 ,h=80,sound=false ,font=40,fText='',color='R',code=pressKey'z'},
    WIDGET.newKey   {name='keyX'        ,x= 300,y=516,w=80 ,h=80,sound=false ,font=40,fText='',color='M',code=pressKey'x'},
    WIDGET.newKey   {name='keyC'        ,x= 395,y=516,w=80 ,h=80,sound=false ,font=40,fText='',color='V',code=pressKey'c'},
    WIDGET.newKey   {name='keyV'        ,x= 490,y=516,w=80 ,h=80,sound=false ,font=40,fText='',color='S',code=pressKey'v'},
    WIDGET.newKey   {name='keyB'        ,x= 585,y=516,w=80 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey'b'},
    WIDGET.newKey   {name='keyN'        ,x= 680,y=516,w=80 ,h=80,sound=false ,font=40,fText='',color='Z',code=pressKey'n'},
    WIDGET.newKey   {name='keyM'        ,x= 775,y=516,w=80 ,h=80,sound=false ,font=40,fText='',color='O',code=pressKey'm'},
    WIDGET.newKey   {name='key,'        ,x= 870,y=516,w=80 ,h=80,sound=false ,font=40,fText='',color='L',code=pressKey','},
    WIDGET.newKey   {name='key.'        ,x= 965,y=516,w=80 ,h=80,sound=false ,font=40,fText='',color='G',code=pressKey'.'},
    WIDGET.newKey   {name='key/'        ,x=1060,y=516,w=80 ,h=80,sound=false ,font=40,fText='',color='C',code=pressKey'/'},
}
setmetatable(virtualKeys,{__index=function(L,k) for i=1,#L do if L[i].name==k then return L[i] end end end})
--/ PREPARE VIRTUAL KEYS
--/ PREPARE VIRTUAL KEYS

local scene={}

-- Set all virtual key's text
local function _setNoteName(offset)
    for key,note in pairs(keys) do
        virtualKeys['key'..key:upper()]:setObject(SFX.getNoteName(note+offset))
    end
end
-- Show virtual key
local function _showVirtualKey(switch)
    for key,note in pairs(keys) do
        virtualKeys['key'..key:upper()].hide=not switch
    end
    showingKey=switch
end


-- Set scene's variables
function scene.enter()
    inst='lead'
    offset=0
    _setNoteName(0)
    _showVirtualKey(MOBILE and true or false)
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
        _setNoteName(offset)
    elseif key=='ralt' then
        offset=math.min(offset+1,12)
        _setNoteName(offset)
    elseif key=='escape' then
        SCN.back()
    end
end

function scene.draw()
    setFont(30)
    GC.setColor(1,1,1)
    gc.print(inst,40,60)
    gc.print(offset,40,100)

    if showingKey then
        for key,note in pairs(keys) do
            virtualKeys['key'..key:upper()]:draw()
        end
    end
end

scene.widgetList={
    WIDGET.newButton{name='back'        ,x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
    WIDGET.newSwitch{name='showKey'     ,x=1180,y=100,fText='Virtual key',disp=function() return showingKey end,code=function() _showVirtualKey(not showingKey) end},
}
return scene
