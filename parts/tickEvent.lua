local min=math.min
local mini=love.window.isMinimized
local tickEvent={}
function tickEvent.finish(P)
	if SCN.cur~="play"then return true end
	P.endCounter=P.endCounter+1
	if P.endCounter>120 then pauseGame()end
end
function tickEvent.lose(P)
	P.endCounter=P.endCounter+1
	if P.endCounter>80 then
		for i=1,#P.field do
			for j=1,10 do
				if P.visTime[i][j]>0 then
					P.visTime[i][j]=P.visTime[i][j]-1
				end
			end
		end
		if P.endCounter==120 then
			for _=#P.field,1,-1 do
				freeRow.discard(P.field[_])
				freeRow.discard(P.visTime[_])
				P.field[_],P.visTime[_]=nil
			end
			if #players==1 and SCN.cur=="play"then
				pauseGame()
			end
			return true
		end
	end
end
function tickEvent.throwBadge(A,data)
	data[2]=data[2]-1
	if data[2]%4==0 then
		local S,R=data[1],data[1].lastRecv
		local x1,y1,x2,y2
		if S.small then
			x1,y1=S.centerX,S.centerY
		else
			x1,y1=S.x+308*S.size,S.y+450*S.size
		end
		if R.small then
			x2,y2=R.centerX,R.centerY
		else
			x2,y2=R.x+66*R.size,R.y+344*R.size
		end
		FX_badge[#FX_badge+1]={x1,y1,x2,y2,t=0}
		--generate badge object

		if not A.ai and data[2]%8==0 then
			SFX.play("collect")
		end
	end
	if data[2]<=0 then return true end
end
function tickEvent.bgmFadeOut(_,id)
	local src=BGM.list[id]
	local v=src:getVolume()-.025*setting.bgm*.1
	src:setVolume(v>0 and v or 0)
	if v<=0 then
		src:stop()
		return true
	end
end
function tickEvent.bgmFadeIn(_,id)
	local src=BGM.list[id]
	local v=min(src:getVolume()+.025*setting.bgm*.1,setting.bgm*.1)
	src:setVolume(v)
	if v>=setting.bgm*.1 then return true end
end
return tickEvent