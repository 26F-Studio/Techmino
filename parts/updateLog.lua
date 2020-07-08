local S=[=[
"Patron"(time ordered,may not accurate):
		[rmb100+]:
			那没事了(T6300)
			加油啊,钉钉动了的大哥哥(T3228)
			弥佑瑶
			Alan
			幽灵3383
			靏鸖龘龘
			込余
	[rmb10+]:
		八零哥  蕴空之灵  gggf127  dtg
		ThTsOd  Fireboos  金巧  10元
		立斐  Deep_Sea  时雪  yyangdid
		sfqr  心痕  Sasoric  夏小亚
		仁参  乐↗乐↘  喜欢c4w的ztcjoin  面包
		蠢熏  潘一栗  Lied  星街书婉
		祝西  829  e m*12  我永远爱白银诺艾尔(鹏
		PCX  kagura77  呆喂  GlowingEmbers
		轩辕辚  HimuroAki  TCV100  tech有养成系统了@7065
		HAGE KANOBU  闪电和拐棍  葡萄味的曼妥思  世界沃德
		蓝绿  天生的魔法师  saki 琳雨空 T8779.易缄

	Thanks!!!

Future outlook:
	New mode:
		PUYO
		game tutorial
		finesse tutorial
		game Abbr. test
		backfire
		finesse exam(3next, 1pt/mino, drop to score)
		round-based dig
		bigbang
		rhythm
		combo
		square
		field shifting(left/right)
		task survival
		dig practice
		dig zen
		sprint_symmetry
		hidden: sound only
		reverb (often repeat a piece many times)
		KPP-locked
		parkour
	Other:
		mod system with:
			block hidden
			field hidden
			up-hidden
			low-hidden
			next hidden
			field flip(LR/UD)
			no fail(∞ lives)
		mini games:
			15 puzzle (with hidden mode)
			2048 (with next (with deadly mode))
			mine sweeper
			tank battle
		time-based-rank for master advanced mode(1:58/2：28/3：03/300P/100P)
		简易防沉迷系统
		full-key control
		dragging control
		"next" SFX
		new layout of player (rectangle so stupid)
		better drop FX
		60+ fps supporting
		in-game document
		lang setting page
		game recording
		new widgets (joystick etc.)
		custom sequence(TTT!)
		splashing block
		cool backgrounds
		more graphic FXs & 3D features & animations
		Encrypt source code (compile to byte code)
		network game
		new AI: task-Z

0.8.25: Custom Sequence Update
	new:
		--TODO: custom sequence
		many new tips
	changed:
		faster&harder attacker-ultimate
		little easier to get S in PC challenge (easy mode)
		easier to get S in infinite mode, c4w, PC
		harder to unlock sprint 400/1000
	code:
		file sorted
		task system rewrited, now perfect
	fixed:
		hard move won't deactive "spin"
		do not clear dead enemies' field
		show ghost's center when ghost is off

0.8.24: Bug Fixed
	new:
		ready to refuse auto-formating stats. if update from versions too old
	changed:
		little changing of pentomino wallkick list
	fixed:
		incorrect color of P/Q
		rank of petomino may be [custom]

0.8.23: Details Update
	new:
		new hidden BGM: Hay what kind of feeling
		now can reset all data (hidden)
	changed:
		add a stat "offset", used to avoid strange radar chart in Attack Mode, show in total stat page only
		6 more X-spin-wallkick added
	fixed:
		speed dial do not moving
		do not show 20+ combo

0.8.22: Shader Update
	new:
		new background: aura (using shader)
		new BGM: Far
		X-spin added
		visual effects for when the player is in danger
		staff page added
	changed:
		remake several backgrounds with shader, instead of image
		kick-list of pentomino optimized
		all backgounds fix screen correctly (maybe)
		won't show "open saving folder" button on mobile devices
		wallkick of J/L-180° spin changed
		reset all settings
	code:
		player generator optimized by FinnTenzor
		player system moduled
	fixed:
		rotating x do not fresh lock delay
		error after reset skin/dir. in pentomino mode
		some times error when any AI exists (wrong kickList code)

0.8.21: Bug Fixed
	changed:
		shape of speed dial changed
		range of FX values changed
		shape of speed dial changed
	fixed:
		error in modes with ai (rotate O in its rotation system, cause some strange error)

0.8.19/20: Fantastic Global Update II
	new:
		new clearing FX
		pentomino with new rotation system (testing)
		new PC training mode with over 1000 quiz
		new English translation by @MattMayuga#8789
		new language: ???
		language-setting page
		[C B A S SS]→[D C B A S]
		powerinfo switch
	changed:
		resume/quit key changed on pause page (quit with Q, resume with esc)
		warning when back to pause page from setting page
		some FX based on real time
		tiny change (almost nothing) changed for powerInfo
		page turing of in-game update log changed
		readable update log of 0.8+ ver
		some new "tips"
		add ENG ver. document(not in game)
	code:
		swap id of J/L
		wall-kick list easier to read
		no utf8 char in code/comments
		less global variables
		light module optimized (but not used)
		code optimized
	fixed:
		impossible to get SS in attacker mode

0.8.18: Details Update II
	new:
		adjustable virtualkey SFX & VIB
	changed:
		add discord link in ENG mode
		change par time/piece of sprint/battle/round mode
		info on pause page more clearly
		faster spaceBG rendering
		updateLog editted
	code:
		delete all removable "goto"s!
		callback system moduled, main.lua easy to read

0.8.17: Details Update
	new:
		bag seperating line switch
		better radar chart & statistics on pause page
		new generator method for drought mode, more difficult to finish
		virtualkey pressing SFX
	changed:
		combo counter changed
		rule of infinite dig changed
		no drop/lock FX in two hardest hidden modes, make them harder
		TSD-easy will auto finish when reach 20TSDs
		solo/round AI setting changed
		show text when entering debug mode
		SFX when enter recording mode
		remove full speed loading
	code:
		launching sound divided to SFX&VOC two parts
		delete many "goto"s
		vocal system moduled
		language system moduled, easier to add new languages
	fixed:
		forgot to load language
		error animation in control setting
		error when paste map containing darkgreen block
		moving block when changing target in t49/t99
		font error in patron list
		do not reset pause count when restart

0.8.16: Fantastic Global Update
	new:
		new statistic page with:
			Radar chart which shows some important info. of player's performance
			count each clear/spin for each piece(old data will be splited averagely)
		linux version!
		welcome vocal by MrZ
		rank label on mode icon(C→B→A→S→SS)
		new J/L-spin: R→2/L→2(0,-1)
		new O-spin-J/L method!
		new tele-ospin method!
		support out frame of skins with transparent pixels
		DAS system remade, no bugs any more!(probably)
		Initial hold/rotate/move switch!
		display ms in control setting
		super secret option
	changed:
		cannot initial hold in a row any more
		new randomizer for drought2
		half-clear judging method changed
		new background system(well, it doesn't look much different but space BG)
		now can loading at full speed with Dblclick/space/enter
		add alipay paycode to help page
		better sequence randomizer
	code:
		first shader applied for white frame of falling block
		many many module packed, easy to manage
		bgm module changed, probably no bug
		4 devMode now
	fixed:
		error when set to max 0 next
		AI sequence initializing error when face setting changed
		DAS error

0.8.15: Bug Fixed
	new:
		can switch line-clear text now
		new attack way "Clear"(half-clear)
		give every update a name!
	changed:
		animation time of lock effect little changed
		bone block of ball-skin changed
		AI change target more slowly
		Author.dignity-=1
	fixed:
		180° I spin kicklist error
		AI will kill itself when spawn dir. of mino changed
		error when reach 400 in 20G(Lunatic)
		error block color in modes with starting field

0.8.14: Cool FX
	new:
		click/tap/any-key to skip loading animation
		lock animation
	changed:
		display scene info when error
	code:
		many optimization
	fixed:
		error when attack
		error garbage line color
		error in finesse checking
		some times error when touch screen
		touch/press release with no press, then error

0.8.13: O-spin Update++
	new:
		a independent page to set DAS/ARR, with an animation for preview
	changed:
		new virtualkey animation
		freer drawing mode(Incompatible with old ver.)
		combo&b3b attack changed
		score of spins little changed
	fixed:
		wrong behavior in pause scene
		ospin error in 0.8.12
		memory leakage in t49/t99
		unnatural behavior of widgets

0.8.12: Bountful Update
	new:
		layout setting: skin system with customizable block color/direction
		more information when pause
		block has more color(7→11)
		skin: smooth(MrZ), contrast(MrZ), steel(kulumi), ball(shaw)
	changed:
		BGM secret7's Inst. changed
		more stable space background
		stat format changed when pause/stat menu
		opaque background in pause when playing, transparent after game
		canceled invalid game
		easier to unlock custom mode
		some text changed
	code:
		better line-clear process
		merge event.lua to player.lua
		new skin image format
		same format for all file
		better virtualkey-scanning opportunity, bit faster when many AI
		some player-method name changed
	fixed:
		an error of pause button
		score may be float number
		many syntax errors of texts
		crash when paste illegal data to drawing mode
		stage reset problem in t49/t99
		wrong info in tech-L/U/U+ mode

0.8.11: Total Update
	changed:
		better rule of checking invalid game
		can setting when pause
		opaque background when pause
	code:
		many code optimized(moduled)
	fixed:
		receive attack when paused in survivor mode
		error when pasteboard has block_13
		must hold R to restart when finished the game
		sth about screen size
		some O-spin error
		error line counting when pc(full b2b)

0.8.10: Cool Update
	new:
		new BGM:Distortion(master-final)
		all background darker
		cooler error page
	fixed:
		error when finish master/ultra mode
		shakeFX no effect when below 3

0.8.9: System Detail Update
	new:
		invalid game when pause too much
		quick play re-added
		new BGM: Oxygen(c4w&pc training)
	changed:
		space background little changed

0.8.8+: Bug-Fix Update
	fixed many fatal bugs

0.8.8: Space BG Update
	new:
		background now is cool space with "planets" and "stars", instead of boring falling tetrominos
		no black side in any screen size
		adjustable waiting time before start
		ajustable maxnext count
		marked the modes with limited das/arr
		new error page and a new voice
		add many fatal bugs
	changed:
		simple records with date
		tiny change in rotate system(JL pistol-spin)
		better board copy/paste
		an unlock-all easter egg
	fixed:
		press invisible func key
		some mode error

0.8.7: Game Detail Update
	new:
		support 2^n G falling speed
	changed:
		better user experience in mode selecting
		speed of marathon mode changed
	code:
		shorter clipboard string(when air above)
		attack system/score system little changed
	fixed:
		wrong behaviour of rank system
		error when enter some mode(again!)

0.8.6: System Detail Update
	new:
		can adjust gamepad keysetting
		add SFX when enter game
	changed:
		map GUI little adjusted
		event system little changed(no control when scene swapping)
	fixed:
		wrong behaviour of rank system
		error when enter some mode

0.8.5-: Exploration Update
	new:
		mode map!Brandly new GUI for mode selecting
		mode unlock system, not that scary for noob
		every mode has rank calculating method(may some mistakes/inappropriate number)
		save 10 best recoreds for each mode
		can save/share custom map now
		"new mode": Big Bang
	changed:
		button appearance changed
		better widget performence
		remove Qplay
	fixed:
		many bugs

0.8.4: Miya Update II
	changed:
		vocal more natural(important, may cause new bug)
		a bit better performence on mobile devices
	fixed:
		some fatal bugs

0.8.3: Miya Update
	new:
		new widget appearence
		cuter miya

0.8.2: Graphics Update
	new:
		miya figure added
		new widget appearence
	changed:
		GUI adjusted
	fixed:
		some bugs

0.8.1: Power Info Update
	changed:
		more FX level
		better battery info displaying
		3 next in GMroll
	fixed:
		some bugs

0.8.0: Small Update
	new:
		better update log from now on(2020.5.2)
	changed:
		more details
	code:
		remade text system
	fixed:
		some bugs

0.7.35: Bug Fixed
	yeah, only bug fixed

0.7.34: Voice Update+
	replace most voice
	shaking FX more natural

0.7.33+: Bot Update
	MORE POWERFUL 9-stack AI
	add stereo-setting slider
	code optimized
	bug fixed

0.7.32: Virtualkey Update+
	Blind-GM now show section directly
	easier&more standard classic mode
	can switch Virtualkey's auto dodging
	in-game setting
	code optimized
	bug fixed

0.7.31: Stereo Update
	stereo system
	fixed a problem in finesse calculating

0.7.30: Virtualkey Update
	auto-tracking virtual key, adjustable parameters!
	can switch on/off virtuakeys
	add 7 more key
	better finesse rate calculating
	block generating position on Y-axis changed
	new icon for android
	can use preset in custom mode with keyboard
	adjusted GUI
	many bug fixed

0.7.28: Finesse Update
	add fineese check(almost useful)
	code optimized

0.7.27: O-spin Update+
	super O transform system
	optimized 	 system(no used)
	bug fixed

0.7.26: Bug Fixed
	new skin
	import light lib
	many bug fixed

0.7.25: Demo Update
	demo play at main menu
	ALMOST reconstructed WHOLE PLAYER SYSTEM, NEED TEST
	many bug fixed

0.7.23/24: Feast of Hearing
	all bgm remade
	more settings with brand new GUI!
	new mode: Master-Final
	new modes: attacker & defender(not survivor!)
	add restart button when pause
	Code Clear added, face it bravely!(Windows only)
	change falling animation
	new GUI details
	louder sound
	code optimized
	many bugs fixed

0.7.22: Graphics Update
	scoring system
	smooth dropping
	can change FX level
	new attaking FX
	new bone skin
	battery info/time display
	in-game update log(this page)
	fast game
	much many more better GUI details
	add EXTRA level of survivor mode
	adjust difficulty of Tech mode
	compressed setting/data
	support 10% step alpha of virtual key
	many code optimized&bugs fixed

0.7.21: Title Update
	new title image
	more GUI details
	many bugs fixed

0.7.20: Music Room Update
	add music room
	change block/space apperance in draw mode
	field shake animation
	default sets of custom options
	can set BG/BGM in custom mode
	bug fixed

0.7.19: Voice Update
	voice system added(voice by Miya)
	support macOS!
	new mode: C4W training
	rendering of royale mode optimized again
	add "free cell" in draw mode
	add 2 new block skins
	new difficulty in infinite mode
	new background/sound effect in master mode
	bug fixed

0.7.18: Skin Update
	3 new block skins!(one skin origional by Miya(nya~))
	better restarting(to prevent mistakenly touching)
	switch display of puzzle mode
	adjust UI
	code optimized
	default custom options changed to as infinite mode

0.7.17: Pause Update
	display game stats when pause
	more options in statistics
	better pausing
	adjust difficulty of Tech mode
	adjust difficulty of PC training mode
	adjust vibrate level for mobile devices
	little optimized
	bugs fixed

0.7.16: Game Detail Update
	change rules of custom puzzle mode
	change rules of TSD mode
	better pausing
	speed optimized
	adjust difficulty of dig mode
	bugs fixed

0.7.15: Puzzle Update
	can make puzzle by drawing mode
	can pause game with animation
	change icon of "Functional key"
	speed optimized
	bugs fixed

0.7.14: Creativity Update
	drawing mode in custom game
	adjustable virtual keys with mouse
	speed optimized
	rotate also create shade

0.7.13+: Small Update
	change difficulty of survivor mode
	little game rule change
	bugs fixed(AI control error)

0.7.13:
	new:
		Chinese game name: 方块研究所
		SUPER COOL instant moving effect
		new b2b bar style & animation
		new transition animation
	changed:
		change difficulty of master mode
		adjust delay algorithm(probably cause controlfeel changing, please reset your DAS setting)
		code reconstructed
		debug key change to F8
	fixed:
		error when seq=his
		error game area size of custom opponent

0.7.12: Total Update
	AI learned to switch attack mode
	seperate master mode from marathon mode
	master mode more interesting
	countdown line in sprint mode
	smooth BGM swapping
	new garbage buffer
	new harddrop&lock SFX feel
	a bit change of rotate system
	grid switch
	swap target by combo key/press
	some Chinese translaton editted
	[reconstruct event system]

0.7.11: Total Update
	some Chinese translaton editted
	add bone block in 2 hardest marathon(new block-fresh system)
	play sound when get badges in royale mode
	change b2b indicator display method
	more difficulty of blind mode
	colorful garbage lines
	clearer attacking pointer
	fix 6 next in classic mode
	add QR code in help page
	change some detials

0.7.10: Small Update
	full Chinese translation
	add Classic mode
	change O spin's behaviour
	bugs fixed

0.7.9: O-spin Update
	O spin is a lie
	better attacking pointer
	language system
	change rotate system
	change BGM&BG set
	code optimized
	bugs fixed

0.7.8: Performance Update
	GPU usage decreased much more than before
	add virtual key animation
	display player's rank after death in royale mode
	fix sequence error of PC training mode
	adjust difficulty of suvivor mode
	code optimized
	bugs fixed

0.7.7: Mode Update
	add dig mode
	add survivor mode
	combine some modes
	change some GUI
	more SFXs
	bugs fixed

0.7.6: Mode Update
	new font
	add DIFFICULTY selection
	virtual keys give visual feedback(PC/phone)
	add vibration
	add default set of visual keys
	add tech mode
	add drought mode
	better GUI&change speed&BGM in royale mode
	more FXs in royale mode
	fix all attacking bug of royale mode
	change sequence of TSD-only mode to bag7

0.7.5: Total Update
	reduce difficuly of PC training mode, and add more patterns
	reduce difficuly of death mode
	add PC challenge mode
	swapping attack mode for royale mode(AI always use 'Random')
	royale mode use less GPU
	new GUI of royale mode
	add intro scene
	soft scene swapping
	adjust other details
	change game icon
	adjust GUI of royale mode
	change sequence of TSD-only mode
	royale mode use LESS GPU

0.7.4: Bug Update
	add a lot of bugs

0.7.3: Game Detail Update
	add infinite target in custom
	fix TSD-only mode result+1 when finishing with a wrong clear
	change sequence generator of TSD-only mode
	GUI position editted
	Fix Screen flow
	smarter AI

0.7.2: Mode Update
	add PC training mode
	add TSD-only mode
	remove non-sense s/z spin double
	GUI position editted
	grid BG changed
	smarter AI
]=]

local find,sub=string.find,string.sub
local L,c={},0--list, \n counter,
local p,p1=1,0--cut start/end pos
local EOF=#S

while true do
	p1=find(S,"\n",p1+1)
	c=c+1
	if c==23 or p1==EOF then
		L[#L+1]=sub(S,p,p1-1)
		if p1==EOF then return L end
		p=p1+1
		c=0
	end
end