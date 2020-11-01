local gc=love.graphics
local Timer=love.timer.getTime
local sin=math.sin

function Pnt.setting_skin()
	gc.setColor(1,1,1)
	for N=1,7 do
		local face=SETTING.face[N]
		local B=blocks[N][face]
		local x,y=-55+140*N-spinCenters[N][face][2]*30,355+spinCenters[N][face][1]*30
		local col=#B[1]
		for i=1,#B do for j=1,col do
			if B[i][j]then
				gc.draw(blockSkin[SETTING.skin[N]],x+30*j,y-30*i)
			end
		end end
		gc.circle("fill",-10+140*N,340,sin(Timer()*10)+5)
	end
	gc.draw(blockSkin[17],930,610,nil,2)
	for i=1,5 do
		gc.draw(blockSkin[19+i],570+60*i,610,nil,2)
	end
end