function sceneInit.debug()
	sceneTemp={
		reset=false,
	}
end
function keyDown.debug(key)
	LOG.print("keyPress: ["..key.."]")
end

WIDGET.init("debug",{
	WIDGET.newButton({name="scrInfo",x=300,y=120,w=300,h=100,color="green",code=function()
		LOG.print("Screen Info:")
		LOG.print("x y: "..SCR.x.." "..SCR.y)
		LOG.print("w h: "..SCR.w.." "..SCR.h)
		LOG.print("W H: "..SCR.W.." "..SCR.H)
		LOG.print("k: "..math.floor(SCR.k*100)*.01)
		LOG.print("rad: "..math.floor(SCR.rad*100)*.01)
		LOG.print("dpi: "..SCR.dpi)
	end}),
	WIDGET.newButton({name="reset",x=640,y=380,w=240,h=100,color="orange",font=40,
		code=function()sceneTemp.reset=true end,
		hide=WIDGET.lnk.STPval("reset")}),
	WIDGET.newButton({name="reset1",x=340,y=480,w=240,h=100,color="red",font=35,
		code=function()
			love.filesystem.remove("unlock.dat")
			SFX.play("finesseError_long")
			TEXT.show("rank resetted",640,300,60,"stretch",.4)
			TEXT.show("effected after restart game",640,360,60,"stretch",.4)
			TEXT.show("play one game if you regret",640,390,40,"stretch",.4)
		end,
		hide=function()return not sceneTemp.reset end}),
	WIDGET.newButton({name="reset2",x=640,y=480,w=260,h=100,color="red",font=35,
		code=function()
			love.filesystem.remove("data.dat")
			SFX.play("finesseError_long")
			TEXT.show("game data resetted",640,300,60,"stretch",.4)
			TEXT.show("effected after restart game",640,360,60,"stretch",.4)
			TEXT.show("play one game if you regret",640,390,40,"stretch",.4)
		end,
		hide=function()return not sceneTemp.reset end}),
	WIDGET.newButton({name="reset3",x=940,y=480,w=260,h=100,color="red",font=35,
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
			TEXT.show("effected after restart game",640,390,60,"stretch",.4)
			SCN.back()
		end,
		hide=function()return not sceneTemp.reset end}),
	WIDGET.newButton({name="back",x=640,y=620,w=200,h=80,font=40,code=WIDGET.lnk.BACK}),
})