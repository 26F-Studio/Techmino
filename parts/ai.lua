--[[
	HighestBlock
	BlockedCells
	Wells
	FilledLines
	4deepShape
	BlockedWells
]]
local int,ceil,min,abs,rnd=math.floor,math.ceil,math.min,math.abs,math.random
local ins,rem=table.insert,table.remove
local Timer=love.timer.getTime
-- controlname:
-- 1~5:mL,mR,rR,rL,rF,
-- 6~10:hD,sD,H,A,R,
-- 11~13:LL,RR,DD
local blockPos={4,4,4,4,4,5,4}
-------------------------------------------------Cold clear
local _CC=LOADLIB("CC")
if _CC then
	local CCblockID={6,5,4,3,2,1,0}
	CC={
		getConf=	_CC.get_default_config	,--()options,weights
		fastWeights=_CC.fast_weights			,--(weights)
		--setConf=	_CC.set_options			,--(options,hold,20g,bag7)

		new=		_CC.launch_async			,--(options,weights)bot
		addNext=	function(bot,id)_CC.add_next_piece_async(bot,CCblockID[id])end	,--(bot,piece)
		update=		_CC.reset_async			,--(bot,field,b2b,combo)
		think=		_CC.request_next_move	,--(bot)
		getMove=	_CC.poll_next_move		,--(bot)success,dest,hold,move
		destroy=	_CC.destroy_async		,--(bot)

		setHold=	_CC.set_hold				,--(opt,bool)
		set20G=		_CC.set_20g				,--(opt,bool)
		-- setPCLoop=	_CC.set_pcloop			,--(opt,bool)
		setBag=		_CC.set_bag7				,--(opt,bool)
		setNode=	_CC.set_max_nodes		,--(opt,bool)
		free=		_CC.free					,--(opt/wei)
	}
	function CC.updateField(P)
		local F,i={},1
		for y=1,#P.field do
			for x=1,10 do
				F[i],i=P.field[y][x]>0,i+1
			end
		end
		while i<=400 do
			F[i],i=false,i+1
		end
		if not pcall(CC.update,P.AI_bot,F,P.b2b>=100,P.combo)then
			LOG.print("CC is dead ("..P.id..")","error")
		end
	end
	function CC.switch20G(P)
		if not pcall(CC.destroy,P.AI_bot)then
			LOG.print("CC is dead ("..P.id..")","error")
			return
		end
		P.AIdata._20G=true
		P.AI_keys={}
		local opt,wei=CC.getConf()
			CC.fastWeights(wei)
			CC.setHold(opt,P.AIdata.hold)
			CC.set20G(opt,P.AIdata._20G)
			CC.setBag(opt,P.AIdata.bag=="bag")
			CC.setNode(opt,P.AIdata.node)
		P.AI_bot=CC.new(opt,wei)
		CC.free(opt)CC.free(wei)
		for i=1,P.AIdata.next do
			CC.addNext(P.AI_bot,CCblockID[P.next[i].id])
		end
		CC.updateField(P)
		P.hd=nil
		P.holded=false
		P.cur=rem(P.next,1)
		P.sc,P.dir=spinCenters[P.cur.id][0],0
		P.r,P.c=#P.cur.bk,#P.cur.bk[1]
		P.curX,P.curY=blockPos[P.cur.id],21+ceil(P.fieldBeneath/30)-P.r+min(int(#P.field*.2),2)

		P:newNext()
		local id=CCblockID[P.next[P.AIdata.next].id]
		if id then
			CC.addNext(P.AI_bot,id)
		end
		collectgarbage()
	end
end
-------------------------------------------------9 Stack setup
local dirCount={1,1,3,3,3,0,1}
local FCL={
	[1]={
		{{11},{11,2},{1},{},{2},{2,2},{12,1},{12}},
		{{11,4},{11,3},{1,4},{4},{3},{2,3},{2,2,3},{12,4},{12,3}},
	},
	[3]={
		{{11},{11,2},{1},{},{2},{2,2},{12,1},{12},},
		{{3,11},{11,3},{11,2,3},{1,3},{3},{2,3},{2,2,3},{12,1,3},{12,3},},
		{{11,5},{11,2,5},{1,5},{5},{2,5},{2,2,5},{12,1,5},{12,5},},
		{{11,4},{11,2,4},{1,4},{4},{2,4},{2,2,4},{12,1,4},{12,4},{4,12},},
	},
	[6]={
		{{11},{11,2},{1,1},{1},{},{2},{2,2},{12,1},{12},},
	},
	[7]={
		{{11},{11,2},{1},{},{2},{12,1},{12},},
		{{4,11},{11,4},{11,3},{1,4},{4},{3},{2,3},{12,4},{12,3},{3,12},},
	},
}FCL[2],FCL[4],FCL[5]=FCL[1],FCL[3],FCL[3]
local LclearScore={[0]=0,-200,-120,-80,200}
local HclearScore={[0]=0,100,140,200,500}
local function ifoverlapAI(f,bk,x,y)
	for i=1,#bk do for j=1,#bk[1]do
		if f[y+i-1]and bk[i][j]and f[y+i-1][x+j-1]>0 then return true end
	end end
end
local discardRow=FREEROW.discard
local getRow=FREEROW.get
local function resetField(f0,f,start)
	for _=#f,start,-1 do
		discardRow(f[_])
		f[_]=nil
	end
	for i=start,#f0 do
		f[i]=getRow(0)
		for j=1,10 do
			f[i][j]=f0[i][j]
		end
	end
end
local function getScore(field,cb,cy)
	local score=0
	local highest=0
	local height=getRow(0)
	local clear=0
	local hole=0

	for i=cy+#cb-1,cy,-1 do
		for j=1,10 do
			if field[i][j]==0 then goto L end
		end
		discardRow(rem(field,i))
		clear=clear+1
		::L::
	end
	if #field==0 then return 1e99 end--PC
	for x=1,10 do
		local h=#field
		while field[h][x]==0 and h>1 do
			h=h-1
		end
		height[x]=h
		if x>3 and x<8 and h>highest then highest=h end
		if h>1 then
			for h1=h-1,1,-1 do
				if field[h1][x]==0 then
					hole=hole+1
					if hole==5 then break end
				end
			end
		end
	end
	local sdh=0
	local h1,mh1=0,0
	for x=1,9 do
		local dh=abs(height[x]-height[x+1])
		if dh==1 then
			h1=h1+1
			if h1>mh1 then mh1=h1 end
		else
			h1=0
		end
		sdh=sdh+min(dh^1.6,20)
	end
	discardRow(height)
	score=
		-#field*30
		-#cb*15
		+(#field>10 and
			HclearScore[clear]--Clearing
			-hole*70--Hole
			-cy*50--Height
			-sdh--Sum of DeltaH
		or
			LclearScore[clear]
			-hole*100
			-cy*40
			-sdh*3
		)
	if #field>6 then score=score-highest*5+20 end
	if mh1>3 then score=score-20-mh1*30 end
	return score
end
-------------------------------------------------
return{
	["9S"]={
		function(P,ctrl)
			local Tfield={}--Test field
			local best={x=1,dir=0,hold=false,score=-1e99}--Best method
			local field_org=P.field
			for i=1,#field_org do
				Tfield[i]=getRow(0)
				for j=1,10 do
					Tfield[i][j]=field_org[i][j]
				end
			end

			for ifhold=0,P.gameEnv.hold and 1 or 0 do
				--Get block id
				local bn
				if ifhold==0 then
					bn=P.cur and P.cur.id
				else
					bn=P.hd and P.hd.id or P.next[1]and P.next[1].id
				end
				if not bn then goto CTN end

				for dir=0,dirCount[bn]do--Each dir
					local cb=BLOCKS[bn][dir]
					for cx=1,11-#cb[1]do--Each pos
						local cy=#Tfield+1

						--Move to bottom
						while true do
							if cy==1 then break end
							if not ifoverlapAI(Tfield,cb,cx,cy-1)then
								cy=cy-1
							else
								break
							end
						end

						--Simulate lock
						for i=1,#cb do
							local y=cy+i-1
							if not Tfield[y]then Tfield[y]=getRow(0)end
							for j=1,#cb[1]do
								if cb[i][j]then
									Tfield[y][cx+j-1]=1
								end
							end
						end
						local score=getScore(Tfield,cb,cy)
						if score>best.score then
							best={bn=bn,x=cx,dir=dir,hold=ifhold==1,score=score}
						end
						resetField(field_org,Tfield,cy)
					end
				end
				::CTN::
			end
			if not best.bn then return 1 end

			--Release cache
			while #Tfield>0 do
				discardRow(rem(Tfield,1))
			end
			local p=#ctrl+1
			if best.hold then
				ctrl[p]=8
				p=p+1
			end
			local l=FCL[best.bn][best.dir+1][best.x]
			for i=1,#l do
				ctrl[p]=l[i]
				p=p+1
			end
			ctrl[p]=6
			return 2
		end,
		function(P)
			P.AI_delay=P.AI_delay0
			if Timer()-P.modeData.point>P.modeData.event then
				P.modeData.point=Timer()
				P.modeData.event=P.AI_delay0+rnd(5,15)
				P:changeAtkMode(rnd()<.85 and 1 or #P.atker>3 and 4 or rnd()<.3 and 2 or 3)
			end
			return 1
		end,
	},
	["CC"]=CC and{
		[0]=NULL,
		function(P)--Start thinking
			if not pcall(CC.think,P.AI_bot)then
				LOG.print("CC is dead ("..P.id..")","error")
				return 0
			end
			return 2
		end,
		function(P,ctrl)--Poll keys
			local success,result,dest,hold,move=pcall(CC.getMove,P.AI_bot)
			if success then
				if result==2 then
					ins(ctrl,6)
					return 3
				elseif result==0 then
					for i=1,#dest do
						for j=1,#dest[i]do
							dest[i][j]=dest[i][j]+1
						end
					end
					P.AI_dest=dest
					if hold then ctrl[1]=8 end--Hold
					while move[1]do
						local m=rem(move,1)
						if m<4 then
							ins(ctrl,m+1)
						elseif not P.AIdata._20G then
							ins(ctrl,13)
						end
					end
					ins(ctrl,6)
					return 3
				else
					--Stay this stage
					return 2
				end
			else
				LOG.print("CC is dead ("..P.id..")","error")
				return 0
			end
		end,
		function(P)--Check if time to change target
			P.AI_delay=P.AI_delay0
			if Timer()-P.modeData.point>P.modeData.event then
				P.modeData.point=Timer()
				P.modeData.event=P.AI_delay0+rnd(5,15)
				P:changeAtkMode(rnd()<.85 and 1 or #P.atker>3 and 4 or rnd()<.3 and 2 or 3)
			end
			return 1
		end,
	},
}--AI think stage