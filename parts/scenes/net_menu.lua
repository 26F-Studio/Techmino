local lastLogoutTime

local scene={}

function scene.sceneInit()
	lastLogoutTime=-1e99
	BG.set("space")
end
function scene.sceneBack()
	NET.wsclose_play()
end

scene.widgetList={
	WIDGET.newButton{name="ffa",	x=640,	y=200,w=350,h=120,font=40,code=function()NET.enterRoom("ffa")end},
	WIDGET.newButton{name="rooms",	x=640,	y=360,w=350,h=120,font=40,code=goScene"net_rooms"},
	WIDGET.newButton{name="chat",	x=640,	y=540,w=350,h=120,color="black",font=40,code=NULL},
	WIDGET.newButton{name="logout",	x=1140,	y=70,w=180,h=70,color="dR",
		code=function()
			if TIME()-lastLogoutTime<1 then
				if USER.uid then
					NET.wsclose_play()
					NET.wsclose_user()
					USER.username=false
					USER.uid=false
					USER.authToken=false
					FILE.save(USER,"conf/user","q")
					SCN.back()
				end
			else
				LOG.print(text.sureQuit,COLOR.orange)
				lastLogoutTime=TIME()
			end
		end},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,				font=40,code=backScene},
}

return scene