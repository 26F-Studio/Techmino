local lastLogoutTime

local scene={}

function scene.sceneInit()
	lastLogoutTime=-1e99
	BG.set()
end
function scene.sceneBack()
	NET.wsclose_play()
end

function scene.draw()
	drawSelfProfile()
end

scene.widgetList={
	WIDGET.newKey{name="setting",fText=TEXTURE.setting,x=1200,y=160,w=90,h=90,code=goScene"setting_game"},
	WIDGET.newButton{name="ffa",	x=640,	y=200,w=350,h=120,font=40,code=function()NET.enterRoom("ffa")end},
	WIDGET.newButton{name="rooms",	x=640,	y=360,w=350,h=120,font=40,code=goScene"net_rooms"},
	WIDGET.newButton{name="chat",	x=640,	y=540,w=350,h=120,color="D",font=40,code=NULL},
	WIDGET.newButton{name="logout",	x=880,	y=40,w=180,h=60,color="dR",
		code=function()
			if TIME()-lastLogoutTime<1 then
				if USER.uid then
					NET.wsclose_play()
					NET.wsclose_user()
					USER.uid=false
					USER.username=false
					USER.authToken=false
					FILE.save(USER,"conf/user","q")
					SCN.back()
				end
			else
				LOG.print(text.sureQuit,COLOR.O)
				lastLogoutTime=TIME()
			end
		end},
	WIDGET.newButton{name="back",	x=1140,	y=640,w=170,h=80,font=40,code=backScene},
}

return scene