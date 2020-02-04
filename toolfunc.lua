local tm=love.timer
local gc=love.graphics
local kb=love.keyboard
local setFont=setFont
local toN,toS=tonumber,tostring

local function splitS(s,sep)
	local t={}
	::L::
		local i=find(s,sep)or #s+1
		ins(t,sub(s,1,i-1))
		s=sub(s,i+#sep)
	if #s~=0 then goto L end
	return t
end
function mStr(s,x,y)
	gc.printf(s,x-300,y,600,"center")
end

function getNewRow(val)
	local t=rem(freeRow)
	for i=1,10 do
		t[i]=val
	end
	--clear a row and move to active list
	if #freeRow==0 then
		for i=1,10 do
			ins(freeRow,{0,0,0,0,0,0,0,0,0,0})
		end
	end
	--prepare new rows
	return t
end
function removeRow(t,k)
	ins(freeRow,rem(t,k))
end

--Single-usage funcs
langName={"中文","English"}
local langID={"chi","eng"}
function swapLanguage(l)
	text=require("language/"..langID[l])
	Buttons.sel=nil
	for S,L in next,Buttons do
		for N,B in next,L do
			B.alpha=0
			B.t=text.ButtonText[S][N]
		end
	end
	drawableText.next:set(text.next)
	drawableText.hold:set(text.hold)
	if royaleCtrlPad then royaleCtrlPad:release()end
	gc.push("transform")
	gc.origin()
		royaleCtrlPad=gc.newCanvas(300,100)
		gc.setCanvas(royaleCtrlPad)
		gc.setColor(1,1,1)
		setFont(25)
		gc.setLineWidth(2)
		for i=1,4 do
			gc.rectangle("line",RCPB[2*i-1],RCPB[2*i],90,35,8,4)
			mStr(text.atkModeName[i],RCPB[2*i-1]+45,RCPB[2*i]+3)
		end
		gc.setCanvas()
	gc.pop()
	collectgarbage()
end

local vibrateLevel={0,0,.03,.04,.05,.07,.9}
function VIB(t)
	if setting.vib>0 then
		love.system.vibrate(vibrateLevel[setting.vib+t])
	end
end
function sysSFX(s,v)
	if setting.sfx then
		local n=1
		::L::if sfx[s][n]:isPlaying()then
			n=n+1
			if not sfx[s][n]then
				sfx[s][n]=sfx[s][n-1]:clone()
				sfx[s][n]:seek(0)
				goto quit
			end
			goto L
		end::quit::
		sfx[s][n]:setVolume(v or 1)
		sfx[s][n]:play()
	end
end
function SFX(s,v)
	if setting.sfx and not P.ai then
		local n=1
		::L::if sfx[s][n]:isPlaying()then
			n=n+1
			if not sfx[s][n]then
				sfx[s][n]=sfx[s][n-1]:clone()
				sfx[s][n]:seek(0)
				goto quit
			end
			goto L
		end::quit::
		sfx[s][n]:setVolume(v or 1)
		sfx[s][n]:play()
	end
end
function BGM(s)
	if setting.bgm and bgmPlaying~=s then
		if bgmPlaying then newTask(Event_task.bgmFadeOut,nil,bgmPlaying)end
		for i=1,#Task do
			if Task[i].code==Event_task.bgmFadeIn then
				Task[i].code=Event_task.bgmFadeOut
			end
		end
		if s then
			newTask(Event_task.bgmFadeIn,nil,s)
			bgm[s]:play()
		end
		bgmPlaying=s
	end
end

local swapDeck_data={
	{4,0,1,1},{6,0,15,1},{5,0,9,1},{6,0,6,1},
	{1,0,3,1},{3,0,12,1},{1,1,8,1},{2,1,4,2},
	{3,2,13,2},{4,1,12,2},{5,2,1,2},{7,1,11,2},
	{2,1,9,3},{3,0,6,3},{4,2,14,3},{1,0,4,4},
	{7,1,1,4},{6,0,2,4},{5,2,6,4},{6,0,14,5},
	{3,3,15,5},{4,0,7,6},{7,1,10,5},{5,0,2,6},
	{2,1,1,7},{1,0,4,6},{4,1,13,5},{1,1,6,7},
	{5,3,11,5},{3,2,11,7},{6,0,8,7},{4,2,12,8},
	{7,0,8,9},{1,0,2,8},{5,2,4,8},{6,0,15,8},
}--Block id [ZSLJTOI] ,dir,x,y
local swap={
	none={2,1,d=function()end},
	flash={8,1,d=function()gc.clear(1,1,1)end},
	fade={30,15,d=function()
		local t=1-abs(sceneSwaping.time*.06667-1)
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,1280,720)
	end},
	deck={50,8,d=function()
		local t=sceneSwaping.time
		gc.setColor(1,1,1)
		if t>8 then
			local t=max(t,15)
			for i=1,51-t do
				local bn=swapDeck_data[i][1]
				local b=blocks[bn][swapDeck_data[i][2]]
				local cx,cy=swapDeck_data[i][3],swapDeck_data[i][4]
				for y=1,#b do for x=1,#b[1]do
					if b[y][x]then
						gc.draw(blockSkin[bn],80*(cx+x-2),80*(10-cy-y),nil,8/3)
					end
				end end
			end
		end
		if t<17 then
			gc.setColor(1,1,1,(8-abs(t-8))*.125)
			gc.rectangle("fill",0,0,1280,720)
		end
	end},
}--Scene swapping animations
function gotoScene(s,style)
	if not sceneSwaping and s~=scene then
		style=style or"fade"
		sceneSwaping={
			tar=s,style=style,
			time=swap[style][1],mid=swap[style][2],
			draw=swap[style].d
		}
		Buttons.sel=nil
		if style~="none"then
			sysSFX("swipe")
		end
	end
end
local prevMenu={
	load=love.event.quit,
	intro="quit",
	main="intro",
	mode="main",
	custom="mode",
	draw=function()
		kb.setKeyRepeat(false)
		gotoScene("custom")
	end,
	ready="mode",
	play=function()
		clearTask("play")
		gotoScene(curMode.id~="custom"and"mode"or"custom","deck")
	end,
	pause=function()
		clearTask("play")
		gotoScene(curMode.id~="custom"and"mode"or"custom","deck")
	end,
	help="main",
	stat="main",
	setting=function()
		saveSetting()
		gotoScene("main")
	end,
	setting2="setting",
	setting3="setting",
}
function back()
	local t=prevMenu[scene]
	if type(t)=="string"then
		gotoScene(t)
	else
		t()
	end
end
function pauseGame()
	if bgmPlaying then bgm[bgmPlaying]:pause()end
	for i=1,#players.alive do
		local l=players.alive[i].keyPressing
		for j=1,#l do
			if l[j]then
				releaseKey(j,players.alive[i])
			end
		end
	end
	gotoScene("pause","none")
end
function resumeGame()
	if bgmPlaying then bgm[bgmPlaying]:play()end
	gotoScene("play","fade")
end
local dataOpt={
	"run",
	"game",
	"gametime",
	"piece",
	"row",
	"atk",
	"key",
	"rotate",
	"hold",
	"spin",
}
local saveOpt={
	"ghost","center",
	"grid","swap",
	"fxs","bg",

	"das","arr",
	"sddas","sdarr",

	"lang",

	"sfx","bgm",
	"vib",
	"fullscreen",
	"bgblock",
	"virtualkeyAlpha",
	"virtualkeyIcon",
	"virtualkeySwitch",
	"frameMul",
}
function loadData()
	userData:open("r")
	--local t=splitS(love.math.decompress(userdata,"zlib"),"\r\n")
	local t=splitS(userData:read(),"\r\n")
	userData:close()
	for i=1,#t do
		local i=t[i]
		if find(i,"=")then
			local t=sub(i,1,find(i,"=")-1)
			local v=sub(i,find(i,"=")+1)
			if t=="run"or t=="game"or t=="gametime"or t=="piece"or t=="row"or t=="atk"or t=="key"or t=="rotate"or t=="hold"or t=="spin"then
				v=toN(v)if not v or v<0 then v=0 end
				stat[t]=v
			end
		end
	end
end
function saveData()
	local t={}
	for i=1,#dataOpt do
		ins(t,dataOpt[i].."="..toS(stat[dataOpt[i]]))
	end
	t=table.concat(t,"\r\n")
	--t=love.math.compress(t,"zlib"):getString()
	userData:open("w")
	userData:write(t)
	userData:close()
end
function loadSetting()
	userSetting:open("r")
	--local t=splitS(love.math.decompress(userdata,"zlib"),"\r\n")
	local t=splitS(userSetting:read(),"\r\n")
	userSetting:close()
	for i=1,#t do
		local i=t[i]
		if find(i,"=")then
			local t=sub(i,1,find(i,"=")-1)
			local v=sub(i,find(i,"=")+1)
			if t=="sfx"or t=="bgm"or t=="bgblock"then
				setting[t]=v=="true"
			elseif t=="vib"then
				setting.vib=toN(v:match("[01234]"))or 0
			elseif t=="fullscreen"then
				setting.fullscreen=v=="true"
				love.window.setFullscreen(setting.fullscreen)
			elseif t=="keymap"then
				v=splitS(v,"/")
				for i=1,16 do
					local v1=splitS(v[i],",")
					for j=1,#v1 do
						setting.keyMap[i][j]=v1[j]
					end
				end
			elseif t=="keylib"then
				v=splitS(v,"/")
				for i=1,4 do
					local v1=splitS(v[i],",")
					for j=1,#v1 do
						setting.keyLib[i][j]=toN(v1[j])
					end
					for j=1,#setting.keyLib[i]do
						local v=setting.keyLib[i][j]
						if int(v)~=v or v>=9 or v<=0 then
							setting.keyLib[i]={i}
							break
						end
					end
				end
			elseif t=="virtualkey"then
				v=splitS(v,"/")
				for i=1,10 do
					if not v[i]then goto c end
					virtualkey[i]=splitS(v[i],",")
					for j=1,4 do
						virtualkey[i][j]=toN(virtualkey[i][j])
					end
					::c::
				end
			elseif t=="virtualkeyAlpha"then
				setting.virtualkeyAlpha=int(abs(toN(v)))
			elseif t=="virtualkeyIcon"or t=="virtualkeySwitch"then
				setting[t]=v=="true"
			elseif t=="frameMul"then
				setting.frameMul=min(max(toN(v)or 100,0),100)
			elseif t=="das"or t=="arr"or t=="sddas"or t=="sdarr"then
				v=toN(v)if not v or v<0 then v=0 end
				setting[t]=int(v)
			elseif t=="ghost"or t=="center"or t=="grid"or t=="swap"or t=="fxs"or t=="bg"then
				setting[t]=v=="true"
			elseif t=="lang"then
				setting[t]=toN(v:match("[12]"))or 1
			end
		end
	end
end
function saveSetting()
	local vk={}
	for i=1,10 do
		for j=1,4 do
			virtualkey[i][j]=int(virtualkey[i][j]+.5)
		end--Saving a integer is better?
		vk[i]=table.concat(virtualkey[i],",")
	end--pre-pack virtualkey setting
	local map={}
	for i=1,16 do
		map[i]=table.concat(setting.keyMap[i],",")
	end
	local lib={}
	for i=1,4 do
		lib[i]=table.concat(setting.keyLib[i],",")
	end
	local t={
		"keymap="..toS(table.concat(map,"/")),
		"keylib="..toS(table.concat(lib,"/")),
		"virtualkey="..toS(table.concat(vk,"/")),
	}
	for i=1,#saveOpt do
		ins(t,saveOpt[i].."="..toS(setting[saveOpt[i]]))
	end
	t=table.concat(t,"\r\n")
	--t=love.math.compress(t,"zlib"):getString()
	userSetting:open("w")
	userSetting:write(t)
	userSetting:close()
end