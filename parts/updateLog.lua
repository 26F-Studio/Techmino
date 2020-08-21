local S=[=[
"Patron"(time ordered, may not accurate):
				[rmb100+]:
						那没事了(T6300)		加油啊,钉钉动了的大哥哥(T3228)
						弥佑瑶				Alan			幽灵3383
						靏鸖龘龘			込余			saki
						模电
		[rmb10+]:
				八零哥    蕴空之灵    gggf127    dtg    ThTsOd
				Fireboos    金巧    10元    立斐    Deep_Sea
				时雪    yyangdid    sfqr    心痕    Sasoric
				夏小亚    仁参    乐↗乐↘    喜欢c4w的ztcjoin
				面包    蠢熏    潘一栗    Lied    星街书婉    祝西
				829    e m*12    我永远爱白银诺艾尔(鹏    PCX
				kagura77    呆喂    GlowingEmbers    轩辕辚
				HimuroAki    TCV100    tech有养成系统了@7065
				HAGE KANOBU    闪电和拐棍    葡萄味的曼妥思
				世界沃德    蓝绿    天生的魔法师    琳雨空    T8779.易缄
				吃水榴莲    诗情画意    星姐阿夸双推Man暗炎    [*炎]
				[*Y]    aaa222    [**城]    cnDD    红桃老给
				昭庭玲秋    旋树墩    火花工作室    Cosine    天上_飞

		Thanks!!!

Future outlook:
		New modes:
				PUYO
				game tutorial
				finesse tutorial/exam(3next, 1pt/mino, drop to score)
				easy finesse (only revert current)
				game Abbr. test
				backfire
				round-based dig
				bigbang
				rhythm
				KPP-locked
				combo
				square
				field shifting(left/right)
				task survival
				dig practice
				dig zen
				symmetry
				hidden: sound only
				reverb (often repeat a piece many times)
				parkour
		Other:
				mod system with:
						block/field/up/low hidden
						next[1-n] hidden
						field flip(LR/UD)
						no fail(∞ lives)
				mini games:
						15 puzzle (with hidden mode)
						2048 (with next/deadly mode)
						mine sweeper
						tank battle
				new AI: task-Z
				'Encrypt'(compile to byte code)
				better drop FX
				60+ fps supporting
				in-game document
				game recording
				full-key control
				drag control for mobile device
				new widgets (joystick etc.)
				splashing block
				more graphic FXs & 3D features & animations
				network game

0.10.5: 特效更新 FX update
		新内容:
				瞬移特效独立为瞬降和移动(旋转)特效,增加移动特效滑条,各特效范围均为0~5
				增加两个莫名其妙的背景(放在无尽和限时打分)
				把之前不小心弄丢的自制蓝屏报错界面捡回来了
		改动:
				雷达图OPM参数改为ADPM
				调整J/L/I的踢墙表
				根据锁延刷新模式决定锁延指示条颜色
				增加无尽挖掘连挖提示,挖完后下一波立即升起
				new English translation by @MattMayuga#8789
				修改100/400/1000L的评级要求
				支持加载部分老版本存档
				软件锁界面出现时机调整,按钮位置调整
				调整混战模式倍率影响边框颜色的范围
		代码:
				重命名大多数背景
				重构createXxxFX函数
		修复:
				几个设置大标题样式统一
				有消行延迟+出块等待时连续硬降出现神秘现象
				垃圾行上涨不刷新ghost
				粘贴序列bug
				可以用键盘复制粘贴序列
				每次启动游戏ai是一样的块序

0.10.4: 漏洞修复 Bug Fix
		代码:
				修改场景模块方法名
				软件锁变量名从lock改为appLock
				使用linter整理代码
				重构锁延相关代码,freshgho,freshLockDelay,freshMinY合并为freshBlock
		修复:
				BPM120~180之间分数计算不正确
				进不指定锁延的模式就报错
				锁延机制错误(这次真修好了)
				游戏结束后马上暂停并解除还会自动暂停(之前没修好)
				提前硬降失效

0.10.3: 软件锁 APP Lock
		新内容:
				设置增加软件锁选项,打开游戏后进入伪装界面
		改动:
				剩余锁延重置次数指示器改为长方形
				debug界面改为重置界面,进入方法修改
				游戏设置页面布局更改
				语音音量条改为无刻度
				取消快速重开设置,游戏过程中长按重开,结束后开局一秒内点击重开
		修复:
				无尽挖掘报错
				极简错误提示声音太小
				修复回放也计入排行榜
				回放时暂停不打断玩家操作
				c4w练习的lunatic分数bug

0.10.2: 锁延修复 Lock Delay Fixed
		改动:
				锁延机制再修正
				"失败"改为"游戏结束"
		修复:
				纠正部分rank文件转换错误
				模式文件使用玩家的随机器以正确回放
				游戏结束后马上暂停并解除还会自动暂停
				改设置后回放错误
				字库缺字

0.10.1: 细节更新 Details update
		新内容:
				新语言:就这?
				新语言配套阴阳怪气Tips
				光标点击动画
				锁延机制修正
				锁延和可刷新次数可视化
				两个新皮肤
		改动:
				BGM重新分配
				rockblock音乐微调
				无刻度滑条
				音量曲线调整
		代码:
				玩家act函数addL/R更名zangiL/R
				玩家属性y_img更名imgY
				旋转中心坐标向左下修正负一
		修复:
				改设置后回放错误
				0.10.0的错误序列生成器
				按R重开后濒死预警不消失
				GM模式通关一直触发win
				手机端屏幕方向错误(也许修复了)
				控制设置das/arr预览错误

0.10.0: 回放更新 Replay Update
		新内容:
				更新后跳转到此页面
				单局回放,要是有cc会出问题,以后再说
				支持复制场地+序列
				修改连击攻击力算法,调整mini的属性
				自定义序列显示方块颜色
				自定义序列菜单ui调整
				新控件:简化按钮 (用于自定义序列等菜单)
		改动:
				Chinese update log
				控件动效优化
				极简错误音效调整
				模电HBM历史性同框
				spin消3的分数下调
				暂停界面数据显示格式和布局微调
				初心/上级20G评级要求改动,清除高分榜
				100L/400L评级要求改动
				这个页面更易读了
		代码:
				帧率控制代码调整,运行可能更流畅(反正不会比以前卡)
				修改部分玩家方法名
				注释更规范了
		修复:
				一些文本小错误
				自定义序列相关的闪退
				按键跟踪设置界面闪退
				五联块成绩排序错误
				pc训练方块ghost浮空
				i平放顶层消1的奇怪行为
				玩家掉出屏幕过程中绘制场地时剪裁不正确
				限时打分的时间条和hold重合

0.9.2: Global Update
		new:
				independent spawning volume setting
				select widgets with arrow keys
				display last played mode on title screen
				new blind mode (extremely hard)
				mode map changed
				[debug page]
		change:
				three little better backgrounds instead of stupid rainbow
				kick list of i-piece little changed
				no extremly huge radar chart in pause page
				new in-game layout
				new setting page layout
		fixed:
				error in infinite-dig
				CC's sudden death sometimes
				missing the top line when paste field
				error when AI used all nexts
				error when play default-bag game after played with custom sequence

0.9.1: Piece Spawn SFX
		new:
				piece spawn SFX
		fixed:
				error when moving [nothing] when arr>0
				error when complete master-advanced

0.9.0: Custom Sequence Update
		new:
				custom sequence
				new sequence type: loop & fixed
				many new tips
				more powerful watermark
				die animation in non-royale mode
				better in-game layout
		changed:
				mode name shown at the top of screen
				faster & harder attacker-ultimate
				time-based-rank for master-advanced
				little easier to get S in PC challenge (easy mode)
				easier to get S in infinite mode, c4w, PC
				harder to unlock sprint-400/1000
				harder to get high rank of sprint-1000
				harder drought-lunatic
		code:
				file sorted
				task system rewrited, now perfect (maybe)
				remove scissors/blendMode setting in drawing players
		fixed:
				screen orientation sometimes error after wake up the phone
				hard move won't deactive "spin"
				do not clear dead enemies' field
				show ghost's center when ghost is off
				error when get a PC in drought-lunatic

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
				show "offset" in stat (only in total stat page)
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

0.8.19/20: Fantastic Global Update+
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

0.8.18: Details Update+
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
		I sequence initializing error when face setting changed
				DAS error

0.8.15: Bug Fixed
		new:
				can switch line-clear text now
				new attack way "Clear"(half-clear)
				give every update a name!
		changed:
				animation time of lock effect little changed
				bone block of ball-skin changed
		I change target more slowly
		uthor.dignity-=1
		fixed:
				180° I spin kicklist error
		I will kill itself when spawn dir. of mino changed
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
				background now is cool space with "planets" and "stars", instead of falling tetrominos
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

0.8.4: Miya Update+
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

0.7.23/24: Sound Update
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
				error when sequence mode is his
				error game area size of custom opponent

0.7.12: Global Update
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

0.7.11: Global Update
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

0.7.5: Global Update
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
local L,c={},0--List, \n counter,
local p,p1=1,0--Cut start/end pos
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