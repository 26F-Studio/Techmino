local gc=love.graphics
local kb=love.keyboard
local int=math.floor
local ins,rem=table.insert,table.remove
local C=COLOR

local inputBox=WIDGET.newInputBox{name="input",x=40,y=650,w=1200,h=50}
local outputBox=WIDGET.newTextBox{name="output",x=40,y=30,w=1200,h=600,font=25,lineH=25,fix=true}
local function log(str)outputBox:push(str)end
log{C.lGrape,"Techmino Shell"}
log{C.lBlue,"©2020 26F Studio   some rights reserved"}
log{C.dRed,"DO NOT RUN ANY CODE YOU DON'T UNDERSTAND"}

local history,hisPtr={"?"}
local the_secret=(14^2*10)..(2*11)



local commands={}
--Basic commands
do--commands.help(arg)
	--format of table command_help_messages:
	--	key: the command
	--	value: a table containing the following two elements:
	--		description: a string that shows when user types `help` or `help [page]`.
	--		details: an array of strings containing documents, shows when user types `help [command]`.
	local command_help_messages={
		help={
			description="Display help messages.",
			details={
				"Display help messages.",
				"",
				"Aliases: help ?",
				"",
				"Usage:",
				"help",
				"help [page|command_name]",
			},
		},
		["?"]="help",
		["#"]={
			description="Run arbitrary Lua code.",
			details={
				"Run arbitrary Lua code.",
				"",
				"Usage: #[lua_source_code]",
				"",
				"print() can be used to print text into this window.",
				"There is a strange box.",
			},
		},
		exit={
			description="Return to the previous menu.",
			details={
				"Return to the previous menu.",
				"",
				"Aliases: exit quit bye",
				"",
				"Usage: exit",
			},
		},quit="exit",bye="exit",
		echo={
			description="Print a message to this window.",
			details={
				"Print a message to this window.",
				"",
				"Aliases: echo print",
				"",
				"Usage: echo [message]",
			},
		},print="echo",
		url={
			description="Attempt to open a URL with your device.",
			details={
				"Attempt to open a URL with your device.",
				"",
				"Usage: url [url]",
			},
		},
		tree={
			description="List all files & directories in saving directory",
			details={
				"List all files & directories in saving directory",
				"",
				"Usage: tree",
			},
		},
		del={
			description="Attempt to delete a file (in saving directory)",
			details={
				"Attempt to delete a file (in saving directory)",
				"",
				"Aliases: rem delete remove",
				"",
				"Usage: del [filename]",
			},
		},rem="del",delete="del",remove="del",
		cls={
			description="Clear the log output.",
			details={
				"Clear the log output.",
				"",
				"Usage: cls",
			},
		},
		rst={
			description="Clear the command history.",
			details={
				"Clear the command history.",
				"",
				"Usage: rst",
			},
		},
		shutdown={
			description="(Attempt to) shutdown your machine.",
			details={
				"(Attempt to) shutdown your machine. Arguments to this command",
				"will be passed on to the system shutdown command.",
				"",
				"Usage:",
				"shutdown",
				"shutdown [args]",
			},
		},
		fn={
			description="Simulates a Function key press.",
			details={
				"Acts as if you have pressed a function key (i.e. F1-F12) on a keyboard.",
				"Useful if you are on a mobile device without access to these keys.",
				"",
				"Usage: fn <1-12>",
			},
		},
		scrinfo={
			description="Display information about the game window.",
			details={
				"Display information about the game window.",
				"",
				"Usage: scrinfo",
			},
		},
		wireframe={
			description="Enable or disable wireframe.",
			details={
				"Enable or disable wireframe.",
				"",
				"Usage: wireframe <true|false>",
			},
		},
		gammacorrect={
			description="Enable or disable gamma correction.",
			details={
				"Enable or disable gamma correction.",
				"",
				"Usage: gammacorrect <true|false>",
			},
		},
		rmwtm={
			description="Remove the \"no recording\" watermark.",
			details={
				"Remove the \"no recording\" watermark.",
				"You will need a password to do that.",
				"",
				"Usage: rmwtm [password]",
			},
		},
		unlockall={
			description="Unlock all modes on the map.",
			details={
				"Unlock all modes on the map.",
				"",
				"Usage: unlockall",
			},
		},
		play={
			description="Load a game mode, including those that are not on the map.",
			details={
				"Load a game mode, including those that are not on the map.",
				"",
				"Usage: play [mode_name]",
			},
		},
		playbgm={
			description="Play a BGM.",
			details={
				"Play a BGM.",
				"",
				"Aliases: playbgm music",
				"",
				"Usage: playbgm [bgmName]"
			},
		},music="playbgm",
		stopbgm={
			description="Stop the BGM.",
			details={
				"Stop the BGM.",
				"",
				"Usage: stopbgm"
			},
		},
		theme={
			description="Load a theme.",
			details={
				"Load a theme.",
				"",
				"Usage: theme <classic|xmas|sprfes|zday>",
			},
		},
	}TABLE.reIndex(command_help_messages)

	local command_help_list={
		"help",
		"#",
		"exit",
		"echo",
		"url",
		"tree",
		"del",
		"cls",
		"rst",
		"shutdown",
		"fn",
		"scrinfo",
		"wireframe",
		"gammacorrect",
		"rmwtm",
		"unlockall",
		"play",
		"playbgm",
		"stopbgm",
		"theme",
	}
	local pageSize=10
	local maxPage=math.ceil(#command_help_list/pageSize)
	function commands.help(arg)
		--help [command]
		if command_help_messages[arg]then
			for _,v in ipairs(command_help_messages[arg].details)do
				log(v)
			end
			return
		end

		--help or help [page]
		local page=arg==""and 1 or tonumber(arg)
		if page then
			if page==int(page)and page>=1 and page<=maxPage then
				log"Use help [page] to view more commands,"
				log"or help [command_name] for details of a command."
				log""
				log{C.lPink,"Page ",C.lG,page,C.lPink," of ",C.lG,maxPage}
				for i=pageSize*(page-1)+1,math.min(pageSize*page,#command_help_list)do
					local cmd=command_help_list[i]
					log{C.W,cmd,C.grey,"    "..command_help_messages[cmd].description}
				end
			else
				log{C.R,"Invalid page number. Must be between 1 and "..maxPage.." (inclusive)."}
			end
		else
			log{C.R,"No command called "..arg}
		end

		--Else
	end
end
function commands.shutdown(arg)os.execute("shutdown "..arg)end
function commands.error(mes)error(mes)end
function commands.cls()outputBox:clear()end
function commands.rst()
	history,hisPtr={}
	log"History cleared"
end
function commands.echo(str)
	if str~=""then
		outputBox:push(str)
	end
end
function commands.url(url)
	if url~=""then
		local res,err=pcall(love.system.openURL,url)
		if not res then
			log{C.R,"[ERR] ",C.W,err}
		end
	else
		log{C.water,"Usage: url [url]"}
	end
end
local function tree(path,name,depth)
	local info=love.filesystem.getInfo(path..name)
	if info.type=="file"then
		log(("\t\t"):rep(depth)..name)
	elseif info.type=="directory"then
		log(("\t\t"):rep(depth)..name..">")
		local L=love.filesystem.getDirectoryItems(path..name)
		for _,subName in next,L do
			tree(path..name.."/",subName,depth+1)
		end
	else
		log("Unkown item type: %s (%s)"):format(name,info.type)
	end
end
function commands.tree()
	local L=love.filesystem.getDirectoryItems("")
	for _,name in next,L do
		if love.filesystem.getRealDirectory(name)==SAVEDIR then
			tree("",name,0)
		end
	end
end
function commands.del(name)
	if name~=""then
		local info=love.filesystem.getInfo(name)
		if info then
			if info.type=="file"then
				if love.filesystem.remove(name)then
					log({C.Y,"Succesfully deleted"})
				else
					log({C.R,"Failed to delete"})
				end
			elseif info.type=="directory"then
				if #love.filesystem.getDirectoryItems(name)==0 then
					if love.filesystem.remove(name)then
						log({C.Y,"Succesfully deleted file '"..name.."'"})
					else
						log({C.R,"Failed to delete file '"..name.."'"})
					end
				else
					log{C.R,"Directory '"..name.."' is not empty"}
				end
			else
				log("Unkown item type: %s (%s)"):format(name,info.type)
			end
		else
			log{C.R,"No file called '"..name.."'"}
		end
	else
		log{C.water,"Usage: del [filename]"}
	end
end
commands.exit=backScene
commands.quit=backScene
commands.bye=backScene

--Game commands
function commands.fn(n)
	if tonumber(n)then
		n=int(tonumber(n))
		if n>=1 and n<=12 then
			love.keypressed("f"..n)
			return
		end
	end
	log{C.water,"Usage: fn [1~12]"}
end
function commands.scrinfo()
	for _,v in next,SCR.info()do
		log(v)
	end
end
function commands.wireframe(bool)
	if bool=="true"or bool=="false"then
		gc.setWireframe(bool=="true")
		log("Wireframe: "..(gc.isWireframe()and"on"or"off"))
	else
		log{C.water,"Usage: wireframe [true|false]"}
	end
end
function commands.gammacorrect(bool)
	if bool=="true"or bool=="false"then
		love._setGammaCorrect(bool=="true")
		log("GammaCorrect: "..(gc.isGammaCorrect()and"on"or"off"))
	else
		log{C.water,"Usage: gammacorrect [true|false]"}
	end
end
function commands.rmwtm(pw)
	if pw==the_secret then
		_G["\100\114\97\119\70\87\77"]=NULL
		log{C.lC,"\87\97\116\101\114\109\97\114\107\32\82\101\109\111\118\101\100"}
		SFX.play("clear")
	else
		log{C.water,"Usage: rmwtm [password]"}
	end
end
function commands.unlockall(bool)
	if bool=="sure"then
		for name,M in next,MODES do
			if type(name)=="string"and not RANKS[name]and M.x then
				RANKS[name]=M.score and 0 or 6
			end
		end
		FILE.save(RANKS,"conf/unlock")
		log{C.lC,"\85\78\76\79\67\75\65\76\76"}
		SFX.play("clear_2")
	else
		log"Are you sure to unlock all modes?"
		log"Type: unlockall sure"
	end
end
function commands.play(m)--marathon_bfmax can only entered through here
	if MODES[m]then
		loadGame(m)
	elseif m~=""then
		log{C.R,"No mode called "..m}
	else
		log{C.water,"Usage: play [modeName]"}
	end
end
function commands.playbgm(bgm)
	if bgm~=""then
		if bgm~=BGM.nowPlay then
			local t=BGM.nowPlay
			BGM.play(bgm)
			if t==BGM.nowPlay then
				log("No BGM called "..bgm)
			else
				log("Now playing: "..bgm)
			end
		end
	else
		log{C.water,"Usage: playbgm [bgmName]"}
	end
end
function commands.stopbgm()
	BGM.stop()
end
function commands.theme(name)
	if name=="classic"then
		THEME=false
		BG.setDefault("space")
		BGM.setDefault("blank")
		BGM.play()
	elseif name=="xmas"then
		THEME="xMas"
		BG.setDefault("snow")
		BGM.setDefault("mXmas")
		BGM.play()
	elseif name=="sprfes"then
		THEME="sprFes"
		BG.setDefault("firework")
		BGM.setDefault("spring festival")
		BGM.play()
	elseif name=="zday"then
		THEME="zDay"
		BG.setDefault("lanterns")
		BGM.setDefault("overzero")
		BGM.play()
	else
		if name~=""then
			log("No theme called "..name)
		end
		log{C.water,"Usage: theme [themeName]"}
	end
end



local combKey={}
function combKey.x()
	love.system.setClipboardText(inputBox.value)
	inputBox.value=""
	SFX.play("reach")
end
function combKey.c()
	love.system.setClipboardText(inputBox.value)
	SFX.play("reach")
end
function combKey.v()
	inputBox.value=inputBox.value..love.system.getClipboardText()
	SFX.play("reach")
end



--Environment for user's function
local noLog=false
local function log_user(str)
	if noLog then return end
	outputBox:push(tostring(str))
end
local userG={
	_VERSION=VERSION_CODE,
	assert=assert,error=error,
	tonumber=tonumber,tostring=tostring,
	select=select,next=next,
	ipairs=ipairs,pairs=pairs,
	print=log_user,type=type,
	pcall=pcall,xpcall=xpcall,
	rawget=rawget,rawset=rawset,rawlen=rawlen,rawequal=rawequal,
	setfenv=setfenv,setmetatable=setmetatable,
	-- require=require,
	-- load=load,loadfile=loadfile,dofile=dofile,
	-- getfenv=getfenv,getmetatable=getmetatable,
	-- collectgarbage=collectgarbage,

	math={},string={},table={},bit={},coroutine={},
	debug={"No way."},package={"No way."},io={"No way."},os={"No way."},
}userG._G=userG
TABLE.complete(math,		userG.math)
TABLE.complete(string,		userG.string)
userG.string.dump=nil
TABLE.complete(table,		userG.table)
TABLE.complete(bit,			userG.bit)
TABLE.complete(coroutine,	userG.coroutine)

--Puzzle box
local first_key={}
local fleg={
	pw=the_secret,
	second_box="Coming soon",
}setmetatable(fleg,{__tostring=function()return"The fl\97g."end})
local function first_box(k,f)
	if k~=first_key then log"Usage:"log"?"return end
	if not f then log"Two keys needed"return end
	if type(f):byte()~=102 then log"Function need"return end
	noLog=true
	if not f()then noLog=false log"There are something in the void."return end
	if f()~=f then noLog=false log"It is itself."return end
	if f(26)~=math.huge then noLog=false log"26 can create the huge"return end
	noLog=false
	log"You lose."
	return fleg
end
userG.the_key=first_key
userG.the_box=first_box



local scene={}

function scene.sceneInit()
	TASK.new(function()YIELD()WIDGET.sel=inputBox end)
	BG.set("none")
end

function scene.keyDown(k)
	if k=="return"then
		local input=inputBox.value
		if input==""then return end

		--Write History
		ins(history,input)
		if history[27]then rem(history,1)end
		hisPtr=nil

		--Insert empty line
		log""

		--Execute
		input=input:sub((input:find("%S")))
		if input:byte()==35 then
			--Execute lua code
			log{C.lC,"> "..input}
			local code,err=loadstring(input:sub(2))
			if code then
				setfenv(code,userG)
				code,err=pcall(code)
				if not code then
					log{C.R,"[ERR] ",C.W,err}
				end
			else
				log{C.R,"[SYNTAX ERR] ",C.W,err}
			end
		else
			--Execute builtin command
			log{C.lSea,"> "..input}
			local p=input:find(" ")
			local cmd,arg
			if p then
				cmd=input:sub(1,p-1):lower()
				arg=input:sub(input:find("%S",p+1)or -1)
			else
				cmd=input
				arg=""
			end
			if commands[cmd]then
				commands[cmd](arg)
			else
				log{C.R,"No command called "..cmd}
			end
		end
		inputBox:clear()
	elseif k=="up"then
		if not hisPtr then
			hisPtr=#history
			if hisPtr>0 then
				inputBox.value=history[hisPtr]
			end
		elseif hisPtr>1 then
			hisPtr=hisPtr-1
			inputBox.value=history[hisPtr]
		end
	elseif k=="down"then
		if hisPtr then
			hisPtr=hisPtr+1
			if history[hisPtr]then
				inputBox.value=history[hisPtr]
			else
				hisPtr=nil
				inputBox.value=""
			end
		end
	elseif k=="tab"then
		local str=inputBox.value
		if str~=""and not str:find("%s")then
			local res={}
			for c in next,commands do
				if c:find(str,nil,true)==1 then
					ins(res,c)
				end
			end

			if #res>1 then
				log(">Commands start with '"..str.."' :")
				table.sort(res)
				for i=1,#res do
					log{COLOR.lGrey,res[i]}
				end
			elseif #res==1 then
				inputBox.value=res[1]
			end
		end
	elseif combKey[k]and kb.isDown("lctrl","rctrl")then
		combKey[k]()
	elseif k=="escape"then
		WIDGET.sel=inputBox
	else
		WIDGET.keyPressed(k)
	end
end

scene.widgetList={
	inputBox,
	outputBox,
}

return scene