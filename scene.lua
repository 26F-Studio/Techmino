local gc=love.graphics
local int,log=math.floor,math.log
local sin,cos=math.sin,math.cos
local max,format=math.max,string.format
local scr=scr
local SCN={
	cur="load",--Current scene
	swapping=false,--ifSwapping
	swap={
		tar=nil,	--Swapping target
		style=nil,	--Swapping style
		mid=nil,	--Loading point
		time=nil,	--Full swap time
		draw=nil,	--Swap draw  func
	},
	seq={"quit","slowFade"},--Back sequence
}--scene datas,returned

local sceneInit={}
sceneInit.quit=love.event.quit
function sceneInit.load()
	sceneTemp={
		phase=1,--Loading stage
		cur=1,--Counter
		tar=#VOC.name,--Loading bar lenth(current)
		tip=require("parts/getTip"),
		list={
			#VOC.name,
			#BGM.list,
			#SFX.list,
			IMG.getCount(),
			#modes,
			1,
		},
		skip=false,--if skipping
	}
end
function sceneInit.intro()
	BG.set("space")
	sceneTemp=0--animation timer
	BGM.play("blank")
end
function sceneInit.main()
	BG.set("space")
	BGM.play("blank")
	destroyPlayers()
	modeEnv={}
	if not players[1]then
		PLY.newDemoPlayer(1,900,35,1.1)
	end--create demo player
end
function sceneInit.music()
	if BGM.nowPlay then
		for i=1,BGM.len do
			if BGM.list[i]==BGM.nowPlay then
				sceneTemp=i--music select
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
		local M=modes[cam.sel]
		cam.x,cam.y=M.x*cam.k+180,M.y*cam.k
		cam.x1,cam.y1=cam.x,cam.y
	end
end
function sceneInit.custom()
	sceneTemp=1--option select
	destroyPlayers()
	BG.set(customRange.bg[customSel[12]])
	BGM.play(customRange.bgm[customSel[13]])
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
			S.key.."/"..S.rotate.."/"..S.hold,
			format("%d  %.2fPPS",S.piece,S.piece/S.time),
			format("%d(%d)  %.2fLPM",S.row,S.dig,S.row/S.time*60),
			format("%d(%d)",S.atk,S.digatk),
			format("%d(%d-%d)",S.pend,S.recv,S.recv-S.pend),
			format("%d/%d/%d/%d",S.clear_S[1],S.clear_S[2],S.clear_S[3],S.clear_S[4]),
			format("(%d)/%d/%d/%d",S.spin_S[1],S.spin_S[2],S.spin_S[3],S.spin_S[4]),
			format("%d(+%d)/%d(%d)",S.b2b,S.b3b,S.pc,S.hpc),
			format("%d[%.2f%%]",S.extraPiece,100*max(1-S.extraRate/S.piece,0)),
		},

		--from right-down, 60 degree each
		radar={
			(S.recv-S.pend+S.dig)/S.time*60,--DefPM
			(S.recv-S.pend)/S.time*60,		--OffPM
			S.atk/S.time*60,				--AtkPM
			S.send/S.time*60,				--SendPM
			S.piece/S.time*24,				--LinePM
			S.dig/S.time*60,				--DigPM
		},
		val={1/80,1/40,1/60,1/60,1/100,1/40},
		timing=org=="play",
	}
	local _=sceneTemp
	local A,B=_.radar,_.val
	for i=1,6 do
		B[i]=B[i]*A[i]if B[i]>1.26 then B[i]=1.26+(B[i]-1.26)*.26 end
	end--normalize vals
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
	sceneTemp={last=0,jump=0}--last sound time,animation count(10 to 0)
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
	BG.set("strap")
end
function sceneInit.setting_key()
	sceneTemp={
		board=1,
		kb=1,js=1,
		kS=false,jS=false,
	}
end
function sceneInit.setting_touch()
	BG.set("game2")
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
	sceneTemp={
		pw=0,
	}
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
	sceneTemp={
		chart={
			A1=S.spin,A2=S.clear,
			X1=S.spin_S,X2=S.clear_S,
			Y1=S.spin_B,Y2=S.clear_B,
		},
		item={
			S.run,
			S.game,
			toTime(S.time),
			S.key.."  "..S.rotate.."  "..S.hold,
			S.piece.."  "..S.row.."  "..int(S.atk),
			S.recv.."  "..(S.recv-S.pend).."  "..S.pend,
			S.dig.."  "..int(S.digatk),
			format("%.2f  %.2f",S.atk/S.row,S.digatk/S.dig),
			format("%d/%.3f%%",S.extraPiece,100*max(1-S.extraRate/S.piece,0)),
			S.b2b.."  "..S.b3b,
			S.pc.."  "..S.hpc,
		}
	}
	for i=1,11 do
		sceneTemp.item[i]=text.stat[i].."\t"..sceneTemp.item[i]
	end
end
function sceneInit.history()
	BG.set("strap")
	sceneTemp={require("updateLog"),1}--scroll pos
end
function sceneInit.quit()
	love.timer.sleep(.3)
	love.event.quit()
end


local swap={
	none={1,0,NULL},
	flash={8,1,function()gc.clear(1,1,1)end},
	fade={30,15,function(t)
		local t=t>15 and 2-t/15 or t/15
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,scr.w,scr.h)
	end},
	fade_togame={120,20,function(t)
		local t=t>20 and (120-t)/100 or t/20
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,scr.w,scr.h)
	end},
	slowFade={180,90,function(t)
		local t=t>90 and 2-t/90 or t/90
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,scr.w,scr.h)
	end},
}--Scene swapping animations
local backFunc={
	load=love.event.quit,
	pause=function()
		love.keyboard.setKeyRepeat(true)
		mergeStat(stat,players[1].stat)
		TASK.clear("play")
	end,
	setting_game=	function()FILE.saveSetting()end,
	setting_video=	function()FILE.saveSetting()end,
	setting_sound=	function()FILE.saveSetting()end,
	setting_touch=	function()FILE.saveVK()end,
	setting_key=	function()FILE.saveKeyMap()end,
	setting_lang=	function()FILE.saveSetting()end,
}
function SCN.swapUpdate()
	local S=SCN.swap
	S.time=S.time-1
	if S.time==S.mid then
		SCN.init(S.tar,SCN.cur)
		SCN.cur=S.tar
		WIDGET.set(widgetList[S.tar])
		collectgarbage()
		--Scene swapped this moment
	end
	if S.time==0 then
		SCN.swapping=false
	end
end
function SCN.init(s,org)
	if sceneInit[s]then sceneInit[s](org)end
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
	_[#_-1]=nil
end
function SCN.swapTo(tar,style)
	local S=SCN.swap
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
function SCN.back()
	if backFunc[SCN.cur] then backFunc[SCN.cur]()end
	--func when scene end
	local m=#SCN.seq
	if m>0 then
		SCN.swapTo(SCN.seq[m-1],SCN.seq[m])
		SCN.seq[m],SCN.seq[m-1]=nil
		--Poll&Back to preScene
	end
end
return SCN