local gc=love.graphics
local int,min=math.floor,math.min
local ins,rem=table.insert,table.remove

local debugMesList={}
local debugMesHistory={
	"Version: "..gameVersion,
	os.date("Launched at %Y/%m/%d %H:%M"),
}
local debugMesFloat=0
local LOG={}
function LOG.update()
	if debugMesList[1]then
		for i=#debugMesList,1,-1 do
			local M=debugMesList[i]
			if M.blink>0 then
				M.blink=M.blink-1
			else
				M.time=M.time-1
				if i==1 and M.time==0 then
					rem(debugMesList,i)
					if not debugMesList[1]then
						debugMesFloat=0
					else
						debugMesFloat=debugMesFloat+25
					end
				end
			end
		end
		if debugMesFloat>0 then
			debugMesFloat=int(debugMesFloat*.9)
		end
	end
end
function LOG.draw()
	if debugMesList[1]then
		setFont(20)
		for i=1,#debugMesList do
			local M=debugMesList[i]
			local t=M.time
			gc.setColor(M.r,M.g,M.b,M.blink>0 and int(M.blink/3)%2 or min(t/26,1))
			gc.print(M.text,10+(20-min(t,20))^1.5/4,25*i+debugMesFloat)
		end
	end
end
function LOG.print(text,T,C)--type/time,color
	local time
	local his
	if type(T)=="table"then
		C,T=T or color.white
	elseif T=="warn"then
		C=C or color.yellow
		his=true
		time=180
	elseif T=="error"then
		C=C or color.red
		his=true
		time=210
	elseif T=="message"then
		C=C or color.green
		his=true
	elseif T=="short"then
		C=C or color.orange
		time=20
	elseif not C then
		C=color.white
	end
	if his then
		ins(debugMesHistory,SCN.cur..": "..tostring(text))
	end
	ins(debugMesList,{text=text,r=C[1],g=C[2],b=C[3],blink=30,time=time or 150})
end
function LOG.copy()
	local str=table.concat(debugMesHistory,"\n")
	love.system.setClipboardText(str)
	LOG.print("Log copied",color.blue)
end
return LOG