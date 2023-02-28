local gc=love.graphics
local int=math.floor
local sin=math.sin

local selRS
local minoRot={0,0,0,0,0,0,0}
local minoRot0={}
local selEggMode

local playEgg=WIDGET.newButton{name='playEgg',  x=1140,y=540,w=140,h=65,color='lP',font=60,fText=CHAR.icon.rankZ,code=function() loadGame(selEggMode,true) end}

local scene={}

function scene.enter()
    selEggMode=false
    scene.widgetList.playEgg.hide=true
    BG.set()
    selRS=RSlist[SETTING.RS]
    for i=1,7 do
        minoRot0[i]=SETTING.face[i]*1.57
        minoRot[i]=minoRot0[i]
    end
end

function scene.update(dt)
    for i=1,7 do
        minoRot[i]=MATH.expApproach(minoRot[i],minoRot0[i],dt*12)
    end
end
function scene.draw()
    local t=TIME()
    gc.setColor(1,1,1)
    local texture=SKIN.lib[SETTING.skinSet]
    for n=1,7 do
        gc.push('transform')
        gc.translate(-10+140*n,330)
        gc.rotate(minoRot[n]+sin(t*3-n*.5)*.08)
        local color=SETTING.skin[n]
        local B=BLOCKS[n][0]
        local x,y=-45-selRS.centerPos[n][0][2]*30,15+selRS.centerPos[n][0][1]*30
        local col=#B[1]
        for i=1,#B do for j=1,col do
            if B[i][j] then
                gc.draw(texture[color],x+30*j,y-30*i)
            end
        end end
        if selRS.centerDisp[n] then
            mDraw(selRS.centerTex)
        end
        gc.pop()
    end
    for i=1,5 do
        gc.draw(texture[19+i],570+60*i,610+sin(2.6*t-i)*5,nil,2)
    end
    gc.draw(texture[17],930,610+sin(2.6*t-6)*5,nil,2)
end

local function _prevSkin(i)
    SETTING.skin[i]=(SETTING.skin[i]-2)%16+1
end
local function _nextSkin(i)
    SETTING.skin[i]=SETTING.skin[i]%16+1
end
local function _nextDir(i)
    trySettingWarn()
    SETTING.face[i]=(SETTING.face[i]+1)%4
    minoRot0[i]=minoRot0[i]+1.5707963
    if not selEggMode and not GAME.playing then
        if minoRot0[5]>62 then
            selEggMode='marathon_bfmax'
            playEgg.color=COLOR.dR
        elseif minoRot0[6]>62 then
            selEggMode='techrash_n'
            playEgg.color=COLOR.lP
        elseif minoRot0[7]>62 then
            selEggMode='techrash_u'
            playEgg.color=COLOR.lY
        end
        playEgg.hide=not selEggMode
    end
end

scene.widgetList={
    WIDGET.newText{name='title',      x=80,y=50,lim=500,font=70,align='L'},

    WIDGET.newSelector{name='skinSet',x=780,y=100,w=320,list=SKIN.getList(),disp=SETval('skinSet'),code=SETsto('skinSet')},
    WIDGET.newButton{name='prev1',    x=130,y=220,w=80,h=65,sound='hold',font=40,fText="↑",code=function() _prevSkin(1) end},
    WIDGET.newButton{name='prev2',    x=270,y=220,w=80,h=65,sound='hold',font=40,fText="↑",code=function() _prevSkin(2) end},
    WIDGET.newButton{name='prev3',    x=410,y=220,w=80,h=65,sound='hold',font=40,fText="↑",code=function() _prevSkin(3) end},
    WIDGET.newButton{name='prev4',    x=550,y=220,w=80,h=65,sound='hold',font=40,fText="↑",code=function() _prevSkin(4) end},
    WIDGET.newButton{name='prev5',    x=690,y=220,w=80,h=65,sound='hold',font=40,fText="↑",code=function() _prevSkin(5) end},
    WIDGET.newButton{name='prev6',    x=830,y=220,w=80,h=65,sound='hold',font=40,fText="↑",code=function() _prevSkin(6) end},
    WIDGET.newButton{name='prev7',    x=970,y=220,w=80,h=65,sound='hold',font=40,fText="↑",code=function() _prevSkin(7) end},

    WIDGET.newButton{name='next1',    x=130,y=440,w=80,h=65,sound='hold',font=40,fText="↓",code=function() _nextSkin(1) end},
    WIDGET.newButton{name='next2',    x=270,y=440,w=80,h=65,sound='hold',font=40,fText="↓",code=function() _nextSkin(2) end},
    WIDGET.newButton{name='next3',    x=410,y=440,w=80,h=65,sound='hold',font=40,fText="↓",code=function() _nextSkin(3) end},
    WIDGET.newButton{name='next4',    x=550,y=440,w=80,h=65,sound='hold',font=40,fText="↓",code=function() _nextSkin(4) end},
    WIDGET.newButton{name='next5',    x=690,y=440,w=80,h=65,sound='hold',font=40,fText="↓",code=function() _nextSkin(5) end},
    WIDGET.newButton{name='next6',    x=830,y=440,w=80,h=65,sound='hold',font=40,fText="↓",code=function() _nextSkin(6) end},
    WIDGET.newButton{name='next7',    x=970,y=440,w=80,h=65,sound='hold',font=40,fText="↓",code=function() _nextSkin(7) end},

    WIDGET.newButton{name='spin1',    x=130,y=540,w=80,h=65,sound='rotate',font=40,code=function() _nextDir(1) end,fText=CHAR.icon.retry_spin},
    WIDGET.newButton{name='spin2',    x=270,y=540,w=80,h=65,sound='rotate',font=40,code=function() _nextDir(2) end,fText=CHAR.icon.retry_spin},
    WIDGET.newButton{name='spin3',    x=410,y=540,w=80,h=65,sound='rotate',font=40,code=function() _nextDir(3) end,fText=CHAR.icon.retry_spin},
    WIDGET.newButton{name='spin4',    x=550,y=540,w=80,h=65,sound='rotate',font=40,code=function() _nextDir(4) end,fText=CHAR.icon.retry_spin},
    WIDGET.newButton{name='spin5',    x=690,y=540,w=80,h=65,sound='rotate',font=40,code=function() _nextDir(5) end,fText=CHAR.icon.retry_spin},
    WIDGET.newButton{name='spin6',    x=825,y=540,w=80,h=65,sound='rotate',font=40,code=function() _nextDir(6) end,fText=CHAR.icon.retry_spin},
    WIDGET.newButton{name='spin7',    x=970,y=540,w=80,h=65,sound='rotate',font=40,code=function() _nextDir(7) end,fText=CHAR.icon.retry_spin},

    WIDGET.newButton{name='skinR',    x=200,y=640,w=220,h=80,color='lV',font=35,sound='back',
        code=function()
            SETTING.skin={1,7,11,3,14,4,9,1,7,2,6,10,2,13,5,9,15,10,11,3,10,2,16,8,4,10,13,2,8}
            SFX.play('rotate')
        end},
    WIDGET.newButton{name='faceR',    x=480,y=640,w=220,h=80,color='lR',font=35,sound='back',
        code=function()
            for i=1,29 do
                SETTING.face[i]=0
            end
            for i=1,7 do
                minoRot0[i]=(int(minoRot0[i]/6.2831853)+(minoRot0[i]%6.2831853>4 and 1 or 0))*6.2831853
            end
            SFX.play('hold')
        end},
    WIDGET.newButton{name='back',     x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
    playEgg,
}

return scene
