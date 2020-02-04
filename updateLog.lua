local S=[=[
Patron(rmb10+):
	gggf/T080/Ykzl/zxc
	[D*a]?

Future outlook:
	Normal Things:
		powerinfo switch
		splashing block
		ajustable next count
		new mode system
		custom block color/direction
		combo mode
		bigbang mode
		TTT mode
		custom block sequence
		CC smarter(think of gaebage buffer)
		game recording
		new AI:task-Z
		auto GUI in any screen size

	Technical things:
		Encrypt source code(compile to byte code)
		infinite 1v1
		square mode
		more FXs & 3d features & animations

0.7.33+:
	MORE POWERFUL 9-stack AI
	add stereo-setting slider
	code optimized
	bug fixed
0.7.32:
	Blind-GM now show section directly
	easier&more standard classic mode
	can switch Virtualkey's auto dodging
	in-game setting
	code optimized
	bug fixed
0.7.31:
	stereo system
	fixed a problem in finesse calculating
0.7.30:
	auto-tracking virtual key,adjustable parameters!
	can switch on/off virtuakeys
	add 7 more key
	better finesse rate calculating
	block generating position on Y-axis changed
	new icon for android
	can use preset in custom mode with keyboard
	adjusted GUI
	many bug fixed
0.7.28:
	add fineese check(almost useful)
	code optimized
0.7.27:
	super O transform system
	optimized light system(no used)
	bug fixed
0.7.26:
	new skin
	import light lib
	many bug fixed
0.7.25:
	demo play at main menu
	ALMOST reconstructed WHOLE PLAYER SYSTEM,NEED TEST
	many bug fixed
0.7.24(0.7.23):
	REMAKE ALL BGM!
	more settings with brand new GUI!
	new mode:Master-Final
	new modes:attacker & defender(not survivor!)
	add restart button when pause
	Code Clear added,face it bravely!(Windows only)
	change falling animation
	new GUI details
	louder sound
	code optimized
	many bugs fixed
0.7.22:
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
0.7.21:
	new title image
	more GUI details
	many bugs fixed
0.7.20:
	add music room
	change block/space apperance in draw mode
	field shake animation
	default sets of custom options
	can set BG/BGM in custom mode
	bug fixed
0.7.19:
	Secret option!
	macOS version!
	add C4W train mode
	rendering of royale mode optimized again
	add "free cell" in draw mode
	add 2 new block skins
	new difficulty in infinite mode
	new background/sound effect in master mode
	bug fixed
0.7.18:
	3 new block skins!(one skin origional by Miya(nya~))
	better restarting(to prevent mistakenly touching)
	switch display of puzzle mode
	adjust UI
	code optimized
	default custom options changed to as infinite mode
0.7.17:
	display game stats when pause
	more options in statistics
	better pausing
	adjust difficulty of Tech mode
	adjust difficulty of PC train mode
	adjust vibrate level for mobile devices
	little optimized
	bugs fixed
0.7.16:
	bugs fixed
	change rules of custom puzzle mode
	change rules of TSD mode
	better pausing
	speed optimized
	adjust difficulty of dig mode
0.7.15:
	can make puzzle by drawing mode
	can pause game with animation
	change icon of "Functional key"
	speed optimized
	bugs fixed
0.7.14:
	drawing mode in custom game
	can adjust virtual keys with mouse
	speed optimized
	rotate also create shade
0.7.13+:
	change difficulty of survivor mode
	little game rule change
	bugs fixed(AI control error)
0.7.13:
	Chinese game name:方块研究所
	SUPER COOL instant moving effect
	new b2b bar style & animation
	new transition animation
	change difficulty of master mode
	adjust delay algorithm(probably cause controlfeel changing,please reset your DAS setting)
	code reconstructed
	bugs fixed(error when seq=his,size of custom oppo)
	debug key change to F8
0.7.12:
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
0.7.11:
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
0.7.10:
	更完全的中文翻译
	add Classic mode
	change O spin's behaviour
	fix bugs
0.7.9:
	O spin is a lie
	better attacking pointer
	language system
	change rotate system
	change BGM&BG set
	code optimized
	fix bugs
0.7.8:
	GPU usage decreased much more than before
	add virtual key animation
	display player's rank after death in royale mode
	fix sequence error of PC train mode
	adjust difficulty of suvivor mode
	code optimized
	fix bugs
0.7.7:
	add dig mode
	add survivor mode
	combine some modes
	change some GUI
	more SFXs
	fix bugs
0.7.6:
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
0.7.5:
	reduce difficuly of PC training mode,and add more patterns
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
0.7.4:
	add a lot of bugs
0.7.3:
	add infinite target in custom
	fix TSD-only mode result+1 when finishing with a wrong clear
	change sequence generator of TSD-only mode
	GUI position editted
	Fix Screen flow
	smarter AI
0.7.2:
	add PC training mode
	add TSD-only mode
	remove non-sense s/z spin double
	GUI position editted
	grid BG changed
	smarter AI
]=]
local find,sub=string.find,string.sub
local L,n,p={},1,1
local EOF=#S
repeat
	p1=find(S,"\n",p)
	L[n]=sub(S,p,p1-1)
	n,p=n+1,p1+1
until p1==EOF
return L