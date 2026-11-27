local scene={}
local logoutUntil=0
local function logout()
    if love.timer.getTime()<logoutUntil then
        logoutUntil=0
        NET.logout(function() SCN.backTo('main') end)
    else logoutUntil=love.timer.getTime()+2 MES.new('warn','Press again within two seconds to revoke this Techmino device grant.',2) end
end
function scene.enter()
    BG.set()
    DiscordRPC.update('Online lobby')
    if not NET.session:isAuthenticated() then SCN.swapTo('login','swipeR') elseif NET.connectionState~='ready' then NET.connect() end
end
function scene.draw()
    drawSelfProfile()
    drawNetworkStatus()
    FONT.set(22)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(NET.session:storageNotice(),40,550,1000,'left')
    love.graphics.printf('Product: techmino / device grant: '..tostring(NET.session.grantId or '--'),40,610,1000,'left')
end
scene.widgetList={
    WIDGET.newKey{name='setting',x=1200,y=160,w=90,h=90,code=goScene'setting_game',font=60,fText=CHAR.icon.settings},
    WIDGET.newButton{name='galaxim',x=640,y=215,w=350,h=110,font=40,color='D',code=goScene'net_galaxim'},
    WIDGET.newButton{name='rooms',x=640,y=350,w=350,h=110,font=40,code=goScene'net_rooms',hideF=function() return NET.connectionState~='ready' end},
    WIDGET.newButton{x=245,y=350,w=350,h=85,font=28,fText='Return to current room',code=goScene'net_game',hideF=function() return NET.roomStore.snapshot==false end},
    WIDGET.newButton{x=365,y=480,w=360,h=85,font=28,fText='Account / sessions',code=function() NET.website('/account') end},
    WIDGET.newButton{x=760,y=480,w=360,h=85,font=28,fText='Cloud save versions',code=goScene'cloud'},
    WIDGET.newButton{name='logout',x=760,y=40,w=250,h=60,color='dR',font=25,code=logout},
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}
return scene
