function sceneInit.quit()
	if math.random()>.000626 then
		love.timer.sleep(.3)
		love.event.quit()
	else
		error("So lucky! 0.0626 precent to get this!!!   You can quit the game now.")
	end
end