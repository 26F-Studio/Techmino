local scene={}

function scene.sceneInit()
	if math.random()>.0000626 then
		love.timer.sleep(.26)
		love.event.quit()
	else
		error("So lucky! 0.00626% to get this!!   You can quit the game now.")
	end
end

return scene