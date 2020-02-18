local int,max,format=math.floor,math.max,string.format
local scene={
	cur="load",--Current scene
	swapping=false,--ifSwapping
	swap={
		tar=nil,	--Swapping target
		style=nil,	--Swapping target
		mid=nil,	--Loading point
		time=nil,	--Full swap time
		draw=nil,	--Swap draw
	},
	seq={"quit","slowFade"},--Back sequence
}--scene datas,returned
local sceneInit={
	quit=love.event.quit,
	load=function()
		loading={
			1,--Loading mode
			1,--Loading counter
			#voiceName,--Loading bar lenth(current)
			text.tips[math.random(#text.tips)],--tip
		}
	end,
	intro=function()
		sceneTemp=0--animation timer
		BGM("blank")
	end,
	main=function()
		curBG="none"
		BGM("blank")
		destroyPlayers()
		modeEnv={}
		if not players[1]then
			newDemoPlayer(1,900,35,1.1)
		end--create demo player
	end,
	music=function()
		if bgmPlaying then
			for i=1,#musicID do
				if musicID[i]==bgmPlaying then
					sceneTemp=i--music select
					return
				end
			end
		else
			sceneTemp=1
		end
	end,
	mode=function()
		curBG="black"
		BGM("blank")
		destroyPlayers()
		local cam=mapCam
		cam.zoomK=scene.swap.tar=="mode"and 5 or 1
		if cam.sel then
			local M=modes[cam.sel]
			cam.x,cam.y=M.x*cam.k+180,M.y*cam.k
			cam.x1,cam.y1=cam.x,cam.y
		end
	end,
	custom=function()
		sceneTemp=1--option select
		destroyPlayers()
		curBG=customRange.bg[customSel[12]]
		BGM(customRange.bgm[customSel[13]])
	end,
	draw=function()
		curBG="none"
		sceneTemp={
			sure=0,
			pen=1,
			x=1,y=1,
			demo=false,
		}
	end,
	play=function()
		love.keyboard.setKeyRepeat(false)
		restartCount=0
		if needResetGameData then
			resetGameData()
			needResetGameData=nil
		else
			BGM(modeEnv.bgm)
		end
		curBG=modeEnv.bg
	end,
	pause=function()
		local S=players[1].stat
		sceneTemp={
			S.key,
			S.rotate,
			S.hold,
			S.piece.."  "..(int(S.piece/S.time*100)*.01).."PPS",
			S.row.."  "..(int(S.row/S.time*600)*.1).."LPM",
			S.atk.."  "..(int(S.atk/S.time*600)*.1).."APM",
			S.send,
			S.recv,
			S.pend,
			S.clear_1.."/"..S.clear_2.."/"..S.clear_3.."/"..S.clear_4,
			"["..S.spin_0.."]/"..S.spin_1.."/"..S.spin_2.."/"..S.spin_3,
			S.b2b.."[+"..S.b3b.."]",
			S.pc,
			format("%0.2f",S.atk/S.row),
			S.extraPiece,
			max(100-int(S.extraRate/S.piece*10000)*.01,0).."%",
		}
	end,
	setting_game=function()
		curBG="none"
	end,
	setting_graphic=function()
		curBG="none"
	end,
	setting_sound=function()
		sceneTemp={last=0,jump=0}--last sound time,animation count(10→0)
		curBG="none"
	end,
	setting_key=function()
		sceneTemp={
			board=1,
			kb=1,js=1,
			kS=false,jS=false,
		}
	end,
	setting_touch=function()
		curBG="game2"
		sceneTemp={
			default=1,
			snap=1,
			sel=nil,
		}
	end,
	setting_touchSwitch=function()
		curBG="matrix"
	end,
	help=function()
		curBG="none"
	end,
	stat=function()
		local S=stat
		sceneTemp={
			S.run,
			S.game,
			format("%.1fHr",S.time*2.78e-4),
			S.key,
			S.rotate,
			S.hold,
			S.piece,
			S.row,
			S.atk,
			S.send,
			S.recv,
			S.pend,
			S.clear_1.."/"..S.clear_2.."/"..S.clear_3.."/"..S.clear_4,
			"["..S.spin_0.."]/"..S.spin_1.."/"..S.spin_2.."/"..S.spin_3,
			S.b2b.."[+"..S.b3b.."]",
			S.pc,
			format("%.2f",S.atk/S.row),
			format("%d[%.2f%%]",S.extraPiece,max(100-S.extraRate/S.piece*100,0)),
		}
	end,
	history=function()
		curBG="lightGrey"
		sceneTemp={require("updateLog"),1}--scroll pos
	end,
	quit=function()
		love.timer.sleep(.3)
		love.event.quit()
	end,
}
local gc=love.graphics
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
		updateStat()
		saveStat()
		clearTask("play")
	end,
	setting_game=	function()saveSetting()end,
	setting_graphic=function()saveSetting()end,
	setting_sound=	function()saveSetting()end,
}
function scene.init(s)
	if sceneInit[s]then sceneInit[s]()end
end
function scene.push(tar,style)
	if not scene.swapping then
		local m=#scene.seq
		scene.seq[m+1]=tar or scene.cur
		scene.seq[m+2]=style or"fade"
	end
end
function scene.pop()
	local _=scene.seq
	_[#_-1]=nil
end
function scene.swapTo(tar,style)
	local S=scene.swap
	if not scene.swapping and tar~=scene.cur then
		scene.swapping=true
		if not style then style="fade"end
		S.tar=tar
		S.style=style
		local swap=swap[style]
		S.time=swap[1]
		S.mid=swap[2]
		S.draw=swap[3]
		widget_sel=nil
	end
end
function scene.back()
	if backFunc[scene.cur] then backFunc[scene.cur]()end
	--func when scene end
	local m=#scene.seq
	if m>0 then
		scene.swapTo(scene.seq[m-1],scene.seq[m])
		scene.seq[m],scene.seq[m-1]=nil
		--Poll&Back to preScene
	end
end
return scene