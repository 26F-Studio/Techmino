local gc=love.graphics
local kb=love.keyboard
local ins,rem=table.insert,table.remove
local C=COLOR

local inputBox=WIDGET.newInputBox{name='input',x=40,y=650,w=1200,h=50,fType='mono'}
local outputBox=WIDGET.newTextBox{name='output',x=40,y=30,w=1200,h=610,font=25,fType='mono',lineH=25,fix=true}

local function log(str) outputBox:push(str) end
_SCLOG=log

log{C.lP,"Techmino Console"}
log{C.lC,"© Copyright 2019–2022 26F Studio. Some rights reserved."}
log{C.dR,"WARNING: DO NOT RUN ANY CODE THAT YOU DON'T UNDERSTAND."}

local history,hisPtr={"?"}
local sumode=false
local the_secret=(0xe^2*10)..(2*0xb)

local scene={}

local commands={} do
    --[[
        format of elements in table 'commands':
        key: the command name
        value: a table containing the following two elements:
            code: code to run when call
            description: a string that shows when user types 'help'.
            details: an array of strings containing documents, shows when user types 'help [command]'.
    ]]

    local cmdList={}-- List of all non-alias commands

    -- Basic
    commands.help={
        code=function(arg)
            if #arg>0 then
                -- help [command]
                if commands[arg] then
                    if commands[arg].description then
                        log{C.H,("%s"):format(commands[arg].description)}
                    end
                    if commands[arg].details then
                        for _,v in ipairs(commands[arg].details) do log(v) end
                    else
                        log{C.Y,("No details for command '%s'"):format(arg)}
                    end
                else
                    log{C.Y,("No command called '%s'"):format(arg)}
                end
            else
                -- help
                for i=1,#cmdList do
                    local cmd=cmdList[i]
                    local body=commands[cmd]
                    log(
                        body.description and
                            {C.Z,cmd,C.H,(" $1 $2"):repD(("·"):rep(16-#cmd),body.description)}
                        or
                            log{C.Z,cmd}
                    )
                end
            end
        end,
        description="Display help messages",
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
        description="Return to the last menu",
        details={
            "Return to the last menu.",
            "",
            "Aliases: exit quit",
            "",
            "Usage: exit",
        },
    }commands.quit="exit"
    commands.echo={
        code=function(str) if str~="" then log(str) end end,
        description="Print a message",
        details={
            "Print a message to this window.",
            "",
            "Usage: echo [message]",
        },
    }
    commands.cls={
        code=function() outputBox:clear() end,
        description="Clear the window",
        details={
            "Clear the log output.",
            "",
            "Usage: cls",
        },
    }

    -- File
    do-- tree
        local function tree(path,name,depth)
            local info=love.filesystem.getInfo(path..name)
            if info.type=='file' then
                log(("\t\t"):rep(depth)..name)
            elseif info.type=='directory' then
                log(("\t\t"):rep(depth)..name..">")
                local L=love.filesystem.getDirectoryItems(path..name)
                for _,subName in next,L do
                    tree(path..name.."/",subName,depth+1)
                end
            else
                log("Unknown item type: %s (%s)"):format(name,info.type)
            end
        end
        commands.tree={
            code=function()
                local L=love.filesystem.getDirectoryItems""
                for _,name in next,L do
                    if FILE.isSafe(name) then
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
    do-- del
        local function delFile(name)
            if love.filesystem.remove(name) then
                log{C.Y,("Deleted: '%s'"):format(name)}
            else
                log{C.R,("Failed to delete: '%s'"):format(name)}
            end
        end
        local function delDir(name)
            if #love.filesystem.getDirectoryItems(name)==0 then
                if love.filesystem.remove(name) then
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
                if love.filesystem.remove(dir) then
                    log{C.Y,("Succesfully deleted directory '%s'"):format(dir)}
                else
                    log{C.R,("Failed to delete directory '%s'"):format(dir)}
                end
            else
                for _,name in next,containing do
                    local path=dir.."/"..name
                    local info=love.filesystem.getInfo(path)
                    if info then
                        if info.type=='file' then
                            delFile(path)
                        elseif info.type=='directory' then
                            recursiveDelDir(path)
                        else
                            log("Unknown item type: %s (%s)"):format(name,info.type)
                        end
                    end
                end
                delDir(dir)
            end
        end
        commands.del={
            code=function(name)
                local recursive=name:sub(1,3)=="-s "
                if recursive then
                    name=name:sub(4)
                end

                if name~="" then
                    local info=love.filesystem.getInfo(name)
                    if info then
                        if info.type=='file' then
                            if not recursive then
                                delFile(name)
                            else
                                log{C.R,("'%s' is not a directory."):format(name)}
                            end
                        elseif info.type=='directory' then
                            (recursive and recursiveDelDir or delDir)(name)
                        else
                            log("Unknown item type: %s (%s)"):format(name,info.type)
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
            -- Check arguments
            arg=arg:split(" ")
            if #arg>2 then
                log{C.lY,"Warning: file names must have no spaces"}
                return
            elseif #arg<2 then
                log{C.A,"Usage: ren [oldfilename] [newfilename]"}
                return
            end

            -- Check file exist
            local info
            info=love.filesystem.getInfo(arg[1])
            if not (info and info.type=='file') then
                log{C.R,("'%s' is not a file!"):format(arg[1])}
                return
            end
            info=love.filesystem.getInfo(arg[2])
            if info then
                log{C.R,("'%s' already exists!"):format(arg[2])}
                return
            end

            -- Read file
            local data,err1=love.filesystem.read('data',arg[1])
            if not data then
                log{C.R,("Failed to read file '%s': "):format(arg[1],err1 or "Unknown error")}
                return
            end

            -- Write file
            local res,err2=love.filesystem.write(arg[2],data)
            if not res then
                log{C.R,("Failed to write file: "):format(err2 or "Unknown error")}
                return
            end

            -- Delete file
            if not love.filesystem.remove(arg[1]) then
                log{C.R,("Failed to delete old file ''"):format(arg[1])}
                return
            end

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
            if name~="" then
                local info=love.filesystem.getInfo(name)
                if info then
                    if info.type=='file' then
                        log{COLOR.lC,"/* "..name.." */"}
                        for l in love.filesystem.lines(name) do
                            log(l)
                        end
                        log{COLOR.lC,"/* END */"}
                    else
                        log{C.R,("Unprintable item: %s (%s)"):format(name,info.type)}
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

    -- System
    commands.crash={
        code=function() error("ERROR") end,
        description="Manually crash the game",
    }
    commands.mes={
        code=function(arg)
            if
                arg=='check' or
                arg=='info' or
                arg=='broadcast' or
                arg=='warn' or
                arg=='error'
            then
                MES.new(arg,"Test message",6)
            else
                log{C.A,"Show a message on the up-left corner"}
                log""
                log{C.A,"Usage: mes <check|info|broadcast|warn|error>"}
            end
        end,
        description="Show a message",
        details={
            "Show a message on the up-left corner",
            "",
            "Usage: mes <check|info|warn|error>",
        },
    }
    commands.log={
        code=function()
            local l=LOG.logs
            for i=1,#l do
                log(l[i])
            end
        end,
        description="Show the logs",
        details={
            "Show the logs",
            "",
            "Usage: log",
        },
    }
    commands.openurl={
        code=function(url)
            if url~="" then
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
            for _,v in next,SCR.info() do
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
            if bool=="on" or bool=="off" then
                gc.setWireframe(bool=="on")
                log("Wireframe: "..(gc.isWireframe() and "on" or "off"))
            else
                log{C.A,"Usage: wireframe <on|off>"}
            end
        end,
        description="Turn on/off wireframe mode",
        details={
            "Enable or disable wireframe drawing mode.",
            "",
            "Usage: wireframe <on|off>",
        },
    }
    commands.gammacorrect={
        code=function(bool)
            if bool=="on" or bool=="off" then
                love._setGammaCorrect(bool=="on")
                log("GammaCorrect: "..(gc.isGammaCorrect() and "on" or "off"))
            else
                log{C.A,"Usage: gammacorrect <on|off>"}
            end
        end,
        description="Turn on/off gamma correction",
        details={
            "Enable or disable gamma correction.",
            "",
            "Usage: gammacorrect <on|off>",
        },
    }
    commands.fn={
        code=function(n)
            if tonumber(n) then
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
            if bgm~="" then
                if bgm~=BGM.getPlaying()[1] then
                    if BGM.play(bgm) then
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
        description="Play a BGM",
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
        description="Stop BGM",
        details={
            "Stop the currently playing BGM.",
            "",
            "Usage: stopbgm"
        },
    }
    commands.setbg={
        code=function(name)
            if name~="" then
                if name~=BG.cur then
                    if BG.set(name) then
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
            if name~="" then
                if THEME.set(name) then
                    log("Theme set to: "..name)
                else
                    log("No theme called "..name)
                end
            else
                log{C.A,"Usage: theme <xmas|halloween|sprfes|zday1/2/3|season1/2/3/4|fool|birth>"}
            end
        end,
        description="Load theme",
        details={
            "Load a theme.",
            "",
            "Usage: theme <xmas|sprfes|zday1/2/3|season1/2/3/4|fool|birth>",
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
    commands.support={
        code=function(arg)
            if FNNS then
                if arg:find"pl" and arg:find"fk" then
                    SCN.go('support','none')
                else
                    love.system.openURL("https://www.bilibili.com/video/BV1uT4y1P7CX?secretcode=fkpl")
                end
            else
                SCN.go('support','none')
            end
        end,
        description="Enter support scene",
        details={
            "Go to an support scene",
            "",
            "Usage: support",
        },
    }
    do-- app
        local APPs={
            {
                code="calc",
                scene='app_calc',
                description="A simple calculator"
            },
            {
                code="15p",
                scene='app_15p',
                description="15 Puzzle (sliding puzzle)"
            },
            {
                code="grid",
                scene='app_schulteG',
                description="Schulte Grid"
            },
            {
                code="pong",
                scene='app_pong',
                description="Pong (2P)"
            },
            {
                code="atoz",
                scene='app_AtoZ',
                description="A to Z (typing)"
            },
            {
                code="uttt",
                scene='app_UTTT',
                description="Ultimate Tic-Tac-Toe (2P)"
            },
            {
                code="cube",
                scene='app_cubefield',
                description="Cubefield, original game by Max Abernethy"
            },
            {
                code="2048",
                scene='app_2048',
                description="2048 with some new features. Original by Asher Vollmer"
            },
            {
                code="ten",
                scene='app_ten',
                description="Just Get Ten"
            },
            {
                code="tap",
                scene='app_tap',
                description="Clicking/Tapping speed test"
            },
            {
                code="dtw",
                scene='app_dtw',
                description="Don't Touch White (Piano Tiles)"
            },
            {
                code="can",
                scene='app_cannon',
                description="A simple cannon shooting game"
            },
            {
                code="drp",
                scene='app_dropper',
                description="Dropper"
            },
            {
                code="rfl",
                scene='app_reflect',
                description="Reflect (2P)"
            },
            {
                code="poly",
                scene='app_polyforge',
                description="Polyforge. Original by ImpactBlue Studios"
            },
            {
                code="link",
                scene='app_link',
                description="Connect tiles (Shisen-Sho)"
            },
            {
                code="arm",
                scene='app_arithmetic',
                description="Arithmetic"
            },
            {
                code="piano",
                scene='app_piano',
                description="A simple keyboard piano"
            },
            {
                code="mem",
                scene='app_memorize',
                description="Number memorize"
            },
            {
                code="trp",
                scene='app_triple',
                description="A Match-3 Game. Original idea from Sanlitun / Triple Town"
            },
            {
                code="sw",
                scene='app_stopwatch',
                description="A stopwatch"
            },
            {
                code="mj",
                scene='app_mahjong',
                description="A simple mahjong game (1 player)"
            },
            {
                code="spin",
                scene='app_spin',
                description="¿"
            },
        }
        commands.app={
            code=function(name)
                if name=="-list" then
                    for i=1,#APPs do
                        log(("$1 $2 $3"):repD(APPs[i].code,("·"):rep(10-#APPs[i].code),APPs[i].description))
                    end
                elseif name~="" then
                    for i=1,#APPs do
                        if APPs[i].code==name then
                            SCN.go(APPs[i].scene)
                            return
                        end
                    end
                    log{C.A,"No applet with this name. Type app -list to view all applets"}
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
    commands.resetall={
        code=function(arg)
            if arg=="sure" then
                log"FINAL WARNING!"
                log"Please remember that resetting everything will delete all saved data. Delete the saved data anyway?"
                log"Once the data has been deleted, there is no way to recover it."
                log"Type: resetall really"
            elseif arg=="really" then
                WIDGET.unFocus(true)inputBox.hide=true
                BGM.stop()
                commands.cls.code()
                outputBox:clear()
                outputBox.h=500
                local button=WIDGET.newButton{name='bye',x=640,y=615,w=426,h=100,code=function()
                    TASK.new(function()
                        scene.widgetList.bye.hide=true
                        TEST.yieldN(30)
                        log{C.R,"Deleting all data in 10..."}SFX.play('ready')SFX.play('clear_1')TEST.yieldN(60)
                        log{C.R,"Deleting all data in 9..."} SFX.play('ready')SFX.play('clear_1')TEST.yieldN(60)
                        log{C.R,"Deleting all data in 8..."} SFX.play('ready')SFX.play('clear_1')TEST.yieldN(60)
                        log{C.R,"Deleting all data in 7..."} SFX.play('ready')SFX.play('clear_2')TEST.yieldN(60)
                        log{C.R,"Deleting all data in 6..."} SFX.play('ready')SFX.play('clear_2')TEST.yieldN(60)
                        log{C.R,"Deleting all data in 5..."} SFX.play('ready')SFX.play('clear_3')TEST.yieldN(60)
                        log{C.R,"Deleting all data in 4..."} SFX.play('ready')SFX.play('clear_3')TEST.yieldN(60)
                        log{C.R,"Deleting all data in 3..."} SFX.play('ready')SFX.play('clear_4')TEST.yieldN(60)
                        log{C.R,"Deleting all data in 2..."} SFX.play('ready')SFX.play('clear_4')TEST.yieldN(60)
                        log{C.R,"Deleting all data in 1..."} SFX.play('ready')SFX.play('clear_5')TEST.yieldN(60)
                        log{C.R,"Deleting all data in 0..."} SFX.play('start')SFX.play('clear_6')TEST.yieldN(60)
                        outputBox.hide=true
                        TEST.yieldN(26)
                        FILE.clear_s('')
                        love.event.quit()
                    end)
                end}
                button:setObject("Techmino is fun. Bye.")
                ins(scene.widgetList,button)
            else
                log"Are you sure you want to reset everything?"
                log"This will delete EVERYTHING in your saved game data, including but not limited to:"
                log"All your replays, saved scores, settings, etc."
                log"This cannot be undone."
                log"Type: resetall sure"
            end
        end,
        description="Reset everything and delete all saved data.",
    }
    commands.su={
        code=function(code)
            if sumode then
                log{C.Y,"You are already in su mode. Use # to run any lua code"}
                log{C.Y,"已经进入最高权限模式了, 请使用 # 执行任意lua代码"}
            elseif code=="7126" then
                sumode=true
                log{C.Y,"* SU MODE ON - DO NOT RUN ANY CODES IF YOU DO NOT KNOW WHAT THEY DO *"}
                log{C.Y,"* Use the _SCLOG(message) function to print into this console *"}
                log{C.Y,"* 最高权限模式开启, 请不要执行任何自己不懂确切含义的代码 *"}
                log{C.Y,"* 使用_SCLOG(信息)函数在控制台打印信息 *"}
            else
                log{C.Y,"Password incorrect"}
            end
        end,
    }

    -- Game
    commands.rmconf={
        code=function(key)
            if #key>0 then
                if SETTING[key]~=nil then
                    SETTING[key]=nil
                    saveSettings()
                    log{C.Y,("Successfully erased key '%s'"):format(key)}
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
            "Useful if any of your settings are corrupted.",
            "YOU MUST RESTART THE GAME AFTER USING THIS COMMAND.",
            "",
            "Usage: rmconf [key]",
        },
    }
    commands.rmrecord={
        code=function(modeName)
            if #modeName>0 then
                if MODES[modeName] then
                    MODES[modeName].records={}
                    log{C.Y,("Succesfully erased records of "..modeName)}
                    love.filesystem.remove("record/"..modeName..".rec")
                else
                    log{C.R,"No mode called "..modeName}
                end
            else
                log{C.R,"Usage: rmrecord [modeName]"}
            end
        end,
        description="Erase records of a mode",
        details={
            "Erase records of a mode",
            "Useful if you have a record list corrupted",
            "",
            "Usage: rmrecord [modeName]",
        },
    }
    commands.unlockall={
        code=function(bool)
            if bool=="sure" then
                for name,M in next,MODES do
                    if type(name)=='string' and not RANKS[name] and M.x then
                        if M.x then
                            RANKS[name]=0
                        end
                    end
                end
                saveProgress()
                log{C.lC,"\85\78\76\79\67\75\65\76\76"}
                SFX.play('clear_2')
            else
                log"Are you sure you want to unlock all game modes?"
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
            if MODES[m] then
                loadGame(m,true)
            elseif m~="" then
                log{C.R,"No mode called "..m}
            else
                log{C.A,"Usage: play [modeName]"}
            end
        end,
        description="Load a game mode",
        details={
            "Load a game mode. This includes those that are not on the map.",
            "",
            "Usage: play [mode_name]",
        },
    }
    commands.tas={
        code=function(bool)
            if bool=="on" or bool=="off" then
                SETTING.allowTAS=bool=="on"
                saveSettings()
                log("Allow TAS: "..bool)
                if bool then
                    log("Hot keys: f1=play/pause f2=slow down f3=speed up/next frame")
                end
            else
                log{C.A,"Usage: tas <on|off>"}
            end
        end,
        description="Toggle TAS tool",
        details={
            "Once the TAS tool is enabled, a TAS button will show up at the pause menu.",
            "",
            "Usage: tas <on|off>",
        },
    }
    commands.tip={
        code=function()
            log(text.getTip())
        end,
        description="Show a random tip",
    }

    -- Network
    commands.switchhost={
        code=function(arg)
            arg=arg:split(" ")
            if arg[1] and #arg<=3 then
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
        description="Switch to another host",
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
    function commands.m_broadcast(str)
        if #str>0 then
            WS.send('game',JSON.encode{action=0,data={message=str}})
            log{C.Y,"Request sent"}
        else
            log{C.R,"Format error"}
        end
    end
    function commands.m_shutdown(time)
        time=tonumber(time)
        if time and time>1 then
            WS.send('game',JSON.encode{action=0,data={countdown=time}})
            log{C.Y,"Request sent"}
        else
            log{C.R,"Format error"}
        end
    end
    function commands.m_connInfo() WS.send('game',JSON.encode{action=10}) end
    function commands.m_playMgrInfo() WS.send('game',JSON.encode{action=11}) end
    function commands.m_streamMgrInfo() WS.send('game',JSON.encode{action=12}) end

    for cmd,body in next,commands do
        if type(body)=='function' then
            commands[cmd]={code=body}
        end
        if type(body)~='string' then
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

-- Environment for user's function
local userG={
    timer=TIME,

    _VERSION=VERSION.code,
    assert=assert,error=error,
    tonumber=tonumber,tostring=tostring,
    select=select,next=next,
    ipairs=ipairs,pairs=pairs,
    type=type,
    pcall=pcall,xpcall=xpcall,
    rawget=rawget,rawset=rawset,rawlen=rawlen,rawequal=rawequal,
    setfenv=setfenv,setmetatable=setmetatable,
    -- require=require,
    -- load=load,loadfile=loadfile,dofile=dofile,
    -- getfenv=getfenv,getmetatable=getmetatable,
    -- collectgarbage=collectgarbage,

    math={},string={},table={},bit={},coroutine={},
    debug={},package={},io={},os={},
}
function userG.print(...)
    local args,L={...},{}
    for k,v in next,args do ins(L,{k,v}) end
    table.sort(L,function(a,b) return a[1]<b[1] end)
    local i=1
    while L[1] do
        if i==L[1][1] then
            log(tostring(L[1][2]))
            rem(L,1)
        else
            log("nil")
        end
        i=i+1
    end
end
userG._G=userG
TABLE.complete(math,userG.math)
TABLE.complete(string,userG.string)userG.string.dump=nil
TABLE.complete(table,userG.table)
TABLE.complete(bit,userG.bit)
TABLE.complete(coroutine,userG.coroutine)
local dangerousLibMeta={__index=function() error("No way.") end}
setmetatable(userG.debug,dangerousLibMeta)
setmetatable(userG.package,dangerousLibMeta)
setmetatable(userG.io,dangerousLibMeta)
setmetatable(userG.os,dangerousLibMeta)

-- Puzzle box
local first_key={}
local fleg={
    pw=the_secret,
    supw=7126,
    second_box="Coming soon",
}setmetatable(fleg,{__tostring=function() return "The fl\97g." end})
function userG.the_box(k)
    if k~=first_key then
        log"Usage:"log"*The box is locked*"
        return
    end
    log"*Breaking sound*"
    userG.the_box,userG.the_key=nil,nil
    return fleg
end
userG.the_key=first_key



function scene.enter()
    WIDGET.focus(inputBox)
    BG.set('none')
end

function scene.wheelMoved(_,y)
    WHEELMOV(y,"scrollup","scrolldown")
end

function scene.keyDown(key)
    if key=='return' or key=='kpenter' then
        local input=STRING.trim(inputBox:getText())
        if input=="" then return end

        -- Write History
        ins(history,input)
        if history[27] then
            rem(history,1)
        end
        hisPtr=nil

        -- Execute
        if input:byte()==35 then
            -- Execute lua code
            log{C.lC,"> "..input}
            local code,err=loadstring(input:sub(2))
            if code then
                local resultColor
                if sumode then
                    resultColor=C.lY
                else
                    setfenv(code,userG)
                    resultColor=C.lG
                end
                local success,result=pcall(code)
                if success then
                    if result~=nil then
                        log{resultColor,">> "..tostring(result)}
                    else
                        log{resultColor,"done"}
                    end
                else
                    log{C.R,result}
                end
            else
                log{C.R,"[SyntaxErr] ",C.R,err}
            end
        else
            -- Execute builtin command
            log{C.lS,"> "..input}
            local p=input:find(" ")
            local cmd,arg
            if p then
                cmd=input:sub(1,p-1):lower()
                arg=input:sub(input:find("%S",p+1) or -1)
            else
                cmd=input
                arg=""
            end
            if commands[cmd] then
                commands[cmd].code(arg)
            else
                log{C.R,"No command called "..cmd}
            end
        end
        inputBox:clear()

        -- Insert empty line
        log""
    elseif key=='up' then
        if not hisPtr then
            hisPtr=#history
            if hisPtr>0 then
                inputBox:setText(history[hisPtr])
            end
        elseif hisPtr>1 then
            hisPtr=hisPtr-1
            inputBox:setText(history[hisPtr])
        end
    elseif key=='down' then
        if hisPtr then
            hisPtr=hisPtr+1
            if history[hisPtr] then
                inputBox:setText(history[hisPtr])
            else
                hisPtr=nil
                inputBox:clear()
            end
        end
    elseif key=='tab' then
        local str=inputBox:getText()
        if str~="" and not str:find("%s") then
            local res={}
            for c in next,commands do
                if c:find(str,nil,true)==1 then
                    ins(res,c)
                end
            end

            if #res>1 then
                log(">Commands that start with '"..str.."' :")
                table.sort(res)
                for i=1,#res do log{COLOR.lH,res[i]} end
            elseif #res==1 then
                inputBox:setText(res[1])
            end
        end
    elseif key=='scrollup' then outputBox:scroll(-5)
    elseif key=='scrolldown' then outputBox:scroll(5)
    elseif key=='pageup' then outputBox:scroll(-25)
    elseif key=='pagedown' then outputBox:scroll(25)
    elseif key=='home' then outputBox:scroll(-1e99)
    elseif key==' end' then outputBox:scroll(1e99)
    elseif combKey[key] and kb.isDown('lctrl','rctrl') then combKey[key]()
    elseif key=='escape' then
        if not WIDGET.isFocus(inputBox) then
            WIDGET.focus(inputBox)
        else
            SCN.back()
        end
    else
        if not WIDGET.isFocus(inputBox) then
            WIDGET.focus(inputBox)
        end
        return true
    end
end

scene.widgetList={
    outputBox,
    inputBox,
}

return scene
