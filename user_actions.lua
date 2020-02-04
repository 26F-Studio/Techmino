act={
	moveLeft=function(auto)
		if not auto then P.moving=-1 end
		if not ifoverlap(cb,cx-1,cy)then
			P.cx=cx-1
			freshgho()
			freshLockDelay()
			if cy==y_img then SFX("move")end
			P.spinLast=false
		end
	end,
	moveRight=function(auto)
		if not auto then P.moving=1 end
		if not ifoverlap(cb,cx+1,cy)then
			P.cx=cx+1
			freshgho()
			freshLockDelay()
			if cy==y_img then SFX("move")end
			P.spinLast=false
		end
	end,
	hardDrop=function()
		if P.waiting<=0 then
			if cy~=y_img then
				P.cy=y_img
				P.spinLast=false
				SFX("drop")
			end
			drop()
			P.keyPressing[6]=false
		end
	end,
	softDrop=function()
		if cy~=y_img then P.cy=cy-1 end
		P.downing=1
	end,
	rotRight=function()spin(1)end,
	rotLeft=function()spin(-1)end,
	rotFlip=function()spin(2)end,
	hold=hold,
	--Player movements
	restart=function()
		resetGameData()
		count=60+26--Althour'z neim
	end,
	down1=function()if cy~=y_img then P.cy=cy-1 end end,
	down4=function()for i=1,4 do if cy~=y_img then P.cy=cy-1 else break end end end,
	toDown=function()if cy~= y_img then P.cy,P.lockDelay,P.spinLast=y_img,gameEnv.lock,false end end,
	toLeft=function()while not ifoverlap(cb,cx-1,cy)do P.cx,P.lockDelay=cx-1,gameEnv.lock;freshgho()end end,
	toRight=function()while not ifoverlap(cb,cx+1,cy)do P.cx,P.lockDelay=cx+1,gameEnv.lock;freshgho()end end,
	quit=function()Event.gameover.lose()end,
	--System movements
}