local gc=love.graphics
local int,min=math.floor,math.min
local ins,rem=table.insert,table.remove

local debugMesList={}
local debugMesHistory={
	"Version: "..gameVersion,
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
		gc.push("transform")
		local k=SCR.w/1280
		setFont(int(20*k))
		for i=1,#debugMesList do
			local M=debugMesList[i]
			local t=M.time
			gc.setColor(M.r,M.g,M.b,M.blink>0 and int(M.blink/3)%2 or min(t/26,1))
			gc.print(M.text,10+(20-min(t,20))^1.5/4,25*i*k)
		end
		gc.pop()
	end
end
function LOG.print(text,T,C)--text,type/time,color
	local time
	local his
	if T=="warn"then
		C=C or COLOR.yellow
		his=true
		time=180
	elseif T=="error"then
		C=C or COLOR.red
		his=true
		time=210
	elseif T=="message"then
		C=C or COLOR.sky
		his=true
	elseif type(T)=="number"then
		C=C or COLOR.white
		time=T
	elseif type(T)=="table"then
		C,T=T
	elseif not C then
		C=COLOR.white
	end
	if his then
		ins(debugMesHistory,SCN.cur..": "..tostring(text))
	end
	ins(debugMesList,{text=text,r=C[1],g=C[2],b=C[3],blink=30,time=time or 120})
end
function LOG.copy()
	local str=table.concat(debugMesHistory,"\n")
	love.system.setClipboardText(str)
	LOG.print("Log copied",COLOR.blue)
end
return LOG