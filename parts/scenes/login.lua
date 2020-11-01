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