local THEME={
	cur=false,--Current theme
}
local themeColor={
	xmas={COLOR.red,COLOR.white,COLOR.green},
	sprfes={COLOR.red,COLOR.orange,COLOR.yellow},
}

function THEME.calculate(Y,M,D)
	if not Y then Y,M,D=os.date"%Y",os.date"%m",os.date"%d"end
	--Festival calculate within one statement
	return
		--Christmas
		M=="12"and math.abs(D-25)<4 and
		"xmas"or

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
		"sprfes"or

		--Z day (Feb./Mar./Apr./May./June 26)
		math.abs(M-4)<=2 and D+0==26 and
		"zday"or

		"classic"
end

function THEME.set(theme)
	if theme=="classic"then
		BG.setDefault("space")
		BGM.setDefault("blank")
	elseif theme=="xmas"then
		BG.setDefault("snow")
		BGM.setDefault("mXmas")
		LOG.print("==============",COLOR.red)
		LOG.print("Merry Christmas!",COLOR.white)
		LOG.print("==============",COLOR.red)
	elseif theme=="sprfes"then
		BG.setDefault("firework")
		BGM.setDefault("spring festival")
		LOG.print(" ★☆☆★",COLOR.red)
		LOG.print("新年快乐!",COLOR.white)
		LOG.print(" ★☆☆★",COLOR.red)
	elseif theme=="zday"then
		BG.setDefault("lanterns")
		BGM.setDefault("overzero")
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
	THEME.set(THEME.calculate(os.date"%Y",os.date"%m",os.date"%d"))
end

return THEME