function keyDown.login(key)
	if key=="return"then
		local email=	WIDGET.active.email.value
		local password=	WIDGET.active.password.value
		if #email==0 or not email:match("^[a-zA-Z0-9_]+@[a-zA-Z0-9_-]+%.[a-zA-Z0-9_]+$") then
			LOG.print(text.wrongEmail)return
		elseif #password==0 then
			LOG.print(text.noPassword)return
		end
		local res=json.encode{
			email=email,
			password=password,
		}
		if res then
			httpRequest(
				TICK.httpREQ_newLogin,
				"/tech/api/v1/users",
				"GET",
				{["Content-Type"]="application/json"},
				res
			)
		end
	elseif key=="escape"then
		SCN.back()
	else
		WIDGET.keyPressed(key)
	end
end

WIDGET.init("login",{
	WIDGET.newText{name="title",		x=80,	y=50,font=70,align="L"},
	WIDGET.newButton{name="register",	x=1140,	y=100,w=170,h=80,color="green",code=function()SCN.swapTo("register","swipeR")end},
	WIDGET.newTextBox{name="email",		x=380,	y=200,w=500,h=60,regex="[0-9A-Za-z@._-]"},
	WIDGET.newTextBox{name="password",	x=380,	y=300,w=626,h=60,secret=true,regex="[ -~]"},
	WIDGET.newButton{name="back",		x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
})