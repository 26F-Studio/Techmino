function keyDown.login(key)
	if key=="return"then
		local username=	WIDGET.active.username.value
		local email=	WIDGET.active.email.value
		local code=		WIDGET.active.code.value
		local password=	WIDGET.active.password.value
		local password2=WIDGET.active.password2.value
		if #username==0 then
			LOG.print(text.noUsername)return
		elseif #email~=#email:match("^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$")then
			LOG.print(text.wrongEmail)return
		elseif #password==0 or #password2==0 then
			LOG.print(text.noPassword)return
		elseif password~=password2 then
			LOG.print(text.diffPassword)return
		end
		httpRequest(
			TICK.httpREQ_register,
			"api/account/register",
			"POST",
			{["Content-Type"]="application/json"},
			json.encode({
				username=username,
				email=email,
				password=password,
				code=code,
			})
		)
	elseif key=="escape"then
		SCN.back()
	else
		WIDGET.keyPressed(key)
	end
end

WIDGET.init("login",{
	WIDGET.newText({name="title",		x=80,	y=50,font=70,align="L"}),
	WIDGET.newTextBox({name="username",	x=380,	y=160,w=500,h=60,regex="[0-9A-Za-z_]"}),
	WIDGET.newTextBox({name="email",	x=380,	y=260,w=626,h=60,regex="[0-9A-Za-z@-._]"}),
	WIDGET.newTextBox({name="code",		x=380,	y=360,w=626,h=60,regex="[0-9A-Za-z]"}),
	WIDGET.newTextBox({name="password",	x=380,	y=460,w=626,h=60,secret=true,regex="[ -~]"}),
	WIDGET.newTextBox({name="password2",x=380,	y=560,w=626,h=60,secret=true,regex="[ -~]"}),
	WIDGET.newButton({name="back",		x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk.BACK}),
})