local gc=love.graphics
local rnd=math.random
local mStr=mStr
local textFX={}
function textFX.appear(t)
	mStr(t.text,t.x,t.y-t.font*.7)
end
function textFX.fly(t)
	mStr(t.text,t.x+(t.c-.5)^3*300,t.y-t.font*.7)
end
function textFX.stretch(t)
	gc.push("transform")
		gc.translate(t.x,t.y)
		if t.c<.3 then gc.scale((.3-t.c)*1.6+1,1)end
		mStr(t.text,0,-t.font*.7)
	gc.pop()
end
function textFX.drive(t)
	gc.push("transform")
		gc.translate(t.x,t.y)
		if t.c<.3 then gc.shear((.3-t.c)*2,0)end
		mStr(t.text,0,-t.font*.7)
	gc.pop()
end
function textFX.spin(t)
	gc.push("transform")
		gc.translate(t.x,t.y)
		if t.c<.3 then
			gc.rotate((.3-t.c)^2*4)
		end
		mStr(t.text,0,-t.font*.7)
	gc.pop()
end
function textFX.flicker(t)
	local _,τ,T,Τ=gc.getColor()
	gc.setColor(_,τ,T,Τ*(rnd()+.5))
	mStr(t.text,t.x,t.y-t.font*.7)
end
function textFX.zoomout(t)
	gc.push("transform")
		local k=t.c^.5*.1+1
		gc.translate(t.x,t.y)
		gc.scale(k,k)
		mStr(t.text,0,-t.font*.7)
	gc.pop()
end
function textFX.beat(t)
	gc.push("transform")
		gc.translate(t.x,t.y)
		if t.c<.3 then
			local k=1.3-t.c^2/.3
			gc.scale(k,k)
		end
		mStr(t.text,0,-t.font*.7)
	gc.pop()
end
function getTEXT(text,x,y,font,style,spd,stop)
	return{
		c=0,				--counter

		text=text,			--string
		x=x or 0,			--x
		y=y or 0,			--y
		font=font or 40,	--font
		spd=(spd or 1)/60,	--timing speed
		stop=stop,			--timing stop

		draw=textFX[style]or error("unavailable type:"..style),	--draw method
	}
end
function TEXT(text,x,y,font,style,spd,stop)
	texts[#texts+1]={
		c=0,				--timer
		text=text or"NaN",	--string
		x=x or 0,			--x
		y=y or 0,			--y
		font=font or 40,	--font
		spd=(spd or 1)/60,	--timing speed(1=last 1 sec)
		stop=stop,			--stop time(sustained text)
		draw=textFX[style]or error("unavailable type:"..style),	--draw method
	}
end