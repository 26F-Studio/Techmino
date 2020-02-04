--[[
	HighestBlock
	HorizontalTransitions
	VerticalTransitions
	BlockedCells
	Wells
	FilledLines
	4deepShape
	BlockedWells;
]]
dirCount={1,1,3,3,3,0,1}
spinOffset={
	{1,0,0},--S
	{1,0,0},--Z
	{1,0,0},--L
	{1,0,0},--J
	{1,0,0},--T
	{0,0,0},--O
	{2,0,1},--I
}for i=1,7 do spinOffset[i][0]=0 end
--[[
	controlname:
	1~5:mL,mR,rR,rL,rF,
	6~10:hD,sD,H,A,R,
	11~13:LL,RR,DD
]]
FCL={
	[1]={
		{{11},{11,2},{1},{},{2},{2,2},{12,1},{12}},
		{{11,4},{11,3},{11,2,3},{4},{3},{2,3},{2,2,3},{12,4},{12,3}},
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
}
FCL[2]=FCL[1]
FCL[4]=FCL[3]
FCL[5]=FCL[3]
clearScore={[0]=0,0,2,4,12}
function ifoverlapAI(f,bk,x,y)
	if y<1 then return true end
	if y>#f then return nil end
	for i=1,#bk do for j=1,#bk[1]do
		if f[y+i-1]and bk[i][j]>0 and f[y+i-1][x+j-1]>0 then return true end
	end end
end
function resetField(f0,f,start)
	while f[start]do
		removeRow(f,start)
	end
	for i=start,#f0 do
		f[i]=getNewRow()
		for j=1,10 do
			f[i][j]=f0[i][j]
		end
	end
end
function getScore(field,bn,cb,cx,cy)
	local score=0
	local highest=0
	local height=getNewRow()
	local clear=0
	local hole=0

	for i=cy+#cb-1,cy,-1 do
		local f=true
		for j=1,10 do
			if field[i][j]==0 then f=false;break end
		end
		if f then
			removeRow(field,i)
			clear=clear+1
		end
	end
	if #field==0 then return 9e99 end--PC best
	for x=1,10 do
		local h=#field
		while field[h][x]==0 and h>1 do
			h=h-1
		end
		height[x]=h
		if x>3 and x<8 and h>highest then highest=h end
		if h>1 then
			for h=h-1,1,-1 do
				if field[h][x]==0 then
					hole=hole+1
					if hole==5 then break end
				end
			end
		end
	end
	local h1,mh1=0,0
	for x=1,9 do
		local dh=abs(height[x]-height[x+1])
		if dh==1 then
			h1=h1+1
			if h1>mh1 then mh1=h1 end
		else
			h1=0
		end
	end
	ins(freeRow,height)
	score=
		#field*20
		-cy*35
		-#cb*25
		+clearScore[clear]*(8+#field)
		-hole*50
	if #field>6 then score=score-highest*5 end
	if mh1>3 then score=score-50-mh1*40 end
	return score
end
function AI_getControls(ctrl)
	local Tfield={}--test field
	local field_org=P.field
    for i=1,#field_org do
		Tfield[i]=getNewRow()
		for j=1,10 do
			Tfield[i][j]=field_org[i][j]
		end
	end
	local best={x=1,dir=0,hold=false,score=-9e99}
	for ifhold=0,P.gameEnv.hold and 1 or 0 do
		local bn=ifhold==0 and P.bn or P.hn>0 and P.hn or P.nxt[1]
		for dir=0,dirCount[bn] do--each dir
			local cb=blocks[bn][dir]
			for cx=1,11-#cb[1]do--each pos
				local cy=#Tfield+1
				while not ifoverlapAI(Tfield,cb,cx,cy-1)do
					cy=cy-1
				end--move to bottom
				for i=1,#cb do
					local y=cy+i-1
					if not Tfield[y]then Tfield[y]=getNewRow()end
					for j=1,#cb[1]do
						if cb[i][j]~=0 then
							Tfield[y][cx+j-1]=1
						end
					end
				end--simulate lock
				local score=getScore(Tfield,bn,cb,cx,cy)
				if score>best.score then
					best={bn=bn,x=cx,dir=dir,hold=ifhold==1,score=score}
				end
				resetField(field_org,Tfield,cy)
			end
		end
	end
	while #Tfield>0 do
		removeRow(Tfield,1)
	end--Release cache
	if best.hold then
		ins(ctrl,8)
	end
	local l=FCL[best.bn][best.dir+1][best.x]
	for i=1,#l do
		ins(ctrl,l[i])
	end
	ins(ctrl,6)

	if rnd()<.1 then
		if P.atkMode~=4 and P==mostDangerous then
			ins(P.ai.controls,9)
			--Smarter AI???
		end
	end
end