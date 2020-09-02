local gc=love.graphics
local int,min=math.floor,math.min
local ins,rem=table.insert,table.remove

local debugMesList={}
local debugMesFloat=0
local LOG={}
function LOG.print(text,clr)--use this for print for debug in-game
	if not clr then clr=color.white end
	ins(debugMesList,{text=text,r=clr[1],g=clr[2],b=clr[3],time=240})
	ins(debugMesHistory,SCN.cur..": "..tostring(text))
end
function LOG.update()
	if debugMesList[1]then
		for i=#debugMesList,1,-1 do
			local M=debugMesList[i]
			M.time=M.time-1
			if i==1 and M.time==0 then
				rem(debugMesList,i)
				if not debugMesList[1]then
					debugMesFloat=0
				else
					debugMesFloat=debugMesFloat+25
				end
			end
			if debugMesFloat>0 then
				debugMesFloat=int(debugMesFloat*.9)
			end
		end
	end
end
function LOG.draw()
	if debugMesList[1]then
		setFont(20)
		for i=1,#debugMesList do
			local M=debugMesList[i]
			local t=M.time
			gc.setColor(M.r,M.g,M.b,t>200 and int(t/3)%2 or min(t/26,1))
			gc.print(M.text,10+(20-min(t,20))^1.5/4,25*i+debugMesFloat)
		end
	end
end
return LOG