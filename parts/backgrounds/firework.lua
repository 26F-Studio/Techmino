--Firework
local gc=love.graphics
local circle,line=gc.circle,gc.line
local rnd=math.random
local ins,rem=table.insert,table.remove
local back={}

local t
local firework,particle
function back.init()
	t=26
	firework,particle={},{}
	BG.resize()
end
function back.update(dt)
	t=t-1
	if t==0 then
		ins(firework,{
			x=nil,y=nil,
			x0=SCR.W*(rnd()*1.2-.1),
			y0=SCR.H*1.5,
			x1=SCR.W*(.15+rnd()*.7),
			y1=SCR.H*(.15+rnd()*.4),
			t=0,
			v=.5+rnd(),
			color=COLOR.random_bright(),
			big=rnd()<.1,
		})
		t=rnd(26,62)
	end
	for i=#firework,1,-1 do
		local F=firework[i]
		local time=F.t^.5
		if time>1 then
			local x,y,color=F.x,F.y,F.color
			if F.big then
				SFX.play("clear_3",.4)
				for _=1,rnd(62,126)do
					ins(particle,{
						x=x,y=y,
						color=color,
						vx=rnd()*16-8,
						vy=rnd()*16-8,
						t=1,
					})
				end
			else
				SFX.play("clear_2",.35)
				for _=1,rnd(16,26)do
					ins(particle,{
						x=x,y=y,
						color=color,
						vx=rnd()*8-4,
						vy=rnd()*8-4,
						t=1,
					})
				end
			end
			rem(firework,i)
		else
			F.t=F.t+dt*F.v
			F.x=F.x0*(1-time)+F.x1*time
			F.y=F.y0*(1-time)+F.y1*time
		end
	end
	for i=#particle,1,-1 do
		local P=particle[i]
		if P.t<0 then
			rem(particle,i)
		else
			P.x=P.x+P.vx
			P.y=P.y+P.vy
			P.vy=P.vy+.04
			P.t=P.t-dt*.6
		end
	end
end
function back.draw()
	gc.clear(.1,.1,.1)
	gc.push("transform")
	gc.origin()
	for i=1,#firework do
		local F=firework[i]
		gc.setColor(F.color)
		circle("fill",F.x,F.y,F.big and 8 or 4)
	end
	gc.setLineWidth(3)
	for i=1,#particle do
		local P=particle[i]
		local c=P.color
		gc.setColor(c[1],c[2],c[3],P.t)
		line(P.x,P.y,P.x-P.vx*4,P.y-P.vy*4)
	end
	gc.pop()
end
function back.discard()
	firework=nil
end
return back