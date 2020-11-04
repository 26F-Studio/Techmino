function sceneInit.savedata()
	sceneTemp={reset=false}
end
function keyDown.savedata(key)
	LOG.print("keyPress: ["..key.."]")
end

local NULL={}
local function encodeCB(T)
	love.system.setClipboardText(
			love.data.encode(
				"string","base64",
				love.data.compress(
					"string","zlib",
					dumpTable(T)
				)
			)
	)
	LOG.print(text.exportSuccess)
end
local function parseCB()
	local _
	local s=love.system.getClipboardText()

	--Decode
	_,s=pcall(love.data.decode,"string","base64",s)
	if not _ then LOG.print(text.dataCorrupted,COLOR.red)return end
	_,s=pcall(love.data.decompress,"string","zlib",s)
	if not _ then LOG.print(text.dataCorrupted,COLOR.red)return end

	s=loadstring(s)
	if s then
		setfenv(s,NULL)
		LOG.print(text.importSuccess,COLOR.green)
		return s()
	end
end
local function HIDE()
	return not sceneTemp.reset
end
WIDGET.init("savedata",{
	WIDGET.newButton({name="exportUnlock",	x=190,y=150,w=280,h=100,color="lGreen",font=25,code=function()encodeCB(RANKS)end}),
	WIDGET.newButton({name="exportData",	x=490,y=150,w=280,h=100,color="lGreen",font=25,code=function()encodeCB(STAT)end}),
	WIDGET.newButton({name="exportSetting",	x=790,y=150,w=280,h=100,color="lGreen",font=25,code=function()encodeCB(SETTING)end}),
	WIDGET.newButton({name="exportVK",		x=1090,y=150,w=280,h=100,color="lGreen",font=25,code=function()encodeCB(VK_org)end}),

	WIDGET.newButton({name="importUnlock",	x=190,y=300,w=280,h=100,color="lBlue",font=25,code=function()addToTable(parseCB()or NULL,RANKS)end}),
	WIDGET.newButton({name="importData",	x=490,y=300,w=280,h=100,color="lBlue",font=25,code=function()addToTable(parseCB()or NULL,STAT)end}),
	WIDGET.newButton({name="importSetting",	x=790,y=300,w=280,h=100,color="lBlue",font=25,code=function()addToTable(parseCB()or NULL,SETTING)end}),
	WIDGET.newButton({name="importVK",		x=1090,y=300,w=280,h=100,color="lBlue",font=25,code=function()addToTable(parseCB()or NULL,VK_org)end}),

	WIDGET.newButton({name="reset",			x=640,y=460,w=280,h=100,color="lRed",font=40,code=function()sceneTemp.reset=true end,hide=function()return sceneTemp.reset end}),
	WIDGET.newButton({name="resetUnlock",	x=340,y=460,w=280,h=100,color="red",
		code=function()
			love.filesystem.remove("unlock.dat")
			SFX.play("finesseError_long")
			TEXT.show("rank resetted",640,300,60,"stretch",.4)
			LOG.print("effected after restart game","message")
			LOG.print("fresh a rank if you regret","message")
		end,
		hide=HIDE}),
	WIDGET.newButton({name="resetData",		x=640,y=460,w=280,h=100,color="red",
		code=function()
			love.filesystem.remove("data.dat")
			SFX.play("finesseError_long")
			TEXT.show("game data resetted",640,300,60,"stretch",.4)
			LOG.print("effected after restart game","message")
			LOG.print("play one game if you regret","message")
		end,
		hide=HIDE}),
	WIDGET.newButton({name="resetALL",		x=940,y=460,w=280,h=100,color="red",
		code=function()
			local L=love.filesystem.getDirectoryItems("")
			for i=1,#L do
				local s=L[i]
				if s:sub(-4)==".dat"then
					love.filesystem.remove(s)
				end
			end
			SFX.play("clear_4")SFX.play("finesseError_long")
			TEXT.show("all file deleted",640,330,60,"stretch",.4)
			LOG.print("effected after restart game","message")
			SCN.back()
		end,
		hide=HIDE}),

		WIDGET.newButton({name="back",			x=640,y=620,w=200,h=80,font=40,code=WIDGET.lnk.BACK}),
})