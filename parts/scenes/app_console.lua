local gc=love.graphics
local kb=love.keyboard
local ins,rem=table.insert,table.remove
local C=COLOR

local inputBox=WIDGET.newInputBox{name="input",x=40,y=650,w=1200,h=50}
local outputBox=WIDGET.newTextBox{name="output",x=40,y=30,w=1200,h=610,font=25,lineH=25,fix=true}

local function log(str)outputBox:push(str)end
log{C.lP,"Techmino Console"}
log{C.lC,"©2021 26F Studio   some rights reserved"}
log{C.dR,"DO NOT RUN ANY CODE YOU DON'T UNDERSTAND"}

local history,hisPtr={"?"}
local the_secret=(14^2*10)..(2*11)

local commands={}do
	--[[
		format of elements in table 'commands':
		key: the command name
		value: a table containing the following two elements:
			code: code to run when call
			description: a string that shows when user types 'help'.
			details: an array of strings containing documents, shows when user types 'help [command]'.
	]]

	local cmdList={}--List of all non-alias commands

	--Basic
	commands.help={
		code=function(arg)
			if #arg>0 then
				--help [command]
				if commands[arg]then
					if commands[arg].description then
						log{C.H,("%s"):format(commands[arg].description)}
						if commands[arg].details then
							for _,v in ipairs(commands[arg].details)do log(v)end
						else
							log{C.Y,("No details for command '%s'"):format(arg)}
						end
					end
				else
					log{C.Y,("No command called '%s'"):format(arg)}
				end
			else
				--help
				for i=1,#cmdList do
					local cmd=cmdList[i]
					local body=commands[cmd]
					log(
						body.description and
							{C.Z,cmd,C.H,"    "..body.description}
						or
							log{C.Z,cmd}
					)
				end
			end
		end,
		details={
			"Display help messages.",
			"",
			"Aliases: help ?",
			"",
			"Usage:",
			"help",
			"help [command_name]",
		},
	}commands["?"]="help"
	commands["#"]={
		description="Run arbitrary Lua code",
		details={
			"Run arbitrary Lua code.",
			"",
			"Usage: #[lua_source_code]",
			"",
			"print() can be used to print text into this window.",
		},
	}
	commands.exit={
		code=backScene,
		details={
			"Return to the previous menu.",
			"",
			"Aliases: exit quit",
			"",
			"Usage: exit",
		},
	}commands.quit="exit"
	commands.echo={
		code=function(str)if str~=""then log(str)end end,
		description="Print a message",
		details={
			"Print a message to this window.",
			"",
			"Usage: echo [message]",
		},
	}
	commands.cls={
		code=function()outputBox:clear()end,
		description="Clear the window",
		details={
			"Clear the log output.",
			"",
			"Usage: cls",
		},
	}

	--File
	do--tree
		local function tree(path,name,depth)
			local info=love.filesystem.getInfo(path..name)
			if info.type=='file'then
				log(("\t\t"):rep(depth)..name)
			elseif info.type=='directory'then
				log(("\t\t"):rep(depth)..name..">")
				local L=love.filesystem.getDirectoryItems(path..name)
				for _,subName in next,L do
					tree(path..name.."/",subName,depth+1)
				end
			else
				log("Unkown item type: %s (%s)"):format(name,info.type)
			end
		end
		commands.tree={
			code=function()
				local L=love.filesystem.getDirectoryItems""
				for _,name in next,L do
					if love.filesystem.getRealDirectory(name)==SAVEDIR then
						tree("",name,0)
					end
				end
			end,
			description="List all files & directories",
			details={
				"List all files & directories in saving directory",
				"",
				"Usage: tree",
			},
		}
	end
	do--del
		local function delFile(name)
			if love.filesystem.remove(name)then
				log{C.Y,("Deleted: '%s'"):format(name)}
			else
				log{C.R,("Failed to delete: '%s'"):format(name)}
			end
		end
		local function delDir(name)
			if #love.filesystem.getDirectoryItems(name)==0 then
				if love.filesystem.remove(name)then
					log{C.Y,("Directory deleted: '%s'"):format(name)}
				else
					log{C.R,("Failed to delete directory '%s'"):format(name)}
				end
			else
				log{C.R,"Directory '"..name.."' is not empty"}
			end
		end
		local function recursiveDelDir(dir)
			local containing=love.filesystem.getDirectoryItems(dir)
			if #containing==0 then
				if love.filesystem.remove(dir)then
					log{C.Y,("Succesfully deleted directory '%s'"):format(dir)}
				else
					log{C.R,("Failed to delete directory '%s'"):format(dir)}
				end
			else
				for _,name in next,containing do
					local path=dir.."/"..name
					local info=love.filesystem.getInfo(path)
					if info then
						if info.type=='file'then
							delFile(path)
						elseif info.type=='directory'then
							recursiveDelDir(path)
						else
							log("Unkown item type: %s (%s)"):format(name,info.type)
						end
					end
				end
				delDir(dir)
			end
		end
		commands.del={
			code=function(name)
				local recursive=name:sub(1,3)=="-s "
				if recursive then name=name:sub(4)end

				if name~=""then
					local info=love.filesystem.getInfo(name)
					if info then
						if info.type=='file'then
							if not recursive then
								delFile(name)
							else
								log{C.R,("'%s' is not a directory."):format(name)}
							end
						elseif info.type=='directory'then
							(recursive and recursiveDelDir or delDir)(name)
						else
							log("Unkown item type: %s (%s)"):format(name,info.type)
						end
					else
						log{C.R,("No file called '%s'"):format(name)}
					end
				else
					log{C.A,"Usage: del [filename|dirname]"}
					log{C.A,"Usage: del -s [dirname]"}
				end
			end,
			description="Delete a file or directory",
			details={
				"Attempt to delete a file or directory (in saving directory)",
				"",
				"Aliases: del rm",
				"",
				"Usage: del [filename|dirname]",
				"Usage: del -s [dirname]",
			}
		}
		commands.rm=commands.del
	end
	commands.mv={
		code=function(arg)
			--Check arguments
			arg=STRING.split(arg," ")
			if #arg>2 then
				log{C.lY,"Warning: file name with space is not allowed"}
				return
			elseif #arg<2 then
				log{C.A,"Usage: ren [oldfilename] [newfilename]"}
				return
			end

			--Check file exist
			local info
			info=love.filesystem.getInfo(arg[1])
			if not(info and info.type=='file')then log{C.R,("'%s' is not a file!"):format(arg[1])}return end
			info=love.filesystem.getInfo(arg[2])
			if info then log{C.R,("'%s' already exists!"):format(arg[2])}return end

			--Read file
			local data,err1=love.filesystem.read('data',arg[1])
			if not data then log{C.R,("Failed to read file '%s': "):format(arg[1],err1 or"Unknown error")}return end

			--Write file
			local res,err2=love.filesystem.write(arg[2],data)
			if not res then log{C.R,("Failed to write file: "):format(err2 or"Unknown error")}return end

			--Delete file
			if not love.filesystem.remove(arg[1])then log{C.R,("Failed to delete old file ''"):format(arg[1])}return end

			log{C.Y,("Succesfully renamed file '%s' to '%s'"):format(arg[1],arg[2])}
		end,
		description="Rename or move a file (in saving directory)",
		details={
			"Rename or move a file (in saving directory)",
			{C.lY,"Warning: file name with space is not allowed"},
			"",
			"Aliases: mv ren",
			"",
			"Usage: mv [oldfilename] [newfilename]",
		},
	}commands.ren="mv"
	commands.print={
		code=function(name)
			if name~=""then
				local info=love.filesystem.getInfo(name)
				if info then
					if info.type=='file'then
						log{COLOR.lC,"/* "..name.." */"}
						for l in love.filesystem.lines(name)do
							log(l)
						end
						log{COLOR.lC,"/* END */"}
					else
						log("Unprintable item: %s (%s)"):format(name,info.type)
					end
				else
					log{C.R,("No file called '%s'"):format(name)}
				end
			else
				log{C.A,"Usage: print [filename]"}
			end
		end,
		description="Print file content",
		details={
			"Print a file to this window.",
			"",
			"Usage: print [filename]",
		},
	}

	--System
	commands.crash={
		code=error,
		description="Manually crash the game",
	}
	commands.message={
		code=function(str)MES.new('warn',str,6)end,
		description="Show a warn message",
	}
	commands.warn={
		code=function(str)MES.new('warn',str,6)end,
		description="Show a warn message",
	}
	commands.error={
		code=function(str)MES.new('error',str,6)end,
		description="Show an error message",
	}
	commands.openurl={
		code=function(url)
			if url~=""then
				local res,err=pcall(love.system.openURL,url)
				if not res then
					log{C.R,"[ERR] ",C.Z,err}
				end
			else
				log{C.A,"Usage: openurl [url]"}
			end
		end,
		description="Open a URL",
		details={
			"Attempt to open a URL with your device.",
			"",
			"Usage: openurl [url]",
		},
	}
	commands.scrinfo={
		code=function()
			for _,v in next,SCR.info()do
				log(v)
			end
		end,
		description="Display window info.",
		details={
			"Display information about the game window.",
			"",
			"Usage: scrinfo",
		},
	}
	commands.wireframe={
		code=function(bool)
			if bool=="true"or bool=="false"then
				gc.setWireframe(bool=="true")
				log("Wireframe: "..(gc.isWireframe()and"on"or"off"))
			else
				log{C.A,"Usage: wireframe <true|false>"}
			end
		end,
		description="Turn on/off wireframe mode",
		details={
			"Enable or disable wireframe drawing mode.",
			"",
			"Usage: wireframe <true|false>",
		},
	}
	commands.gammacorrect={
		code=function(bool)
			if bool=="true"or bool=="false"then
				love._setGammaCorrect(bool=="true")
				log("GammaCorrect: "..(gc.isGammaCorrect()and"on"or"off"))
			else
				log{C.A,"Usage: gammacorrect <true|false>"}
			end
		end,
		description="Turn on/off gamma correction",
		details={
			"Enable or disable gamma correction.",
			"",
			"Usage: gammacorrect <true|false>",
		},
	}
	commands.fn={
		code=function(n)
			if tonumber(n)then
				n=math.floor(tonumber(n))
				if n>=1 and n<=12 then
					love.keypressed("f"..n)
				end
			else
				log{C.A,"Usage: fn [1~12]"}
			end
		end,
		description="Simulates a Function key press",
		details={
			"Acts as if you have pressed a function key (i.e. F1-F12) on a keyboard.",
			"Useful if you are on a mobile device without access to these keys.",
			"",
			"Usage: fn <1-12>",
		},
	}
	commands.playbgm={
		code=function(bgm)
			if bgm~=""then
				if bgm~=BGM.nowPlay then
					if BGM.play(bgm)then
						log("Now playing: "..bgm)
					else
						log("No BGM called "..bgm)
					end
					else
					log("Already playing: "..bgm)
					end
			else
				log{C.A,"Usage: playbgm [bgmName]"}
			end
		end,
		details={
			"Play a BGM.",
			"",
			"Usage: playbgm [bgmName]"
		},
	}
	commands.stopbgm={
		code=function()
			BGM.stop()
		end,
		details={
			"Stop the BGM.",
			"",
			"Usage: stopbgm"
		},
	}
	commands.setbg={
		code=function(name)
			if name~=""then
				if name~=BG.cur then
					if BG.set(name)then
						log(("Background set to '%s'"):format(name))
					else
						log(("No background called '%s'"):format(name))
					end
				else
					log(("Background already set to '%s'"):format(name))
				end
			else
				log{C.A,"Usage: setbg [bgName]"}
			end
		end,
		description="Set background",
		details={
			"Set a background.",
			"",
			"Usage: setbg [bgName]",
		},
	}
	commands.theme={
		code=function(name)
			if name~=""then
				if THEME.set(name)then
					log("Theme set to: "..name)
				else
					log("No theme called "..name)
				end
			else
				log{C.A,"Usage: theme [themeName]"}
			end
		end,
		description="Load theme",
		details={
			"Load a theme.",
			"",
			"Usage: theme <classic|xmas|sprfes|zday1/2/3|birth>",
		},
	}
	commands.test={
		code=function()
			SCN.go('test','none')
		end,
		description="Enter test scene",
		details={
			"Go to an empty test scene",
			"",
			"Usage: test",
		},
	}
	do--app
		local APPs={
			{
				code="15p",
				scene='app_15p',
				description="15 Puzzle, a.k.a. sliding puzzle"
			},
			{
				code="grid",
				scene='app_schulteG',
				description="Schulte Grid"
			},
			{
				code="pong",
				scene='app_pong',
				description="Pong (2P minigame)"
			},
			{
				code="atoz",
				scene='app_AtoZ',
				description="A to Z, a.k.a. typing"
			},
			{
				code="uttt",
				scene='app_UTTT',
				description="Ultimate Tic-Tac-Toe (2P minigame)"
			},
			{
				code="cube",
				scene='app_cubefield',
				description="Cubefield"
			},
			{
				code="2048",
				scene='app_2048',
				description="2048"
			},
			{
				code="ten",
				scene='app_ten',
				description="Just Get Ten"
			},
			{
				code="tap",
				scene='app_tap',
				description="Tapping speed test"
			},
			{
				code="dtw",
				scene='app_dtw',
				description="Don't Touch White, a.k.a. Piano Tiles"
			},
			{
				code="cannon",
				scene='app_cannon',
				description="Cannon"
			},
			{
				code="dropper",
				scene='app_dropper',
				description="Dropper"
			},
			{
				code="calc",
				scene='app_calc',
				description="Calculator"
			},
			{
				code="reflect",
				scene='app_reflect',
				description="Reflect (2P minigame)"
			},
			{
				code="poly",
				scene='app_polyforge',
				description="Polyforge"
			},
		}
		commands.app={
			code=function(name)
				if name=="-list"then
					for i=1,#APPs do
						log(APPs[i].code..": "..APPs[i].description)
					end
				elseif name~=""then
					for i=1,#APPs do
						if APPs[i].code==name then
							SCN.go(APPs[i].scene)
							return
						end
					end
					log{C.A,"No this applet"}
				else
					log{C.A,"Usage:"}
					log{C.A,"app -list"}
					log{C.A,"app [appName]"}
				end
			end,
			description="Enter a applet scene",
			details={
				"Go to an applet scene",
				"",
				"Usage:",
				"app -list",
				"app [appName]",
			},
		}
	end

	--Game
	commands.rmconf={
		code=function(key)
			if #key>0 then
				if SETTING[key]~=nil then
					SETTING[key]=nil
					FILE.save(SETTING,'conf/settings','q')
					log{C.Y,("Succesfully erased key '%s'"):format(key)}
				else
					log{C.R,"No key called "..key}
				end
			else
				log{C.A,"Usage: rmconf [key]"}
			end
		end,
		description="Erase a setting value",
		details={
			"Erase a setting value",
			"Useful if you have your setting corrupted",
			"YOU MUST RESTART THE GAME AFTER USING THIS",
			"",
			"Usage: rmconf [key]",
		},
	}
	commands.unlockall={
		code=function(bool)
			if bool=="sure"then
				for name,M in next,MODES do
					if type(name)=='string'and not RANKS[name]and M.x then
						RANKS[name]=M.score and 0 or 6
					end
				end
				FILE.save(RANKS,'conf/unlock')
				log{C.lC,"\85\78\76\79\67\75\65\76\76"}
				SFX.play('clear_2')
			else
				log"Are you sure to unlock all modes?"
				log"Type: unlockall sure"
			end
		end,
		description="Unlock the whole map",
		details={
			"Unlock all modes on the map.",
			"",
			"Usage: unlockall",
		},
	}
	commands.play={
		code=function(m)
			if MODES[m]then
				loadGame(m,true)
			elseif m~=""then
				log{C.R,"No mode called "..m}
			else
				log{C.A,"Usage: play [modeName]"}
			end
		end,
		description="Load a game mode",
		details={
			"Load a game mode, including those that are not on the map.",
			"",
			"Usage: play [mode_name]",
		},
	}
	commands["\114\109\119\116\109"]={
		code=function(pw)
			if pw==the_secret then
				_G["\100\114\97\119\70\87\77"]=NULL
				log{C.lC,"\87\97\116\101\114\109\97\114\107\32\82\101\109\111\118\101\100"}
				SFX.play('clear')
			end
		end,
		details={
			"Remove something",
			"",
			"Usage: ?",
		},
	}

	--Network
	commands.switchhost={
		code=function(arg)
			arg=STRING.split(arg," ")
			if arg[1]and #arg<=3 then
				WS.switchHost(unpack(arg))
				log{C.Y,"Host switched"}
			else
				log{C.A,"Usage:"}
				log{C.A,"switchhost [host]"}
				log{C.A,"switchhost [host] [port]"}
				log{C.A,"switchhost [host] [port] [path]"}
				log{C.A,"Example: switchhost 127.0.0.1 26000 /sock"}
			end
		end,
		details={
			"Disconnect all connections and switch to another host",
			"",
			"Usage:",
			"switchhost [host]",
			"switchhost [host] [port]",
			"switchhost [host] [port] [path]",
			"Example: switchhost 127.0.0.1 26000 /sock",
		},
	}
	function commands.manage()
		if WS.status('manage')=='running'then
			WS.close('manage')
			log{C.Y,"Disconnected"}
		else
			if({[1]=0,[2]=0,[26]=0})[USER.uid]then
				NET.wsconn_manage()
				log{C.Y,"Connecting"}
			else
				log{C.R,"Permission denied"}
			end
		end
	end
	function commands.m_broadcast(str)
		if #str>0 then
			WS.send('manage','{"action":0,"data":'..JSON.encode{message=str}..'}')
			log{C.Y,"Request sent"}
		else
			log{C.R,"format error"}
		end
	end
	function commands.m_shutdown(sec)
			sec=tonumber(sec)
		if sec and sec>0 and sec~=math.floor(sec) then
			WS.send('manage','{"action":9,"data":'..JSON.encode{countdown=tonumber(sec)}..'}')
			log{C.Y,"Request sent"}
		else
			log{C.R,"format error"}
		end
	end
	function commands.m_connInfo()WS.send('manage','{"action":10}')end
	function commands.m_playMgrInfo()WS.send('manage','{"action":11}')end
	function commands.m_streamMgrInfo()WS.send('manage','{"action":12}')end

	for cmd,body in next,commands do
		if type(body)=='function'then
			commands[cmd]={code=body}
		end
		if type(body)~='string'then
			ins(cmdList,cmd)
		end
	end
	table.sort(cmdList)
	TABLE.reIndex(commands)
end

local combKey={
	x=function()
		love.system.setClipboardText(inputBox:getText())
		inputBox:clear()
		SFX.play('reach')
	end,
	c=function()
		love.system.setClipboardText(inputBox:getText())
		SFX.play('reach')
	end,
	v=function()
		inputBox:addText(love.system.getClipboardText())
		SFX.play('reach')
	end,
}

--Environment for user's function
local noLog=false
local function log_user(str)
	log(noLog and"CHEATER."or tostring(str))
end
local userG={
	timer=TIME,

	_VERSION=VERSION.code,
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
}
userG._G=userG
TABLE.complete(math,userG.math)
TABLE.complete(string,userG.string)userG.string.dump=nil
TABLE.complete(table,userG.table)
TABLE.complete(bit,userG.bit)
TABLE.complete(coroutine,userG.coroutine)

--Puzzle box
local first_key={}
local fleg={
	pw=the_secret,
	second_box="Coming soon",
}setmetatable(fleg,{__tostring=function()return"The fl\97g."end})
function userG.the_box(k,f)
	if k~=first_key then log"Usage:"log"?"return end
	if not f then log"Two keys needed"return end
	if type(f)~='function'then log"Function need"return end
	noLog=true
	if f()~=f then noLog=false log"Give me yourself."return end
	if f(26)~=math.huge then noLog=false log"Infinity for the lucky number"return end
	noLog=false
	log"*You Lose*"
	return fleg
end
userG.the_key=first_key



local scene={}

function scene.sceneInit()
	TASK.new(function()WIDGET.focus(inputBox)end)
	BG.set('none')
end

function scene.wheelMoved(_,y)
	WHEELMOV(y,"scrollup","scrolldown")
end

function scene.keyDown(k)
	if k=="return"then
		local input=STRING.trim(inputBox:getText())
		if input==""then return end

		--Write History
		ins(history,input)
		if history[27]then rem(history,1)end
		hisPtr=nil

		--Insert empty line
		log""

		--Execute
		if input:byte()==35 then
			--Execute lua code
			log{C.lC,"> "..input}
			local code,err=loadstring(input:sub(2))
			if code then
				setfenv(code,userG)
				code,err=pcall(code)
				if not code then
					log{C.R,"[ERR] ",C.Z,err}
				end
			else
				log{C.R,"[SYNTAX ERR] ",C.Z,err}
			end
		else
			--Execute builtin command
			log{C.lS,"> "..input}
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
				commands[cmd].code(arg)
			else
				log{C.R,"No command called "..cmd}
			end
		end
		inputBox:clear()
	elseif k=="up"then
		if not hisPtr then
			hisPtr=#history
			if hisPtr>0 then
				inputBox:setText(history[hisPtr])
			end
		elseif hisPtr>1 then
			hisPtr=hisPtr-1
			inputBox:setText(history[hisPtr])
		end
	elseif k=="down"then
		if hisPtr then
			hisPtr=hisPtr+1
			if history[hisPtr]then
				inputBox:setText(history[hisPtr])
			else
				hisPtr=nil
				inputBox:clear()
			end
		end
	elseif k=="tab"then
		local str=inputBox:getText()
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
				for i=1,#res do log{COLOR.lH,res[i]}end
			elseif #res==1 then
				inputBox:setText(res[1])
			end
		end
	elseif k=="scrollup"then outputBox:scroll(-5)
	elseif k=="scrolldown"then outputBox:scroll(5)
	elseif k=="pageup"then outputBox:scroll(-20)
	elseif k=="pagedown"then outputBox:scroll(20)
	elseif k=="home"then outputBox:scroll(-1e99)
	elseif k=="end"then outputBox:scroll(1e99)
	elseif combKey[k]and kb.isDown("lctrl","rctrl")then
		combKey[k]()
	elseif k=="escape"then
		if not WIDGET.isFocus(inputBox)then
			WIDGET.focus(inputBox)
		else
			SCN.back()
		end
	else
		if not WIDGET.isFocus(inputBox)then WIDGET.focus(inputBox)end
		WIDGET.keyPressed(k)
	end
end

scene.widgetList={
	outputBox,
	inputBox,
}

return scene