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
end
function game.mode()
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
end
function game.setting2()
	scene="setting2"
	curBG="none"
	keyssetting=nil
	BGM("blank")
end
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