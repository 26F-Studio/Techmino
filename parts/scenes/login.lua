local function login()
	local email=	WIDGET.active.email.value
	local password=	WIDGET.active.password.value
	if #email==0 or not email:match("^[a-zA-Z0-9_]+@[a-zA-Z0-9_-]+%.[a-zA-Z0-9_]+$")then
		LOG.print(text.wrongEmail)return
	elseif #password==0 then
		LOG.print(text.noPassword)return
	end
	--[[TODO
		json.encode{
			email=email,
			password=password,
		}
	]]
end

local scene={}

scene.widgetList={
	WIDGET.newText{name="title",		x=80,	y=50,font=70,align="L"},
	-- WIDGET.newButton{name="register",	x=1140,	y=100,w=170,h=80,color="green",code=function()SCN.swapTo("register","swipeR")end},
	WIDGET.newInputBox{name="email",		x=380,	y=200,w=500,h=60,regex="[0-9A-Za-z@._-]"},
	WIDGET.newInputBox{name="password",	x=380,	y=300,w=626,h=60,secret=true,regex="[ -~]"},
	WIDGET.newKey{name="login",			x=1140,	y=540,w=170,h=80,font=40,code=login},
	WIDGET.newButton{name="back",		x=1140,	y=640,w=170,h=80,font=40,code=backScene},
}

return scene