-------------------------------------------------
--Var P in other files represent Player object!--
-------------------------------------------------
local Player={}--Player class

local int,ceil,rnd=math.floor,math.ceil,math.random
local max,min,modf=math.max,math.min,math.modf
local ins,rem=table.insert,table.remove
local resume,yield,status=coroutine.resume,coroutine.yield,coroutine.status

local kickList=require"parts.kickList"

--------------------------<FX>--------------------------
function Player:showText(text,dx,dy,font,style,spd,stop)
	if self.gameEnv.text then
		ins(self.bonus,TEXT.getText(text,150+dx,300+dy,font*self.size,style,spd,stop))
	end
end
function Player:showTextF(text,dx,dy,font,style,spd,stop)
	ins(self.bonus,TEXT.getText(text,150+dx,300+dy,font*self.size,style,spd,stop))
end
function Player:createLockFX()
	local CB=self.cur.bk
	local t=12-self.gameEnv.lockFX*2

	for i=1,#CB do
		local y=self.curY+i-1
		local L=self.clearedRow
		for j=1,#L do
			if L[j]==y then goto CONTINUE_skip end
		end
		y=-30*y
		for j=1,#CB[1]do
			if CB[i][j]then
				ins(self.lockFX,{30*(self.curX+j-2),y,0,t})
			end
		end
		::CONTINUE_skip::
	end
end
function Player:createDropFX(x,y,w,h)
	ins(self.dropFX,{x,y,w,h,0,13-2*self.gameEnv.dropFX})
end
function Player:createMoveFX(dir)
	local T=10-1.5*self.gameEnv.moveFX
	local C=self.cur.color
	local CB=self.cur.bk
	local x=self.curX-1
	local y=self.gameEnv.smooth and self.curY+self.dropDelay/self.gameEnv.drop-2 or self.curY-1
	if dir=="left"then
		for i=1,#CB do for j=#CB[1],1,-1 do
			if self.cur.bk[i][j]then
				ins(self.moveFX,{C,x+j,y+i,0,T})
				break
			end
		end end
	elseif dir=="right"then
		for i=1,#CB do for j=1,#CB[1]do
			if self.cur.bk[i][j]then
				ins(self.moveFX,{C,x+j,y+i,0,T})
				break
			end
		end end
	elseif dir=="down"then
		for j=1,#CB[1]do for i=#CB,1,-1 do
			if self.cur.bk[i][j]then
				ins(self.moveFX,{C,x+j,y+i,0,T})
				break
			end
		end end
	else
		for i=1,#CB do for j=1,#CB[1]do
			if self.cur.bk[i][j]then
				ins(self.moveFX,{C,x+j,y+i,0,T})
			end
		end end
	end
end
function Player:createSplashFX(h)
	local L=self.field[h]
	local size=self.size
	local y=self.fieldY+size*(self.fieldOff.y+self.fieldBeneath+self.fieldUp+615)
	for x=1,10 do
		local c=L[x]
		if c>0 then
			SYSFX.newCell(
				2.5-self.gameEnv.splashFX*.4,
				SKIN.curText[c],
				size,
				self.fieldX+(30*x-15)*size,y-30*h*size,
				rnd()*5-2.5,rnd()*-1,
				0,.6
			)
		end
	end
end
function Player:createClearingFX(y,spd)
	ins(self.clearFX,{y,0,spd})
end
function Player:createBeam(R,send,color)
	local x1,y1,x2,y2
	if self.mini then x1,y1=self.centerX,self.centerY
	else x1,y1=self.x+(30*(self.curX+self.cur.sc[2])-30+15+150)*self.size,self.y+(600-30*(self.curY+self.cur.sc[1])+15)*self.size
	end
	if R.small then x2,y2=R.centerX,R.centerY
	else x2,y2=R.x+308*R.size,R.y+450*R.size
	end

	local c=minoColor[color]
	local r,g,b=c[1]*2,c[2]*2,c[3]*2

	local a=GAME.modeEnv.royaleMode and not(self.type=="human"or R.type=="human")and .2 or 1
	SYSFX.newAttack(1-SETTING.atkFX*.1,x1,y1,x2,y2,int(send^.7*(4+SETTING.atkFX)),r,g,b,a*(SETTING.atkFX+2)*.0626)
end
--------------------------</FX>--------------------------

--------------------------<Method>--------------------------
function Player:RND(a,b)
	local R=self.randGen
	return R:random(a,b)
end
function Player:newTask(code,...)
	local thread=coroutine.create(code)
	resume(thread,self,...)
	if status(thread)~="dead"then
		self.tasks[#self.tasks+1]={
			thread=thread,
			code=code,
			args={...},
		}
	end
end

function Player:setPosition(x,y,size)
	size=size or 1
	self.x,self.y,self.size=x,y,size
	if self.mini or self.demo then
		self.fieldX,self.fieldY=x,y
		self.centerX,self.centerY=x+300*size,y+600*size
	else
		self.fieldX,self.fieldY=x+150*size,y
		self.centerX,self.centerY=x+300*size,y+370*size
		self.absFieldX,self.absFieldY=x+150*size,y-10*size
	end
end
local function task_movePosition(self,x,y,size)
	local x1,y1,size1=self.x,self.y,self.size
	while true do
		yield()
		if (x1-x)^2+(y1-y)^2<1 then
			self:setPosition(x,y,size)
			return true
		else
			x1=x1+(x-x1)*.126
			y1=y1+(y-y1)*.126
			size1=size1+(size-size1)*.126
			self:setPosition(x1,y1,size1)
		end
	end
end
local function checkPlayer(obj,Ptar)
	return obj.args[1]==Ptar
end
function Player:movePosition(x,y,size)
	TASK.removeTask_iterate(checkPlayer,self)
	TASK.new(task_movePosition,self,x,y,size or self.size)
end

function Player:switchKey(id,on)
	self.keyAvailable[id]=on
	if not on then
		self:releaseKey(id)
	end
	if self.type=="human"then
		virtualkey[id].ava=on
	end
end
function Player:set20G(if20g)
	self._20G=if20g
	self:switchKey(7,not if20g)
	if if20g and self.AI_mode=="CC"then CC.switch20G(self)end
end
function Player:setHold(count)--Set hold count (false/true as 0/1)
	if not count then
		count=0
	elseif count==true then
		count=1
	end
	self.gameEnv.holdCount=count
	self.holdTime=count
	while self.holdQueue[count+1]do rem(self.holdQueue)end
end
function Player:setNext(next,hidden)--Set next count　(use hidden=true if set env.nextStartPos>1)
	self.gameEnv.nextCount=next
	if next==0 then
		self.drawNext=NULL
	elseif not hidden then
		self.drawNext=PLY.draw.drawNext_norm
	else
		self.drawNext=PLY.draw.drawNext_hidden
	end
end
function Player:setInvisible(time)--Time in frames
	if time<0 then
		self.keepVisible=true
		self.showTime=1e99
	else
		self.keepVisible=false
		self.showTime=time
	end
end
function Player:setRS(RSname)
	self.RS=kickList[RSname]
end

function Player:setConf(confStr)
	confStr=JSON.decode(confStr)
	if confStr then
		for k,v in next,confStr do
			if not GAME.modeEnv[k]then
				self.gameEnv[k]=v
			end
		end
	else
		LOG.print("Bad conf from "..self.username.."#"..self.uid)
	end
end

function Player:getHolePos()--Get a good garbage-line hole position
	if self.garbageBeneath==0 then
		return generateLine(self:RND(10))
	else
		local p=self:RND(10)
		if self.field[1][p]<=0 then
			return generateLine(self:RND(10))
		end
		return generateLine(p)
	end
end
function Player:garbageRelease()--Check garbage buffer and try to release them
	local n,flag=1
	while true do
		local A=self.atkBuffer[n]
		if A and A.countdown<=0 and not A.sent then
			self:garbageRise(19+A.lv,A.amount,A.line)
			self.atkBuffer.sum=self.atkBuffer.sum-A.amount
			A.sent,A.time=true,0
			self.stat.pend=self.stat.pend+A.amount
			n=n+1
			flag=true
		else
			break
		end
	end
	if flag and self.AI_mode=="CC"and self.AI_bot then CC.updateField(self)end
end
function Player:garbageRise(color,amount,line)--Release n-lines garbage to field
	local _
	local t=self.showTime*2
	for _=1,amount do
		ins(self.field,1,FREEROW.get(0,true))
		ins(self.visTime,1,FREEROW.get(t))
		for i=1,10 do
			self.field[1][i]=bit.rshift(line,i-1)%2==1 and color or 0
		end
	end
	self.fieldBeneath=self.fieldBeneath+amount*30
	if self.cur then
		self.curY=self.curY+amount
		self.ghoY=self.ghoY+amount
	end
	self.garbageBeneath=self.garbageBeneath+amount
	for i=1,#self.clearingRow do
		self.clearingRow[i]=self.clearingRow[i]+amount
	end
	self:freshBlock("push")
	for i=1,#self.lockFX do
		_=self.lockFX[i]
		_[2]=_[2]-30*amount--Shift 30px per line cleared
	end
	for i=1,#self.dropFX do
		_=self.dropFX[i]
		_[3],_[5]=_[3]+amount,_[5]+amount
	end
	if #self.field>42 then self:lose()end
end

local invList={2,1,4,3,5,6,7}
function Player:pushLineList(L,mir)--Push some lines to field
	local l=#L
	local S=self.gameEnv.skin
	for i=1,l do
		local r=FREEROW.get(0)
		if not mir then
			for j=1,10 do
				r[j]=S[L[i][j]]or 0
			end
		else
			for j=1,10 do
				r[j]=S[invList[L[i][11-j]]]or 0
			end
		end
		ins(self.field,1,r)
		ins(self.visTime,1,FREEROW.get(20))
	end
	self.fieldBeneath=self.fieldBeneath+30*l
	self.curY=self.curY+l
	self.ghoY=self.ghoY+l
	self:freshBlock("push")
end
function Player:pushNextList(L,mir)--Push some nexts to nextQueue
	for i=1,#L do
		self:getNext(mir and invList[L[i]]or L[i])
	end
end

function Player:getCenterX()
	return self.curX+self.cur.sc[2]-5.5
end
function Player:solid(x,y)
	if x<1 or x>10 or y<1 then return true end
	if y>#self.field then return false end
	return self.field[y]
	[x]>0--to catch bug (nil[*])
end
function Player:ifoverlap(bk,x,y)
	local C=#bk[1]
	if x<1 or x+C>11 or y<1 then return true end
	if y>#self.field then return end
	for i=1,#bk do
		if self.field[y+i-1]then
			for j=1,C do
				if bk[i][j]and self.field[y+i-1][x+j-1]>0 then return true end
			end
		end
	end
end
function Player:attack(R,send,time,line,fromStream)
	if GAME.net then
		if self.type=="human"then--Local player attack others
			ins(GAME.rep,GAME.frame)
			ins(GAME.rep,
				R.sid+
				send*0x100+
				time*0x10000+
				line*0x100000000+
				0x2000000000000
			)
		end
		if fromStream and R.type=="human"then--Local player receiving lines
			ins(GAME.rep,GAME.frame)
			ins(GAME.rep,
				self.sid+
				send*0x100+
				time*0x10000+
				line*0x100000000+
				0x1000000000000
			)
			R:receive(self,send,time,line)
		end
	else
		R:receive(self,send,time,line)
	end
end
function Player:receive(A,send,time,line)
	self.lastRecv=A
	local B=self.atkBuffer
	if B.sum<26 then
		if send>26-B.sum then send=26-B.sum end
		local m,k=#B,1
		while k<=m and time>B[k].countdown do k=k+1 end
		for i=m,k,-1 do
			B[i+1]=B[i]
		end
		B[k]={
			line=line,
			amount=send,
			countdown=time,
			cd0=time,
			time=0,
			sent=false,
			lv=min(int(send^.69),5),
		}--Sorted insert(by time)
		B.sum=B.sum+send
		self.stat.recv=self.stat.recv+send
		if self.sound then
			SFX.play(send<4 and"blip_1"or"blip_2",min(send+1,5)*.1)
		end
	end
end
function Player:freshTarget()
	if self.atkMode==1 then
		if not self.atking or not self.atking.alive or rnd()<.1 then
			self:changeAtk(randomTarget(self))
		end
	elseif self.atkMode==2 then
		self:changeAtk(self~=GAME.mostBadge and GAME.mostBadge or GAME.secBadge or randomTarget(self))
	elseif self.atkMode==3 then
		self:changeAtk(self~=GAME.mostDangerous and GAME.mostDangerous or GAME.secDangerous or randomTarget(self))
	elseif self.atkMode==4 then
		for i=1,#self.atker do
			if not self.atker[i].alive then
				rem(self.atker,i)
				return
			end
		end
	end
end
function Player:changeAtkMode(m)
	if self.atkMode==m then return end
	self.atkMode=m
	if m==1 then
		self:changeAtk(randomTarget(self))
	elseif m==2 or m==3 then
		self:freshTarget()
	elseif m==4 then
		self:changeAtk()
	end
end
function Player:changeAtk(R)
	-- if self.type~="human"then R=PLAYERS[1]end--1vALL mode?
	if self.atking then
		local K=self.atking.atker
		for i=1,#K do
			if K[i]==self then
				rem(K,i)
				break
			end
		end
	end
	if R then
		self.atking=R
		ins(R.atker,self)
	else
		self.atking=false
	end
end
function Player:freshBlock(mode)--string mode: push/move/fresh/newBlock
	local ENV=self.gameEnv
	--Fresh ghost
	if(mode=="move"or mode=="newBlock"or mode=="push")and self.cur then
		local CB=self.cur.bk
		self.ghoY=min(#self.field+1,self.curY)
		if self._20G or ENV.sdarr==0 and self.keyPressing[7]and self.downing>ENV.sddas then
			local _=self.ghoY

			--Move ghost to bottom
			while not self:ifoverlap(CB,self.curX,self.ghoY-1)do
				self.ghoY=self.ghoY-1
			end

			--Cancel spinLast
			if _~=self.ghoY then
				self.spinLast=false
			end

			--Create FX if dropped
			if self.curY>self.ghoY then
				if ENV.dropFX and ENV.block and self.curY-self.ghoY-#CB>-1 then
					self:createDropFX(self.curX,self.curY-1,#CB[1],self.curY-self.ghoY-#CB+1)
				end
				if ENV.shakeFX then
					self.fieldOff.vy=ENV.shakeFX*.5
				end
				self.curY=self.ghoY
			end
		else
			while not self:ifoverlap(CB,self.curX,self.ghoY-1)do
				self.ghoY=self.ghoY-1
			end
		end
	end

	--Fresh delays
	if mode=="move"or mode=="newBlock"or mode=="fresh"then
		local d0,l0=ENV.drop,ENV.lock
		if ENV.easyFresh then
			if self.lockDelay<l0 and self.freshTime>0 then
				if mode~="newBlock"then
					self.freshTime=self.freshTime-1
				end
				self.lockDelay=l0
				self.dropDelay=d0
			end
			if self.curY+self.cur.sc[1]<self.minY then
				self.minY=self.curY+self.cur.sc[1]
				self.dropDelay=d0
				self.lockDelay=l0
			end
		else
			if self.curY+self.cur.sc[1]<self.minY then
				self.minY=self.curY+self.cur.sc[1]
				if self.lockDelay<l0 and self.freshTime>0 then
					self.freshTime=self.freshTime-1
					self.dropDelay=d0
					self.lockDelay=l0
				end
			end
		end
	end
end
function Player:lock()
	local dest=self.AI_dest
	local has_dest=dest~=nil
	local CB=self.cur.bk
	for i=1,#CB do
		local y=self.curY+i-1
		if not self.field[y]then self.field[y],self.visTime[y]=FREEROW.get(0),FREEROW.get(0)end
		for j=1,#CB[1]do
			if CB[i][j]then
				self.field[y][self.curX+j-1]=self.cur.color
				self.visTime[y][self.curX+j-1]=self.showTime
				if dest then
					local x=self.curX+j-1
					for k=1,#dest,2 do
						if x==dest[k]+1 and y==dest[k+1]+1 then
							rem(dest,k)rem(dest,k)
							goto BREAK_success
						end
					end
					dest=nil
					::BREAK_success::
				end
			end
		end
	end
	if has_dest and not dest and self.AI_mode=="CC"and self.AI_bot then
		CC.updateField(self)
	end
end

local spawnSFX_name={}for i=1,7 do spawnSFX_name[i]="spawn_"..i end
function Player:resetBlock()--Reset Block's position and execute I*S
	local B=self.cur.bk
	self.curX=int(6-#B[1]*.5)
	local y=int(self.gameEnv.fieldH+1-modf(self.cur.sc[1]))+ceil(self.fieldBeneath/30)
	self.curY=y
	self.minY=y+self.cur.sc[1]

	local _=self.keyPressing
	--IMS
	if self.gameEnv.ims and(_[1]and self.movDir==-1 or _[2]and self.movDir==1)and self.moving>=self.gameEnv.das then
		local x=self.curX+self.movDir
		if not self:ifoverlap(B,x,y)then
			self.curX=x
		end
	end

	--IRS
	if self.gameEnv.irs then
		if _[5]then
			self:spin(2,true)
		else
			if _[3]then
				if _[4]then
					self:spin(2,true)
				else
					self:spin(1,true)
				end
			elseif _[4]then
				self:spin(3,true)
			end
		end
	end

	--DAS cut
	if self.gameEnv.dascut>0 then
		self.moving=self.moving-(self.moving>0 and 1 or -1)*self.gameEnv.dascut
	end

	--Spawn SFX
	if self.sound and self.cur.id<8 then
		SFX.fplay(spawnSFX_name[self.cur.id],SETTING.sfx_spawn)
	end
end

function Player:spin(d,ifpre)
	local kickData=self.RS[self.cur.id]
	if type(kickData)=="table"then
		local idir=(self.cur.dir+d)%4
		kickData=kickData[self.cur.dir*10+idir]
		if not kickData then
			self:freshBlock("move")
			SFX.play(ifpre and"prerotate"or"rotate",nil,self:getCenterX()*.15)
			return
		end
		local icb=BLOCKS[self.cur.id][idir]
		local isc=SCS[self.cur.id][idir]
		local ix,iy=self.curX+self.cur.sc[2]-isc[2],self.curY+self.cur.sc[1]-isc[1]
		for test=1,#kickData do
			local x,y=ix+kickData[test][1],iy+kickData[test][2]
			if not self:ifoverlap(icb,x,y)and(self.freshTime>=0 or kickData[test][2]<0)then
				ix,iy=x,y
				if self.gameEnv.moveFX and self.gameEnv.block then
					self:createMoveFX()
				end
				self.curX,self.curY,self.cur.dir=ix,iy,idir
				self.cur.sc,self.cur.bk=isc,icb
				self.spinLast=test==2 and 0 or 1

				local t=self.freshTime
				if not ifpre then
					self:freshBlock("move")
				end
				if kickData[test][2]>0 and self.freshTime~=t and self.curY~=self.imgY then
					self.freshTime=self.freshTime-1
				end

				if self.sound then
					local sfx
					if ifpre then
						sfx="prerotate"
					elseif self:ifoverlap(icb,ix,iy+1)and self:ifoverlap(icb,ix-1,iy)and self:ifoverlap(icb,ix+1,iy)then
						sfx="rotatekick"
						if self.gameEnv.shakeFX then
							if d==1 or d==3 then
								self.fieldOff.va=self.fieldOff.va+(2-d)*self.gameEnv.shakeFX*6e-3
							else
								self.fieldOff.va=self.fieldOff.va+self:getCenterX()*self.gameEnv.shakeFX*3e-3
							end
						end
					else
						sfx="rotate"
					end
					SFX.play(sfx,nil,self:getCenterX()*.15)
				end
				self.stat.rotate=self.stat.rotate+1
				return
			end
		end
	elseif kickData then
		kickData(self,d)
	else
		self:freshBlock("move")
		SFX.play(ifpre and"prerotate"or"rotate",nil,self:getCenterX()*.15)
	end
end
local phyHoldKickX={
	[true]={0,-1,1},--X==?.0 tests
	[false]={-.5,.5},--X==?.5 tests
}
function Player:hold(ifpre)
	local ENV=self.gameEnv
	if self.holdTime>0 and(ifpre or self.waiting==-1)then
		if #self.holdQueue<ENV.holdCount and self.nextQueue[1]then--Skip
			ins(self.holdQueue,self:getBlock(self.cur.id))

			local t=self.holdTime
			self:popNext(true)
			self.holdTime=t
		else--Hold
			local C,H=self.cur,self.holdQueue[1]

			--Finesse check
			if H and C and H.id==C.id and H.name==C.name then
				self.ctrlCount=self.ctrlCount+1
			elseif self.ctrlCount<=1 then
				self.ctrlCount=0
			end

			if ENV.phyHold and C and not ifpre then--Physical hold
				local x,y=self.curX,self.curY
				x=x+(#C.bk[1]-#H.bk[1])*.5
				y=y+(#C.bk-#H.bk)*.5

				local iki=phyHoldKickX[x==int(x)]
				for Y=int(y),ceil(y+.5)do
					for i=1,#iki do
						local X=x+iki[i]
						if not self:ifoverlap(H.bk,X,Y)then
							x,y=X,Y
							goto BREAK_success
						end
					end
				end
				--<for-else> All test failed, interrupt with sound
					SFX.play("finesseError")
					do return end
				--<for-end>
				::BREAK_success::

				self.spinLast=false
				self.spinSeq=0
				local hb=self:getBlock(C.id)
				hb.name=C.name
				hb.color=C.color
				ins(self.holdQueue,hb)
				self.cur=rem(self.holdQueue,1)
				self.curX,self.curY=x,y
			else--Normal hold
				self.spinLast=false
				self.spinSeq=0

				if C then
					local hb=self:getBlock(C.id)
					hb.color=C.color
					hb.name=C.name
					ins(self.holdQueue,hb)
				end
				self.cur=rem(self.holdQueue,1)

				self:resetBlock()
			end
			self:freshBlock("move")
			self.dropDelay=ENV.drop
			self.lockDelay=ENV.lock
			if self:ifoverlap(self.cur.bk,self.curX,self.curY)then
				self:lock()
				self:lose()
			end
		end

		self.freshTime=int(min(self.freshTime+ENV.freshLimit*.25,ENV.freshLimit*((self.holdTime+1)/ENV.holdCount)))
		if not ENV.infHold then
			self.holdTime=self.holdTime-1
		end

		if self.sound then
			SFX.play(ifpre and"prehold"or"hold")
		end

		if self.AI_mode=="CC"then
			local next=self.nextQueue[self.AIdata.nextCount]
			if next then
				CC.addNext(self.AI_bot,next.id)
			end
		end

		self.stat.hold=self.stat.hold+1
	end
end

function Player:getBlock(n)--Get a block(id=n) object
	local E=self.gameEnv
	local dir=E.face[n]
	return{
		id=n,
		bk=BLOCKS[n][dir],
		sc=SCS[n][dir],
		dir=dir,
		name=n,
		color=E.bone and 17 or E.skin[n],
	}
end
function Player:getNext(n)--Push a block(id=n) to nextQueue
	local E=self.gameEnv
	local dir=E.face[n]
	ins(self.nextQueue,{
		id=n,
		bk=BLOCKS[n][dir],
		sc=SCS[n][dir],
		dir=dir,
		name=n,
		color=E.bone and 17 or E.skin[n],
	})
end
function Player:popNext(ifhold)--Pop nextQueue to hand
	if not ifhold then
		self.holdTime=min(self.holdTime+1,self.gameEnv.holdCount)
	end
	self.spinLast=false
	self.spinSeq=0
	self.ctrlCount=0

	self.cur=rem(self.nextQueue,1)
	self.newNext()
	if self.cur then
		self.pieceCount=self.pieceCount+1
		if self.AI_mode=="CC"then
			local next=self.nextQueue[self.AIdata.next]
			if next then
				CC.addNext(self.AI_bot,next.id)
			end
		end

		local _=self.keyPressing

		--IHS
		if not ifhold and _[8]and self.gameEnv.ihs then
			self:hold(true)
			_[8]=false
		else
			self:resetBlock()
		end

		self.dropDelay=self.gameEnv.drop
		self.lockDelay=self.gameEnv.lock
		self.freshTime=self.gameEnv.freshLimit

		if self.cur then
			if self:ifoverlap(self.cur.bk,self.curX,self.curY)then
				self:lock()
				self:lose()
			end
			self:freshBlock("newBlock")
		end

		--IHdS
		if _[6]and not ifhold then
			self.act_hardDrop(self)
			_[6]=false
		end
	else
		self:hold()
	end
end

function Player:cancel(N)--Cancel Garbage
	local off=0--Lines offseted
	local bf=self.atkBuffer
	for i=1,#bf do
		if bf.sum==0 or N==0 then break end
		local A=bf[i]
		if not A.sent then
			local O=min(A.amount,N)--Cur Offset
			if N<A.amount then
				A.amount=A.amount-O
			else
				A.sent,A.time=true,0
			end
			off=off+O
			bf.sum=bf.sum-O
			N=N-O
		end
	end
	return off
end
do--Player.drop(self)--Place piece
	local clearSCR={80,200,400}--Techrash:1K; B2Bmul:1.3/1.8
	local spinSCR={
		{200,750,1300,2000},--Z
		{200,750,1300,2000},--S
		{220,700,1300,2000},--L
		{220,700,1300,2000},--J
		{250,800,1400,2000},--T
		{260,900,1600,4500,7000},--O
		{300,1200,1700,4000,6000},--I
		{220,800,2000,3000,8000,26000},--Else
	}--B2B*=1.2; B3B*=2.0; Mini*=.6
	local b2bPoint={50,100,180,800,1000,9999}

	local b2bATK={3,5,8,12,18,26}
	local reAtk={0,0,1,1,1,2,2,3,3}
	local reDef={0,1,1,2,3,3,4,4,5}

	local spinVoice={"zspin","sspin","jspin","lspin","tspin","ospin","ispin","zspin","sspin","pspin","qspin","fspin","espin","tspin","uspin","vspin","wspin","xspin","jspin","lspin","rspin","yspin","hspin","nspin","ispin"}
	local clearVoice={"single","double","triple","techrash","pentcrash","hexcrash"}
	local spinSFX={[0]="spin_0","spin_1","spin_2"}
	local clearSFX={"clear_1","clear_2","clear_3"}
	local renSFX={}for i=1,11 do renSFX[i]="ren_"..i end
	local finesseList={
		{
			{1,2,1,0,1,2,2,1},
			{2,2,2,1,1,2,3,2,2},
			1,2
		},--Z
		1,--S
		{
			{1,2,1,0,1,2,2,1},
			{2,2,3,2,1,2,3,3,2},
			{3,4,3,2,3,4,4,3},
			{2,3,2,1,2,3,3,2,2},
		},--J
		3,--L
		3,--T
		{
			{1,2,2,1,0,1,2,2,1},
			1,1,1
		},--O
		{
			{1,2,1,0,1,2,1},
			{2,2,2,2,1,1,2,2,2,2},
			1,2
		},--I
		{
			{1,2,1,0,1,2,2,1},
			{2,3,2,1,2,3,3,2},
			1,2
		},--Z5
		8,--S5
		3,--self
		3,--Q
		{
			{1,2,1,0,1,2,2,1},
			{2,3,2,1,2,3,3,2},
			{3,4,3,2,3,4,4,3},
			2
		},--F
		12,--E
		12,--T5
		3,--U
		{
			{1,2,1,0,1,2,2,1},
			{2,3,3,2,1,2,3,2},
			{3,4,4,3,2,3,4,3},
			{2,3,2,1,2,3,3,2},
		},--V
		12,--W
		{
			{1,2,1,0,1,2,2,1},
			1,1,1
		},--X
		{
			{1,2,1,0,1,2,1},
			{2,2,3,2,1,2,3,2,2},
			{3,4,3,2,3,4,3},
			2,
		},--J5
		19,--L5
		19,--R
		19,--Y
		19,--N
		19,--H
		{
			{1,1,0,1,2,1},
			{2,3,2,2,1,2,3,2,3,2},
			1,2
		},--I5
		{
			{1,2,1,0,1,2,2,1},
			{2,2,3,2,1,2,3,3,2,2},
			1,2
		},--I3
		{
			{1,2,2,1,0,1,2,2,1},
			{2,3,3,2,1,2,3,3,2},
			{3,4,4,3,2,3,4,4,3},
			2
		},--C
		{
			{1,2,2,1,0,1,2,2,1},
			{2,2,3,2,1,1,2,3,2,2},
			1,2
		},--I2
		{
			{1,2,2,1,0,1,2,3,2,1},
			1,1,1
		},--O1
	}
	for k,v in next,finesseList do
		if type(v)=="table"then
			for d,l in next,v do
				if type(l)=="number"then
					v[d]=v[l]
				end
			end
		else
			finesseList[k]=finesseList[v]
		end
	end

	function Player:drop()
		local _
		local CHN=VOC.getFreeChannel()
		self.dropTime[11]=ins(self.dropTime,1,GAME.frame)--Update speed dial
		local ENV=self.gameEnv
		local STAT=self.stat
		local piece=self.lastPiece

		local finish
		local cmb=self.combo
		local C,CB,CX,CY=self.cur,self.cur.bk,self.curX,self.curY
		local clear--If clear with no line fall
		local cc,gbcc=0,0--Row/garbage-row cleared,full-part
		local atk,exblock=0,0--Attack & extra defense
		local send,off=0,0--Sending lines remain & offset
		local cscore,sendTime=10,0--Score & send Time
		local dospin,mini=0

		piece.id,piece.name=C.id,C.name
		self.waiting=ENV.wait

		--Tri-corner spin check
		if self.spinLast then
			if C.id<6 then
				local x,y=CX+self.cur.sc[2],CY+self.cur.sc[1]
				local c=0
				if self:solid(x-1,y+1)then c=c+1 end
				if self:solid(x+1,y+1)then c=c+1 end
				if c~=0 then
					if self:solid(x-1,y-1)then c=c+1 end
					if self:solid(x+1,y-1)then c=c+1 end
					if c>2 then dospin=dospin+2 end
				end
			end
		end
		--Immovable spin check
		if self:ifoverlap(CB,CX,CY+1)and self:ifoverlap(CB,CX-1,CY)and self:ifoverlap(CB,CX+1,CY)then
			dospin=dospin+2
		end

		--Lock block to field
		self:lock()

		--Clear list of cleared-rows
		if self.clearedRow[1]then self.clearedRow={}end

		--Check line clear
		for i=1,#CB do
			local h=CY+i-2

			--Bomb trigger
			if h>0 and self.field[h]and self.clearedRow[cc]~=h then
				for x=1,#CB[1]do
					if CB[i][x]and self.field[h][CX+x-1]==19 then
						cc=cc+1
						self.clearingRow[cc]=h-cc+1
						self.clearedRow[cc]=h
						break
					end
				end
			end

			h=h+1
			--Row filled
			for x=1,10 do
				if self.field[h][x]<=0 then
					goto CONTINUE_notFull
				end
			end
			cc=cc+1
			self.clearingRow[cc]=h-cc+1
			self.clearedRow[cc]=h
			::CONTINUE_notFull::
		end

		--Create clearing FX
		if cc>0 and ENV.clearFX then
			local t=7-ENV.clearFX*1
			for i=1,cc do
				local y=self.clearedRow[i]
				self:createClearingFX(y,t)
				if ENV.splashFX then
					self:createSplashFX(y)
				end
			end
		end

		--Create locking FX
		if ENV.lockFX then
			if cc==0 then
				self:createLockFX()
			else
				_=#self.lockFX
				if _>0 then
					for _=1,_ do
						rem(self.lockFX)
					end
				end
			end
		end

		--Final spin check
		if dospin>0 then
			if cc>0 then
				dospin=dospin+(self.spinLast or 0)
				if dospin<3 then
					mini=C.id<6 and cc<#CB
				end
			end
		else
			dospin=false
		end

		--Finesse: roof check
		local finesse
		if CY>ENV.fieldH-2 then
			finesse=true
		else
			for x=1,#CB[1]do
				local y=#CB

				--Find the highest y of blocks' x-th column
				while not CB[y][x]do y=y-1 end

				local testX=CX+x-1--Optimize

				--Test the whole column of field to find roof
				for testY=CY+y,#self.field do
					if self:solid(testX,testY)then
						finesse=true
						goto BERAK_roofFound
					end
				end
			end
			::BERAK_roofFound::
		end

		--Remove rows need to be cleared
		if cc>0 then
			for i=cc,1,-1 do
				_=self.clearedRow[i]
				if self.field[_].garbage then
					self.garbageBeneath=self.garbageBeneath-1
					gbcc=gbcc+1
				end
				FREEROW.discard(rem(self.field,_))
				FREEROW.discard(rem(self.visTime,_))
			end
		end

		--Cancel no-sense clearing FX
		_=#self.clearingRow
		while _>0 and self.clearingRow[_]>#self.field do
			self.clearingRow[_]=nil
			_=_-1
		end
		if self.clearingRow[1]then
			self.falling=ENV.fall
		elseif cc>=#C.bk then
			clear=true
		end

		--Finesse check (control)
		local finePts
		if not finesse then
			if dospin then self.ctrlCount=self.ctrlCount-2 end--Allow 2 more step for roof-less spin
			local id=C.id
			local d=self.ctrlCount-finesseList[id][self.cur.dir+1][CX]
			finePts=d<=0 and 5 or max(3-d,0)
		else
			finePts=5
		end
		piece.finePts=finePts

		STAT.finesseRate=STAT.finesseRate+finePts
		if finePts<5 then
			STAT.extraPiece=STAT.extraPiece+1
			if ENV.fineKill then
				finish=true
			end
			if self.sound then
				if ENV.fineKill then
					SFX.play("finesseError_long",.6)
				elseif ENV.fine then
					SFX.play("finesseError",.8)
				else
					SFX.play("lock",nil,self:getCenterX()*.15)
				end
			end
		elseif self.sound then
			SFX.play("lock",nil,self:getCenterX()*.15)
		end

		if finePts<=1 then
			self.finesseCombo=0
		else
			self.finesseCombo=self.finesseCombo+1
			if self.finesseCombo>2 then
				self.finesseComboTime=12
			end
		end

		piece.spin,piece.mini=dospin,false
		piece.pc,piece.hpc=false,false
		piece.special=false
		if cc>0 then--If lines cleared,about 200 lines below
			cmb=cmb+1
			if dospin then
				cscore=(spinSCR[C.name]or spinSCR[8])[cc]
				if self.b2b>800 then
					self:showText(text.b3b..text.block[C.name]..text.spin.." "..text.clear[cc],0,-30,35,"stretch")
					atk=b2bATK[cc]+cc*.5
					exblock=exblock+1
					cscore=cscore*2
					STAT.b3b=STAT.b3b+1
					if self.sound then
						VOC.play("b3b",CHN)
					end
				elseif self.b2b>=50 then
					self:showText(text.b2b..text.block[C.name]..text.spin.." "..text.clear[cc],0,-30,35,"spin")
					atk=b2bATK[cc]
					cscore=cscore*1.2
					STAT.b2b=STAT.b2b+1
					if self.sound then
						VOC.play("b2b",CHN)
					end
				else
					self:showText(text.block[C.name]..text.spin.." "..text.clear[cc],0,-30,45,"spin")
					atk=2*cc
				end
				sendTime=20+atk*20
				if mini then
					self:showText(text.mini,0,-80,35,"appear")
					atk=atk*.25
					sendTime=sendTime+60
					cscore=cscore*.5
					self.b2b=self.b2b+b2bPoint[cc]*.5
					if self.sound then
						VOC.play("mini",CHN)
					end
				else
					self.b2b=self.b2b+b2bPoint[cc]
				end
				piece.mini=mini
				piece.special=true
				if self.sound then
					SFX.play(spinSFX[cc]or"spin_3")
					VOC.play(spinVoice[C.name],CHN)
				end
			elseif cc>=4 then
				cscore=cc==4 and 1000 or cc==5 and 1500 or 2000
				if self.b2b>800 then
					self:showText(text.b3b..text.clear[cc],0,-30,50,"fly")
					atk=4*cc-10
					sendTime=100
					exblock=exblock+1
					cscore=cscore*1.8
					STAT.b3b=STAT.b3b+1
					if self.sound then
						VOC.play("b3b",CHN)
					end
				elseif self.b2b>=50 then
					self:showText(text.b2b..text.clear[cc],0,-30,50,"drive")
					sendTime=80
					atk=3*cc-7
					cscore=cscore*1.3
					STAT.b2b=STAT.b2b+1
					if self.sound then
						VOC.play("b2b",CHN)
					end
				else
					self:showText(text.clear[cc],0,-30,70,"stretch")
					sendTime=60
					atk=2*cc-4
				end
				self.b2b=self.b2b+cc*100-300
				piece.special=true
			else
				piece.special=false
			end
			if self.sound then
				VOC.play(clearVoice[cc],CHN)
			end

			--Normal clear,reduce B2B point
			if not piece.special then
				self.b2b=max(self.b2b-250,0)
				if self.b2b<50 and ENV.b2bKill then
					finish=true
				end
				self:showText(text.clear[cc],0,-30,35,"appear",(8-cc)*.3)
				atk=cc-.5
				sendTime=20+int(atk*20)
				cscore=cscore+clearSCR[cc]
			end

			--Combo bonus
			sendTime=sendTime+25*cmb
			if cmb>1 then
				atk=atk*(1+(cc==1 and .15 or .25)*min(cmb-1,12))
				if cmb>=3 then
					atk=atk+1
				end
				self:showText(text.cmb[min(cmb,21)],0,25,15+min(cmb,15)*5,cmb<10 and"appear"or"flicker")
				cscore=cscore+min(50*cmb,500)*(2*cc-1)
			end

			--PC/HPC
			if clear and #self.field==0 then
				self:showText(text.PC,0,-80,50,"flicker")
				atk=max(atk,min(8+STAT.pc*2,16))
				exblock=exblock+2
				sendTime=sendTime+120
				if STAT.row+cc>4 then
					self.b2b=1000
					cscore=cscore+300*min(6+STAT.pc,10)
				else
					cscore=cscore+626
				end
				STAT.pc=STAT.pc+1
				if self.sound then
					SFX.play("clear")
					VOC.play("perfect_clear",CHN)
				end
				piece.pc=true
				piece.special=true
			elseif clear and(cc>1 or #self.field==self.garbageBeneath)then
				self:showText(text.HPC,0,-80,50,"fly")
				atk=atk+2
				exblock=exblock+2
				sendTime=sendTime+60
				cscore=cscore+626
				STAT.hpc=STAT.hpc+1
				if self.sound then
					SFX.play("clear")
					VOC.play("half_clear",CHN)
				end
				piece.hpc=true
				piece.special=true
			end

			if self.b2b>1000 then self.b2b=1000 end

			--Bonus atk/def when focused
			if GAME.modeEnv.royaleMode then
				local i=min(#self.atker,9)
				if i>1 then
					atk=atk+reAtk[i]
					exblock=exblock+reDef[i]
				end
			end

			--Send Lines
			atk=int(atk*(1+self.strength*.25))--Badge Buff
			send=atk
			if exblock>0 then
				exblock=int(exblock*(1+self.strength*.25))--Badge Buff
				self:showText("+"..exblock,0,53,20,"fly")
				off=off+self:cancel(exblock)
			end
			if send>=1 then
				self:showText(send,0,80,35,"zoomout")
				_=self:cancel(send)
				send=send-_
				off=off+_
				if send>0 then
					local T
					if GAME.modeEnv.royaleMode then
						if self.atkMode==4 then
							local M=#self.atker
							if M>0 then
								for i=1,M do
									self:attack(self.atker[i],send,sendTime,generateLine(self:RND(10)))
									if SETTING.atkFX>0 then
										self:createBeam(self.atker[i],send,C.color)
									end
								end
							else
								T=randomTarget(self)
							end
						else
							T=self.atking
							self:freshTarget()
						end
					elseif #PLY_ALIVE>1 then
						T=randomTarget(self)
					end
					if T then
						self:attack(T,send,sendTime,generateLine(self:RND(10)))
						if SETTING.atkFX>0 then
							self:createBeam(T,send,C.color)
						end
					end
				end
				if self.sound and send>3 then SFX.play("emit",min(send,7)*.1)end
			end

			--SFX & Vibrate
			if self.sound then
				SFX.play(clearSFX[cc]or"clear_4")
				SFX.play(renSFX[min(cmb,11)])
				if cmb>14 then SFX.play("ren_mega",(cmb-10)*.1)end
				VIB(cc+1)
			end
		else--No lines clear
			cmb=0

			--Spin bonus
			if dospin then
				self:showText(text.block[C.name]..text.spin,0,-30,45,"appear")
				self.b2b=self.b2b+20
				if self.sound then
					SFX.play("spin_0")
					VOC.play(spinVoice[C.name],CHN)
				end
				cscore=30
			end

			if self.b2b>800 then
				self.b2b=max(self.b2b-40,800)
			end
			self:garbageRelease()
		end

		self.combo=cmb

		--DropSpeed bonus
		if self._20G then
			cscore=cscore*2
		elseif ENV.drop<1 then
			cscore=cscore*1.5
		elseif ENV.drop<3 then
			cscore=cscore*1.2
		end

		--Speed bonus
		if self.dropSpeed>60 then
			cscore=cscore*(.9+self.dropSpeed/600)
		end

		cscore=int(cscore)
		if ENV.score then
			self:showText(cscore,(self.curX+self.cur.sc[2]-5.5)*30,(10-self.curY-self.cur.sc[1])*30+self.fieldBeneath+self.fieldUp,40-600/(cscore+20),"score",2)
		end

		piece.row,piece.dig=cc,gbcc
		piece.score=cscore
		piece.atk,piece.exblock=atk,exblock
		piece.off,piece.send=off,send

		--Check clearing task
		if cc>0 and self.curMission then
			local t=ENV.mission[self.curMission]
			local success
			if t<5 then
				if piece.row==t and not piece.spin then
					success=true
				end
			elseif t<9 then
				if piece.row==t-4 and piece.spin then
					success=true
				end
			elseif t==9 then
				if piece.pc then
					success=true
				end
			elseif t<90 then
				if piece.row==t%10 and piece.name==int(t/10)and piece.spin then
					success=true
				end
			end
			if success then
				self.curMission=self.curMission+1
				SFX.play("reach")
				if self.curMission>#ENV.mission then
					self.curMission=false
					if not finish then finish="finish"end
				end
			elseif ENV.missionKill then
				self:showText(text.missionFailed,0,140,40,"flicker",.5)
				SFX.play("finesseError_long",.6)
				finish=true
			end
		end

		--Update stat
		STAT.score=STAT.score+cscore
		STAT.piece=STAT.piece+1
		STAT.row=STAT.row+cc
		STAT.maxFinesseCombo=max(STAT.maxFinesseCombo,self.finesseCombo)
		STAT.maxCombo=max(STAT.maxCombo,self.combo)
		if atk>0 then
			STAT.atk=STAT.atk+atk
			if send>0 then
				STAT.send=STAT.send+int(send)
			end
			if off>0 then
				STAT.off=STAT.off+off
			end
		end
		if gbcc>0 then
			STAT.dig=STAT.dig+gbcc
			if atk>0 then
				STAT.digatk=STAT.digatk+atk*gbcc/cc
			end
		end
		local n=C.name
		if dospin then
			_=STAT.spin[n]	_[cc+1]=_[cc+1]+1--Spin[1~25][0~4]
			_=STAT.spins	_[cc+1]=_[cc+1]+1--Spin[0~4]
		elseif cc>0 then
			_=STAT.clear[n]	_[cc]=_[cc]+1--Clear[1~25][1~5]
			_=STAT.clears	_[cc]=_[cc]+1--Clear[1~5]
		end

		if finish then
			if finish==true then self:lose()end
			_=ENV.dropPiece if _ then _(self)end
			if finish then self:win(finish)end
		else
			_=ENV.dropPiece if _ then _(self)end
		end
	end
end
function Player:loadAI(data)--Load AI params
	if not CC then
		data.type="9S"
		data.delta=int(data.delta*.3)
	end
	self.AI_mode=data.type
	self.AI_keys={}
	self.AI_delay=min(int(self.gameEnv.drop*.8),data.delta*rnd()*4)
	self.AI_delay0=data.delta
	self.AIdata={
		type=data.type,
		delay=data.delay,
		delta=data.delta,

		next=data.next,
		hold=data.hold,
		_20G=self._20G,
		bag=data.bag,
		node=data.node,
	}
	if self.AI_mode=="CC"then
		self:setRS("SRS")
		local opt,wei=CC.getConf()
			CC.fastWeights(wei)
			CC.setHold(opt,self.AIdata.hold)
			CC.set20G(opt,self.AIdata._20G)
			CC.setBag(opt,self.AIdata.bag=="bag")
			CC.setNode(opt,self.AIdata.node)
		self.AI_bot=CC.new(opt,wei)
		CC.free(opt)CC.free(wei)
		for i=1,self.AIdata.next do
			CC.addNext(self.AI_bot,self.nextQueue[i].id)
		end
		if self.gameEnv.holdCount and self.gameEnv.holdCount>1 then
			self:setHold(1)
		end
	else
		self:setRS("TRS")
	end
	self.AI_thread=coroutine.wrap(AIFUNC[data.type])
	self.AI_thread(self,self.AI_keys)
end
--------------------------</Methods>--------------------------

--------------------------<Ticks>--------------------------
local function tick_throwBadge(ifAI,sender,time)
	while true do
		yield()
		time=time-1
		if time%4==0 then
			local S,R=sender,sender.lastRecv
			local x1,y1,x2,y2
			if S.small then
				x1,y1=S.centerX,S.centerY
			else
				x1,y1=S.x+308*S.size,S.y+450*S.size
			end
			if R.small then
				x2,y2=R.centerX,R.centerY
			else
				x2,y2=R.x+66*R.size,R.y+344*R.size
			end

			--Generate badge object
			SYSFX.newBadge(x1,y1,x2,y2)

			if not ifAI and time%8==0 then
				SFX.play("collect")
			end
		end
		if time<=0 then return end
	end
end
local function tick_finish(self)
	while true do
		yield()
		self.endCounter=self.endCounter+1
		if self.endCounter<40 then
			--Make field visible
			for j=1,#self.field do for i=1,10 do
				if self.visTime[j][i]<20 then self.visTime[j][i]=self.visTime[j][i]+.5 end
			end end
		elseif self.endCounter==60 then
			return
		end
	end
end
local function tick_lose(self)
	while true do
		yield()
		self.endCounter=self.endCounter+1
		if self.endCounter<40 then
			--Make field visible
			for j=1,#self.field do for i=1,10 do
				if self.visTime[j][i]<20 then self.visTime[j][i]=self.visTime[j][i]+.5 end
			end end
		elseif self.endCounter>80 then
			for i=1,#self.field do
				for j=1,10 do
					if self.visTime[i][j]>0 then
						self.visTime[i][j]=self.visTime[i][j]-1
					end
				end
			end
			if self.endCounter==120 then
				for _=#self.field,1,-1 do
					FREEROW.discard(self.field[_])
					FREEROW.discard(self.visTime[_])
					self.field[_],self.visTime[_]=nil
				end
				return
			end
		end
		if not GAME.modeEnv.royaleMode and #PLAYERS>1 then
			self.y=self.y+self.endCounter*.26
			self.absFieldY=self.absFieldY+self.endCounter*.26
		end
	end
end
function tick_autoPause()
	local time=0
	while true do
		yield()
		time=time+1
		if SCN.cur~="play"or GAME.frame<180 then
			return
		elseif time==120 then
			pauseGame()
			return
		end
	end
end
--------------------------</Ticks>--------------------------

--------------------------<Events>--------------------------
local function gameOver()--Save record
	if GAME.replaying then return end
	FILE.save(STAT,"conf/data")
	local M=GAME.curMode
	local R=M.getRank
	if R then
		local P=PLAYERS[1]
		R=R(P)--New rank
		if R then
			if R>0 then
				GAME.rank=R
			end
			if scoreValid()and M.score then
				if RANKS[M.name]then--Old rank exist
					local needSave
					if R>RANKS[M.name]then
						RANKS[M.name]=R
						needSave=true
					end
					if R>0 then
						if M.unlock then
							for i=1,#M.unlock do
								local m=M.unlock[i]
								local n=MODES[m].name
								if not RANKS[n]then
									RANKS[n]=MODES[m].getRank and 0 or 6
									needSave=true
								end
							end
						end
					end
					if needSave then
						FILE.save(RANKS,"conf/unlock","q")
					end
				end
				local D=M.score(P)
				local L=M.records
				local p=#L--Rank-1
				if p>0 then
					while M.comp(D,L[p])do--If higher rank
						p=p-1
						if p==0 then break end
					end
				end
				if p<10 then
					if p==0 then
						P:showTextF(text.newRecord,0,-100,100,"beat",.5)
					end
					D.date=os.date("%Y/%m/%d %H:%M")
					ins(L,p+1,D)
					if L[11]then L[11]=nil end
					FILE.save(L,"record/"..M.name..".rec","lq")
				end
			end
		end
	end
end

function Player:die()--Called both when win/lose!
	self.alive=false
	self.timing=false
	self.control=false
	self.update=PLY.update.dead
	self.waiting=1e99
	self.b2b=0
	self.tasks={}
	for i=1,#self.atkBuffer do
		self.atkBuffer[i].sent=true
		self.atkBuffer[i].time=0
	end
	for i=1,#self.field do
		for j=1,10 do
			self.visTime[i][j]=min(self.visTime[i][j],20)
		end
	end
	if GAME.net then
		if self.id==1 then
			ins(GAME.rep,GAME.frame)
			ins(GAME.rep,0)
		else
			if self.lastRecv and self.lastRecv.id==1 then
				SFX.play("collect")
			end
		end
	end
end
function Player:win(result)
	if self.result then return end
	self:die()
	self.result="WIN"
	if GAME.modeEnv.royaleMode then
		self.modeData.place=1
		self:changeAtk()
	end
	if self.type=="human"then
		GAME.result=result or"win"
		SFX.play("win")
		VOC.play("win")
		if GAME.modeEnv.royaleMode then
			BGM.play("8-bit happiness")
		end
	end
	if GAME.curMode.id=="custom_puzzle"then
		self:showTextF(text.win,0,0,90,"beat",.4)
	else
		self:showTextF(text.win,0,0,90,"beat",.5,.2)
	end
	if self.type=="human"then
		gameOver()
		TASK.new(tick_autoPause)
	end
	self:newTask(tick_finish)
end
function Player:lose(force)
	if self.result then return end
	if self.life>0 and not force then
		self.waiting=62
		local h=#self.field
		for _=h,1,-1 do
			FREEROW.discard(self.field[_])
			FREEROW.discard(self.visTime[_])
			self.field[_],self.visTime[_]=nil
		end
		self.garbageBeneath=0

		if self.AI_mode=="CC"then
			CC.destroy(self.AI_bot)
			TABLE.clear(self.holdQueue)
			self:loadAI(self.AIdata)
		end

		self.life=self.life-1
		self.fieldBeneath=0
		self.b2b=0
		for i=1,#self.atkBuffer do
			local A=self.atkBuffer[i]
			if not A.sent then
				A.sent=true
				A.time=0
			end
		end
		self.atkBuffer.sum=0

		for i=1,h do
			self:createClearingFX(i,1.5)
		end
		SYSFX.newShade(1.4,self.fieldX,self.fieldY,300*self.size,610*self.size)
		SYSFX.newRectRipple(2,self.fieldX,self.fieldY,300*self.size,610*self.size)
		SYSFX.newRipple(2,self.x+(475+25*(self.life<3 and self.life or 0)+12)*self.size,self.y+(665+12)*self.size,20)
		SFX.play("clear_3")
		SFX.play("emit")

		return
	end
	self:die()
	for i=1,#PLY_ALIVE do
		if PLY_ALIVE[i]==self then
			rem(PLY_ALIVE,i)
			break
		end
	end
	self.result="K.O."
	if GAME.modeEnv.royaleMode then
		self:changeAtk()
		self.modeData.place=#PLY_ALIVE+1
		self.strength=0
		if self.lastRecv then
			local A,i=self,0
			repeat
				A,i=A.lastRecv,i+1
			until not A or A.alive or A==self or i==3
			if A and A.alive then
				if self.id==1 or A.id==1 then
					self.killMark=A.id==1
				end
				A.modeData.ko,A.badge=A.modeData.ko+1,A.badge+self.badge+1
				for j=A.strength+1,4 do
					if A.badge>=royaleData.powerUp[j]then
						A.strength=j
						A.frameColor=A.strength
					end
				end
				self.lastRecv=A
				if self.id==1 or A.id==1 then
					TASK.new(tick_throwBadge,not A.type=="human",self,max(3,self.badge)*4)
				end
			end
		else
			self.badge=-1
		end

		freshMostBadge()
		freshMostDangerous()
		if #PLY_ALIVE==royaleData.stage[GAME.stage]then
			royaleLevelup()
		end
		self:showTextF(self.modeData.place,0,120,60,"appear",.26,.9)
	end
	self.gameEnv.keepVisible=self.gameEnv.visible~="show"
	self:showTextF(text.gameover,0,0,60,"appear",.26,.9)
	if self.type=="human"then
		GAME.result="gameover"
		SFX.play("fail")
		VOC.play("lose")
		if GAME.modeEnv.royaleMode then
			BGM.play("end")
		end
		gameOver()
		self:newTask(#PLAYERS>1 and tick_lose or tick_finish)
		if GAME.net then
			NET.signal_die()
		else
			TASK.new(tick_autoPause)
		end
	else
		self:newTask(tick_lose)
	end
	if #PLY_ALIVE==1 then
		PLY_ALIVE[1]:win()
	end
end
--------------------------<\Events>--------------------------

--------------------------<Actions>--------------------------
function Player:act_moveLeft(auto)
	if not auto then
		self.ctrlCount=self.ctrlCount+1
	end
	self.movDir=-1
	if self.keyPressing[9]then
		if self.gameEnv.swap then
			self:changeAtkMode(1)
			self.keyPressing[1]=false
		end
	elseif self.control and self.waiting==-1 then
		if self.cur and not self:ifoverlap(self.cur.bk,self.curX-1,self.curY)then
			if self.gameEnv.moveFX and self.gameEnv.block then
				self:createMoveFX("left")
			end
			self.curX=self.curX-1
			self:freshBlock("move")
			if self.sound and self.curY==self.ghoY then SFX.play("move")end
			if not auto then self.moving=0 end
			self.spinLast=false
		else
			self.moving=self.gameEnv.das
		end
	else
		self.moving=0
	end
end
function Player:act_moveRight(auto)
	if not auto then
		self.ctrlCount=self.ctrlCount+1
	end
	self.movDir=1
	if self.keyPressing[9]then
		if self.gameEnv.swap then
			self:changeAtkMode(2)
			self.keyPressing[2]=false
		end
	elseif self.control and self.waiting==-1 then
		if self.cur and not self:ifoverlap(self.cur.bk,self.curX+1,self.curY)then
			if self.gameEnv.moveFX and self.gameEnv.block then
				self:createMoveFX("right")
			end
			self.curX=self.curX+1
			self:freshBlock("move")
			if self.sound and self.curY==self.ghoY then SFX.play("move")end
			if not auto then self.moving=0 end
			self.spinLast=false
		else
			self.moving=self.gameEnv.das
		end
	else
		self.moving=0
	end
end
function Player:act_rotRight()
	if self.control and self.waiting==-1 and self.cur then
		self.ctrlCount=self.ctrlCount+1
		self:spin(1)
		self.keyPressing[3]=false
	end
end
function Player:act_rotLeft()
	if self.control and self.waiting==-1 and self.cur then
		self.ctrlCount=self.ctrlCount+1
		self:spin(3)
		self.keyPressing[4]=false
	end
end
function Player:act_rot180()
	if self.control and self.waiting==-1 and self.cur then
		self.ctrlCount=self.ctrlCount+2
		self:spin(2)
		self.keyPressing[5]=false
	end
end
function Player:act_hardDrop()
	if self.keyPressing[9]then
		if self.gameEnv.swap then
			self:changeAtkMode(3)
		end
		self.keyPressing[6]=false
	elseif self.control and self.waiting==-1 and self.cur then
		if self.curY>self.ghoY then
			local CB=self.cur.bk
			if self.gameEnv.dropFX and self.gameEnv.block and self.curY-self.ghoY-#CB>-1 then
				self:createDropFX(self.curX,self.curY-1,#CB[1],self.curY-self.ghoY-#CB+1)
			end
			self.curY=self.ghoY
			self.spinLast=false
			if self.sound then
				SFX.play("drop",nil,self:getCenterX()*.15)
				VIB(1)
			end
		end
		if self.gameEnv.shakeFX then
			self.fieldOff.vy=self.gameEnv.shakeFX*.6
			self.fieldOff.va=self.fieldOff.va+self:getCenterX()*self.gameEnv.shakeFX*6e-4
		end
		self.lockDelay=-1
		self:drop()
		self.keyPressing[6]=false
	end
end
function Player:act_softDrop()
	local ENV=self.gameEnv
	if self.keyPressing[9]then
		if ENV.swap then
			self:changeAtkMode(4)
		end
	else
		self.downing=1
		if self.control and self.waiting==-1 and self.cur then
			if self.curY>self.ghoY then
				self.curY=self.curY-1
				self:freshBlock("fresh")
				self.spinLast=false
			elseif ENV.deepDrop then
				local CB=self.cur.bk
				local y=self.curY-1
				while self:ifoverlap(CB,self.curX,y)and y>0 do
					y=y-1
				end
				if y>0 then
					if ENV.dropFX and ENV.block and self.curY-y-#CB>-1 then
						self:createDropFX(self.curX,self.curY-1,#CB[1],self.curY-y-#CB+1)
					end
					self.curY=y
					self:freshBlock("move")
					SFX.play("swipe")
				end
			end
		end
	end
end
function Player:act_hold()
	if self.control and self.waiting==-1 then
		self:hold()
	end
end
function Player:act_func1()
	self.gameEnv.fkey1(self)
end
function Player:act_func2()
	self.gameEnv.fkey2(self)
end

function Player:act_insLeft(auto)
	if not self.cur then return end
	local x0=self.curX
	while not self:ifoverlap(self.cur.bk,self.curX-1,self.curY)do
		if self.gameEnv.moveFX and self.gameEnv.block then
			self:createMoveFX("left")
		end
		self.curX=self.curX-1
		self:freshBlock("move")
	end
	if self.curX~=x0 then
		self.spinLast=false
	end
	if self.gameEnv.shakeFX then
		self.fieldOff.vx=-self.gameEnv.shakeFX*.5
	end
	if auto then
		if self.ctrlCount==0 then self.ctrlCount=1 end
	else
		self.ctrlCount=self.ctrlCount+1
	end
end
function Player:act_insRight(auto)
	if not self.cur then return end
	local x0=self.curX
	while not self:ifoverlap(self.cur.bk,self.curX+1,self.curY)do
		if self.gameEnv.moveFX and self.gameEnv.block then
			self:createMoveFX("right")
		end
		self.curX=self.curX+1
		self:freshBlock("move")
	end
	if self.curX~=x0 then
		self.spinLast=false
	end
	if self.gameEnv.shakeFX then
		self.fieldOff.vx=self.gameEnv.shakeFX*.5
	end
	if auto then
		if self.ctrlCount==0 then self.ctrlCount=1 end
	else
		self.ctrlCount=self.ctrlCount+1
	end
end
function Player:act_insDown()
	if self.cur and self.curY>self.ghoY then
		local ENV=self.gameEnv
		local CB=self.cur.bk
		if ENV.dropFX and ENV.block and self.curY-self.ghoY-#CB>-1 then
			self:createDropFX(self.curX,self.curY-1,#CB[1],self.curY-self.ghoY-#CB+1)
		end
		if ENV.shakeFX then
			self.fieldOff.vy=ENV.shakeFX*.5
		end
		self.curY=self.ghoY
		self.lockDelay=ENV.lock
		self.spinLast=false
		self:freshBlock("fresh")
	end
end
function Player:act_down1()
	if self.cur and self.curY>self.ghoY then
		if self.gameEnv.moveFX and self.gameEnv.block then
			self:createMoveFX("down")
		end
		self.curY=self.curY-1
		self:freshBlock("fresh")
		self.spinLast=false
	end
end
function Player:act_down4()
	if self.cur and self.curY>self.ghoY then
		local y=max(self.curY-4,self.ghoY)
		local CB=self.cur.bk
		if self.gameEnv.dropFX and self.gameEnv.block and self.curY-y-#CB>-1 then
			self:createDropFX(self.curX,self.curY-1,#CB[1],self.curY-y-#CB+1)
		end
		self.curY=y
		self:freshBlock("fresh")
		self.spinLast=false
	end
end
function Player:act_down10()
	if self.cur and self.curY>self.ghoY then
		local y=max(self.curY-10,self.ghoY)
		local CB=self.cur.bk
		if self.gameEnv.dropFX and self.gameEnv.block and self.curY-y-#CB>-1 then
			self:createDropFX(self.curX,self.curY-1,#CB[1],self.curY-y-#CB+1)
		end
		self.curY=y
		self:freshBlock("fresh")
		self.spinLast=false
	end
end
function Player:act_dropLeft()
	if not self.cur then return end
	self:act_insLeft()
	self:act_hardDrop()
end
function Player:act_dropRight()
	if not self.cur then return end
	self:act_insRight()
	self:act_hardDrop()
end
function Player:act_zangiLeft()
	if not self.cur then return end
	self:act_insLeft()
	self:act_insDown()
	self:act_insRight()
	self:act_hardDrop()
end
function Player:act_zangiRight()
	if not self.cur then return end
	self:act_insRight()
	self:act_insDown()
	self:act_insLeft()
	self:act_hardDrop()
end
Player.actList={
	Player.act_moveLeft,	--1
	Player.act_moveRight,	--2
	Player.act_rotRight,	--3
	Player.act_rotLeft,		--4
	Player.act_rot180,		--5
	Player.act_hardDrop,	--6
	Player.act_softDrop,	--7
	Player.act_hold,		--8
	Player.act_func1,		--9
	Player.act_func2,		--10
	Player.act_insLeft,		--11
	Player.act_insRight,	--12
	Player.act_insDown,		--13
	Player.act_down1,		--14
	Player.act_down4,		--15
	Player.act_down10,		--16
	Player.act_dropLeft,	--17
	Player.act_dropRight,	--18
	Player.act_zangiLeft,	--19
	Player.act_zangiRight,	--20
}
--------------------------</Actions>--------------------------
return Player