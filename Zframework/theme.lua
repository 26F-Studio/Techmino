local THEME={
	cur=false,--Current theme
}
local themeColor={
	xmas={COLOR.R,COLOR.Z,COLOR.G},
	sprfes={COLOR.R,COLOR.O,COLOR.Y},
}

function THEME.calculate(Y,M,D)
	if not Y then Y,M,D=os.date("%Y"),os.date("%m"),os.date("%d")end
	--Festival calculate within one statement
	return
		--Christmas
		M=="12"and math.abs(D-25)<4 and
		'xmas'or

		--Spring festival
		M<"03"and math.abs((({
			--Festival days. Jan 26=26, Feb 1=32, etc.
			24,43,32,22,40,29,49,38,26,45,
			34,23,41,31,50,39,28,47,36,25,
			43,32,22,41,29,48,37,26,44,34,
			23,42,31,50,39,28,46,35,24,43,
			32,22,41,30,48,37,26,45,33,23,
			42,32,50,39,28,46,35,24,43,33,
			21,40,
		})[Y-2000]or -26)-((M-1)*31+D))<6 and
		'sprfes'or

		--April fool's day
		M=="04"and D=="01"and
		'fool'or

		--Z day (Feb./Mar./Apr./May./June. 26)
		D=="26"and(
			(M=="01"or M=="02")and'zday1'or
			(M=="03"or M=="04")and'zday2'or
			(M=="05"or M=="06")and'zday3'
		)or

		'classic'
end

function THEME.set(theme)
	if theme=='classic'then
		BG.setDefault('space')
		BGM.setDefault("space")
	elseif theme=='xmas'then
		BG.setDefault('snow')
		BGM.setDefault('xmas')
		LOG.print("==============")
		LOG.print("Merry Christmas!")
		LOG.print("==============")
	elseif theme=='sprfes'then
		BG.setDefault('firework')
		BGM.setDefault("spring festival")
		LOG.print(" ★☆☆★")
		LOG.print("新年快乐!")
		LOG.print(" ★☆☆★")
	elseif theme=='zday1'then
		BG.setDefault('lanterns')
		BGM.setDefault("empty")
	elseif theme=='zday2'then
		BG.setDefault('lanterns')
		BGM.setDefault("overzero")
	elseif theme=='zday3'then
		BG.setDefault('lanterns')
		BGM.setDefault("vacuum")
	elseif theme=='fool'then
		BG.setDefault('blockrain')
		BGM.setDefault("how feeling")
	else
		return
	end
	THEME.cur=theme
	BG.set()
	BGM.play()
	return true
end

function THEME.getThemeColor(theme)
	if not theme then theme=THEME.cur end
	return themeColor[theme]
end

function THEME.fresh()
	THEME.set(THEME.calculate(os.date("%Y"),os.date("%m"),os.date("%d")))
end

return THEME