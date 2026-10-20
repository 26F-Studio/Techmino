local scene={}
function scene.keyDown(key,rep)
    if rep then return true end
    if key=='escape' then SCN.back() elseif key=='return' or key=='kpenter' then NET.website('/account/recover') end
end
function scene.draw()
    FONT.set(32)
    love.graphics.setColor(1,1,1)
    love.graphics.printf('Password recovery is managed by the account website.\nA verified reset revokes product sessions on every device.\nTechmino never handles your account password or reset-mail token.',70,190,1130,'center')
end
scene.widgetList={
    WIDGET.newText{x=70,y=65,align='L',font=50,fText='Account password recovery'},
    WIDGET.newButton{x=640,y=480,w=620,h=110,font=32,fText='Open account recovery website',code=function() NET.website('/account/recover') end},
    WIDGET.newButton{name='back',x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}
return scene
