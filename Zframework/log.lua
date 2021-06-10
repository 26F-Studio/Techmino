local utf8=require"utf8"
local gc=love.graphics
local gc_setColor,gc_print=gc.setColor,gc.print
local int,min=math.floor,math.min
local ins,rem=table.insert,table.remove
local setFont=setFont

local mesList={}
local mesHistory={
	"Version: "..VERSION.string,
	os.date("Launched at %Y/%m/%d %H:%M"),
}
local LOG={}
function LOG.update(dt)
	if mesList[1]then
		for i=#mesList,1,-1 do
			local M=mesList[i]
			if M.blink>0 then
				M.blink=M.blink-1
			else
				M.time=M.time-dt
				if M.time<=0 then
					rem(mesList,i)
				end
			end
		end
	end
end
function LOG.draw()
	if mesList[1]then
		setFont(20)
		for i=1,#mesList do
			local M=mesList[i]
			M.rgba[4]=M.blink>0 and int(M.blink/3)%2 or min(M.time*60/26,1)
			gc_setColor(M.rgba)
			gc_print(M.text,10+(20-min(M.time*60,20))^1.5/4,25*i)
		end
	end
end
function LOG.print(text,T)--text,type/time
	local color=COLOR.Z
	local his,time
	if T=='message'then
		color=COLOR.N
		his,time=true,4
	elseif T=='warn'then
		color=COLOR.Y
		his,time=true,4
	elseif T=='error'then
		color=COLOR.R
		his,time=true,5
	elseif type(T)=='number'then
		time=T
	end
	text=tostring(text)
	assert(utf8.len(text),"Error UTF-8 coding")
	if his then ins(mesHistory,SCN.cur..": "..text)end
	ins(mesList,{text=text,rgba={color[1],color[2],color[3],nil},blink=30,time=time or 3})
end
function LOG.copy()
	love.system.setClipboardText(table.concat(mesHistory,"\n"))
	LOG.print("Log copied",'message')
end
return LOG