-- local gc=love.graphics

function sceneInit.account()
	sceneTemp={}
end

WIDGET.init("account",{
	WIDGET.newText({name="title",	x=80,	y=50,font=70,align="L"}),
	WIDGET.newButton({name="back",	x=1140,	y=640,w=170,h=80,font=40,code=WIDGET.lnk.BACK}),
})