--[[
HighestBlock
HorizontalTransitions
VerticalTransitions
BlockedCells
Wells
FilledLines
TetrisShape
BlockedWells;
]]
spinNeed={2,2,4,4,4,1,2}
spinOffset={
	{1,0,0},--S
	{1,0,0},--Z
	{1,0,0},--L
	{1,0,0},--J
	{1,0,0},--T
	{0,0,0},--O
	{2,0,1},--I
}for i=1,7 do spinOffset[i][0]=0 end
function ifoverlapAI(field,bk,x,y)
	if x<1 or x+#bk[1]>11 or y<1 then return true end
	if y>#field then return nil end
	for i=1,#bk do for j=1,#bk[1]do
		if field[y+i-1]and bk[i][j]>0 and field[y+i-1][x+j-1]>0 then return true end
	end end
end
function resetField(f0,start)
	while field[start]do
		rem(field,start)
	end
	for i=start,#f0 do
		field[i]={}
		for j=1,10 do
			field[i][j]=f0[i][j]
		end
	end
end
function getScore(field,cb,cx,cy)
	local highest=0
	local height={}
	local rough=0
	local clear=0
	local hole=0

	for i=cy+#cb-1,cy,-1 do
		local f=true
		for j=1,10 do
			if field[i][j]==0 then f=false;break end
		end
		if f then
			rem(field,i)
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
				if field[h][x]==0 then hole=hole+1 end
			end
		end
	end
	for x=1,9 do
		local dh=abs(height[x]-height[x])
		if dh>1 then
			rough=rough+dh^1.5
		end
	end
	return 
	-highest*5
	-rough*15
	-cy*15
	+clear^2*3
	-hole*20
end
--controlname:mL,mR,rR,rL,rF,hD,sD,H,LL,RR
function AI_getControls(ctrl)
    local field_org,cb,cx,cy={}
    for i=1,#field do
		field_org[i]={}
		for j=1,10 do
			field_org[i][j]=field[i][j]
		end
	end
	local best={x=1,dir=0,hold=false,score=-9e99}
	for ifhold=0,1 do
		local bn=ifhold==0 and bn or hn>0 and hn or nxt[1]
		for dir=0,spinNeed[bn]-1 do--for each direction
			cb=blocks[bn][dir]
			for cx=1,11-#cb[1]do--for each positioon
				cy=#field+1
				while not ifoverlapAI(field,cb,cx,cy-1)do
					cy=cy-1
				end--move to bottom
				for i=1,#cb do
					local y=cy+i-1
					if not field[y]then field[y]={0,0,0,0,0,0,0,0,0,0}end
					for j=1,#cb[1]do
						if cb[i][j]~=0 then
							field[y][cx+j-1]=1
						end
					end
				end--simulate lock
				local score=getScore(field,cb,cx,cy)
				if score>best.score then
					best={bn=bn,x=cx,dir=dir,hold=ifhold==1,score=score}
				end
				resetField(field_org,cy)
			end
		end
	end--ifHold

	cb,cx,cy=cb_org,cx_org,cy_org
	if best.hold then
		ins(ctrl,8)
	end
	if best.dir==1 then
		ins(ctrl,3)
	elseif best.dir==2 then
		ins(ctrl,5)
	elseif best.dir==3 then
		ins(ctrl,4)
	end--rotate
	best.x=best.x-spinOffset[best.bn][best.dir]
	local n=blockPos[best.bn]<best.x and 2 or 1
	for i=1,abs(blockPos[best.bn]-best.x)do
		ins(ctrl,n)
	end--move
	ins(ctrl,6)--harddrop
end