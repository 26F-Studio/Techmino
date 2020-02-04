function sysSFX(s,v)
	if setting.sfx then
		local n=1
		while sfx[s][n]:isPlaying()do
			n=n+1
			if not sfx[s][n]then
				sfx[s][n]=sfx[s][n-1]:clone()
				sfx[s][n]:seek(0)
			end
		end
		sfx[s][n]:setVolume(v or 1)
		sfx[s][n]:play()
	end
end
function SFX(s,v)
	if setting.sfx then
		local n=1
		while sfx[s][n]:isPlaying()do
			n=n+1
			if not sfx[s][n]then
				sfx[s][n]=sfx[s][n-1]:clone()
				sfx[s][n]:seek(0)
				break
			end
		end
		if P.id>1 then
			v=1/(#players.alive-1)
			-- if v<.02 then return nil end
		end
		sfx[s][n]:setVolume(v or 1)
		sfx[s][n]:play()
	end
end
function BGM(s)
	if setting.bgm and bgmPlaying~=s then
		for k,v in pairs(bgm)do v:stop()end
		if s then bgm[s]:play()end
		bgmPlaying=s
	end
end
function gotoScene(s,style)
	if not sceneSwaping and s~=scene then
		style=style or"deck"
		sceneSwaping={
			tar=s,style=style,
			time=swap[style][1],mid=swap[style][2],
			draw=swap[style].d
		}
		Buttons.sel=nil
	end
end
function startGame(mode)
	--rec=""
	gamemode=mode
	gotoScene("play")
end
function back()
	local t=prevMenu[scene]
	if type(t)=="string"then
		gotoScene(t)
	else
		t()
	end
end
function loadData()
	userData:open("r")
    --local t=string.splitS(love.math.decompress(userdata,"zlib"),"\r\n")
	local t=string.splitS(userData:read(),"\r\n")
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
	local t=table.concat({
		stringPack("run=",stat.run),
		stringPack("game=",stat.game),
		stringPack("gametime=",stat.gametime),
		stringPack("piece=",stat.piece),
		stringPack("row=",stat.row),
		stringPack("atk=",stat.atk),
		stringPack("key=",stat.key),
		stringPack("rotate=",stat.rotate),
		stringPack("hold=",stat.hold),
		stringPack("spin=",stat.spin),
	},"\r\n")
	--t=love.math.compress(t,"zlib"):getString()
	userData:open("w")
	userData:write(t)
	userData:close()
end
function loadSetting()
	userSetting:open("r")
    --local t=string.splitS(love.math.decompress(userdata,"zlib"),"\r\n")
	local t=string.splitS(userSetting:read(),"\r\n")
	userSetting:close()
	for i=1,#t do
		local i=t[i]
		if find(i,"=")then
			local t=sub(i,1,find(i,"=")-1)
			local v=sub(i,find(i,"=")+1)
			if t=="sfx"or t=="bgm"then
				setting[t]=v=="true"
			elseif t=="fullscreen"then
				setting.fullscreen=v=="true"
				love.window.setFullscreen(setting.fullscreen)
			elseif t=="keyset"then
				v=string.splitS(v)
				for i=#v+1,8 do v[i]="N/A"end
				setting.key=v
			elseif t=="gamepadset"then
				v=string.splitS(v)
				for i=#v+1,8 do v[i]="N/A"end
				setting.gamepad=v
			elseif t=="virtualkey"then
				v=string.splitS(v,"/")
				for i=1,9 do
					virtualkey[i]=string.splitS(v[i],",")
					for j=1,4 do
						virtualkey[i][j]=toN(virtualkey[i][j])
					end
				end
			elseif t=="virtualkeyAlpha"then
				setting.virtualkeyAlpha=int(abs(toN(v)))
			elseif t=="virtualkeyIcon"then
				setting.virtualkeyIcon=v=="true"
			elseif t=="virtualkeySwitch"then
				setting.virtualkeySwitch=v=="true"
			elseif t=="frameMul"then
				v=min(max(toN(v)or 100,0),100)
				setting.frameMul=v
			elseif t=="das"or t=="arr"or t=="sddas"or t=="sdarr"then
				v=toN(v)if not v or v<0 then v=0 end
				setting[t]=int(v)
			elseif t=="ghost"or t=="center"then
				setting[t]=v=="true"
			end
		end
	end
end
function saveSetting()
	local vk={}
	for i=1,9 do
		for j=1,4 do
			virtualkey[i][j]=int(virtualkey[i][j]+.5)
		end--Saving a integer is better?
		vk[i]=table.concat(virtualkey[i],",")
	end--pre-pack virtualkey setting

	local t=table.concat({
		stringPack("sfx=",setting.sfx),
		stringPack("bgm=",setting.bgm),
		stringPack("fullscreen=",setting.fullscreen),
		stringPack("das=",setting.das),
		stringPack("arr=",setting.arr),
		stringPack("sddas=",setting.sddas),
		stringPack("sdarr=",setting.sdarr),
		stringPack("keyset=",table.concat(setting.key,"/")),
		stringPack("gamepadset=",table.concat(setting.gamepad,"/")),
		stringPack("virtualkey=",table.concat(vk,"/")),
		stringPack("virtualkeyAlpha=",setting.virtualkeyAlpha),
		stringPack("virtualkeyIcon=",setting.virtualkeyIcon),
		stringPack("virtualkeySwitch=",setting.virtualkeySwitch),
		stringPack("frameMul=",setting.frameMul),
	},"\r\n")
	--t=love.math.compress(t,"zlib"):getString()
	userSetting:open("w")
	userSetting:write(t)
	userSetting:close()
end