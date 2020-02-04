math.randomseed(os.time()*626)
gc,kb,ms,tm,fs=love.graphics,love.keyboard,love.mouse,love.timer,love.filesystem
toN,toS=tonumber,tostring
int,ceil,abs,rnd,max,min,sin,cos,atan,pi=math.floor,math.ceil,math.abs,math.random,math.max,math.min,math.sin,math.cos,math.atan,math.pi
sub,gsub,find,format,byte,char=string.sub,string.gsub,string.find,string.format,string.byte,string.char
ins,rem,sort=table.insert,table.remove,table.sort
function null()end
function sortByTime(a,b)
	return a.time>b.time
end

ww,wh=gc.getWidth(),gc.getHeight()

Timer=tm.getTime
mx,my,mouseShow=-10,-10,true
pause=0--pause countdown
focus=true
scene=""
gamemode=""
bgmPlaying=nil
curBG="none"

languages={"eng"}
prevMenu={
	load=love.event.quit,
	ready="mode",
	play="mode",
	mode="main",
	help="main",
	stat="main",
	setting="main",
	setting2="setting",
	intro="quit",
	main="quit",
}
swap={
none={2,1,d=function()end},
flash={8,1,d=function()gc.clear(1,1,1)end},
deck={60,20,d=function()
	local t=sceneSwaping.time
	t=(t>40 and 60-t or t>20 and 20 or t)/255
	gc.setColor(.6,.6,.6,t*13)
	gc.rectangle("fill",0,0,1000,t*15)
	gc.rectangle("fill",0,600-t*15,1000,t*15)
	gc.setColor(.5,0,0,t*13)
	gc.line(0,t*15,1000,t*15)
	gc.line(0,600-t*15,1000,600-t*15)
end
},
}
kb.setKeyRepeat(false)
kb.setTextInput(false)

Texts={
	eng={
		load={"Loading textures","Loading BGM","Loading SFX","Finished",},
		stat={"Games played:","Game time:","Total block used:","Total rows cleared:","Total lines sent:",},
	},
}
numFonts={}
function numFont(s)
	if numFonts[s]then
		gc.setFont(numFonts[s])
	else
		local t=gc.setNewFont("cb.ttf",s)
		numFonts[s]=t
		gc.setFont(t)
	end
	currentFont=-1
end
Fonts={}for i=1,#languages do Fonts[languages[i]]={}end
fontLib={
eng=function(s)
	if s~=currentFont then
		if Fonts[s]then
			gc.setFont(Fonts[s])
		else
			local t=gc.setNewFont("cb.ttf",s)
			Fonts[s]=t
			gc.setFont(t)
		end
		currentFont=s
	end
end,
chi=function(s)
	if s~=currentFont then
		if Fonts[setting.lang][s]then
			gc.setFont(Fonts[setting.lang][s])
		else
			local t=gc.newFont("hei.ttf",s-5,"normal")
			Fonts[setting.lang][s]=t
			gc.setFont(t)
		end
		currentFont=s
	end
end,
}

require("button")

sfx={
	"button",
	"ready","start",
	"move","rotate","rotatekick","hold",
	"prerotate","prehold",
	"drop","fall",
	"reach",
	"ren_1","ren_2","ren_3","ren_4","ren_5","ren_6","ren_7","ren_8","ren_9","ren_10","ren_11",
	"clear_1","clear_2","clear_3","clear_4",
	"spin_0","spin_1","spin_2","spin_3",
	"perfectclear",
}
bgm={
	"blank",
	"way",
	"race",
	"push",
	"reason",
}
img={
	title={
		eng=gc.newImage("/image/title/eng.png"),
		chi=gc.newImage("/image/title/chi.png"),
	}
}
FX={
	flash=0,--Black screen(frame)
	shake=0,--Screen shake(frame)
	beam={},--Attack beam
	appear=function(t)
		setFont(t.font)
		gc.setColor(1,1,1,min((30-abs(t.t-30))*.05,1)*(#field>9 and .7 or 1))
		mStr(t.text,150,250-t.font*.5+t.dy)
	end,
	stretch=function(t)
		gc.push("transform")
			setFont(t.font)
			gc.translate(150,250)
			gc.setColor(1,1,1,min((30-abs(t.t-30))*.1,1)*(#field>9 and .7 or 1))
			if t.t<20 then gc.scale((20-t.t)*.015+1,1)end
			mStr(t.text,0,-t.font*.5+t.dy)
		gc.pop()
	end,
	drive=function(t)
		gc.push("transform")
			setFont(t.font)
			gc.translate(150,290)
			gc.setColor(1,1,1,min((30-abs(t.t-30))*.1,1)*(#field>9 and .7 or 1))
			if t.t<20 then gc.shear((20-t.t)*.03,0)end
			mStr(t.text,0,-t.font*.5+t.dy)
		gc.pop()
	end,
	spin=function(t)
		gc.push("transform")
			setFont(t.font)
			gc.translate(150,250)
			gc.setColor(1,1,1,min((30-abs(t.t-30))*.1,1)*(#field>9 and .7 or 1))
			if t.t<20 then
				gc.scale((20-t.t)*.01+1,(20-t.t)*.015+1)
			end
			mStr(t.text,0,-t.font*.5+t.dy)
		gc.pop()
	end,
	flicker=function(t)
		setFont(t.font)
		gc.setColor(1,1,1,min((30-abs(t.t-30))*.05,1)*(#field>9 and .7 or 1)*(rnd()+.5))
		mStr(t.text,150,250-t.font*.5+t.dy)
	end,
}
function stencil_field()
	gc.rectangle("fill",0,0,300,600)
end
--System data
list={
	clearname={"Single","Double","Triple"},
	reason={[0]="Escape","Block out","Lock out","Finished","Top out"},
	method={"Bag7","His4","Rnd"},
}
actName={"moveLeft","moveRight","rotRight","rotLeft","rotFlip","hardDrop","softDrop","hold","toLeft","toRight"}
actName_={"move left","move right","rotate right","rotate left","rotate flip","hard drop","soft drop","hold","toLeft","toRight"}
name={"Z","S","L","J","T","O","I"}
blockPos={4,4,4,4,4,5,4}
renATK={[0]=0,0,0,1,1,1,2,2,2,3,3,3}
require"SRS"
gameEnv0={
	das=6,arr=1,
	ghost=true,center=true,
	drop=30,lock=45,
	wait=0,fall=20,
	next=6,hold=true,
	sequence=1,visible=1,
	_20G=false,target=9e99,
	color={1,5,2,8,10,3,7,13},
	key={"left","right","x","z","c","up","down","space","LEFT","RIGHT"},
	reach=function()end
}
randomMethod={
	function()
		P.bn,P.cb=rem(nxt,1),rem(nb,1)
		if #nxt<6 then
			local bag={1,2,3,4,5,6,7}
			for i=1,7 do
				ins(nxt,rem(bag,rnd(8-i)))
			end
		end
		for i=6,#nxt do
			nb[i]=blocks[nxt[i]][0]
		end
	end,
	function()
		P.bn,P.cb=rem(nxt,1),rem(nb,1)
		for j=1,4 do
			local i,f=rnd(7)
			for k=1,4 do
				if i==his[k]then f=true end
			end
			if not f then break end
		end
		P.nxt[6],P.nb[6]=i,blocks[i][0]
		rem(his,1)ins(his,i)
	end,
	function()
		P.bn,P.cb=rem(nxt,1),rem(nb,1)
		repeat i=rnd(7)until i~=nxt[5]
		P.nxt[6],P.nb[6]=i,blocks[i][0]
	end,
}
loadmode={
	marathon=function()
		modeEnv={
			drop=60,
			wait=1,
			fall=20,
			target=10,
			reach=Event.marathon_reach,
		}
		createPlayer(1,190,20,.8)
		curBG="game1"
		BGM("way")
	end,
	sprint=function()
		modeEnv={
			wait=1,
			fall=1,
			target=40,
			reach=Event.gameover.win,
		}
		createPlayer(1,190,20,.8)
		curBG="game1"
		BGM("race")
	end,
	zen=function()
		modeEnv={
			drop=1e99,
			lock=1e99,
			wait=1,
			fall=1,
			target=200,
			reach=Event.gameover.win,
		}
		createPlayer(1,190,20,.8)
		curBG="game1"
		BGM("reason")
	end,
	gm=function()
		modeEnv={
			drop=60,
			wait=10,
			fall=5,
			target=100,
			reach=Event.gm_reach,
		}
		createPlayer(1,190,20,.8)
		curBG="game2"
		BGM("push")
	end,
	battle=function()
		modeEnv={
			wait=1,
			fall=1,
		}
		createPlayer(1,240,30,.8)--Player

		-- createPlayer(2,580,25,.38,true)
		-- createPlayer(3,580,315,.38,true)
		--Triple

		-- createPlayer(2,580,140,.6,true)
		--Solo

		local n=2
		for i=1,3 do
			for j=1,7 do
				createPlayer(n,75*i-65,80*j-55,.1,true)
				n=n+1
			end
		end
		for i=11,13 do
			for j=1,7 do
				createPlayer(n,75*i-65,80*j-55,.1,true)
				n=n+1
			end
		end

		curBG="game2"
		BGM("race")
	end,
}
Event={
	task={
		win=function()
			gameover=gameover+1
			if gameover%3==0 then
				local j=gameover/3
				if j<=#field then
					for i=1,10 do
						if field[j][i]>0 then field[j][i]=13 end
					end
					if j==#field then gameover=50 end
				end
			end
			if gameover>80 then
				return true
			end
		end,
		lose=function()
			gameover=gameover+1
			if gameover%3==0 then
				local j=gameover/3
				if j<=#field then
					for i=1,10 do
						if field[j][i]>0 then field[j][i]=13 end
					end
				end
			end
			if gameover>80 then
				return true
			end
		end,
	},
	gameover={
		win=function()
			P.control=false
			P.waiting=1e99
			gameover=0
			for i=1,#visTime do for j=1,10 do
				P.visTime[i][j]=1e99
			end end--Make all visible
			P.control=false
			ins(task,Event.task.win)
		end,
		lose=function()
			P.control=false
			P.waiting=1e99
			gameover=0
			for i=1,#visTime do for j=1,10 do
				P.visTime[i][j]=1e99
			end end--Make all visible
			P.control=false
			for i=1,#players.alive do
				if players.alive[i]==P.id then
					rem(players.alive,i)
					break
				end
			end
			for i=1,#P.atkBuffer do
				P.atkBuffer[i].sent=true
				P.atkBuffer[i].time=0
			end
			ins(task,Event.task.lose)
		end,
	},
	marathon_reach=function()
		local s=int(P.cstat.row*.1)
		if s>=20 then
			Event.gameover.win()
		else
			gameEnv.drop=Data.marathon_drop[s]
			gameEnv.target=s*10+10
		end
	end,
	gm_reach=function()

	end
}
Data={
	marathon_drop={[0]=60,50,40,30,25,20,18,16,14,12,10,8,7,6,5,4,3,2,1,1},
	shirase_drop={[0]=0},
	shirase_lock={[0]=0},
	shirase_are={[0]=0},
	shirase_lare={[0]=0},
}
mesDisp={
	marathon=function()
		gc.setColor(1,1,1)
		setFont(40)
		gc.print(format("%0.2f",time),-130,530)
		mStr(P.cstat.row.."/"..gameEnv.target,-80,250)
	end,
	sprint=function()
		gc.setColor(1,1,1)
		setFont(40)
		gc.print(format("%0.2f",time),-130,530)
		setFont(75)
		mStr(max(40-P.cstat.row,0),-80,280)
	end,
	zen=function()
		gc.setColor(1,1,1)
		setFont(40)
		gc.print(format("%0.2f",time),-130,530)
		setFont(75)
		mStr(max(200-P.cstat.row,0),-80,280)
	end,
	gm=function()end,
	battle=function()end,
}
--Game system Data

setting={
	sfx=true,bgm=true,
	fullscreen=false,
	lang="eng",
	das=5,arr=0,
	ghost=true,center=true,
	key={"left","right","x","z","c","up","down","space","LEFT","RIGHT"},
	color={1,5,2,8,10,3,7,13},
}
stat={
	run=0,
	game=0,
	gametime=0,
	piece=0,
	row=0,
	atk=0,
	key=0,
	hold=0,
	rotate=0,
	spin=0,
}
--Userdata tables

function string.splitS(s,sep)
	sep=sep or"/"
	local t={}
	repeat
		local i=find(s,sep)
		ins(t,sub(s,1,i-1))
		s=sub(s,i+#sep)
	until #s==0
	return t
end
function string.concat(t,sep)
	sep=sep or"/"
	local s=""
	for i=1,#t do
		s=s..t[i]..sep
	end
	return s
end
function sgn(i)return i>0 and 1 or i<0 and -1 or 0 end
function stringPack(s,v)return s..toS(v).."\r\n"end
function without(t,v)
	for i=1,#t do
		if t[i]==v then return nil end
	end
	return true
end
function nextLanguage()
	for i=1,#languages do
		if setting.lang==languages[i]then return languages[i+1]or"eng"end
	end
end
function mStr(s,x,y)gc.printf(s,x-500,y,1000,"center")end
function mouseConvert(x,y)
	if wh/ww<=.6 then
		return 500+(x-ww*.5)*600/wh,y*600/wh
	else
		return x*1000/ww,300+(y-wh*.5)*1000/ww
	end
end
function drawButton()
	for i=1,#Buttons[scene]do
		local B=Buttons[scene][i]
		if not(B.hide and B.hide())then
			local t=B==Buttons.sel and .3 or 0
			B.alpha=abs(B.alpha-t)>.02 and(B.alpha+(B.alpha<t and .02 or -.02))or t
			if B.alpha>t then B.alpha=B.alpha-.02 elseif B.alpha<t then B.alpha=B.alpha+.02 end
			gc.setColor(B.rgb[1],B.rgb[2],B.rgb[3],B.alpha)
			gc.rectangle("fill",B.x-B.w*.5,B.y-B.h*.5,B.w,B.h)
			local t=type(B.t)=="string"and B.t or B.t()
			gc.setColor(B.rgb[1],B.rgb[2],B.rgb[3],.3)
			gc.setLineWidth(6)gc.rectangle("line",B.x-B.w*.5,B.y-B.h*.5,B.w,B.h)
			mStr(t,B.x-1,B.y-1-currentFont*.5)
			mStr(t,B.x-1,B.y+1-currentFont*.5)
			mStr(t,B.x+1,B.y-1-currentFont*.5)
			mStr(t,B.x+1,B.y+1-currentFont*.5)
			gc.setColor(B.rgb)
			gc.setLineWidth(3)gc.rectangle("line",B.x-B.w*.5,B.y-B.h*.5,B.w,B.h)
			mStr(t,B.x,B.y-currentFont*.5)
		end
	end
end
function SFX(s,v)
	if setting.sfx then
		sfx[s]:stop()
		sfx[s]:setVolume(v or 1)
		sfx[s]:play()
	end
end
function BGM(s)
	if setting.bgm and bgmPlaying~=s then
		for k,v in pairs(bgm)do v:stop()end
		if s then bgm[s]:play()end
		bgmPlaying=s
	end
end
--System functions

function gotoScene(s,style)
	if not sceneSwaping and s~=scene then
		style=style or"none"
		sceneSwaping={
			tar=s,style=style,
			time=swap[style][1],mid=swap[style][2],
			draw=swap[style].d
		}
	end
end
function createPlayer(id,x,y,size,ifAI,data)
	players[id]={id=id}
	ins(players.alive,id)
	local P=players[id]
	P.index={__index=P}
	P.x,P.y,P.size=x,y,size

	if ifAI then
		P.ai={
			controls={},
			controlDelay=2,
			controlDelay0=2,
		}
	end

	P.control=false
	P.time=0
	P.cstat={piece=0,row=0,atk=0}--Current gamestat
	P.keyTime={}for i=1,10 do P.keyTime[i]=-1e5 end P.keySpeed=0
	P.dropTime={}for i=1,10 do P.dropTime[i]=-1e5 end P.dropSpeed=0

	P.gameEnv={}--Game setting vars,like dropDelay setting
	for k,v in pairs(gameEnv0)do
		if data and data[k]~=nil then
			P.gameEnv[k]=data[k]
		elseif modeEnv[k]~=nil then
			P.gameEnv[k]=modeEnv[k]
		elseif setting[k]~=nil then
			P.gameEnv[k]=setting[k]
		else
			P.gameEnv[k]=v
		end
	end--reset current game settings

	P.field,P.visTime,P.atkBuffer={},{},{}
	P.hn,P.hb,P.holded=0,{{}},false
	P.nxt,P.nb={},{}
	P.dropDelay,P.lockDelay=P.gameEnv.drop,P.gameEnv.lock

	local bag1={1,2,3,4,5,6,7}
	for i=1,7 do
		P.nxt[i]=rem(bag1,rnd(#bag1))
		P.nb[i]=blocks[P.nxt[i]][0]
	end--First bag

	if P.gameEnv.sequence==1 then P.bag={}--Bag7
	elseif P.gameEnv.sequence==2 then P.his={}for i=1,4 do P.his[i]=P.nxt[i+3]end--History4
	elseif P.gameEnv.sequence==3 then--Pure random
	end
	P.showTime=P.gameEnv.visible==1 and 1e99 or P.gameEnv.visible==2 and 300 or 20
	P.freshNext=randomMethod[P.gameEnv.sequence]
	P.cb,P.sc,P.bn,P.r,P.c,P.cx,P.cy,P.dir,P.y_img={{}},{0,0},1,0,0,0,0,0,0
	P.keyPressing={}for i=1,10 do P.keyPressing[i]=false end
	P.moving,P.downing=0,0
	P.waiting,P.falling=0,0
	P.clearing={}
	P.fieldBeneath=0

	P.combo=0
	P.b2b=false

	P.task={}
	P.bonus={}
end
function startGame(mode)
	--rec=""
	gamemode=mode
	players={alive={}}
	loadmode[mode]()

	frame=0
	count=179
	for i=1,#PTC.dust do PTC.dust[i]:release()end
	for i=1,#players do
		PTC.dust[i]=PTC.dust[0]:clone()
		PTC.dust[i]:start()
	end
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
function loaddata()
	userdata:open("r")
    --local t=string.splitS(love.math.decompress(userdata,"zlib"),"\r\n")
	local t=string.splitS(userdata:read(),"\r\n")
	userdata:close()
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
			elseif t=="lang"then
				if not Fonts[v]then v="eng"end
				setting.lang=v
				setFont=fontLib[v]
			elseif t=="keyset"then
				v=string.splitS(v)
				for i=#v+1,8 do v[i]="N/A"end
				setting.key=v
			--Settings
			elseif t=="das"or t=="arr"then
				v=toN(v)if not v or v<0 then v=0 end
				setting[t]=v
			elseif t=="ghost"or t=="center"then
				setting[t]=v=="true"
			elseif t=="run"or t=="game"or t=="gametime"or t=="piece"or t=="row"or t=="atk"or t=="key"then
				v=toN(v)if not v or v<0 then v=0 end
				stat[t]=v
			--Statistics
			end
		end
	end
end
function savedata()
	local t=""
	t=t..stringPack("sfx=",setting.sfx)
	t=t..stringPack("bgm=",setting.bgm)
	t=t..stringPack("fullscreen=",setting.fullscreen)
	t=t..stringPack("lang=",setting.lang)

	t=t..stringPack("run=",stat.run)
	t=t..stringPack("game=",stat.game)
	t=t..stringPack("gametime=",stat.gametime)
	t=t..stringPack("piece=",stat.piece)
	t=t..stringPack("row=",stat.row)
	t=t..stringPack("atk=",stat.atk)
	t=t..stringPack("key=",stat.key)
	t=t..stringPack("das=",setting.das)
	t=t..stringPack("arr=",setting.arr)
	t=t..stringPack("keyset=",string.concat(setting.key))
	--t=love.math.compress(t,"zlib"):getString()
	userdata:open("w")
	userdata:write(t)
	userdata:close()
end
--System events
function showText(text,type,font,dy)
	ins(P.bonus,{t=0,text=text,draw=FX[type],font=font,dy=dy or 0})
end
function createBeam(s,r)--Player id
	s,r=players[s],players[r]
	ins(FX.beam,{s.x+308*s.size,s.y+680*s.size,r.x+308*r.size,r.y+680*r.size,t=0})
end
function freshgho()
	if not P.gameEnv._20G then
		P.y_img=P.cy>#field+1 and #field+1 or P.cy
		while not ifoverlap(cb,cx,y_img-1)do
			P.y_img=P.y_img-1
		end
	else
		while not ifoverlap(cb,cx,cy-1)do
			P.cy=P.cy-1
		end
		P.y_img=P.cy
	end
end
function ifoverlap(bk,x,y)
	if x<1 or x+#bk[1]>11 or y<1 then return true end
	if y>#field then return nil end
	for i=1,#bk do for j=1,#bk[1]do
		if field[y+i-1]and bk[i][j]>0 and field[y+i-1][x+j-1]>0 then return true end
	end end
end
function resetblock()
	P.holded=false
	P.freshNext()
	P.sc={scs[bn][1],scs[bn][2]}P.dir=0
	P.r,P.c=#cb,#cb[1]
	P.cx,P.cy=blockPos[bn],21+ceil(fieldBeneath/30)
	freshgho()
	P.dropDelay,P.lockDelay=gameEnv.drop,gameEnv.lock
	if keyPressing[8]then hold(true)end
	if keyPressing[3]then spin(1,true)end
	if keyPressing[4]then spin(-1,true)end
	if keyPressing[5]then spin(2,true)end
	if ifoverlap(cb,cx,cy)then Event.gameover.lose()end
	if keyPressing[6]then act.hardDrop()P.keyPressing[6]=false end
end
function pressKey(i,player)
	P=player or players[1]
	setmetatable(_G,P.index)
	if control then
		P.keyPressing[i]=true
		if waiting<=0 then
			act[actName[i]]()
			if i>2 and i<6 then keyPressing[i]=false end
		elseif i==1 then
			P.moving=-1
		elseif i==2 then
			P.moving=1
		end
		P.cstat.key=stat.key+1;ins(keyTime,1,frame)rem(keyTime,11)
		-- if playmode=="recording"then ins(rec,{i,frame})end
		stat.key=stat.key+1
	end
end
function releaseKey(i,player)
	P=player or players[1]
	setmetatable(_G,P.index)
	P.keyPressing[i]=false
	-- if playmode=="recording"then ins(rec,{-i,frame})end
end
function spin(d,ifpre)
	if bn==6 then return nil end
	local icb=blocks[bn][(dir+d)%4]
	local isc=d==1 and{c-sc[2]+1,sc[1]}or d==-1 and{sc[2],r-sc[1]+1}or{r-sc[1]+1,c-sc[2]+1}
	local ir,ic=#icb,#icb[1]
	local ix,iy=cx+sc[2]-isc[2],cy+sc[1]-isc[1]
	local t=false
	local iki=SRS[bn][dir*10+(dir+d)%4]
	for i=1,#iki do
		if not ifoverlap(icb,ix+iki[i][1],iy+iki[i][2])then
			ix,iy=ix+iki[i][1],iy+iki[i][2]
			t=true
			break
		end
	end
	if t then
		P.cx,P.cy=ix,iy
		P.sc,P.cb=isc,icb
		P.r,P.c=ir,ic
		P.dir=(dir+d)%4
		freshgho()
		P.lockDelay=gameEnv.lock
		SFX(ifpre and"prerotate"or ifoverlap(cb,cx,cy+1)and ifoverlap(cb,cx-1,cy)and ifoverlap(cb,cx+1,cy)and"rotatekick"or"rotate")
		stat.rotate=stat.rotate+1
	end
end
function hold(ifpre)
	if not holded and waiting<=0 and gameEnv.hold then
		P.hn,P.bn=bn,hn
		P.hb,P.cb=blocks[hn][0],hb

		if bn==0 then freshNext()end
		P.sc={scs[bn][1],scs[bn][2]}P.dir=0
		P.r,P.c=#cb,#cb[1]
		P.cx,P.cy=blockPos[bn],21
		freshgho()
		P.dropDelay,P.lockDelay=gameEnv.drop,gameEnv.lock
		if ifoverlap(cb,cx,cy) then Event.gameover.lose()end
		P.holded=true
		SFX(ifpre and"prehold"or"hold")
		stat.hold=stat.hold+1
	end
end
function drop()
	if cy==y_img then
		P.waiting=gameEnv.wait
		local dospin=ifoverlap(cb,cx,cy+1)and ifoverlap(cb,cx-1,cy)and ifoverlap(cb,cx+1,cy)
		ins(dropTime,1,frame)rem(dropTime,11)
		lock()
		local cc,csend=checkrow(cy,r),0--Currect clear&send

		P.combo=P.combo+1--combo=0 is under
		if cc==4 then
			if b2b then
				showText("Tetris B2B","drive",70)
				csend=5
			else
				showText("Tetris","stretch",80)
				csend=4
				P.b2b=true
			end
		elseif cc>0 then
			if dospin then
				if b2b then
					showText(name[bn].." spin "..list.clearname[cc].." B2B","spin",40)
					csend=2*cc+1
				else
					showText(name[bn].." spin "..list.clearname[cc],"spin",50)
					csend=2*cc
					P.b2b=true
				end
				SFX("spin_"..cc)
				stat.spin=stat.spin+1
			else
				P.b2b=false
				showText(list.clearname[cc],"appear",50)
				csend=cc-1
			end
		else
			P.combo=0
			if dospin then
				showText(name[bn].." spin","appear",50)
				SFX("spin_0")
			end
		end
		if cc>0 and #clearing==#field then
			showText("Perfect Clear","flicker",70,-60)
			csend=csend+5
			SFX("perfectclear")
		end
		csend=csend+(renATK[combo]or 4)
		if cc>0 then
			SFX("clear_"..cc)
			SFX("ren_"..min(combo,11))
		end
		if csend>0 then
			while csend>0 and P.atkBuffer[1]do
				csend=csend-1
				P.atkBuffer[1].amount=P.atkBuffer[1].amount-1
				if P.atkBuffer[1].amount==0 then
					rem(P.atkBuffer,1)
				end
			end
			if csend>0 and #players.alive>1 then garbageSend(P.id,csend,120)end
		elseif cc==0 then
			garbageRelease()
		end--Send attack
		stat.piece,stat.row,stat.atk=stat.piece+1,stat.row+cc,stat.atk+csend
		P.cstat.piece,P.cstat.row,P.cstat.atk=P.cstat.piece+1,P.cstat.row+cc,P.cstat.atk+csend
		if P.cstat.row>=gameEnv.target then
			gameEnv.reach()
			if control then SFX("reach")end
		end
	else
		if cy>y_img then P.cy=cy-1 end
	end
end
function lock()
	for i=1,r do
		local y=cy+i-1
		if not P.field[y]then P.field[y],P.visTime[y]={0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0}end
		for j=1,c do
			if cb[i][j]~=0 then
				P.field[y][cx+j-1]=P.gameEnv.color[bn]
				P.visTime[y][cx+j-1]=P.showTime
			end
		end
	end
end
function ckfull(i)
	for j=1,10 do if field[i][j]==0 then return nil end end
	return true
end
function checkrow(s,num)--(cy,r)
	local c=0--rows cleared
	for i=s,s+num-1 do if ckfull(i)then
		ins(clearing,1,i)
		P.falling=gameEnv.fall
		c=c+1--row cleared+1
		for k=1,1000 do
			PTC.dust[P.id]:setPosition(rnd(0,300),600-30*i+rnd(30))
			PTC.dust[P.id]:emit(1)
		end
	end end
	return c
end
function garbageSend(sender,send,time)
	local pos,r=rnd(10)
	repeat
		r=players.alive[rnd(#players.alive)]
	until r~=P.id
	createBeam(sender,r)
	ins(players[r].atkBuffer,{pos,amount=send,countdown=time,cd0=time,time=0,sent=false})
	sort(players[r].atkBuffer,sortByTime)
end
function garbageRelease()
	local t=P.showTime*2
	for i=1,#P.atkBuffer do
		local atk=P.atkBuffer[i]
		if not atk.sent and atk.countdown==0 then
			for j=1,atk.amount do
				ins(P.field,1,{13,13,13,13,13,13,13,13,13,13})
				ins(P.visTime,1,{t,t,t,t,t,t,t,t,t,t})
				for k=1,#atk do
					P.field[1][atk[k]]=0
				end
			end
			atk.sent=true
			atk.time=0
			P.fieldBeneath=P.fieldBeneath+atk.amount*30
		end
	end
end
function drawPixel(y,x,id,alpha)
	gc.setColor(1,1,1,alpha)
	gc.draw(blockSkin[id],30*x-30,600-30*y)
end
--------------------------------Warning!_G is __indexed to players[n]!

require("user_actions")--Game control functions

mouseDown={}
keyDown={}
function keyDown.play(key)
	local k=players[1].gameEnv.key
	for i=1,10 do
		if key==k[i]then
			pressKey(i,players[1])
			break
		end
	end
	if key=="escape"then back()end
end
function keyDown.setting2(key)
	if key=="escape"then
		back()
	elseif keysetting then
		setting.key[keysetting]=key
		keysetting=nil
	end
end
keyUp={}
function keyUp.play(key)
	local k=players[1].gameEnv.key
	for i=1,10 do
		if key==k[i]then
			releaseKey(i,players[1])
			break
		end
	end
end
wheelmoved={}

require("ai")--AI module
require("timer")--Timer
require("paint")--Paint
require("game_scene")--Game scenes
require("control")--User control

function love.update(dt)
	if players then
		for i=1,#players do
			for k,v in pairs(players[i])do
				if rawget(_G,k)then print(i,k)end
			end
		end
	end
	if Buttons.pressing>0 then
		Buttons.pressing=Buttons.pressing+1
		if Buttons.pressing>35 and Buttons.pressing%6==0 then love.mousepressed(ms.getX(),ms.getY(),1)end
	end
	if sceneSwaping then
		sceneSwaping.time=sceneSwaping.time-1
		if sceneSwaping.time==sceneSwaping.mid then
			for i=1,#Buttons[scene]do
				Buttons[scene][i].alpha=0
			end
			game[sceneSwaping.tar]()
			Buttons.sel=nil
			love.mousemoved(ms.getX(),ms.getY())
		elseif sceneSwaping.time==0 then
			sceneSwaping=nil
		end
	elseif Tmr[scene]then
		Tmr[scene](dt)
	end
end
function love.draw()
	Pnt.BG[curBG]()
	if Pnt[scene]then Pnt[scene]()end
	setFont(35)
	drawButton()
	if mouseShow then
		gc.setColor(1,0,0,.6)
		gc.circle("fill",mx,my,4)
	end
	if sceneSwaping then sceneSwaping.draw()end

	gc.setColor(0,0,0)
	if wh/ww>=.6 then
		gc.rectangle("fill",0,0,1000,-(wh*1000/ww-600)*.5)
		gc.rectangle("fill",0,600,1000,(wh*1000/ww-600)*.5)
	else
		gc.rectangle("fill",0,0,-(ww*600/wh-1000)*.5,600)
		gc.rectangle("fill",1000,0,(ww*600/wh-1000)*.5,600)
	end--Draw black side

	--numFont(10)gc.setColor(1,1,1)
	--gc.print(tm.getFPS(),0,590)
	--if gcinfo()>500 then collectgarbage()end
end
function love.resize(x,y)
	ww,wh=x,y
	gc.origin()
	gc.translate(ww*.5,wh*.5)
	if wh/ww>=.6 then
		gc.scale(ww/1000)
	else
		gc.scale(wh/600)
	end
	gc.translate(-500,-300)
end
function love.focus(f)
	if f then
		focus=true
		ms.setVisible(false)
		if bgmPlaying then bgm[bgmPlaying]:play()end
	else
		if scene=="play"then pause=20 end
		focus=false
		ms.setVisible(true)
		if bgmPlaying then bgm[bgmPlaying]:pause()end
	end
end
function love.run()
	tm.step()
	love.resize(1000,600)
	game.load()--Launch
	return function()
		love.event.pump()
		for name,a,b,c,d,e,f in love.event.poll()do
			if name=="quit"then
				savedata()
				return 0
			end
			love.handlers[name](a,b,c,d,e,f)
		end
		if focus or pause==20 then
			tm.step()
			love.update(tm.getDelta())
			if gc.isActive()then
				gc.clear(1,1,1)
				love.draw()--Draw all things
				gc.present()
			end
		end
	end
end
--System callbacks

do--Texture/Image
	local p=gc.newImage("/image/block.png")
	local l={}
	gc.setColor(1,1,1)
	for i=1,13 do
		l[i]=gc.newCanvas(30,30)
		gc.setCanvas(l[i])
		gc.draw(p,30-30*i)
	end
	blockSkin=l
	l={}
	for i=1,1 do
		local p=gc.newImage("/image/BG/"..i..".png")
		l[i]=gc.newCanvas(1200,1200)
		gc.setCanvas(l[i])
		gc.draw(p,nil,nil,nil,10,10)
		p:release()
	end
	background=l
	gc.setCanvas()
end
do--Particle
	PTC={dust={}}--Particle systems
	c=gc.newCanvas(6,6)gc.setCanvas(c)
	gc.clear(1,1,1)
	PTC.dust[0]=gc.newParticleSystem(c,10000)
	PTC.dust[0]:setParticleLifetime(.2,.3)
	PTC.dust[0]:setEmissionRate(0)
	PTC.dust[0]:setLinearAcceleration(-1500,-200,1500,200)
	PTC.dust[0]:setColors(1,1,1,.4,1,1,1,0)
	--Dust particles
	gc.setCanvas()
end
c=nil

userdata=fs.newFile("userdata")
if fs.getInfo("userdata")then
	loaddata()
end

stat.run=stat.run+1
setFont=fontLib[setting.lang]
Text=Texts[setting.lang]