local gc=love.graphics
local int=math.floor
local ins=table.insert

local inputBox=WIDGET.newInputBox{name="input",x=40,y=650,w=1200,h=50}
local outputBox=WIDGET.newTextBox{name="output",x=40,y=30,w=1200,h=600,font=25,lineH=25,fix=true}
outputBox:push("Techmino Shell")
outputBox:push("By MrZ_26")
local history,hisPtr={"help"}

local scene={}

local function log(str)
	outputBox:push(str)
end
local userEnv={
	print=log,
	math=math,
	table=table,
	string=string,
}

function scene.sceneInit()
	TASK.new(function()YIELD()WIDGET.sel=inputBox end)
	BG.set("none")
end

local commands={
	--Basic commands
	help=function()
		log"1.Type in commands and press enter"
		log"e.g. echo hihihi"
		log"e.g. cls"
		log""
		log"2.Run LUA code with #..."
		log"e.g. #print(\"hello world\")"
		log"e.g. #for i=1,5 do print(i) end"
	end,
	shutdown=function(arg)os.execute("shutdown "..arg)end,
	cls=function()outputBox:clear()end,
	echo=log,
	exit=backScene,
	quit=backScene,
	bye=backScene,

	--Game commands
	fn=function(n)
		if tonumber(n)then
			n=int(tonumber(n))
			if n>=1 and n<=12 then
				love.keypressed("f"..v)
				return
			end
		end
		log"Usage: fn [1~12]"
	end,
	scrinfo=function()for _,v in next,SCR.info()do log(v)end end,
	wireframe=function(bool)
		if bool=="true"or bool=="false"then
			gc.setWireframe(bool=="true")
			log("Wireframe: "..(gc.isWireframe()and"on"or"off"))
		else
			log"Usage: wireframe [true|false]"
		end
	end,
	gammacorrect=function(bool)
		if bool=="true"or bool=="false"then
			love._setGammaCorrect(bool=="true")
			log("GammaCorrect: "..(gc.isGammaCorrect()and"on"or"off"))
		else
			log"Usage: gammacorrect [true|false]"
		end
	end,
	rmwtm=function(password)
		if password=="196022"then
			_G["\100\114\97\119\70\87\77"]=NULL
			log("\68\69\86\58\87\97\116\101\114\109\97\114\107\32\82\101\109\111\118\101\100")
			SFX.play("clear")
		else
			log"Usage: None."
		end
	end,
	unlockall=function(bool)
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
			log"Usage: unlockall sure"
		end
	end,
	play=function(m)--marathon_bfmax can only played here
		if MODES[m]then
			loadGame(m)
		elseif m then
			log("No mode called "..m)
		else
			log"Usage: play [modeName]"
		end
	end,
}
function scene.keyDown(k)
	if k=="return"then
		local input=inputBox.value
		if input:byte()==35 then
			--Execute code
			local code=loadstring(input:sub(2))
			if code then
				setfenv(code,userEnv)
				ins(history,input)
				code()
			else
				log"Syntax error"
			end
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