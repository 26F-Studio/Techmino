local gc=love.graphics

local scene={}

function scene.sceneInit()
    BG.set('league')
    BGM.play('exploration')
end

function scene.draw()
    gc.setColor(COLOR.Z)
    setFont(100)
    mStr("Tech League",640,120)
    drawSelfProfile()
    drawOnlinePlayerCount()
end
scene.widgetList={
    WIDGET.newKey{name='setting',x=1200,y=160,w=90,h=90,font=60,fText=CHAR.icon.settings,code=goScene'setting_game'},
    WIDGET.newKey{name='match',x=640,y=500,w=760,h=140,font=60,code=function()MES.new('warn',text.notFinished)end},
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,font=60,sound='back',fText=CHAR.icon.back,code=backScene},
}

return scene
