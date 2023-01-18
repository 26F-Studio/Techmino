local scene={}

function scene.enter()
    if SYSTEM=="iOS" then
        MES.update(1e99)
        Z.setPowerInfo(false)
        Z.setClickFX(false)
        VERSION.string=""
        MES.new('error',"Please swipe up or press Home button to quit Techmino on iOS",1e99)
    else
        if math.random()>.0000626 then
            love.timer.sleep(.26)
            love.event.quit()
        else
            error("So lucky! 0.00626% to get this!!   You can quit the game now.")
        end
    end
end

function scene.draw()
    love.graphics.clear()
end

return scene
