local gc=love.graphics
local gc_getColor,gc_setColor,gc_push,gc_pop,gc_translate,gc_scale,gc_rotate,gc_shear
=gc.getColor,gc.setColor,gc.push,gc.pop,gc.translate,gc.scale,gc.rotate,gc.shear

local int,rnd,rem=math.floor,math.random,table.remove
local setFont,mStr=setFont,mStr

local texts={}

local textFX={}
function textFX.appear(t)
	mStr(t.text,t.x,t.y-t.font*.7)
end
function textFX.sudden(t)
	gc_setColor(1,1,1,1-t.c)
	mStr(t.text,t.x,t.y-t.font*.7)
end
function textFX.fly(t)
	mStr(t.text,t.x+(t.c-.5)^3*300,t.y-t.font*.7)
end
function textFX.stretch(t)
	gc_push("transform")
		gc_translate(t.x,t.y)
		if t.c<.3 then gc_scale((.3-t.c)*1.6+1,1)end
		mStr(t.text,0,-t.font*.7)
	gc_pop()
end
function textFX.drive(t)
	gc_push("transform")
		gc_translate(t.x,t.y)
		if t.c<.3 then gc_shear((.3-t.c)*2,0)end
		mStr(t.text,0,-t.font*.7)
	gc_pop()
end
function textFX.spin(t)
	gc_push("transform")
		gc_translate(t.x,t.y)
		if t.c<.3 then
			gc_rotate((.3-t.c)^2*4)
		elseif t.c>.8 then
			gc_rotate((t.c-.8)^2*-4)
		end
		mStr(t.text,0,-t.font*.7)
	gc_pop()
end
function textFX.flicker(t)
	local _,_,_,T=gc_getColor()
	gc_setColor(1,1,1,T*(rnd()+.5))
	mStr(t.text,t.x,t.y-t.font*.7)
end
function textFX.zoomout(t)
	gc_push("transform")
		local k=t.c^.5*.1+1
		gc_translate(t.x,t.y)
		gc_scale(k,k)
		mStr(t.text,0,-t.font*.7)
	gc_pop()
end
function textFX.beat(t)
	gc_push("transform")
		gc_translate(t.x,t.y)
		if t.c<.3 then
			local k=1.3-t.c^2/.3
			gc_scale(k,k)
		end
		mStr(t.text,0,-t.font*.7)
	gc_pop()
end
function textFX.score(t)
	local _,_,_,T=gc_getColor()
	gc_setColor(1,1,1,T*.5)
	mStr(t.text,t.x,t.y-t.font*.7-t.c^.2*50)
end

local TEXT={}
function TEXT.clear()
	texts={}
end
function TEXT.show(text,x,y,font,style,spd,stop)
	texts[#texts+1]={
		c=0,				--Timer
		text=text,			--String
		x=x or 0,			--X
		y=y or 0,			--Y
		font=int(font/5)*5 or 40,	--Font
		spd=(spd or 1)/60,	--Timing speed(1=last 1 sec)
		stop=stop,			--Stop time(sustained text)
		draw=textFX[style]or error("unavailable type:"..style),	--Draw method
	}
end
function TEXT.getText(text,x,y,font,style,spd,stop)--Another version of TEXT.show(), but only return text object, need manual management
	return{
		c=0,
		text=text,
		x=x or 0,
		y=y or 0,
		font=int(font/5)*5 or 40,
		spd=(spd or 1)/60,
		stop=stop,
		draw=textFX[style]or error("unavailable type:"..style),
	}
end
function TEXT.update(list)
	if not list then list=texts end
	for i=#list,1,-1 do
		local t=list[i]
		t.c=t.c+t.spd
		if t.stop then
			if t.c>t.stop then
				t.c=t.stop
			end
		end
		if t.c>1 then
			rem(list,i)
		end
	end
end
function TEXT.draw(list)
	if not list then list=texts end
	for i=1,#list do
		local t=list[i]
		local p=t.c
		gc_setColor(1,1,1,p<.2 and p*5 or p<.8 and 1 or 5-p*5)
		setFont(t.font)
		t:draw()
	end
end
return TEXT