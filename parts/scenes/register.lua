local function tick_httpREQ_register(task)
	local time=0
	while true do
		coroutine.yield()
		local response,request_error=client.poll(task)
		if response then
			local res=json.decode(response.body)
			if res then
				if response.code==200 then
					LOG.print(text.registerSuccessed..": "..res.message)
				else
					LOG.print(text.netErrorCode..response.code..": "..res.message,"warn")
				end
			end
			return
		elseif request_error then
			LOG.print(text.loginFailed..": "..request_error,"warn")
			return
		end
		time=time+1
		if time>360 then
			LOG.print(text.httpTimeout,"message")
			return
		end
	end
end

local scene={}

function scene.keyDown(key)
	if key=="return"then
		local username=	WIDGET.active.username.value
		local email=	WIDGET.active.email.value
		local password=	WIDGET.active.password.value
		local password2=WIDGET.active.password2.value
		if #username==0 then
			LOG.print(text.noUsername)return
		elseif not email:match("^[a-zA-Z0-9_]+@[a-zA-Z0-9_-]+%.[a-zA-Z0-9_]+$")then
			LOG.print(text.wrongEmail)return
		elseif #password==0 or #password2==0 then
			LOG.print(text.noPassword)return
		elseif password~=password2 then
			LOG.print(text.diffPassword)return
		end
		httpRequest(
			tick_httpREQ_register,
			PATH.api..PATH.auth,
			"POST",
			{["Content-Type"]="application/json"},
			json.encode{
				username=username,
				email=email,
				password=password,
			}
		)
	elseif key=="escape"then
		SCN.back()
	else
		WIDGET.keyPressed(key)
	end
end

scene.widgetList={
	WIDGET.newText{name="title",		x=80,	y=50,font=70,align="L"},
	WIDGET.newButton{name="login",		x=1140,	y=100,w=170,h=80,color="green",code=function()SCN.swapTo("login","swipeL")end},
	WIDGET.newTextBox{name="username",	x=380,	y=200,w=500,h=60,regex="[0-9A-Za-z_]"},
	WIDGET.newTextBox{name="email",		x=380,	y=300,w=626,h=60,regex="[0-9A-Za-z@._-]"},
	WIDGET.newTextBox{name="password",	x=380,	y=400,w=626,h=60,secret=true,regex="[ -~]"},
	WIDGET.newTextBox{name="password2",	x=380,	y=500,w=626,h=60,secret=true,regex="[ -~]"},
	WIDGET.newButton{name="back",		x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
}

return scene