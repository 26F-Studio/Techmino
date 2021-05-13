local scene={}

local function register()
	local username=	WIDGET.active.username:getText()
	local email=	WIDGET.active.email:getText()
	local password=	WIDGET.active.password:getText()
	local password2=WIDGET.active.password2:getText()
	if #username==0 then
		LOG.print(text.noUsername)return
	elseif not STRING.simpEmailCheck(email)then
		LOG.print(text.wrongEmail)return
	elseif #password==0 or #password2==0 then
		LOG.print(text.noPassword)return
	elseif password~=password2 then
		LOG.print(text.diffPassword)return
	end
	NET.register(username,email,password)
end

scene.widgetList={
	WIDGET.newText{name="title",		x=80,	y=50,font=70,align='L'},
	WIDGET.newButton{name="login",		x=1140,	y=100,w=170,h=80,color='lY',code=function()SCN.swapTo('login','swipeL')end},
	WIDGET.newInputBox{name="username",	x=380,	y=200,w=500,h=60,regex="[0-9A-Za-z_]"},
	WIDGET.newInputBox{name="email",	x=380,	y=300,w=626,h=60},
	WIDGET.newInputBox{name="password",	x=380,	y=400,w=626,h=60,secret=true,regex="[ -~]"},
	WIDGET.newInputBox{name="password2",x=380,	y=500,w=626,h=60,secret=true,regex="[ -~]"},
	WIDGET.newKey{name="register",		x=1140,	y=540,w=170,h=80,font=40,code=register},
	WIDGET.newButton{name="back",		x=1140,	y=640,w=170,h=80,font=40,code=backScene},
}

return scene