act={
	moveLeft=function(auto)
		if not auto then P.moving=-1 end
		if not ifoverlap(cb,cx-1,cy)then
			P.cx=cx-1
			freshgho()
			P.freshTime=P.freshTime+1
			if P.freshTime<=gameEnv.freshLimit then
				P.lockDelay=gameEnv.lock
			end
			if cy==y_img then SFX("move")end
		end
	end,
	moveRight=function(auto)
		if not auto then P.moving=1 end
		if not ifoverlap(cb,cx+1,cy)then
			P.cx=cx+1
			freshgho()
			P.freshTime=P.freshTime+1
			if P.freshTime<=gameEnv.freshLimit then
				P.lockDelay=gameEnv.lock
			end
			if cy==y_img then SFX("move")end
		end
	end,
	hardDrop=function()
		if P.waiting<=0 then
			if cy~=y_img then
				P.cy=y_img
				SFX("drop")
			end
			drop()
			P.keyPressing[6]=false
		end
	end,
	softDrop=function()
		act.toDown()
		P.downing=1
	end,
	rotRight=function()spin(1)end,
	rotLeft=function()spin(-1)end,
	rotFlip=function()spin(2)end,
	hold=hold,
	--Player movements
	restart=function()
		startGame(gamemode)
	end,
	down1=function()drop()end,
	down4=function()for i=1,4 do if cy~=y_img then drop()else break end end end,
	toDown=function()P.cy,P.lockDelay=y_img,gameEnv.lock end,
	toLeft=function()while not ifoverlap(cb,cx-1,cy)do P.cx,P.lockDelay=cx-1,gameEnv.lock;freshgho()end end,
	toRight=function()while not ifoverlap(cb,cx+1,cy)do P.cx,P.lockDelay=cx+1,gameEnv.lock;freshgho()end end,
	quit=function()Event.gameover.lose()end,
	--System movements
}