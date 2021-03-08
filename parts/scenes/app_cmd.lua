local gc=love.graphics
local int=math.floor
local ins=table.insert

local inputBox=WIDGET.newInputBox{name="input",x=40,y=650,w=1200,h=50}
local outputBox=WIDGET.newTextBox{name="output",x=40,y=30,w=1200,h=600,font=25,lineH=25,fix=true}
outputBox:push("Techmino Shell")
outputBox:push("©2020 26F Studio   some rights reserved")
local history,hisPtr={"?"}

local noLog=false
local function log(str)
	if noLog then return end
	outputBox:push(tostring(str))
end

--Environment for user's function
local userG={
	_VERSION=VERSION_CODE,
	assert=assert,error=error,
	tonumber=tonumber,tostring=tostring,
	select=select,next=next,
	ipairs=ipairs,pairs=pairs,
	print=log,type=type,
	pcall=pcall,xpcall=xpcall,
	rawget=rawget,rawset=rawset,rawlen=rawlen,rawequal=rawequal,
	setfenv=setfenv,setmetatable=setmetatable,
	-- load=load,loadfile=loadfile,dofile=dofile,
	-- getfenv=getfenv,getmetatable=getmetatable,
	-- collectgarbage=collectgarbage,

	math={},
	table={},
	string={},
	coroutine={},
	bit={},

	debug={"No way."},
	package={"No way."},
	io={"No way."},
	os={"No way."},
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
	pw=(14^2*10)..(2*11),
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



local commands={}
--Basic commands
do--commands.help(arg)
	-- command_help_messages format:
	-- command_help_messages is a table
	--     key: the command
	--     value: a table containing the following two elements:
	--         description: a string that shows when user types `help` or
	--                      `help [page]`.
	--         details: an array of strings, each representing a line, that shows
	--                  when user types `help [command]`.
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
				"help [page]",
				"help [command_name]",
			},
		},
		["?"]="help",
		["#"]={
			description="Run arbitrary Lua code.",
			details={
				"Run arbitrary Lua code.",
				"",
				"Usage:",
				"#[lua_source_code]",
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
				"Usage:",
				"exit",
			},
		},
		quit="exit",
		bye="exit",
		echo={
			description="Print a message to this window.",
			details={
				"Print a message to this window.",
				"",
				"Usage:",
				"echo [message]",
			},
		},
		cls={
			description="Clear the log output.",
			details={
				"Clear the log output.",
				"",
				"Usage:",
				"cls",
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
				"Usage:",
				"fn <1-12>",
			},
		},
		scrinfo={
			description="Display information about your screen.",
			details={
				"Display information about your screen.",
				"",
				"Usage:",
				"scrinfo",
			},
		},
		wireframe={
			description="Enable or disable wireframe.",
			details={
				"Enable or disable wireframe.",
				"",
				"Usage:",
				"wireframe <true|false>",
			},
		},
		gammacorrect={
			description="Enable or disable gamma correction.",
			details={
				"Enable or disable gamma correction.",
				"",
				"Usage:",
				"gammacorrect <true|false>",
			},
		},
		rmwtm={
			description="Remove the \"no recording\" watermark.",
			details={
				"Remove the \"no recording\" watermark.",
				"You will need a password to do that.",
				"",
				"Usage:",
				"rmwtm [password]",
			},
		},
		unlockall={
			description="Unlock all modes on the map.",
			details={
				"Unlock all modes on the map.",
				"",
				"Usage:",
				"unlockall",
			},
		},
		play={
			description="Load a game mode, including those that are not on the map.",
			details={
				"Load a game mode, including those that are not on the map.",
				"",
				"Usage:",
				"play [mode_name]",
			},
		},
		festival={
			description="Load a festival theme.",
			details={
				"Load a festival theme.",
				"",
				"Usage:",
				"festival [festival_name]",
				"",
				"Available festivals:",
				"classic|xmas|sprfes|zday",
			},
		},
	}TABLE.reIndex(command_help_messages)

	-- while I could have used a for loop to get this... the order at which the
	-- table elements turn up in the loop is not quite ideal. Doing this manually
	-- so that at least the most basic commands are on page 1.
	local command_help_list={
		"help",
		"#",
		"exit",
		"echo",
		"cls",
		"shutdown",
		"fn",
		"scrinfo",
		"wireframe",
		"gammacorrect",
		"rmwtm",
		"unlockall",
		"play",
		"festival"
	}

	local command_help_page_size=10
	function commands.help(arg)
		if command_help_messages[arg]then -- help [command]
			for _,v in ipairs(command_help_messages[arg].details)do
				log(v)
			end
			return
		end
		if tonumber(arg)then
			arg=int(tonumber(arg))
		else
			arg=1
		end -- help or help [page]
		local total_pages=math.ceil(#command_help_list/command_help_page_size)
		if arg<=0 or arg>total_pages then
			log("Invalid page number. Must be between 1 and "..total_pages.." (inclusive).")
			return
		end
		log"Use help [page] to view more commands,"
		log"or help [command_name] for more info on a command."
		log""
		log("Page "..arg.." of "..total_pages)
		for i=(arg-1)*10+1,math.min(arg*10,#command_help_list)do
			local _c=command_help_list[i]
			log("".._c.." - "..command_help_messages[_c].description)
		end
	end
end
function commands.shutdown(arg)os.execute("shutdown "..arg)end
function commands.cls()outputBox:clear()end
commands.echo=log
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
	log"Usage: fn [1~12]"
end
function commands.scrinfo()for _,v in next,SCR.info()do log(v)end end
function commands.wireframe(bool)
	if bool=="true"or bool=="false"then
		gc.setWireframe(bool=="true")
		log("Wireframe: "..(gc.isWireframe()and"on"or"off"))
	else
		log"Usage: wireframe [true|false]"
	end
end
function commands.gammacorrect(bool)
	if bool=="true"or bool=="false"then
		love._setGammaCorrect(bool=="true")
		log("GammaCorrect: "..(gc.isGammaCorrect()and"on"or"off"))
	else
		log"Usage: gammacorrect [true|false]"
	end
end
function commands.rmwtm(pw)
	if pw==fleg.pw then
		_G["\100\114\97\119\70\87\77"]=NULL
		log("\68\69\86\58\87\97\116\101\114\109\97\114\107\32\82\101\109\111\118\101\100")
		SFX.play("clear")
	else
		log"Usage: None."
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
		log("\68\69\86\58\85\78\76\79\67\75\65\76\76")
		SFX.play("clear_2")
	else
		log"Are you sure to unlock all modes?"
		log"Type: unlockall sure"
	end
end
function commands.play(m)--marathon_bfmax can only entered through here
	if MODES[m]then
		loadGame(m)
	elseif m then
		log("No mode called "..m)
	else
		log"Usage: play [modeName]"
	end
end
function commands.festival(name)
	if name=="classic"then
		FESTIVAL=false
		BG.setDefault("space")
		BGM.setDefault("blank")
		BGM.play()
	elseif name=="xmas"then
		FESTIVAL="xMas"
		BG.setDefault("snow")
		BGM.setDefault("mXmas")
		BGM.play()
	elseif name=="sprfes"then
		FESTIVAL="sprFes"
		BG.setDefault("firework")
		BGM.setDefault("spring festival")
		BGM.play()
	elseif name=="zday"then
		FESTIVAL="zDay"
		BG.setDefault("lanterns")
		BGM.setDefault("overzero")
		BGM.play()
	else
		if name~=""then
			log("No festival called "..name)
		end
		log"Usage: festival [fesitivalName]"
	end
end



local scene={}

function scene.sceneInit()
	TASK.new(function()YIELD()WIDGET.sel=inputBox end)
	BG.set("none")
end

function scene.keyDown(k)
	if k=="return"then
		local input=inputBox.value
		log""
		log("> "..input)
		if input:byte()==35 then
			--Execute code
			local code,err=loadstring(input:sub(2))
			if code then
				setfenv(code,userG)
				code,err=pcall(code)
				if not code then
					log("[ERR] "..err)
				end
			else
				log("[SYNTAX ERR] "..err)
			end
			ins(history,input)
			hisPtr=nil
		elseif input~=""then
			--Load command
			local p=input:find(" ")
			local cmd,arg
			if p then
				cmd=input:sub(1,p-1):lower()
				arg=input:sub(p+1)
			else
				cmd=input
				arg=""
			end
			if commands[cmd]then
				commands[cmd](arg)
			else
				log("No command called "..cmd)
			end
			ins(history,input)
			hisPtr=nil
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
	else
		WIDGET.keyPressed(k)
	end
end

scene.widgetList={
	inputBox,
	outputBox,
}

return scene