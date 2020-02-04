game={}
function game.load()
	scene="load"
	curBG="none"
	mouseShow=true
	loading=1--Loading mode
	loadnum=1--Loading counter
	loadprogress=0--Loading bar
end
function game.intro()
	scene="intro"
	curBG="none"
	mouseShow=true
end
function game.main()
	scene="main"
	curBG="none"
	mouseShow=true
	BGM("blank")
end
function game.mode()
	scene="mode"
	curBG="none"
	mouseShow=true
	BGM("blank")
end
function game.play()
	scene="play"
	--curBG="game1"
	resetGameData()
	SFX("ready")
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