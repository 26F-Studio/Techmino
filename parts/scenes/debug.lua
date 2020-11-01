function sceneInit.debug()
	sceneTemp={
		reset=false,
	}
end
function keyDown.debug(key)
	LOG.print("keyPress: ["..key.."]")
end