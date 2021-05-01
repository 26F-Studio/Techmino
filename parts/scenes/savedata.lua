local scene={}

local function dumpCB(T)
	love.system.setClipboardText(
		love.data.encode(
			'string','base64',
			love.data.compress(
				'string','zlib',
				TABLE.dump(T)
			)
		)
	)
	LOG.print(text.exportSuccess)
end
local function parseCB()
	local _
	local s=love.system.getClipboardText()

	--Decode
	_,s=pcall(love.data.decode,'string','base64',s)
	if not _ then LOG.print(text.dataCorrupted,COLOR.R)return end
	_,s=pcall(love.data.decompress,'string','zlib',s)
	if not _ then LOG.print(text.dataCorrupted,COLOR.R)return end

	s=loadstring(s)
	if s then
		setfenv(s,NONE)
		return s()
	end
end
scene.widgetList={
	WIDGET.newButton{name="exportUnlock",	x=190,y=150,w=280,h=100,color='lG',font=25,code=function()dumpCB(RANKS)end},
	WIDGET.newButton{name="exportData",		x=490,y=150,w=280,h=100,color='lG',font=25,code=function()dumpCB(STAT)end},
	WIDGET.newButton{name="exportSetting",	x=790,y=150,w=280,h=100,color='lG',font=25,code=function()dumpCB(SETTING)end},
	WIDGET.newButton{name="exportVK",		x=1090,y=150,w=280,h=100,color='lG',font=25,code=function()dumpCB(VK_org)end},

	WIDGET.newButton{name="importUnlock",	x=190,y=300,w=280,h=100,color='lB',font=25,
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
	WIDGET.newButton{name="importData",		x=490,y=300,w=280,h=100,color='lB',font=25,
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
	WIDGET.newButton{name="importSetting",	x=790,y=300,w=280,h=100,color='lB',font=25,
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
	WIDGET.newButton{name="importVK",		x=1090,y=300,w=280,h=100,color='lB',font=25,
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
	WIDGET.newButton{name="back",		x=640,y=620,w=200,h=80,font=40,code=backScene},
}

return scene