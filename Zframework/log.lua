local gc=love.graphics
local int,max,min=math.floor,math.max,math.min
local ins,rem=table.insert,table.remove

local debugMesList={}
local debugMesHistory={
	"Version: "..VERSION.string,
	os.date("Launched at %Y/%m/%d %H:%M"),
}
local LOG={}
function LOG.update()
	if debugMesList[1]then
		for i=#debugMesList,1,-1 do
			local M=debugMesList[i]
			if M.blink>0 then
				M.blink=M.blink-1
			else
				M.time=M.time-1
				if M.time==0 then
					rem(debugMesList,i)
				end
			end
		end
	end
end
function LOG.draw()
	if debugMesList[1]then
		local k=SCR.w/SCR.w0
		setFont(max(int(4*k)*5,5))
		for i=1,#debugMesList do
			local M=debugMesList[i]
			local t=M.time
			gc.setColor(M.r,M.g,M.b,M.blink>0 and int(M.blink/3)%2 or min(t/26,1))
			gc.print(M.text,10+(20-min(t,20))^1.5/4,25*i*k)
		end
	end
end
function LOG.print(text,T)--text,type/time/color,color
	local color=COLOR.Z
	local time,his
	if T=='message'then
		color=COLOR.N
		his,time=true,180
	elseif T=='warn'then
		color=COLOR.Y
		his,time=true,180
	elseif T=='error'then
		color=COLOR.R
		his,time=true,210
	elseif type(T)=='number'then
		time=T
	end
	if his then ins(debugMesHistory,SCN.cur..": "..tostring(text))end
	ins(debugMesList,{text=tostring(text),r=color[1],g=color[2],b=color[3],blink=30,time=time or 120})
end
function LOG.copy()
	love.system.setClipboardText(table.concat(debugMesHistory,"\n"))
	LOG.print("Log copied",'message')
end
return LOG