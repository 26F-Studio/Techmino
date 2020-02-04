game={}
function game.load()
	scene="load"
	curBG="none"
	loading=1--Loading mode
	loadnum=1--Loading counter
	loadprogress=0--Loading bar
end
function game.intro()
	scene="intro"
	curBG="none"
end
function game.main()
	scene="main"
	curBG="none"
	BGM("blank")
	collectgarbage()
end
function game.mode()
	saveData()
	modeSel=modeSel or 1
	if players then restockRow()end--collectGarbage
	scene="mode"
	curBG="none"
	BGM("blank")
end
function game.play()
	scene="play"
	--curBG="game1"
	resetGameData()
	sysSFX("ready")
	mouseShow=false
end
function game.setting()
	scene="setting"
	curBG="none"
	BGM("blank")
end--Normal setting
function game.setting2()
	scene="setting2"
	curBG="none"
	keyssetting=nil
	BGM("blank")
end--Advanced setting and keyboard&joystick setting
function game.setting3()
	scene="setting3"
	curBG="game1"
	keyssetting=nil
	BGM("blank")
end--Touch setting
function game.help()
	scene="help"
	curBG="none"
	BGM("blank")
end
function game.stat()
	scene="stat"
	curBG="none"
	BGM("blank")
end
function game.quit()
	love.event.quit()
end