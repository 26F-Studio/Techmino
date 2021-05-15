local emailBox=WIDGET.newInputBox{name="email",x=380,y=200,w=500,h=60}
local passwordBox=WIDGET.newInputBox{name="password",x=380,y=300,w=620,h=60,secret=true,regex="[ -~]"}

local savePW=false

local function login()
	local email,password=emailBox:getText(),passwordBox:getText()
	if not STRING.simpEmailCheck(email)then
		LOG.print(text.wrongEmail,'warn')return
	elseif #password==0 then
		LOG.print(text.noPassword,'warn')return
	end
	NET.wsconn_user_pswd(email,password)
	if savePW then
		FILE.save({email,password},"conf/account",'q')
	else
		if love.filesystem.getInfo("conf/account")then
			love.filesystem.remove("conf/account")
		end
	end
end

local scene={}

function scene.sceneInit()
	local data=FILE.load("conf/account")
	if data then
		savePW=true
		emailBox:setText(data[1])
		passwordBox:setText(data[2])
	end
end

scene.widgetList={
	WIDGET.newText{name="title",		x=80,	y=50,font=70,align='L'},
	WIDGET.newButton{name="register",	x=1140,	y=100,w=170,h=80,color='lY',code=function()SCN.swapTo('register','swipeR')end},
	emailBox,
	passwordBox,
	WIDGET.newSwitch{name="keepPW",		x=900,y=420,disp=function()return savePW end,code=function()savePW=not savePW end},
	WIDGET.newKey{name="login",			x=1140,	y=540,w=170,h=80,font=40,code=login},
	WIDGET.newButton{name="back",		x=1140,	y=640,w=170,h=80,font=40,code=backScene},
}

return scene