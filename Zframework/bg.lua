local function NULL(...)end
local BG={
	list={},
	cur="",
	init=NULL,
	resize=NULL,
	update=NULL,
	draw=NULL,
	event=NULL,
	discard=NULL,
}
function BG.send(data)
	if BG.event then
		BG.event(data)
	end
end
function BG.set(background)
	if background==BG.cur or not SETTING.bg then return end
	BG.discard()
	background=BG.list[background]
	if not background then
		LOG.print("No BG called"..background,"warn")
		return
	end
	BG.cur=background

	BG.init=	background.init or NULL
	BG.resize=	background.resize or NULL
	BG.update=	background.update or NULL
	BG.draw=	background.draw or NULL
	BG.event=	background.event or NULL
	BG.discard=	background.discard or NULL
	BG.init()
end
return BG