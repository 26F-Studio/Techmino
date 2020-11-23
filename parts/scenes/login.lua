function keyDown.login(key)
	if key=="return"then
		local username=	WIDGET.active.username.value
		local password=	WIDGET.active.password.value
		if #username==0 then
			LOG.print(text.noUsername)return
		elseif #password==0 then
			LOG.print(text.noPassword)return
		end
		local success,data=json.encode({
			username=username,
			password=password,
		})
		if not success then
			LOG.print(text.jsonError,"warn")
			return
		end
		httpRequest(
			TICK.httpREQ_login,
			"/tech/api/v1/users",
			"GET",
			{["Content-Type"]="application/json"},
			data
		)
	elseif key=="escape"then
		SCN.back()
	else
		WIDGET.keyPressed(key)
	end
end

WIDGET.init("login",{
	WIDGET.newText{name="title",		x=80,	y=50,font=70,align="L"},
	WIDGET.newButton{name="register",	x=1140,	y=100,w=170,h=80,color="green",code=function()SCN.swapTo("register","swipeR")end},
	WIDGET.newTextBox{name="username",	x=380,	y=200,w=500,h=60,regex="[0-9A-Za-z_]"},
	WIDGET.newTextBox{name="password",	x=380,	y=300,w=626,h=60,secret=true,regex="[ -~]"},
	WIDGET.newButton{name="back",		x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
})