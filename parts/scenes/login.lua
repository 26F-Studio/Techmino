local scene={}
local issuer=WIDGET.newInputBox{x=250,y=125,w=960,h=50,font=24,limit=2048}
local cadence=WIDGET.newInputBox{x=250,y=225,w=960,h=50,font=24,limit=2048}
local website=WIDGET.newInputBox{x=250,y=325,w=960,h=50,font=24,limit=2048}
local function configure()
    return NET.configure{tesseraOrigin=STRING.trim(issuer:getText()),cadenceOrigin=STRING.trim(cadence:getText()),websiteOrigin=STRING.trim(website:getText()),webRedirectUri=NET.session.config.webRedirectUri}
end
local function authorize()
    if NET.session.login then return end
    if configure() then NET.beginLogin() end
end
function scene.enter()
    local config=NET.session.config
    issuer:setText(config.tesseraOrigin or '')
    cadence:setText(config.cadenceOrigin or '')
    website:setText(config.websiteOrigin or '')
end
function scene.leave()
    if NET.session.login then NET.cancelLogin() end
end
function scene.keyDown(key,rep)
    if rep then return true end
    if key=='escape' then NET.cancelLogin() SCN.back()
    elseif key=='return' or key=='kpenter' then authorize()
    else return true end
end
function scene.update()
    if NET.session:isAuthenticated() and not SCN.swapping then SCN.swapTo('net_menu','swipeL') end
end
function scene.draw()
    FONT.set(24)
    love.graphics.setColor(1,1,1)
    love.graphics.printf('The system browser handles passwords, email verification and consent.\nNo account password, pasted ticket or refresh credential is entered here.',45,400,1170,'left')
    love.graphics.printf('Authorization: '..NET.session.status..' / connection: '..NET.connectionState,45,478,1170,'left')
    love.graphics.printf(NET.session:storageNotice(),45,514,1170,'left')
    if NET.session.error then
        love.graphics.setColor(1,.45,.4)
        love.graphics.printf(NET.session.error.code..': '..NET.session.error.message,45,558,1170,'left')
    end
end
scene.widgetList={
    WIDGET.newText{x=45,y=35,align='L',font=45,fText='Techmino product login'},
    WIDGET.newText{x=45,y=135,align='L',font=24,fText='Tessera API'},issuer,
    WIDGET.newText{x=45,y=235,align='L',font=24,fText='Cadence API'},cadence,
    WIDGET.newText{x=45,y=335,align='L',font=24,fText='Account website'},website,
    WIDGET.newButton{x=235,y=645,w=350,h=75,font=28,fText='Sign in with browser',code=authorize,hideF=function() return NET.session.login~=false end},
    WIDGET.newButton{x=235,y=645,w=350,h=75,font=28,fText='Cancel authorization',code=NET.cancelLogin,hideF=function() return NET.session.login==false end},
    WIDGET.newButton{x=615,y=645,w=350,h=75,font=26,fText='Account / recovery',code=function() if configure() then NET.website('/account') end end},
    WIDGET.newButton{name='back',x=1140,y=645,w=170,h=75,sound='back',font=60,fText=CHAR.icon.back,code=pressKey'escape'},
}
return scene
