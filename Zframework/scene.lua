local gc=love.graphics
local int,abs=math.floor,math.abs
local max,log=math.max,math.log
local rnd,sin,cos=math.random,math.sin,math.cos
local format=string.format
local scr=scr

local sceneInit={}
sceneInit.quit=love.event.quit
function sceneInit.calculator()
	sceneTemp={
		reg=false,
		val=0,
		sym=false,
		pass=false,
		tip=require("parts/getTip"),
	}
end
function sceneInit.load()
	sceneTemp={
		phase=1,--Loading stage
		cur=1,--Counter
		tip=setting.appLock or require("parts/getTip"),
		list={
			#VOC.name,
			#BGM.list,
			#SFX.list,
			IMG.getCount(),
			#Modes,
			1,
		},
		skip=false,--If skipped
	}
end
function sceneInit.intro()
	BG.set("space")
	sceneTemp={
		t1=0,--Timer 1
		t2=0,--Timer 2
		r={},--Random animation type
	}
	for i=1,8 do
		sceneTemp.r[i]=rnd(5)
	end
	BGM.play("blank")
end
function sceneInit.main()
	BG.set("space")
	BGM.play("blank")

	modeEnv={}
	--Create demo player
	destroyPlayers()
	PLY.newDemoPlayer(1,900,35,1.1)
end
function sceneInit.music()
	if BGM.nowPlay then
		for i=1,BGM.len do
			if BGM.list[i]==BGM.nowPlay then
				sceneTemp=i--Music selected
				return
			end
		end
	else
		sceneTemp=1
	end
end
function sceneInit.mode(org)
	BG.set("space")
	BGM.play("blank")
	destroyPlayers()
	local cam=mapCam
	cam.zoomK=org=="main"and 5 or 1
	if cam.sel then
		local M=Modes[cam.sel]
		cam.x,cam.y=M.x*cam.k+180,M.y*cam.k
		cam.x1,cam.y1=cam.x,cam.y
	end
end
function sceneInit.custom()
	sceneTemp=1--Option selected
	destroyPlayers()
	BG.set(customRange.bg[customSel[12]])
	BGM.play(customRange.bgm[customSel[13]])
end
function sceneInit.sequence()
	sceneTemp={cur=#preBag,sure=0}
end
function sceneInit.draw()
	BG.set("space")
	sceneTemp={
		sure=0,
		pen=1,
		x=1,y=1,
		demo=false,
	}
end
function sceneInit.play()
	love.keyboard.setKeyRepeat(false)
	restartCount=0
	if needResetGameData then
		resetGameData()
		needResetGameData=nil
	end
	BG.set(modeEnv.bg)
end
function sceneInit.pause(org)
	if
		org=="setting_game"or
		org=="setting_video"or
		org=="setting_sound"
	then
		TEXT.show(text.needRestart,640,440,50,"fly",.6)
	end
	local S=players[1].stat
	sceneTemp={
		timer=org=="play"and 0 or 50,
		list={
			toTime(S.time),
			format("%d/%d/%d",S.key,S.rotate,S.hold),
			format("%d  %.2fPPS",S.piece,S.piece/S.time),
			format("%d(%d)  %.2fLPM",S.row,S.dig,S.row/S.time*60),
			format("%d(%d)  %.2fAPM",S.atk,S.digatk,S.atk/S.time*60),
			format("%d(%d-%d)",S.pend,S.recv,S.recv-S.pend),
			format("%d/%d/%d/%d",S.clears[1],S.clears[2],S.clears[3],S.clears[4]),
			format("(%d)/%d/%d/%d",S.spins[1],S.spins[2],S.spins[3],S.spins[4]),
			format("%d/%d ; %d/%d",S.b2b,S.b3b,S.pc,S.hpc),
			format("%d [%.2f%%]",S.extraPiece,100*max(1-S.extraRate/S.piece,0)),
		},

		--From right-down, 60 degree each
		radar={
			(S.off+S.dig)/S.time*60,--DefPM
			(S.send+S.dig)/S.time*60,--ADPM
			S.atk/S.time*60,		--AtkPM
			S.send/S.time*60,		--SendPM
			S.piece/S.time*24,		--LinePM
			S.dig/S.time*60,		--DigPM
		},
		val={1/80,1/80,1/80,1/60,1/100,1/40},
		timing=org=="play",
	}
	local _=sceneTemp
	local A,B=_.radar,_.val

	--Normalize Values
	for i=1,6 do
		B[i]=B[i]*A[i]if B[i]>1.26 then B[i]=1.26+log(B[i]-.26,10)end
	end

	for i=1,6 do
		A[i]=format("%.2f",A[i])..text.radarData[i]
	end
	local f=1
	for i=1,6 do
		if B[i]>.5 then f=2 end
		if B[i]>1 then f=3 break end
	end
	if f==1 then	 _.color,f={.4,.9,.5},1.25	--Vegetable
	elseif f==2 then _.color,f={.4,.7,.9},1		--Normal
	elseif f==3 then _.color,f={1,.3,.3},.626	--Diao
	end
	A={
		120*.5*f,	120*3^.5*.5*f,
		120*-.5*f,	120*3^.5*.5*f,
		120*-1*f,	120*0*f,
		120*-.5*f,	120*-3^.5*.5*f,
		120*.5*f,	120*-3^.5*.5*f,
		120*1*f,	120*0*f,
	}
	_.scale=f
	_.standard=A

	for i=6,1,-1 do
		B[2*i-1],B[2*i]=B[i]*A[2*i-1],B[i]*A[2*i]
	end
	_.val=B
end
function sceneInit.setting_game()
	BG.set("space")
end
function sceneInit.setting_video()
	BG.set("space")
end
function sceneInit.setting_sound()
	sceneTemp={
		last=0,--Last sound time
		jump=0,--Animation timer(10 to 0)
	}
	BG.set("space")
end
function sceneInit.setting_control()
	sceneTemp={
		das=setting.das,
		arr=setting.arr,
		pos=0,
		dir=1,
		wait=30,
	}
	BG.set("bg1")
end
function sceneInit.setting_key()
	sceneTemp={
		board=1,
		kb=1,js=1,
		kS=false,jS=false,
	}
end
function sceneInit.setting_touch()
	BG.set("rainbow")
	sceneTemp={
		default=1,
		snap=1,
		sel=nil,
	}
end
function sceneInit.setting_touchSwitch()
	BG.set("matrix")
end
function sceneInit.help()
	BG.set("space")
end
function sceneInit.staff()
	sceneTemp={
		time=0,
		v=1,
	}
	BG.set("space")
end
function sceneInit.stat()
	local S=stat
	local X1,X2,Y1,Y2={0,0,0,0},{0,0,0,0},{},{}
	for i=1,7 do
		local S,C=S.spin[i],S.clear[i]
		Y1[i]=S[1]+S[2]+S[3]+S[4]
		Y2[i]=C[1]+C[2]+C[3]+C[4]
		for j=1,4 do
			X1[j]=X1[j]+S[j]
			X2[j]=X2[j]+C[j]
		end
	end
	sceneTemp={
		chart={
			A1=S.spin,A2=S.clear,
			X1=X1,X2=X2,
			Y1=Y1,Y2=Y2,
		},
		item={
			S.run,
			S.game,
			toTime(S.time),
			S.key.."  "..S.rotate.."  "..S.hold,
			S.piece.."  "..S.row.."  "..int(S.atk),
			S.recv.."  "..S.off.."  "..S.pend,
			S.dig.."  "..int(S.digatk),
			format("%.2f  %.2f",S.atk/S.row,S.digatk/S.dig),
			format("%d/%.3f%%",S.extraPiece,100*max(1-S.extraRate/S.piece,0)),
			S.b2b.."  "..S.b3b,
			S.pc.."  "..S.hpc,
		},
	}
	for i=1,11 do
		sceneTemp.item[i]=text.stat[i].."\t"..sceneTemp.item[i]
	end
end
function sceneInit.history()
	BG.set("rainbow")
	sceneTemp={
		text=require("parts/updateLog"),--Text list
		pos=1,--Scroll pos
	}
	if newVersionLaunch then
		newVersionLaunch=nil
		sceneTemp.pos=4
	end
end
function sceneInit.debug()
	sceneTemp={
		reset=false,
	}
end
function sceneInit.quit()
	if rnd()>.000626 then
		love.timer.sleep(.3)
		love.event.quit()
	else
		error("So lucky! 0.0626 precent to get this!!!   You can quit the game now.")
	end
end

local sceneBack={}
function sceneBack.load()
	love.event.quit()
end
function sceneBack.pause()
	love.keyboard.setKeyRepeat(true)
	if not game.replaying then
		mergeStat(stat,players[1].stat)
	end
	FILE.saveData()
	TASK.clear("play")
end
function sceneBack.setting_game()
	FILE.saveSetting()
end
function sceneBack.setting_video()
	FILE.saveSetting()
end
function sceneBack.setting_sound()
	FILE.saveSetting()
end
function sceneBack.setting_touch()
	FILE.saveVK()
end
function sceneBack.setting_key()
	FILE.saveKeyMap()
end
function sceneBack.setting_lang()
	FILE.saveSetting()
end

local SCN={
	cur="load",--Current scene
	swapping=false,--If Swapping
	stat={
		tar=nil,	--Swapping target
		style=nil,	--Swapping style
		mid=nil,	--Loading point
		time=nil,	--Full swap time
		draw=nil,	--Swap draw  func
	},
	seq={"quit","slowFade"},--Back sequence
}--Scene datas, returned

function SCN.swapUpdate()
	local S=SCN.stat
	S.time=S.time-1
	if S.time==S.mid then
		SCN.init(S.tar,SCN.cur)
		collectgarbage()
		--Scene swapped this moment
	end
	if S.time==0 then
		SCN.swapping=false
	end
end
function SCN.init(s,org)
	if sceneInit[s]then sceneInit[s](org)end
	SCN.cur=s
	WIDGET.set(Widgets[s])
end
function SCN.push(tar,style)
	if not SCN.swapping then
		local m=#SCN.seq
		SCN.seq[m+1]=tar or SCN.cur
		SCN.seq[m+2]=style or"fade"
	end
end
function SCN.pop()
	local _=SCN.seq
	_[#_],_[#_-1]=nil
end

local swap={
	none={1,0,NULL},--swap time, change time, draw function
	flash={8,1,function()gc.clear(1,1,1)end},
	fade={30,15,function(t)
		local t=t>15 and 2-t/15 or t/15
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,scr.W,scr.H)
	end},
	fade_togame={120,20,function(t)
		local t=t>20 and(120-t)/100 or t/20
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,scr.W,scr.H)
	end},
	slowFade={180,90,function(t)
		local t=t>90 and 2-t/90 or t/90
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,scr.W,scr.H)
	end},
	swipe={30,15,function(t)
		t=t/30
		gc.setColor(.1,.1,.1,1-abs(t-.5))
		t=t*t*(3-2*t)*2-1
		local w=scr.W
		gc.rectangle("fill",t*w,0,w,scr.H)
	end},
}--Scene swapping animations
function SCN.swapTo(tar,style)--Parallel scene swapping, cannot back
	local S=SCN.stat
	if not SCN.swapping and tar~=SCN.cur then
		SCN.swapping=true
		if not style then style="fade"end
		S.tar=tar
		S.style=style
		local swap=swap[style]
		S.time=swap[1]
		S.mid=swap[2]
		S.draw=swap[3]
	end
end
function SCN.go(tar,style)--Normal scene swapping, can back
	SCN.push()SCN.swapTo(tar,style)
end
function SCN.back()
	--Leave scene
	if sceneBack[SCN.cur] then sceneBack[SCN.cur]()end

	--Poll&Back to previous Scene
	local m=#SCN.seq
	if m>0 then
		SCN.swapTo(SCN.seq[m-1],SCN.seq[m])
		SCN.seq[m],SCN.seq[m-1]=nil
	end
end
return SCN