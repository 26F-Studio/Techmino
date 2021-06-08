local scene={}

local function dumpCB(T)
	love.system.setClipboardText(STRING.packText(TABLE.dump(T)))
	LOG.print(text.exportSuccess,'message')
end
local function parseCB()
	local _
	local s=love.system.getClipboardText()

	--Decode
	s=STRING.unpackText(s)
	if not s then LOG.print(text.dataCorrupted,'error')return end

	s=loadstring(s)
	if s then
		setfenv(s,NONE)
		return s()
	end
end
scene.widgetList={
	WIDGET.newText{name="export",		x=55,y=45,color='lY',align='L',font=50},
	WIDGET.newButton{name="unlock",		x=190,y=170,w=280,h=100,color='lY',code=function()dumpCB(RANKS)end},
	WIDGET.newButton{name="data",		x=490,y=170,w=280,h=100,color='lY',code=function()dumpCB(STAT)end},
	WIDGET.newButton{name="setting",	x=790,y=170,w=280,h=100,color='lY',code=function()dumpCB(SETTING)end},
	WIDGET.newButton{name="vk",			x=1090,y=170,w=280,h=100,color='lY',code=function()dumpCB(VK_org)end},

	WIDGET.newText{name="import",		x=55,y=265,color='lR',align='L',font=50},
	WIDGET.newButton{name="unlock",		x=190,y=390,w=280,h=100,color='lR',
		code=function()
			local D=parseCB()
			if D then
				TABLE.update(D,RANKS)
				FILE.save(RANKS,'conf/unlock')
				LOG.print(text.importSuccess,'message')
			else
				LOG.print(text.dataCorrupted,'warn')
			end
		end},
	WIDGET.newButton{name="data",		x=490,y=390,w=280,h=100,color='lR',
		code=function()
			local D=parseCB()
			if D and D.version==STAT.version then
				TABLE.update(D,STAT)
				FILE.save(STAT,'conf/data')
				LOG.print(text.importSuccess,'message')
			else
				LOG.print(text.dataCorrupted,'warn')
			end
		end},
	WIDGET.newButton{name="setting",	x=790,y=390,w=280,h=100,color='lR',
		code=function()
			local D=parseCB()
			if D then
				TABLE.update(D,SETTING)
				FILE.save(SETTING,'conf/settings')
				LOG.print(text.importSuccess,'message')
			else
				LOG.print(text.dataCorrupted,'warn')
			end
		end},
	WIDGET.newButton{name="vk",			x=1090,y=390,w=280,h=100,color='lR',
		code=function()
			local D=parseCB()
			if D then
				TABLE.update(D,VK_org)
				FILE.save(VK_org,'conf/virtualkey')
				LOG.print(text.importSuccess,'message')
			else
				LOG.print(text.dataCorrupted,'warn')
			end
		end},

	WIDGET.newText{name="couldSave",	x=55,y=485,color='lB',align='L',font=50},
	WIDGET.newText{name="notLogin",		x=55,y=550,color='dB',align='L',font=30,hideF=function()return WS.status('user')=='running'end},
	WIDGET.newButton{name="upload",		x=190,y=610,w=280,h=90,color='lB',font=25,code=NET.uploadSave,hideF=function()return WS.status('user')~='running'end},
	WIDGET.newButton{name="download",	x=490,y=610,w=280,h=90,color='lB',font=25,code=NET.downloadSave,hideF=function()return WS.status('user')~='running'end},
	WIDGET.newButton{name="back",		x=1140,y=640,w=170,h=80,fText=TEXTURE.back,code=backScene},
}

return scene