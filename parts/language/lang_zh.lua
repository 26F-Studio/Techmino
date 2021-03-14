local c=COLOR
return{
	back="返回",
	anykey="按任意键继续",
	sureQuit="再按一次退出",
	newVersion="感谢更新!更新内容如下",
	httpTimeout="网络连接超时!",
	newDay="新的一天,新的开始~",
	playedLong="已经玩很久了!注意休息!",
	playedTooMuch="今天玩太久啦!打块好玩但也要适可而止哦~",

	atkModeName={"随机","徽章","击杀","反击"},
	royale_remain="剩余 $1 名玩家",
	cmb={nil,"1 Combo","2 Combo","3 Combo","4 Combo","5 Combo","6 Combo","7 Combo","8 Combo","9 Combo","10 Combo!","11 Combo!","12 Combo!","13 Combo!","14 Combo!","15 Combo!","16 Combo!","17 Combo!","18 Combo!","19 Combo!","MEGACMB"},
	spin="-spin ",
	clear={"single","double","triple","Techrash","Pentcrash","Hexcrash"},
	mini="Mini",b2b="B2B ",b3b="B2B2B ",
	PC="Perfect Clear",HPC="Half Clear",
	hold="暂存",next="下一个",
	replaying="[回放]",

	stage="关卡 $1",
	great="Great!",
	awesome="Awesome.",
	almost="Almost!",
	continue="Continue.",
	maxspeed="最高速度",
	speedup="速度加快",
	missionFailed="非任务消除",

	speedLV="速度等级",
	line="行数",atk="攻击",eff="效率",
	rpm="RPM",tsd="T2",
	grade="段位",techrash="Techrash",
	wave="波数",nextWave="下一波",
	combo="Combo",maxcmb="Max Combo",
	pc="Perfect Clear",ko="KO",

	win="胜利",
	finish="完成",
	gameover="游戏结束",
	pause="暂停",
	pauseCount="暂停统计",
	finesse_ap="All Perfect",
	finesse_fc="Full Combo",

	page="页面:",

	ai_fixed="不能同时开启AI和固定序列",
	ai_prebag="不能同时开启AI和自定义序列",
	ai_mission="不能同时开启AI和自定义任务",
	saveDone="保存成功!",
	saveError="保存失败:",
	loadError="读取失败:",
	switchSpawnSFX="请开启方块出生音效",
	ranks={"D","C","B","A","S"},

	needRestart="重新开始以生效",

	exportSuccess="导出成功",
	importSuccess="导入成功",
	dataCorrupted="数据损坏",

	VKTchW="触摸点权重",
	VKOrgW="原始点权重",
	VKCurW="当前点权重",

	noScore="暂无成绩",
	highScore="最佳成绩",
	newRecord="打破纪录",

	getNoticeFail="拉取公告失败",
	getVersionFail="检测新版本失败",
	oldVersion="最新版本$1可以下载了!",

	httpCode="Http码",
	jsonError="json错误",

	noUsername="请填写用户名",
	wrongEmail="邮箱格式错误",
	noPassword="请填写密码",
	diffPassword="两次密码不一致",
	registerSuccessed="注册成功!",
	registerFailed="注册失败",
	loginSuccessed="登录成功",
	loginFailed="登录失败",
	accessSuccessed="身份验证成功",
	accessFailed="身份验证失败",
	wsSuccessed="WS连接成功",
	wsFailed="WS连接失败",
	wsDisconnected="WS连接断开",
	wsNoConn="WS未连接",
	wsClose="WS被断开: ",
	waitNetTask="正在连接,请稍候",

	createRoomTooFast="创建房间太快啦,等等吧",
	createRoomSuccessed="创建房间成功!",
	joinRoom="进入房间",
	leaveRoom="离开房间",
	notReady="等待中",
	beReady="准备",
	champion="$1 获胜",
	chatRemain="人数:",
	chatStart="------消息的开头------",
	chatHistory="------以上是历史消息------",

	noRooms="一个房间都没有哎...",
	roomsCreateFailed="创建房间失败",
	roomsFetchFailed="拉取房间列表失败",

	errorMsg="Techmino遭受了雷击,需要重新启动.\n我们已收集了一些错误信息,你可以向作者进行反馈.",

	modInstruction="选择你要使用的Mod!\n不同Mod会用不同的方式改变初始游戏规则(可能导致不能正常游玩)\n来开发新玩法或者挑战自我吧!\n提醒:开启一些Mod会让成绩无效,你也可以用键盘开关Mod,按住shift反向",
	modInfo={
		next="Next数量:\n强制使用Next的个数",
		hold="Hold数量:\n强制使用Hold的个数",
		hideNext="隐藏Next:\n隐藏前几个Next",
		infHold="无限Hold:\n可以无限制使用Hold",
		hideBlock="隐藏方块:\n使当前方块不可见",
		hideGhost="隐藏阴影:\n使提示阴影不可见",
		hidden="隐形:\n方块将会在锁定之后隐形",
		hideBoard="遮挡:\n遮挡部分或者全部场地",
		flipBoard="翻转:\n将场地以一定方式翻转显示",
		dropDelay="重力:\n强制使用下落速度(单位:帧/格)",
		lockDelay="锁延:\n强制使用锁定延迟(单位:帧)",
		waitDelay="出块等待:\n出块后的等待时间(单位:帧)",
		fallDelay="消行等待:\n消行后的等待时间(单位:帧)",
		life="生命数:\n修改初始生命数量",
		forceB2B="强制B2B:\nB2B条掉到启动线以下就会结束游戏",
		forceFinesse="强制极简:\n非极简操作将强制结束游戏",
		tele="瞬移:\n强制启用0移动延迟",
		noRotation="无旋转:\n禁用旋转按键",
		noMove="无移动:\n禁用移动按键",
		customSeq="指定序列:\n强制使用某种序列",
		pushSpeed="涨行速度:\n改变垃圾行升起的速度(单位:格/帧)",
		boneBlock="骨块:\n使用骨块进行游戏",
	},
	pauseStat={
		"时间:",
		"按键/旋转/暂存:",
		"落块:",
		"消行/挖掘:",
		"攻击/挖掘攻击:",
		"上涨/接收/抵消:",
		"消除:",
		"Spin:",
		"B2B/B3B/PC/HPC:",
		"Finesse:",
	},
	radar={"DEF","OFF","ATK","SEND","SPD","DIG"},
	radarData={
		"D'PM",
		"ADPM",
		"APM",
		"SPM",
		"L'PM",
		"DPM",
	},
	stat={
		"游戏运行次数:",
		"游戏局数:",
		"游戏时间:",
		"按键/旋转/暂存:",
		"方块/消行/攻击:",
		"接收/抵消/上涨:",
		"挖掘/挖掘攻击:",
		"效率/挖掘效率:",
		"满贯/大满贯:",
		"全/半清:",
		"多余操作/极简率:",
	},
	help={
		"既然你能玩到这个游戏,应该也不需要什么帮助吧?",
		"这只是一个普通的方块游戏,请勿称此游戏为某某某方块",
		"从TO/C2/KOS/TGM3/JS等方块获得过灵感",
		"",
		"使用LOVE2D引擎",
		"错误或者建议请附带截图发送到内测群或者作者邮箱~",
		"仅通过内测群1127702001进行免费下载/更新",
		"其他渠道获得游戏皆有被修改/加广告/植入病毒的风险,程序只申请了振动&联网权限!",
		"若由于被修改的本游戏产生的各种损失作者不负责(我怎么负责啊跟我有啥关系)",
		"请从正规途径获得最新版,游戏现为免费,不过有打赏当然感谢啦~",
	},
	staff={
		"作者:MrZ  邮箱:1046101471@qq.com",
		"使用LOVE2D引擎",
		"",
		"程序: MrZ, Particle_G, [蓝绿, FinnTenzor]",
		"美术: MrZ, ScF, [Gnyar, 旋律星萤, T0722]",
		"音乐: MrZ, [T0722]",
		"音效/语音: Miya, Naki, MrZ",
		"测试: 思竣  演出: 模电, HBM",
		"翻译: User670, MattMayuga, Mizu, Mr.Faq, ScF",
		"",
		"特别感谢:",
		"User670, Big_True, Flyz, Farter, T9972",
		"蕴空之灵, Teatube, [所有内测人员]",
	},
	used=[[
	使用工具:
		Beepbox
		GFIE
		Goldwave
	使用库:
		Cold_Clear [MinusKelvin]
		json.lua [rxi]
		profile.lua [itraykov]
		simple-love-lights [dylhunn]
	]],
	support="支持作者",
	group="官方QQ群(如果没有被暗改的话就是这个):913154753",
	WidgetText={
		main={
			offline="单机游戏",
			online="联网游戏",
			custom="自定义",
			stat="统计信息",
			setting="设置",
			qplay="快速开始",
			lang="言/A",
			help="帮助",
			quit="退出",
			music="音乐室",
			sound="音效室",
		},
		main_simple={
			sprint="40行",
			marathon="马拉松",
		},
		mode={
			mod="Mods (F1)",
			start="开始",
		},
		mod={
			title="Mods",
			reset="重置(tab)",
			unranked="成绩无效",
		},
		pause={
			setting="设置(S)",
			replay=	"回放(P)",
			save="保存(O)",
			resume=	"继续(esc)",
			restart="重新开始(R)",
			quit=	"退出(Q)",
		},
		net_menu={
			ffa="FFA",
			rooms="房间列表",
			chat="聊天室",
		},
		net_rooms={
			fresh="刷新",
			new="创建房间",
			join="加入",
			up="↑",
			down="↓",
		},
		net_game={
			ready="准备",
		},
		net_chat={
			send="发送",
		},
		setting_game={
			title="游戏设置",
			graphic="←画面设置",
			sound="声音设置→",

			ctrl="控制设置",
			key="键位设置",
			touch="触屏设置",
			reTime="开局等待时间",
			RS="旋转系统",
			layout="外观",
			autoPause="失去焦点自动暂停",
			swap="组合键切换攻击模式",
			fine="极简操作提示音",
			appLock="软件锁(密码6+26)",
			simpMode="简洁模式",
		},
		setting_video={
			title="画面设置",
			sound="←声音设置",
			game="游戏设置→",

			block="方块可见",
			smooth="平滑下落",
			upEdge="3D方块",
			bagLine="包分界线",

			ghost="阴影透明度",
			grid="网格",
			center="旋转中心透明度",

			lockFX="锁定特效",
			dropFX="下落特效",
			moveFX="移动特效",
			clearFX="消除特效",
			splashFX="溅射特效",
			shakeFX="晃动特效",
			atkFX="攻击特效",
			frame="绘制帧率",

			text="消行文本",
			score="分数动画",
			warn="死亡预警",
			highCam="超屏视野",
			nextPos="生成预览",
			fullscreen="全屏",
			bg="背景",
			power="电量显示",
		},
		setting_sound={
			title="声音设置",
			game="←游戏设置",
			graphic="画面设置→",

			sfx="音效",
			spawn="方块生成",
			warn="危险警告",
			bgm="音乐",
			stereo="立体声",
			vib="振动",
			voc="语音",
			cv="语音包",
			apply="应用",
		},
		setting_control={
			title="控制设置",
			preview="预览",

			das="DAS",arr="ARR",dascut="DAS打断",
			sddas="软降DAS",sdarr="软降ARR",
			ihs="提前Hold",
			irs="提前旋转",
			ims="提前移动",
			reset="重置",
		},
		setting_key={
			a1="左移",
			a2="右移",
			a3="顺时针旋转",
			a4="逆时针旋转",
			a5="180°旋转",
			a6="硬降",
			a7="软降",
			a8="暂存",
			a9="功能键1",
			a10="功能键2",
			a11="左瞬移",
			a12="右瞬移",
			a13="软降到底",
			a14="软降一格",
			a15="软降四格",
			a16="软降十格",
			a17="落在最左",
			a18="落在最右",
			a19="列在最左",
			a20="列在最右",
			restart="重新开始",
		},
		setting_skin={
			title="外观设置",
			spin1="R",spin2="R",spin3="R",spin4="R",spin5="R",spin6="R",spin7="R",
			skinR="重置配色",
			faceR="重置方向",
		},
		setting_touch={
			default="默认组合",
			snap="吸附",
			option="选项",
			size="大小",
		},
		setting_touchSwitch={
			b1=	"左移:",	b2="右移:",		b3="顺时针旋转:",	b4="逆时针旋转:",
			b5=	"180°旋转:",b6="硬降:",		b7="软降:",			b8="暂存:",
			b9=	"功能键1:",	b10="功能键2:",b11="左瞬移:",		b12="右瞬移:",
			b13="软降到底:",b14="软降一格:",b15="软降四格:",	b16="软降十格:",
			b17="落在最左:",b18="落在最右:",b19="列在最左:",	b20="列在最右:",
			norm="标准",
			pro="专业",
			hide="显示虚拟按键",
			track="按键自动跟踪",
			sfx="按键音效",
			vib="按键振动",
			icon="图标",
			tkset="跟踪设置",
			alpha="透明度",
		},
		setting_trackSetting={
			VKDodge="自动避让",
		},
		customGame={
			title="自定义游戏",
			subTitle="基本",
			defSeq="默认序列",
			noMsn="无任务",

			drop="下落延迟",
			lock="锁定延迟",
			wait="出块等待",
			fall="消行延迟",

			bg="背景",
			bgm="音乐",

			copy="复制场地+序列+任务",
			paste="粘贴场地+序列+任务",
			clear="开始-消除",
			puzzle="开始-拼图",

			advance="更多设置(A)",
			mod="Mods",
			field="场地编辑(F)",
			sequence="序列编辑(S)",
			mission="任务编辑(M)",
		},
		custom_advance={
			title="自定义游戏",
			subTitle="高级",

			nextCount="Next",
			holdCount="Hold",
			infHold="无限Hold",
			phyHold="物理Hold",
			bone="骨块",

			fieldH="场地高度",
			ospin="O-spin",
			deepDrop="穿墙软降",
			target="目标行数",
			visible="能见度",
			freshLimit="锁延刷新限制",
			easyFresh="普通刷新锁延",
			fineKill="强制极简",
			b2bKill="强制B2B",
			opponent="对手",
			life="命数",
			pushSpeed="上涨速度",
		},
		custom_field={
			title="自定义游戏",
			subTitle="场地",

			any="不定",
			space="×",
			smartPen="智能",

			pushLine="增加一行(K)",
			delLine="消除行(L)",

			copy="复制",
			paste="粘贴",
			clear="清除",
			demo="不显示×",

			newPage="新页面(N)",
			delPage="删除页面(M)",
			prevPage="上一页面",
			nextPage="下一页面",
		},
		custom_sequence={
			title="自定义游戏",
			subTitle="序列",

			sequence="序列",

			Z="Z",S="S",J="J",L="L",T="T",O="O",I="I",left="←",right="→",ten="→→",backsp="<X",reset="清空",
			Z5="Z5",S5="S5",P="P",Q="Q",F="F",E="E",T5="T5",U="U",I3="I3",C="C",rnd="随机",
			V="V",W="W",X="X",J5="J5",L5="L5",R="R",Y="Y",N="N",H="H",I5="I5",I2="I2",O1="O1",
			copy="复制",paste="粘贴",
		},
		custom_mission={
			title="自定义游戏",
			subTitle="任务",

			_1="1",_2="2",_3="3",_4="4",
			any1="any1",any2="any2",any3="any3",any4="any4",
			PC="PC",
			Z1="Z1",S1="S1",J1="J1",L1="L1",T1="T1",O1="O1",I1="I1",
			Z2="Z2",S2="S2",J2="J2",L2="L2",T2="T2",O2="O2",I2="I2",
			Z3="Z3",S3="S3",J3="J3",L3="L3",T3="T3",O3="O3",I3="I3",
			O4="O4",I4="I4",
			left="←",right="→",
			ten="→→",
			backsp="<X",
			reset="R",
			copy="复制",
			paste="粘贴",
			mission="强制任务",
		},
		music={
			title="音乐室",
			arrow="→",
			now="正在播放:",

			bgm="BGM",
			up="↑",
			play="播放",
			down="↓",
		},
		help={
			manual="说明书",
			dict="小Z词典",
			staff="制作人员",
			his="更新历史",
			qq="作者QQ",
		},
		dict={
			title="小Z方块词典",
			link="打开链接",
			up="↑",
			down="↓",
		},
		stat={
			path="打开存储目录",
			save="用户档案管理",
		},
		login={
			title="登录",
			register="注册",
			email="邮箱",
			password="密码",
			login="登录",
		},
		register={
			title="注册",
			login="登录",
			username="用户名",
			email="邮箱",
			password="密码",
			password2="确认密码",
		},
		account={
			title="账户",
		},
		sound={
			title="音效室",
			sfx="音效",
			voc="语音",

			move="移动",
			lock="锁定",
			drop="硬降",
			fall="行落下",
			rotate="旋转",
			rotatekick="旋转进洞",
			hold="Hold",
			prerotate="提前旋转",
			prehold="提前Hold",
			_pc="全消",

			clear1="Single",
			clear2="Double",
			clear3="Triple",
			clear4="Techrash",
			spin0="spin 0",
			spin1="spin 1",
			spin2="spin 2",
			spin3="spin 3",

			_1="Single",
			_2="Double",
			_3="Triple",
			_4="Techrash",
			z0="Z-spin",
			z1="Z-spin 1",
			z2="Z-spin 2",
			z3="Z-spin 3",
			s0="S-spin",
			s1="S-spin 1",
			s2="S-spin 2",
			s3="S-spin 3",

			j0="J-spin",
			j1="J-spin 1",
			j2="J-spin 2",
			j3="J-spin 3",
			l0="L-spin",
			l1="L-spin 1",
			l2="L-spin 2",
			l3="L-spin 3",

			t0="T-spin",
			t1="T-spin 1",
			t2="T-spin 2",
			t3="T-spin 3",
			o0="O-spin",
			o1="O-spin 1",
			o2="O-spin 2",
			o3="O-spin 3",

			i0="I-spin",
			i1="I-spin 1",
			i2="I-spin 2",
			i3="I-spin 3",

			mini="Mini",
			b2b="B2B",
			b3b="B3B",
			pc="PC",
		},
		app_15p={
			reset="打乱",
			color="颜色",
			blind="盲打",
			slide="滑动操作",
			pathVis="路径显示",
			revKB="键盘反向",
		},
		app_schulteG={
			reset="重来",
			rank="尺寸",
			blind="盲打",
			disappear="消失",
			tapFX="点击动画",
		},
		app_pong={
			reset="重置",
		},
		app_AtoZ={
			level="关卡",
			keyboard="键盘",
			reset="重置",
		},
		app_UTTT={
			reset="重置",
		},
		app_2048={
			reset="重置",
			blind="盲打",
			tapControl="点击操作",

			skip="跳过回合",
		},
		app_ten={
			reset="重置",
			next="预览",
			blind="盲打",
			fast="速打",
		},
		app_dtw={
			reset="重置",
			mode="模式",
		},
		savedata={
			exportUnlock="导出地图进度",
			exportData="导出统计数据",
			exportSetting="导出设置",
			exportVK="导出虚拟按键布局",

			importUnlock="导入地图进度",
			importData="导入统计数据",
			importSetting="导入设置",
			importVK="导入虚拟按键布局",

			reset="重置?",
			resetUnlock="重置解锁/等级",
			resetRecord="重置纪录",
			resetData="重置统计",
		},
	},
	modes={
		["sprint_10l"]=			{"竞速",		"10L",		"消除10行"},
		["sprint_20l"]=			{"竞速",		"20L",		"消除20行"},
		["sprint_40l"]=			{"竞速",		"40L",		"消除40行"},
		["sprint_100l"]=		{"竞速",		"100L",		"消除100行"},
		["sprint_400l"]=		{"竞速",		"400L",		"消除400行"},
		["sprint_1000l"]=		{"竞速",		"1000L",	"消除1000行"},
		["sprintPenta"]=		{"竞速",		"五连块",	"伤脑筋十八块"},
		["sprintMPH"]=			{"竞速",		"MPH",		"纯随机\n无预览\n无暂存"},
		["dig_10l"]=			{"挖掘",		"10L",		"挖掘10行"},
		["dig_40l"]=			{"挖掘",		"40L",		"挖掘40行"},
		["dig_100l"]=			{"挖掘",		"100L",		"挖掘100行"},
		["dig_400l"]=			{"挖掘",		"400L",		"挖掘400行"},
		["dig_1000l"]=			{"挖掘",		"1000L",	"挖掘1000行"},
		["drought_n"]=			{"干旱",		"100L",		"你I没了"},
		["drought_l"]=			{"干旱",		"100L",		"后 妈 发 牌"},
		["marathon_n"]=			{"马拉松",		"普通",		"200行加速马拉松"},
		["marathon_h"]=			{"马拉松",		"困难",		"200行高速马拉松"},
		["solo_e"]=				{"单挑",		"简单",		"打败AI"},
		["solo_n"]=				{"单挑",		"普通",		"打败AI"},
		["solo_h"]=				{"单挑",		"困难",		"打败AI"},
		["solo_l"]=				{"单挑",		"疯狂",		"打败AI"},
		["solo_u"]=				{"单挑",		"极限",		"打败AI"},
		["techmino49_e"]=		{"49人混战",	"简单",		"49人混战,活到最后"},
		["techmino49_h"]=		{"49人混战",	"困难",		"49人混战,活到最后"},
		["techmino49_u"]=		{"49人混战",	"极限",		"49人混战,活到最后"},
		["techmino99_e"]=		{"99人混战",	"简单",		"99人混战,活到最后"},
		["techmino99_h"]=		{"99人混战",	"困难",		"99人混战,活到最后"},
		["techmino99_u"]=		{"99人混战",	"极限",		"99人混战,活到最后"},
		["round_e"]=			{"回合制",		"简单",		"下棋模式"},
		["round_n"]=			{"回合制",		"普通",		"下棋模式"},
		["round_h"]=			{"回合制",		"困难",		"下棋模式"},
		["round_l"]=			{"回合制",		"疯狂",		"下棋模式"},
		["round_u"]=			{"回合制",		"极限",		"下棋模式"},
		["master_beginner"]=	{"大师",		"疯狂",		"20G初心者练习"},
		["master_advance"]=		{"大师",		"极限",		"上级者20G挑战"},
		["master_final"]=		{"大师",		"终点",		"究极20G:无法触及的终点"},
		["master_phantasm"]=	{"大师",		"虚幻",		"虚幻20G:???"},
		["GM"]=					{"宗师",		"GM",		"成为方块大师"},
		["rhythm_e"]=			{"节奏",		"简单",		"200行低速节奏马拉松"},
		["rhythm_h"]=			{"节奏",		"困难",		"200行中速节奏马拉松"},
		["rhythm_u"]=			{"节奏",		"极限",		"200行高速节奏马拉松"},
		["blind_e"]=			{"隐形",		"半隐",		"不强大脑"},
		["blind_n"]=			{"隐形",		"全隐",		"挺强大脑"},
		["blind_h"]=			{"隐形",		"瞬隐",		"很强大脑"},
		["blind_l"]=			{"隐形",		"瞬隐+",	"最强大脑"},
		["blind_u"]=			{"隐形",		"啊这",		"你准备好了吗"},
		["blind_wtf"]=			{"隐形",		"不会吧",	"还没准备好"},
		["classic_fast"]=		{"高速经典",	"CTWC",		"高速经典"},
		["survivor_e"]=			{"生存",		"简单",		"你能存活多久?"},
		["survivor_n"]=			{"生存",		"普通",		"你能存活多久?"},
		["survivor_h"]=			{"生存",		"困难",		"你能存活多久?"},
		["survivor_l"]=			{"生存",		"疯狂",		"你能存活多久?"},
		["survivor_u"]=			{"生存",		"极限",		"你能存活多久?"},
		["attacker_h"]=			{"进攻",		"困难",		"进攻练习"},
		["attacker_u"]=			{"进攻",		"极限",		"进攻练习"},
		["defender_n"]=			{"防守",		"普通",		"防守练习"},
		["defender_l"]=			{"防守",		"疯狂",		"防守练习"},
		["dig_h"]=				{"挖掘",		"困难",		"挖掘练习"},
		["dig_u"]=				{"挖掘",		"极限",		"挖掘练习"},
		["bigbang"]=			{"大爆炸",		"简单",		"All-spin 入门教程\n未制作完成,落块即通"},
		["c4wtrain_n"]=			{"C4W练习",		"普通",		"无 限 连 击"},
		["c4wtrain_l"]=			{"C4W练习",		"疯狂",		"无 限 连 击"},
		["pctrain_n"]=			{"全清训练",	"普通",		"简易PC题库,熟悉全清定式的组合"},
		["pctrain_l"]=			{"全清训练",	"疯狂",		"困难PC题库,强算力者进"},
		["pc_n"]=				{"全清挑战",	"普通",		"100行内刷PC"},
		["pc_h"]=				{"全清挑战",	"困难",		"100行内刷PC"},
		["pc_l"]=				{"全清挑战",	"疯狂",		"100行内刷PC"},
		["tech_n"]=				{"科研",		"普通",		"禁止断B2B"},
		["tech_n_plus"]=		{"科研",		"普通+",	"仅允许spin与PC"},
		["tech_h"]=				{"科研",		"困难",		"禁止断B2B"},
		["tech_h_plus"]=		{"科研",		"困难+",	"仅允许spin与PC"},
		["tech_l"]=				{"科研",		"疯狂",		"禁止断B2B"},
		["tech_l_plus"]=		{"科研",		"疯狂+",	"仅允许spin与PC"},
		["tech_finesse"]=		{"科研",		"极简",		"强制最简操作"},
		["tech_finesse_f"]=		{"科研",		"极简+",	"禁止普通消除,强制最简操作"},
		["tsd_e"]=				{"TSD挑战",		"简单",		"你能连续做几个TSD?"},
		["tsd_h"]=				{"TSD挑战",		"困难",		"你能连续做几个TSD?"},
		["tsd_u"]=				{"TSD挑战",		"极限",		"你能连续做几个TSD?"},
		["zen"]=				{"禅",			"200",		"不限时200行"},
		["ultra"]=				{"限时打分",	"挑战",		"在两分钟内尽可能拿到最多的分数"},
		["infinite"]=			{"无尽",		"",			"沙盒"},
		["infinite_dig"]=		{"无尽:挖掘",	"",			"挖呀挖呀挖"},
		["sprintFix"]=			{"竞速",		"无移动"},
		["sprintLock"]=			{"竞速",		"无旋转"},
		["marathon_bfmax"]=		{"马拉松",		"极限"},
		["custom_clear"]=		{"自定义",		"普通"},
		["custom_puzzle"]=		{"自定义",		"拼图"},
	},
	getTip={refuseCopy=true,
		"...,合群了就会消失,不合群世界毁灭(指game over",
		"...,合群了就会消失,但消失并非没有意义",
		"(a+b)³=a³+3a²b+3ab²+b³",
		"(RUR'U')R'FR2U'R'U'(RUR'F')",
		"【【【【【【",
		"\"TechOS\"",
		"↑↑↓↓←→←→BA",
		"$include<studio.h>",
		"0next 0hold.",
		"100行内23PC来一个?",
		"11renPC!",
		"1next 0hold",
		"1next 1hold!",
		"1next 6hold!",
		"2.182818284590452353",
		"2021年是Techmino联机元年",
		"20连PC来一个?",
		"20G本质是一个全新的游戏规则!",
		"29种块里28个都能spin你敢信?",
		"3.1415926535897932384 ? ? ?",
		"3next 1hold?",
		"40行世界纪录:15.654s by VinceHD",
		"626r/s",
		"6next 1hold!",
		"6next 6hold?!",
		"7宽三SZ架空捐了解一下",
		"把手机调到特殊的日期也许会发生什么",
		"报时机器人:新的一天开始了",
		"背景影响游玩?可以去设置关闭",
		"本游戏的一部分内容是国际合作的!",
		"本游戏的B2B是气槽机制,和传统的开关机制不一样哦",
		"本游戏可不是休闲游戏。",
		"本游戏内置了几个休(ying)闲(he)小游戏哦~去词典找找吧",
		"必须要软降才能到达的位置都会判定为极简操作",
		"别问游戏名怎么取的,问就是随便想的",
		"不同人打40行最合适的方式不一样,s1w/63/散消/s2w...",
		"不要盯着bug不放",
		"部分手机系统开启震动会导致严重卡顿",
		"彩色消除即将到来!",
		"草(日本语)",
		"成就系统在做了!",
		"触摸板打osu也很好!",
		"凑数tip什么时候能站起来!",
		"打好块跟学习一样没有捷径,多练。",
		"大概还是有人会看tip的",
		"大满贯10连击消四全清!",
		"戴上耳机以获得最佳体验",
		"单手也能玩!",
		"低帧率会降低游戏体验",
		"点击添加标题",
		"点击添加副标题",
		"点击退出按钮会有极小概率会…",
		"电脑游玩自带按键显示~",
		"对编程有真·兴趣推荐Lua,安装无脑语法简单执行速度快",
		"对战游戏不是单机游戏,所以timing在对战里也非常重要!",
		"多年小游戏玩家表示痛恨假加载,启动动画主要是在加载资源",
		"多hold现代块又回来了!",
		"物理hold了解一下",
		"发现有个\"隐形\"皮肤了吗",
		"方块不能吃",
		"方块教会我们,合群了就会消失,...",
		"方块默认出现的方向都是重心在下哦",
		"服务器随时爆炸",
		"感觉自己明明按键了但是没反应?你真的按到了吗?",
		"感觉自己速度到上限了?试着把das调低一点",
		"感谢群友帮忙想tip",
		"感谢Orzmic为这个tip显示框提供灵感",
		"刚接触方块的话多玩玩就行,40行两分钟以外没啥好针对性练习的",
		"刚开始练全隐形可以尽量堆平,留一列消四",
		"隔断消除即将到来!",
		"各种画面细节选项都可以在设置里找到哦",
		"更换方块皮肤也许能帮助提升成绩?不懂,玄学",
		"更小的DAS和ARR拥有更高的操作上限(能控制得了的话)",
		"更新内容在游戏里和群公告都有写!",
		"攻击生效速度(从快到慢):消二/三,消四,spin,高连击",
		"官网在做了",
		"还能写些什么tip呢",
		"好像还没人能用脚打块打到一定水平",
		"好像可以把手机倒过来打场地旋转180...那还是不建议违反规则",
		"很有精神!",
		"混合消除即将到来!",
		"即使被顶到天上了也不要放弃,每一行垃圾都有可能成为你的武器",
		"极简率决定了你大约的速度上限和相等手速下的放块速度",
		"假如生活欺骗了你,不要悲伤,不要心急,还有块陪着你",
		"架空消除即将到来!",
		"建议使用双手游玩",
		"健康小贴士:不要熬夜,真的会猝死",
		"健康小贴士:玩游戏多眨眼,不然会干眼病",
		"键位是可以自定义的",
		"觉得移动速度太慢或太快,手感不好?快去设置调整DAS/ARR",
		"开启软件锁的时候别忘了密码是626",
		"看到更新历史上面的赞助榜了吗?喜欢本游戏的话可以给Z酱打赞助",
		"快去打一把100%极简看看会怎样",
		"六连块总共有…?那不重要,不会做的",
		"卖弱禁言警告",
		"每个块的出现方向可以自定义",
		"每个块的颜色可以自定义",
		"每个虚拟按键都可以隐藏/显示,尺寸也可调",
		"免费吃鸡方块",
		"喵!",
		"魔方也是方块(确信",
		"你的双手是为了你的一生服务的,而不是Techmino",
		"你今天的人品值是:0.22",
		"你今天的人品值是:0.26",
		"你今天的人品值是:0",
		"你今天的人品值是:12.7",
		"你今天的人品值是:22",
		"你今天的人品值是:26",
		"你今天的人品值是:28.3",
		"你今天的人品值是:35.5",
		"你今天的人品值是:6.26",
		"你今天的人品值是:62.6",
		"你今天的人品值是:87.2",
		"你今天的人品值是:89.5",
		"你今天的人品值是:9999%",
		"你今天的人品值是:"..math.random(100),
		"你可以从统计页面打开游戏存档目录",
		"你们考虑过Z酱的感受吗?没有!你们只考虑你自己。",
		"你知道吗:看主页机器人玩可能比较费电",
		"你知道吗:全程不使用任何旋转键完成40行模式是有可能的",
		"你知道吗:全程不使用左右移动键完成40行模式是有可能的",
		"你知道吗:停留在模式地图界面很费电",
		"你准备好了吗?",
		"请勿大力敲打设备!敲坏了就没有Techmino玩了",
		"请勿使用三只手游玩",
		"去玩别的方块的时候记得没有Ospin!",
		"全球应该没人能全S评价(大爆炸不算)",
		"三连块只有2种",
		"三岁通关困难马拉松",
		"少女祈祷中",
		"适度游戏益脑,沉迷游戏伤身,合理安排时间,享受健康生活",
		"手机玩也可以外接键盘哦",
		"术语不认识?去帮助-词典里查查吧",
		"四连块总共7种",
		"虽然极简连击和极简率计算看着很怪,但是很科学!",
		"提前旋转等功能可以用来救命",
		"天哪,我竟然是一条凑数tip",
		"挖掘能力在对战里非常非常非常重要!!!!",
		"玩到一半弹出消息框?快去设置禁止弹窗",
		"为了保护玩家们的健康,本游戏有一个临时的简易防沉迷系统!(不过估计你也触发不了/笑)",
		"为什么关卡那么少!因为前一模式成绩连D都没达到,再加把劲吧~",
		"我曾经在极度愤怒的时候15秒消了40行",
		"我们是不是第一个在方块游戏做tip的?",
		"我是一条凑数tip",
		"我也不知道分数有啥用应该只是好看的,建议别管他,只看关卡要求你做啥",
		"我也是一条凑数tip",
		"我一个滑铲就挖了个11renPC",
		"无聊翻翻设置是好习惯",
		"五连块总共18种",
		"希望极简率没事",
		"希望你们都能喜欢Z…哦不是,喜欢Techmino",
		"喜欢本游戏的话可以到应用商…好像没上架呢还",
		"享受Tech的特色旋转系统!",
		"旋转不是变形!请尽量灵活利用顺逆时针两个旋转键!",
		"学会使用两个旋转键,三个更好",
		"学习能力很重要,无论是学校知识还是玩游戏",
		"音乐使用beepbox制作",
		"音游方块是一家(暴论",
		"游戏使用love2d引擎制作",
		"游戏中左下角三个信息分别是分数/时间/极简连击数",
		"有建议的话可以把信息反馈给作者~",
		"有三个隐藏模式不能从模式地图进入,到处找找看吧",
		"有疑问? 先看设置有没有你想要的",
		"右边那个不是录像,是机器人实时在玩",
		"这里的极简判定不松不严,放心软降,小心hold!",
		"震惊,我只是一条凑数tip吗",
		"中国的方块起步晚,所以世界级高手很少…下一个会是你吗?",
		"注意到方块\"旋转\"的时候到底发生了些什么吗?",
		"自定义场地可以画图实现逐页演示",
		"总共有300多条tip哦",
		"作者40行sub26了",
		"作者电脑上装了9个方块",
		"作者浏览器收藏夹里有6个方块",
		"作者写不出那种很酷的音乐(哭",
		"ALLSPIN!",
		"Am G F G",
		"B2B2B???",
		"B2B2B2B并不存在..",
		"B2B2B2B存在吗?",
		"BT炮=beta炮=TCM-β炮",
		"c4w可不是在所有游戏里都很强哦",
		"c4w人竟是我自己",
		"c4w人竟在我身边",
		"cos(α+β)=CαCβ-SβSα",
		"cos²α-cos²β=-S(α+β)S(α-β)",
		"cos²α-sin²β=C(α+β)C(α-β)",
		"cos2α=C²α-S²α",
		"e^(pi*i)=-1",
		"e^(pi*i/2)=i",
		"e^(pi*i/4)=(1+i)/√2",
		"Farter:\"成天被夸赞'好玩'的\"",
		"Farter:\"可以形成方块圈子小中心话题,同作者一起衍生一些概念与梗的\"",
		"Farter:\"民间微创新\"",
		"Farter:\"民间音le与图案\"",
		"Farter:\"民间游戏设计\"",
		"Farter:\"是方块爱好者研究平台\"",
		"Farter:\"是方块萌新入坑接收器\"",
		"Farter:\"是居家旅行装逼必备\"",
		"Farter:\"是民间UI动效艺术作品\"",
		"Farter:\"是一滩散乱的代码组成的蜜汁结构\"",
		"Farter:\"它是现在的techmino已发布版本\"",
		"Farter:论方块的软工意义(就算这么小个范围内,各种取舍蒙混翻车现象都总会以很易懂的方式出现(",
		"fin neo iso 是满足tspin条件的特殊t2的名字",
		"if a==true",
		"l-=-1",
		"Let-The-Bass-Kick!",
		"pps-0.01",
		"sin(α+β)=SαCβ+SβCα",
		"sin²α-cos²β=-C(α+β)C(α-β)",
		"sin²α-sin²β=S(α+β)S(α-β)",
		"sin2α=2SαCα",
		"SΔABC=√(h(h-a)(h-b)(h-c)), h=(a+b+c)/2",
		"Tech生日不太清楚,那就定在2019.6.26吧",
		"Tech也有节日主题了哦",
		"Techmino = Technique + tetromino",
		"Techmino n.铁壳米诺(游戏名)",
		"Techmino安卓下载",
		"Techmino好玩!",
		"Techmino有一个Nspire-CX版本!",
		"Techmino在哪里下载",
		"Techminohaowan",
		"viod main[]",
		"while(false)",
		"Z酱竟是我自己",
		"Z酱累了,Z酱不想更新",
		"Z酱只是个写代码的,懂什么方块",
		"Z块等身抱枕来一个(x",
		{c.B,"BLUE"},
		{c.C,"<PURE ",c.grape,"MEMORY>"},
		{c.C,"15puzzle好玩!"},
		{c.C,"魔方好玩!"},
		{c.C,"扫雷好玩!"},
		{c.C,"泰拉瑞亚好玩!"},
		{c.C,"我的世界好玩!"},
		{c.C,"CYAN"},
		{c.C,"Orzmic好玩!"},
		{c.C,"Osu!好玩!"},
		{c.C,"Phigros好玩!"},
		{c.C,"VVVVVV好玩!"},
		{c.fire,"Cultris II也很好玩!"},
		{c.fire,"FIRE"},
		{c.fire,"Jstris也很好玩!"},
		{c.fire,"Nullpomino也很好玩!"},
		{c.fire,"Tetr.io也很好玩!"},
		{c.fire,"Tetr.js也很好玩!"},
		{c.fire,"Tetralegends也很好玩!"},
		{c.G,"快捷键: Alt+F4=关闭当前窗口"},
		{c.G,"快捷键: Alt+Tab=切换窗口"},
		{c.G,"快捷键: backspace=返回上一个文件目录"},
		{c.G,"快捷键: Ctrl+鼠标滚轮=缩放"},
		{c.G,"快捷键: Ctrl+A=全选"},
		{c.G,"快捷键: Ctrl+Alt+Z=查看所有qq消息"},
		{c.G,"快捷键: Ctrl+D=复制一份"},
		{c.G,"快捷键: Ctrl+F=查找"},
		{c.G,"快捷键: Ctrl+Tab=切换标签页"},
		{c.G,"快捷键: Ctrl+W=关闭当前标签页"},
		{c.G,"快捷键: shift+del=永久删除文件 (技术人员别杠)"},
		{c.grape,"GRAPE"},
		{c.grape,"T-spin!"},
		{c.grass,"GRASS"},
		{c.grey,"俄罗斯方块环游记也不错!"},
		{c.grey,"感谢Phigros提供部分tip模板("},
		{c.grey,"暂定段位:9"},
		{c.grey,"REGRET!!"},
		{c.lame,"LAME"},
		{c.lC,"26连T2来一个?"},
		{c.lC,"Xspin",c.W,"是啥"},
		{c.lGrape,"Naki",c.W," 可爱!"},
		{c.lGrey,"腱鞘炎警告"},
		{c.lGrey,"看起来是个计算器,其实…"},
		{c.lGrey,"没学过编曲,音乐都是自己瞎写的,觉得不好听就去设置关了吧"},
		{c.lGrey,"秘密数字:626"},
		{c.lGrey,"你有一个好"},
		{c.lGrey,"STSD必死"},
		{c.lGrey,"Techmino没有抽卡没有氪金,太良心了"},
		{c.lR,"Z ",c.lG,"S ",c.lSea,"J ",c.lOrange,"L ",c.lGrape,"T ",c.lY,"O ",c.lC,"I"},
		{c.lSea,"茶娘",c.W," 可爱!"},
		{c.lY,"COOL!!"},
		{c.magenta,"MAGENTA"},
		{c.orange,"ORANGE"},
		{c.pink,"PINK"},
		{c.pink,"uid:225238922"},
		{c.purple,"PURPLE"},
		{c.R,"《滥用DMCA》"},
		{c.R,"《知识产权法》"},
		{c.R,"本游戏难度上限很高,做好心理准备。"},
		{c.R,"不要向不感兴趣的路人推荐!!!!!!!!"},
		{c.R,"不要在上课时玩游戏!"},
		{c.R,"光敏性癫痫警告"},
		{c.R,"请在有一定游戏基础之后再学Tspin!不然副作用非常大!"},
		{c.R,"新人请千万记住,打好基础,不要太早学那些花里胡哨的。"},
		{c.R,"长时间游戏状态会越来越差!玩久了记得放松一下~"},
		{c.R,"DD",c.W,"炮=",c.grape,"TS",c.R,"D",c.W,"+",c.grape,"TS",c.R,"D",c.W,"炮"},
		{c.R,"DT",c.W,"炮=",c.grape,"TS",c.R,"D",c.W,"+",c.grape,"TS",c.R,"T",c.W,"炮"},
		{c.R,"LrL ",c.G,"RlR ",c.B,"LLr ",c.orange,"RRl ",c.grape,"RRR LLL ",c.C,"FFF ",c.Y,"RfR RRf rFF"},
		{c.R,"RED"},
		{c.sea,"SEA"},
		{c.sky,"Lua",c.W,"天下第一"},
		{c.sky,"SKY"},
		{c.W,"1, 2, ",c.C,"⑨",c.W,"!!!!!"},
		{c.W,"效率药水",c.grey," 效率提升 (8:00)"},
		{c.W,"协调药水",c.grey," MD减少 II(1:30)"},
		{c.water,"WATER"},
		{c.Y,"暂定段位:GM"},
		{c.Y,"暂定段位:M"},
		{c.Y,"暂定段位:MK"},
		{c.Y,"暂定段位:MM"},
		{c.Y,"暂定段位:MO"},
		{c.Y,"暂定段位:MV"},
		{c.Y,"GREEN"},
		{c.Y,"Miya",c.W," 可爱!"},
		{c.Y,"O-spin Triple!"},
		{c.Y,"YELLOW"},
		-- "Z酱 可爱!",
	}
}