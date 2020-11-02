local gc=love.graphics
local Timer=love.timer.getTime

local setFont=setFont
local mStr=mStr

local abs,int,sin=math.abs,math.floor,math.sin
local format=string.format

function sceneInit.stat()
	local S=STAT
	local X1,X2,Y1,Y2={0,0,0,0},{0,0,0,0},{},{}
	for i=1,7 do
		local s,c=S.spin[i],S.clear[i]
		Y1[i]=s[1]+s[2]+s[3]+s[4]
		Y2[i]=c[1]+c[2]+c[3]+c[4]
		for j=1,4 do
			X1[j]=X1[j]+s[j]
			X2[j]=X2[j]+c[j]
		end
	end
	sceneTemp={
		chart={
			A1=S.spin,A2=S.clear,
			X1=X1,X2=X2,
			Y1=Y1,Y2=Y2,
		},
		item={
			S.run,
			S.game,
			toTime(S.time),
			S.key.."  "..S.rotate.."  "..S.hold,
			S.piece.."  "..S.row.."  "..int(S.atk),
			S.recv.."  "..S.off.."  "..S.pend,
			S.dig.."  "..int(S.digatk),
			format("%.2f  %.2f",S.atk/S.row,S.digatk/S.dig),
			S.b2b.."  "..S.b3b,
			S.pc.."  "..S.hpc,
			format("%d/%.2f%%",S.extraPiece,S.finesseRate*20/S.piece),
		},
	}
	for i=1,11 do
		sceneTemp.item[i]=text.stat[i].."\t"..sceneTemp.item[i]
	end
end

function Pnt.stat()
	local chart=sceneTemp.chart
	setFont(24)
	local _,__=SKIN.libColor,SETTING.skin
	local A,B=chart.A1,chart.A2
	for x=1,7 do
		gc.setColor(_[__[x]])
		mStr(text.block[x],80*x,40)
		mStr(text.block[x],80*x,280)
		for y=1,4 do
			mStr(A[x][y],80*x,40+40*y)
			mStr(B[x][y],80*x,280+40*y)
		end
		mStr(chart.Y1[x],80*x,240)
		mStr(chart.Y2[x],80*x,480)
	end
	gc.setColor(1,1,1)
	A,B=chart.X1,chart.X2

	for y=1,4 do
		mStr(A[y],650,40+40*y)
		mStr(B[y],650,280+40*y)
	end

	setFont(22)
	for i=1,11 do
		gc.print(sceneTemp.item[i],740,40*i+10)
	end

	gc.setLineWidth(4)
	for x=1,8 do
		x=80*x-40
		gc.line(x,80,x,240)
		gc.line(x,320,x,480)
	end
	for y=2,6 do
		gc.line(40,40*y,600,40*y)
		gc.line(40,240+40*y,600,240+40*y)
	end

	gc.draw(IMG.title,260,615,.2+.04*sin(Timer()*3),nil,nil,206,35)

	local r=Timer()*2
	local R=int(r)%7+1
	gc.setColor(1,1,1,1-abs(r%1*2-1))
	gc.draw(TEXTURE.miniBlock[R],650,50,Timer()*10%6.2832,15,15,spinCenters[R][0][2]+.5,#blocks[R][0]-spinCenters[R][0][1]-.5)
	gc.draw(TEXTURE.miniBlock[R],650,300,0,15,15,spinCenters[R][0][2]+.5,#blocks[R][0]-spinCenters[R][0][1]-.5)
end

WIDGET.init("stat",{
	WIDGET.newButton({name="path",x=980,y=620,w=250,h=80,font=25,code=function()love.system.openURL(love.filesystem.getSaveDirectory())end,hide=MOBILE}),
	WIDGET.newButton({name="back",x=640,y=620,w=200,h=80,font=35,code=WIDGET.lnk.BACK}),
})