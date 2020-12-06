local function tick_httpREQ_newLogin(task)
	local time=0
	while true do
		coroutine.yield()
		local response,request_error=client.poll(task)
		if response then
			local res=json.decode(response.body)
			LOGIN=response.code==200
			if res then
				if LOGIN then
					LOG.print(text.loginSuccessed)
					ACCOUNT.email=res.email
					ACCOUNT.auth_token=res.auth_token
					FILE.save(ACCOUNT,"account","")

					httpRequest(
						TICK.httpREQ_getAccessToken,
						PATH.api..PATH.access,
						"POST",
						{["Content-Type"]="application/json"},
						json.encode{
							email=ACCOUNT.email,
							auth_token=ACCOUNT.auth_token,
						}
					)
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

local function login()
	local email=	WIDGET.active.email.value
	local password=	WIDGET.active.password.value
	if #email==0 or not email:match("^[a-zA-Z0-9_]+@[a-zA-Z0-9_-]+%.[a-zA-Z0-9_]+$")then
		LOG.print(text.wrongEmail)return
	elseif #password==0 then
		LOG.print(text.noPassword)return
	end
	httpRequest(
		tick_httpREQ_newLogin,
		PATH.api..PATH.auth,
		"GET",
		{["Content-Type"]="application/json"},
		json.encode{
			email=email,
			password=password,
		}
	)
end

local scene={}

scene.widgetList={
	WIDGET.newText{name="title",		x=80,	y=50,font=70,align="L"},
	WIDGET.newButton{name="register",	x=1140,	y=100,w=170,h=80,color="green",code=function()SCN.swapTo("register","swipeR")end},
	WIDGET.newTextBox{name="email",		x=380,	y=200,w=500,h=60,regex="[0-9A-Za-z@._-]"},
	WIDGET.newTextBox{name="password",	x=380,	y=300,w=626,h=60,secret=true,regex="[ -~]"},
	WIDGET.newKey{name="login",			x=1140,	y=540,w=170,h=80,font=40,code=login},
	WIDGET.newButton{name="back",		x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk_BACK},
}

return scene