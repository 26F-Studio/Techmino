local defaultCenterTex=GC.DO{1,1}--No texture
local defaultCenterPos={--For SRS-like RSs
	--Tetromino
	{[0]={0,1},{1,0},{1,1},{1,1}},--Z
	{[0]={0,1},{1,0},{1,1},{1,1}},--S
	{[0]={0,1},{1,0},{1,1},{1,1}},--L
	{[0]={0,1},{1,0},{1,1},{1,1}},--J
	{[0]={0,1},{1,0},{1,1},{1,1}},--T
	{[0]={.5,.5},{.5,.5},{.5,.5},{.5,.5}},--O
	{[0]={-.5,1.5},{1.5,-.5},{.5,1.5},{1.5,.5}},--I

	--Pentomino
	{[0]={1,1},{1,1},{1,1},{1,1}},--Z5
	{[0]={1,1},{1,1},{1,1},{1,1}},--S5
	{[0]={0,1},{1,0},{1,1},{1,1}},--P
	{[0]={0,1},{1,0},{1,1},{1,1}},--Q
	{[0]={1,1},{1,1},{1,1},{1,1}},--F
	{[0]={1,1},{1,1},{1,1},{1,1}},--E
	{[0]={1,1},{1,1},{1,1},{1,1}},--T5
	{[0]={0,1},{1,0},{1,1},{1,1}},--U
	{[0]={.5,1.5},{.5,.5},{1.5,.5},{1.5,1.5}},--V
	{[0]={1,1},{1,1},{1,1},{1,1}},--W
	{[0]={1,1},{1,1},{1,1},{1,1}},--X
	{[0]={.5,1.5},{1.5,.5},{.5,1.5},{1.5,.5}},--J5
	{[0]={.5,1.5},{1.5,.5},{.5,1.5},{1.5,.5}},--L5
	{[0]={.5,1.5},{1.5,.5},{.5,1.5},{1.5,.5}},--R
	{[0]={.5,1.5},{1.5,.5},{.5,1.5},{1.5,.5}},--Y
	{[0]={.5,1.5},{1.5,.5},{.5,1.5},{1.5,.5}},--N
	{[0]={.5,1.5},{1.5,.5},{.5,1.5},{1.5,.5}},--H
	{[0]={0,2},{2,0},{0,2},{2,0}},--I5

	--Trimino
	{[0]={0,1},{1,0},{0,1},{1,0}},--I3
	{[0]={.5,.5},{.5,.5},{.5,.5},{.5,.5}},--C

	--Domino
	{[0]={-.5,.5},{.5,-.5},{.5,.5},{.5,.5}},--I2

	--Dot
	{[0]={0,0},{0,0},{0,0},{0,0}},--O1
}

local noKickSet,noKickSet_180 do
	local Zero={{0,0}}
	noKickSet={[01]=Zero,[10]=Zero,[03]=Zero,[30]=Zero,[12]=Zero,[21]=Zero,[32]=Zero,[23]=Zero}
	noKickSet_180={[01]=Zero,[10]=Zero,[03]=Zero,[30]=Zero,[12]=Zero,[21]=Zero,[32]=Zero,[23]=Zero,[02]=Zero,[20]=Zero,[13]=Zero,[31]=Zero}
end
local function strToVec(list)
	for i,vecStr in next,list do
		list[i]={tonumber(vecStr:sub(1,2)),tonumber(vecStr:sub(3,4))}
	end
	return list
end

--Use this if the block is centrosymmetry, *PTR!!!
local function centroSymSet(L)
	L[23]=L[01]L[32]=L[10]
	L[21]=L[03]L[12]=L[30]
	L[20]=L[02]L[31]=L[13]
end

--Use this to copy a symmetry set
local function flipList(O)
	if not O then return end
	local L={}
	for i,s in next,O do
		L[i]=string.char(88-s:byte())..s:sub(2)
	end
	return L
end

local function reflect(a)
	return{
		[03]=flipList(a[01]),
		[01]=flipList(a[03]),
		[30]=flipList(a[10]),
		[32]=flipList(a[12]),
		[23]=flipList(a[21]),
		[21]=flipList(a[23]),
		[10]=flipList(a[30]),
		[12]=flipList(a[32]),
		[02]=flipList(a[02]),
		[20]=flipList(a[20]),
		[31]=flipList(a[13]),
		[13]=flipList(a[31]),
	}
end

local TRS
do
	local OspinList={
		{111,5,2, 0,-1,0},{111,5,2,-1,-1,0},{111,5,0,-1, 0,0},--T
		{333,5,2,-1,-1,0},{333,5,2, 0,-1,0},{333,5,0, 0, 0,0},--T
		{313,1,2,-1, 0,0},{313,1,2, 0,-1,0},{313,1,2, 0, 0,0},--Z
		{131,2,2, 0, 0,0},{131,2,2,-1,-1,0},{131,2,2,-1, 0,0},--S
		{131,1,2,-1, 0,0},{131,1,2, 0,-1,0},{131,1,2, 0, 0,0},--Z(misOrder)
		{313,2,2, 0, 0,0},{313,2,2,-1,-1,0},{313,2,2,-1, 0,0},--S(misOrder)
		{331,3,2, 0,-1,0},--J(farDown)
		{113,4,2,-1,-1,0},--L(farDown)
		{113,3,2,-1,-1,0},{113,3,0, 0, 0,0},--J
		{331,4,2, 0,-1,0},{331,4,0,-1, 0,0},--L
		{222,7,2,-1, 0,2},{222,7,2,-2, 0,2},{222,7,2, 0, 0,2},--I
		{222,7,0,-1, 1,1},{222,7,0,-2, 1,1},{222,7,0, 0, 1,1},--I(high)
		{121,6,0, 1,-1,2},{112,6,0, 2,-1,2},{122,6,0, 1,-2,2},--O
		{323,6,0,-1,-1,2},{332,6,0,-2,-1,2},{322,6,0,-1,-2,2},--O
	}--{keys, ID, dir, dx, dy, freeLevel (0=immovable, 1=U/D-immovable, 2=free)}
	local XspinList={
		{{ 1,-1},{ 1, 0},{ 1, 1},{ 1,-2},{ 1, 2}},
		{{ 0,-1},{ 0,-2},{ 0, 1},{ 0,-2},{ 0, 2}},
		{{-1,-1},{-1, 0},{-1, 1},{-1,-2},{-1, 2}},
	}
	TRS={
		centerTex=GC.DO{10,10,
			{'setCL',1,1,1,.4},
			{'fRect',1,1,8,8},
			{'setCL',1,1,1,.6},
			{'fRect',2,2,6,6},
			{'setCL',1,1,1,.8},
			{'fRect',3,3,4,4},
			{'setCL',1,1,1},
			{'fRect',4,4,2,2},
		},
		centerDisp=TABLE.new(true,29),
		kickTable={
			{
				[01]={'+0+0','-1+0','-1+1','+0-2','-1+2','+0+1'},
				[10]={'+0+0','+1+0','+1-1','+0+2','+1-2','+1-2'},
				[03]={'+0+0','+1+0','+1+1','+0-2','+1-1','+1-2'},
				[30]={'+0+0','-1+0','-1-1','+0+2','-1+2','+0-1'},
				[12]={'+0+0','+1+0','+1-1','+0+2','+1+2'},
				[21]={'+0+0','-1+0','-1+1','+0-2','-1-2'},
				[32]={'+0+0','-1+0','-1-1','+0+2','-1+2'},
				[23]={'+0+0','+1+0','+1+1','+0-2','+1-2'},
				[02]={'+0+0','+1+0','-1+0','+0-1','+0+1'},
				[20]={'+0+0','-1+0','+1+0','+0+1','+0-1'},
				[13]={'+0+0','+0-1','+0+1','+0-2'},
				[31]={'+0+0','+0+1','+0-1','+0+2'},
			},--Z
			false,--S
			{
				[01]={'+0+0','-1+0','-1+1','+1+0','+0-2','+1+1'},
				[10]={'+0+0','+1+0','+1-1','-1+0','+0+2','+1+2'},
				[03]={'+0+0','+1+0','+1+1','+0-2','+1-2','+1-1','+0+1'},
				[30]={'+0+0','-1+0','-1-1','+0+2','-1+2','+0-1','-1+1'},
				[12]={'+0+0','+1+0','+1-1','+1+1','-1+0','+0-1','+0+2','+1+2'},
				[21]={'+0+0','-1+0','-1+1','-1-1','+1+0','+0+1','+0-2','-1-2'},
				[32]={'+0+0','-1+0','-1-1','+1+0','+0+2','-1+2','-1+1'},
				[23]={'+0+0','+1+0','+1-1','-1+0','+1+1','+0-2','+1-2'},
				[02]={'+0+0','-1+0','+1+0','+0-1','+0+1'},
				[20]={'+0+0','+1+0','-1+0','+0+1','+0-1'},
				[13]={'+0+0','+0-1','+0+1','+1+0'},
				[31]={'+0+0','+0+1','+0-1','-1+0'},
			},--J
			false,--L
			{
				[01]={'+0+0','-1+0','-1+1','+0-2','-1-2','+0+1'},
				[10]={'+0+0','+1+0','+1-1','+0+2','+1+2','+0-1'},
				[03]={'+0+0','+1+0','+1+1','+0-2','+1-2','+0+1'},
				[30]={'+0+0','-1+0','-1-1','+0+2','-1+2','+0-1'},
				[12]={'+0+0','+1+0','+1-1','+0-1','-1-1','+0+2','+1+2','+1+1'},
				[21]={'+0+0','-1+0','+0-2','-1-2','-1-1','+1+1'},
				[32]={'+0+0','-1+0','-1-1','+0-1','+1-1','+0+2','-1+2','-1+1'},
				[23]={'+0+0','+1+0','+0-2','+1-2','+1-1','-1+1'},
				[02]={'+0+0','-1+0','+1+0','+0+1'},
				[20]={'+0+0','+1+0','-1+0','+0-1'},
				[13]={'+0+0','+0-1','+0+1','+1+0','+0-2','+0+2'},
				[31]={'+0+0','+0-1','+0+1','-1+0','+0-2','+0+2'},
			},--T
			function(P,d)
				if P.gameEnv.easyFresh then
					P:freshBlock('fresh')
				end
				if P.gameEnv.ospin then
					local x,y=P.curX,P.curY
					if y==P.ghoY and((P:solid(x-1,y)or P:solid(x-1,y+1)))and(P:solid(x+2,y)or P:solid(x+2,y+1))then
						if P.sound then SFX.play('rotatekick',nil,P:getCenterX()*.15)end
						P.spinSeq=P.spinSeq%100*10+d
						if P.spinSeq<100 then return end
						for i=1,#OspinList do
							local L=OspinList[i]
							if P.spinSeq==L[1]then
								local id,dir=L[2],L[3]
								local bk=BLOCKS[id][dir]
								x,y=P.curX+L[4],P.curY+L[5]
								if
									not P:ifoverlap(bk,x,y)and(
										L[6]>0 or(P:ifoverlap(bk,x-1,y)and P:ifoverlap(bk,x+1,y))
									)and(
										L[6]==2 or(P:ifoverlap(bk,x,y-1)and P:ifoverlap(bk,x,y+1))
									)
								then
									local C=P.cur
									C.id=id
									C.bk=bk
									P.curX,P.curY=x,y
									P.cur.dir,P.cur.sc=dir,defaultCenterPos[id][dir]
									P.spinLast=2
									P.stat.rotate=P.stat.rotate+1
									P:freshBlock('move')
									P.spinSeq=0
									return
								end
							end
						end
					else
						if P.sound then SFX.play('rotate',nil,P:getCenterX()*.15)end
						P.spinSeq=0
					end
				else
					if P.sound then SFX.play('rotate',nil,P:getCenterX()*.15)end
				end
			end,--O
			{
				[01]={'+0+0','+0+1','+1+0','-2+0','-2-1','+1+2'},
				[10]={'+0+0','+2+0','-1+0','-1-2','+2+1','+0+1'},
				[03]={'+0+0','+0+1','-1+0','+2+0','+2-1','-1+2'},
				[30]={'+0+0','-2+0','+1+0','+1-2','-2+1','+0+1'},
				[12]={'+0+0','-1+0','+2+0','+2-1','+0-1','-1+2'},
				[21]={'+0+0','-2+0','+1+0','+1-2','-2+1','+0+1'},
				[32]={'+0+0','+1+0','-2+0','-2-1','+0-1','+1+2'},
				[23]={'+0+0','+2+0','-1+0','-1-2','+2+1','+0+1'},
				[02]={'+0+0','-1+0','+1+0','+0-1','+0+1'},
				[20]={'+0+0','+1+0','-1+0','+0+1','+0-1'},
				[13]={'+0+0','+0-1','-1+0','+1+0','+0+1'},
				[31]={'+0+0','+0-1','+1+0','-1+0','+0+1'},
			},--I
			{
				[01]={'+0+0','+0+1','+1+1','-1+0','+0-3','+0+2','+0-2','+0+3','-1+2'},
				[10]={'+0+0','+0-1','-1-1','+1+0','+0-3','+0+2','+0-2','+0+3','+1-2'},
				[03]={'+0+0','+1+0','+0-3','+0+1','+0+2','+0+3','+1+2'},
				[30]={'+0+0','-1+0','+0+1','+0-2','+0-3','+0+3','-1-2'},
			},--Z5
			false,--S5
			{
				[01]={'+0+0','-1+0','-1+1','+0-2','-1-2','-1-1','+0+1'},
				[10]={'+0+0','+1+0','+1-1','+0+2','+1+2','+0-1','+1+1'},
				[03]={'+0+0','+1+0','+1+1','+0-2','+1-2'},
				[30]={'+0+0','-1+0','-1-1','+0+2','-1+2'},
				[12]={'+0+0','+1+0','+1-1','+0+2','+1+2','+1+1'},
				[21]={'+0+0','-1+0','-1-1','-1+1','+0-2','-1-2','-1-1'},
				[32]={'+0+0','-1+0','-1-1','-1+1','+0-1','+0+2','-1+2'},
				[23]={'+0+0','+1+0','+1+1','-1+0','+0-2','+1-2'},
				[02]={'+0+0','-1+0','+0-1','+0+1'},
				[20]={'+0+0','+1+0','+0+1','+0-1'},
				[13]={'+0+0','+1+0','+0+1','-1+0'},
				[31]={'+0+0','-1+0','+0-1','+1+0'},
			},--P
			false,--Q
			{
				[01]={'+0+0','-1+0','+1+0','-1+1','+0-2','+0-3'},
				[10]={'+0+0','+1+0','+1-1','-1+0','+0+2','+0+3'},
				[03]={'+0+0','+1+0','+1-1','+0+1','+0-2','+0-3'},
				[30]={'+0+0','-1+1','+1+0','+0-1','+0+2','+0+3'},
				[12]={'+0+0','+1+0','+0-1','-1+0','+0+2'},
				[21]={'+0+0','-1+0','+0+1','+1+0','+0-2'},
				[32]={'+0+0','-1+0','+0+1','-1+1','+1+0','+0+2','-2+0'},
				[23]={'+0+0','+1+0','+1-1','+0-1','-1+0','+0-2','+2+0'},
				[02]={'+0+0','+1+0','-1+0','-1-1'},
				[20]={'+0+0','-1+0','+1+0','+1+1'},
				[13]={'+0+0','+0-1','-1+1','+0+1'},
				[31]={'+0+0','+0-1','+1-1','+0+1'},
			},--F
			false,--E
			{
				[01]={'+0+0','+0-1','-1-1','+1+0','+1+1','+0-3','-1+0','+0+2','-1+2'},
				[10]={'+0+0','+1+0','+0-1','-1-1','+0-2','-1+1','+0-3','+1-2','+0+1'},
				[03]={'+0+0','+0-1','+1-1','-1+0','-1+1','+0-3','+1+0','+0+2','+1+2'},
				[30]={'+0+0','-1+0','+0-1','+1-1','+0-2','+1+1','+0-3','-1-2','+0+1'},
				[12]={'+0+0','+1+0','-1+0','+0-2','+0-3','+0+1','-1+1'},
				[21]={'+0+0','+1-1','-1+0','+1+0','+0-1','+0+2','+0+3'},
				[32]={'+0+0','-1+0','+1+0','+0-2','+0-3','+0+1','+1+1'},
				[23]={'+0+0','-1-1','+1+0','-1+0','+0-1','+0+2','+0+3'},
				[02]={'+0+0','+0-1','+0+1','+0+2'},
				[20]={'+0+0','+0-1','+0+1','+0-2'},
				[13]={'+0+0','+1+0','-1+1','-2+0'},
				[31]={'+0+0','-1+0','+1+1','+2+0'},
			},--T5
			{
				[01]={'+0+0','-1+0','-1+1','+0-2','-1-2'},
				[10]={'+0+0','+1+0','+1-1','+0+2','+1+2'},
				[03]={'+0+0','+1+0','+1+1','+0-2','+1-2'},
				[30]={'+0+0','-1+0','-1-1','+0-2','-1+2'},
				[12]={'+0+0','+1+0','+1-1','+1+1'},
				[21]={'+0+0','-1-1','-1+1','-1-1'},
				[32]={'+0+0','-1+0','-1-1','-1+1'},
				[23]={'+0+0','+1-1','+1+1','+1-1'},
				[02]={'+0+0','+0+1'},
				[20]={'+0+0','+0-1'},
				[13]={'+0+0','+0-1','+0+1','+1+0'},
				[31]={'+0+0','+0-1','+0+1','-1+0'},
			},--U
			{
				[01]={'+0+0','+0+1','-1+0','+0-2','-1-2'},
				[10]={'+0+0','+0+1','+1+0','+0-2','+1-2'},
				[03]={'+0+0','+0-1','+0+1','+0+2'},
				[30]={'+0+0','+0-1','+0+1','+0-2'},
				[12]={'+0+0','+0-1','+0+1'},
				[21]={'+0+0','+0-1','+0-2'},
				[32]={'+0+0','+1+0','-1+0'},
				[23]={'+0+0','-1+0','+1+0'},
				[02]={'+0+0','-1+1','+1-1'},
				[20]={'+0+0','+1-1','-1+1'},
				[13]={'+0+0','+1+1','-1-1'},
				[31]={'+0+0','-1-1','+1+1'},
			},--V
			{
				[01]={'+0+0','+0-1','-1+0','+1+0','+1-1','+0+2'},
				[10]={'+0+0','+0-1','-1-1','+0+1','+0-2','+1-2','+0+2'},
				[03]={'+0+0','+1+0','+1+1','+0-1','+0-2','+0-3','+1-1','+0+1','+0+2','+0+3'},
				[30]={'+0+0','-1+0','-1+1','+0-1','+0-2','+0-3','-1-1','+0+1','+0+2','+0+3'},
				[12]={'+0+0','+1+0','+0-1','-2+0','+1+1','-1+0','+0+1','-1-1'},
				[21]={'+0+0','-1+0','+0-1','+2+0','-1+1','+1+0','+0+1','+1-1'},
				[32]={'+0+0','+0-1','+1+0','+0+1','-1+0','-1-1','+0+2'},
				[23]={'+0+0','+0-1','+1-1','+0+1','+0-2','-1-2','+0+2'},
				[02]={'+0+0','+0-1','-1+0'},
				[20]={'+0+0','+0+1','+1+0'},
				[13]={'+0+0','+0+1','-1+0'},
				[31]={'+0+0','+0-1','+1+0'},
			},--W
			function(P,d)
				if P.type=='human'then SFX.play('rotate',nil,P:getCenterX()*.15)end
				local kickData=XspinList[d]
				for test=1,#kickData do
					local x,y=P.curX+kickData[test][1],P.curY+kickData[test][2]
					if not P:ifoverlap(P.cur.bk,x,y)then
						P.curX,P.curY=x,y
						P.spinLast=1
						P:freshBlock('move')
						P.stat.rotate=P.stat.rotate+1
						return
					end
				end
				P:freshBlock('fresh')
			end,--X
			{
				[01]={'+0+0','-1+0','-1+1','+0-3','-1+1','-1+2','+0+1'},
				[10]={'+0+0','-1+0','+1-1','+0+3','+1-1','+1-2','+0+1'},
				[03]={'+0+0','+0-1','+1-1','-1+0','+1+1','+0-2','+1-2','+0-3','+1-3','-1+1'},
				[30]={'+0+0','+0+1','-1+1','+1+0','-1-1','+0+2','-1+2','+0+3','-1+3','+1-1'},
				[12]={'+0+0','+1+0','+1-1','+0-1','+1-2','+0-2','+1+1','-1+0','+0+2','+1+2'},
				[21]={'+0+0','-1+0','-1+1','+0+1','-1+2','+0+2','-1-1','+1+0','+0-2','-1-2'},
				[32]={'+0+0','-1+0','-1+1','-1-1','+1+0','+0+2','-1+2','+0-2'},
				[23]={'+0+0','+1+0','+1-1','+1+1','-1+0','+0-2','+1-2','+0+2'},
				[02]={'+0+0','+0-1','+1-1','-1+0','+2-1'},
				[20]={'+0+0','+0+1','-1+1','+1+0','-2+1'},
				[13]={'+0+0','-1+0','-1-1','+0+1','-1-2'},
				[31]={'+0+0','+1+0','+1+1','+0-1','+1+2'},
			},--J5
			false,--L5
			{
				[01]={'+0+0','-1+0','-1+0','-1+1','+1+0','-1+2','-1-1','+0-3','+0+1'},
				[10]={'+0+0','-1+0','+1+0','+1-1','+1+0','+1-2','+1+1','+0+3','+0+1'},
				[03]={'+0+0','+0-1','+0+1','+1+0','+1-1','-1+0','+1+1','+0-2','+1-2','+0-3','+1-3','-1+1'},
				[30]={'+0+0','+0-1','+0+1','-1+0','-1+1','+1+0','-1-1','+0+2','-1+2','+0+3','-1+3','+1-1'},
				[12]={'+0+0','+1+0','+1-1','+0-1','+1-2','+0-2','+1+1','-1+0','+0+2','+1+2'},
				[21]={'+0+0','-1+0','-1+1','+0+1','-1+2','+0+2','-1-1','+1+0','+0-2','-1-2'},
				[32]={'+0+0','+0-1','-1+0','-1+1','-1-1','+1+0','+0+2','-1+2','+0-2'},
				[23]={'+0+0','+0+1','+1+0','+1-1','+1+1','-1+0','+0-2','+1-2','+0+2'},
				[02]={'+0+0','+0-1','+1-1','-1+0','+2-1','+0+1'},
				[20]={'+0+0','+0+1','-1+1','+1+0','-2+1','+0-1'},
				[13]={'+0+0','-1+0','-1-1','+0+1','-1-2'},
				[31]={'+0+0','+1+0','+1+1','+0-1','+1+2'},
			},--R
			false,--Y
			{
				[01]={'+0+0','-1+0','-1+1','+0+1','+1+0','-1+2','-2+0','+0-2'},
				[10]={'+0+0','+1+0','-1+0','+0-1','+1-1','+1-2','+2+0','+0+2'},
				[03]={'+0+0','-1+0','+1-1','+0-2','+0-3','+1+0','+1-2','+1-3','+0+1','-1+1'},
				[30]={'+0+0','-1+0','+1-1','+1-2','+1+0','+0-2','+1-3','-1+2','+0+3','-1+3'},
				[12]={'+0+0','-1+0','+1-1','-1-1','+1-2','+1+0','+0-2','+1-3','-1+2','+0+3','-1+3'},
				[21]={'+0+0','-1+0','+1-1','+1+1','+0-2','+0-3','+1+0','+1-2','+1-3','+0+1','-1+1'},
				[32]={'+0+0','-1+0','+0-1','-1-2','+1-1','+1+0','+1+1','+0+2','+0+3'},
				[23]={'+0+0','+0-2','+0-3','+1+2','+1+0','+0+1','-1+1','+0-1','+0+2'},
				[02]={'+0+0','-1+0','+0+2','+0-1'},
				[20]={'+0+0','+1+0','+0-2','+0+1'},
				[13]={'+0+0','-1+0','-1-1','+0+1','+1+2'},
				[31]={'+0+0','+1+0','+1+1','+0-1','-1-2'},
			},--N
			false,--H
			{
				[01]={'+0+0','+1-1','+1+0','+1+1','+0+1','-1+1','-1+0','-1-1','+0-1','+0-2','-2-1','-2-2','+2+0','+2-1','+2-2','+1+2','+2+2','-1+2','-2+2'},
				[10]={'+0+0','-1+0','-1-1','+0-1','+1-1','-2-2','-2-1','-2+0','-1-2','+0-2','+1-2','+2-2','-1+1','-2+1','-2+2','+1+0','+2+0','+2-1','+0+1','+1-1','+2-2'},
				[03]={'+0+0','-1-1','-1+0','-1+1','-0+1','+1+1','+1+0','+1-1','-0-1','-0-2','+2-1','+2-2','-2+0','-2-1','-2-2','-1+2','-2+2','+1+2','+2+2'},
				[30]={'+0+0','+1+0','+1-1','-0-1','-1-1','+2-2','+2-1','+2+0','+1-2','-0-2','-1-2','-2-2','+1+1','+2+1','+2+2','-1+0','-2+0','-2-1','+0+1','-1-1','-2-2'},
			},--I5
			{
				[01]={'+0+0','-1+0','-1-1','+1+1','-1+1'},
				[10]={'+0+0','-1+0','+1+0','-1-1','+1+1'},
				[03]={'+0+0','+1+0','+1-1','-1+1','+1+1'},
				[30]={'+0+0','+1+0','-1+0','+1-1','-1+1'},
			},--I3
			{
				[01]={'+0+0','-1+0','+1+0'},
				[10]={'+0+0','+1+0','-1+0'},
				[03]={'+0+0','+0+1','+0-1'},
				[30]={'+0+0','+0-1','+0+1'},
				[12]={'+0+0','+0+1','+0-1'},
				[21]={'+0+0','+0-1','+0+1'},
				[32]={'+0+0','-1+0','+1+0'},
				[23]={'+0+0','+1+0','-1+0'},
				[02]={'+0+0','+0-1','+1-1','-1-1'},
				[20]={'+0+0','+0+1','-1+1','+1+1'},
				[13]={'+0+0','+0-1','-1-1','+1-1'},
				[31]={'+0+0','+0+1','+1+1','-1+1'},
			},--C
			{
				[01]={'+0+0','-1+0','+0+1'},
				[10]={'+0+0','+1+0','+0+1'},
				[03]={'+0+0','+1+0','+0+1'},
				[30]={'+0+0','-1+0','+0+1'},
				[12]={'+0+0','+1+0','+0+2'},
				[21]={'+0+0','+0-1','-1+0'},
				[32]={'+0+0','-1+0','+0+2'},
				[23]={'+0+0','+0-1','-1+0'},
				[02]={'+0+0','+0-1','+0+1'},
				[20]={'+0+0','+0+1','+0-1'},
				[13]={'+0+0','-1+0','+1+0'},
				[31]={'+0+0','+1+0','-1+0'},
			},--I2
			nil,--O1
		}
	}
	TRS.centerDisp[6]=false
	TRS.centerDisp[18]=false
	TRS.kickTable[2]= reflect(TRS.kickTable[1])--SZ
	TRS.kickTable[4]= reflect(TRS.kickTable[3])--LJ
	TRS.kickTable[9]= reflect(TRS.kickTable[8])--S5Z5
	TRS.kickTable[11]=reflect(TRS.kickTable[10])--PQ
	TRS.kickTable[13]=reflect(TRS.kickTable[12])--FE
	TRS.kickTable[20]=reflect(TRS.kickTable[19])--L5J5
	TRS.kickTable[22]=reflect(TRS.kickTable[21])--RY
	TRS.kickTable[24]=reflect(TRS.kickTable[23])--NH
	centroSymSet(TRS.kickTable[8])centroSymSet(TRS.kickTable[9])--S5Z5
	centroSymSet(TRS.kickTable[25])centroSymSet(TRS.kickTable[26])--I5I3
end

local SRS
do
	SRS={
		centerTex=GC.DO{10,10,
			{'setCL',1,1,1,.3},
			{'fCirc',5,5,4},
			{'setCL',1,1,1,.6},
			{'fCirc',5,5,3},
			{'setCL',1,1,1},
			{'fCirc',5,5,2},
		},
		kickTable={
			{
				[01]={'+0+0','-1+0','-1+1','+0-2','-1-2'},
				[10]={'+0+0','+1+0','+1-1','+0+2','+1+2'},
				[03]={'+0+0','+1+0','+1+1','+0-2','+1-2'},
				[30]={'+0+0','-1+0','-1-1','+0+2','-1+2'},
				[12]={'+0+0','+1+0','+1-1','+0+2','+1+2'},
				[21]={'+0+0','-1+0','-1+1','+0-2','-1-2'},
				[32]={'+0+0','-1+0','-1-1','+0+2','-1+2'},
				[23]={'+0+0','+1+0','+1+1','+0-2','+1-2'},
				[02]={'+0+0'},[20]={'+0+0'},[13]={'+0+0'},[31]={'+0+0'},
			},--Z
			false,--S
			false,--J
			false,--L
			false,--T
			noKickSet,--O
			{
				[01]={'+0+0','-2+0','+1+0','-2-1','+1+2'},
				[10]={'+0+0','+2+0','-1+0','+2+1','-1-2'},
				[12]={'+0+0','-1+0','+2+0','-1+2','+2-1'},
				[21]={'+0+0','+1+0','-2+0','+1-2','-2+1'},
				[23]={'+0+0','+2+0','-1+0','+2+1','-1-2'},
				[32]={'+0+0','-2+0','+1+0','-2-1','+1+2'},
				[30]={'+0+0','+1+0','-2+0','+1-2','-2+1'},
				[03]={'+0+0','-1+0','+2+0','-1+2','+2-1'},
				[02]={'+0+0'},[20]={'+0+0'},[13]={'+0+0'},[31]={'+0+0'},
			}--I
		}
	}
	for i=2,5 do SRS.kickTable[i]=SRS.kickTable[1]end
	for i=8,29 do SRS.kickTable[i]=SRS.kickTable[1]end
end

local SRS_plus
do
	SRS_plus={
		centerTex=GC.DO{10,10,
			{'setCL',1,1,1,.4},
			{'fCirc',5,5,5},
			{'setCL',1,1,1,.6},
			{'fCirc',5,5,4},
			{'setCL',1,1,1,.9},
			{'fCirc',5,5,3},
			{'setCL',1,1,1},
			{'fCirc',5,5,2},
		},
		kickTable={
			{
				[01]={'+0+0','-1+0','-1+1','+0-2','-1-2'},
				[10]={'+0+0','+1+0','+1-1','+0+2','+1+2'},
				[03]={'+0+0','+1+0','+1+1','+0-2','+1-2'},
				[30]={'+0+0','-1+0','-1-1','+0+2','-1+2'},
				[12]={'+0+0','+1+0','+1-1','+0+2','+1+2'},
				[21]={'+0+0','-1+0','-1+1','+0-2','-1-2'},
				[32]={'+0+0','-1+0','-1-1','+0+2','-1+2'},
				[23]={'+0+0','+1+0','+1+1','+0-2','+1-2'},
				[02]={'+0+0','-1+0','+1+0','+0-1','+0+1'},
				[20]={'+0+0','+1+0','-1+0','+0-1','+0+1'},
				[13]={'+0+0','+0-1','-1+0','+1+0','+0+1'},
				[31]={'+0+0','+0-1','-1+0','+1+0','+0+1'},
			},--Z
			false,--S
			false,--J
			false,--L
			false,--T
			noKickSet,--O
			{
				[01]={'+0+0','-2+0','+1+0','-2-1','+1+2'},
				[10]={'+0+0','+2+0','-1+0','+2+1','-1-2'},
				[12]={'+0+0','-1+0','+2+0','-1+2','+2-1'},
				[21]={'+0+0','+1+0','-2+0','+1-2','-2+1'},
				[23]={'+0+0','+2+0','-1+0','+2+1','-1-2'},
				[32]={'+0+0','-2+0','+1+0','-2-1','+1+2'},
				[30]={'+0+0','+1+0','-2+0','+1-2','-2+1'},
				[03]={'+0+0','-1+0','+2+0','-1+2','+2-1'},
				[02]={'+0+0','-1+0','+1+0','+0-1','+0+1'},
				[20]={'+0+0','+1+0','-1+0','+0+1','+0-1'},
				[13]={'+0+0','+0-1','-1+0','+1+0','+0+1'},
				[31]={'+0+0','+0-1','+1+0','-1+0','+0+1'},
			}--I
		}
	}
	for i=2,5 do SRS_plus.kickTable[i]=SRS_plus.kickTable[1]end
	for i=8,29 do SRS_plus.kickTable[i]=SRS_plus.kickTable[1]end
end

local BiRS
do
	local R=strToVec{'+0+0','-1+0','-1-1','+0-1','-1+1','+1-1','+1+0','+0+1','+1+1','+0+2','-1+2','+1+2','-2+0','+2+0'}
	local L=strToVec{'+0+0','+1+0','+1-1','+0-1','+1+1','-1-1','-1+0','+0+1','-1+1','+0+2','+1+2','-1+2','+2+0','-2+0'}
	local F=strToVec{'+0+0','+0-1','+0+1','+0+2'}
	local list={
		{[02]=L,[20]=R,[13]=R,[31]=L},--Z
		{[02]=R,[20]=L,[13]=L,[31]=R},--S
		{[02]=L,[20]=R,[13]=L,[31]=R},--J
		{[02]=R,[20]=L,[13]=L,[31]=R},--L
		{[02]=F,[20]=F,[13]=L,[31]=R},--T
		{[02]=F,[20]=F,[13]=F,[31]=F},--O
		{[02]=F,[20]=F,[13]=R,[31]=L},--I

		{[02]=L,[20]=L,[13]=R,[31]=R},--Z5
		{[02]=R,[20]=R,[13]=L,[31]=L},--S5
		{[02]=L,[20]=R,[13]=L,[31]=R},--P
		{[02]=R,[20]=L,[13]=R,[31]=L},--Q
		{[02]=R,[20]=L,[13]=L,[31]=R},--F
		{[02]=L,[20]=R,[13]=R,[31]=L},--E
		{[02]=F,[20]=F,[13]=L,[31]=R},--T5
		{[02]=F,[20]=F,[13]=L,[31]=R},--U
		{[02]=R,[20]=L,[13]=L,[31]=R},--V
		{[02]=R,[20]=L,[13]=L,[31]=R},--W
		{[02]=F,[20]=F,[13]=F,[31]=F},--X
		{[02]=L,[20]=R,[13]=R,[31]=L},--J5
		{[02]=R,[20]=L,[13]=L,[31]=R},--L5
		{[02]=L,[20]=R,[13]=R,[31]=L},--R
		{[02]=R,[20]=L,[13]=L,[31]=R},--Y
		{[02]=L,[20]=R,[13]=R,[31]=L},--N
		{[02]=R,[20]=L,[13]=L,[31]=R},--H
		{[02]=F,[20]=F,[13]=F,[31]=F},--I5

		{[02]=F,[20]=F,[13]=F,[31]=F},--I3
		{[02]=R,[20]=L,[13]=L,[31]=R},--C
		{[02]=F,[20]=F,[13]=R,[31]=L},--I2
		{[02]=F,[20]=F,[13]=F,[31]=F},--O1
	}
	for i=1,29 do
		local a,b=R,L
		if i==6 or i==18 then a,b=b,a end
		list[i][01]=a;list[i][10]=b;list[i][03]=b;list[i][30]=a
		list[i][12]=a;list[i][21]=b;list[i][32]=b;list[i][23]=a
	end
	BiRS={
		centerTex=GC.DO{10,10,
			{'setCL',1,1,1,.6},
			{'fRect',0,3,10,4},
			{'fRect',3,0,4,10},
			{'setCL',1,1,1},
			{'fRect',1,4,8,2},
			{'fRect',4,1,2,8},
			{'fRect',3,3,4,4},
		},
		kickTable=TABLE.new(function(P,d,ifpre)
			local C=P.cur
			local idir=(C.dir+d)%4
			local kickList=list[C.id][C.dir*10+idir]
			local icb=BLOCKS[C.id][idir]
			local isc=defaultCenterPos[C.id][idir]
			local ix,iy=P.curX+C.sc[2]-isc[2],P.curY+C.sc[1]-isc[1]
			local dx,dy=0,0 do
				local pressing=P.keyPressing
				if pressing[1]and P:ifoverlap(C.bk,P.curX-1,P.curY)then dx=dx-1 end
				if pressing[2]and P:ifoverlap(C.bk,P.curX+1,P.curY)then dx=dx+1 end
				if pressing[7]and P:ifoverlap(C.bk,P.curX,P.curY-1)then dy=  -1 end
			end
			while true do
				for test=1,#kickList do
					local fdx,fdy=kickList[test][1]+dx,kickList[test][2]+dy
					if
						dx*fdx>=0 and
						fdx^2+fdy^2<=5 and
						(P.freshTime>0 or fdy<=0)
					then
						local x,y=ix+fdx,iy+fdy
						if not P:ifoverlap(icb,x,y)then
							if P.gameEnv.moveFX and P.gameEnv.block then
								P:createMoveFX()
							end
							P.curX,P.curY,C.dir=x,y,idir
							C.sc,C.bk=isc,icb
							P.spinLast=test==2 and 0 or 1

							local t=P.freshTime
							if not ifpre then
								P:freshBlock('move')
							end
							if fdy>0 and P.freshTime==t and P.curY~=P.imgY then
								P.freshTime=P.freshTime-1
							end

							if P.sound then
								local sfx
								if ifpre then
									sfx='prerotate'
								elseif P:ifoverlap(icb,x,y+1)and P:ifoverlap(icb,x-1,y)and P:ifoverlap(icb,x+1,y)then
									sfx='rotatekick'
									if P.gameEnv.shakeFX then
										if d==1 or d==3 then
											P.fieldOff.va=P.fieldOff.va+(2-d)*P.gameEnv.shakeFX*6e-3
										else
											P.fieldOff.va=P.fieldOff.va+P:getCenterX()*P.gameEnv.shakeFX*3e-3
										end
									end
								else
									sfx='rotate'
								end
								SFX.play(sfx,nil,P:getCenterX()*.15)
							end
							P.stat.rotate=P.stat.rotate+1
							return
						end
					end
				end

				--Try release left/right, then softdrop, failed to rotate otherwise
				if dx~=0 then
					dx=0
				elseif dy~=0 then
					dy=0
				else
					return
				end
			end
		end,29)
	}
end

local ASC
do
	local L={'+0+0','+1+0','+0-1','+1-1','+0-2','+1-2','+2+0','+2-1','+2-2','-1+0','-1-1','+0+1','+1+1','+2+1','-1-2','-2+0','+0+2','+1+2','+2+2','-2-1','-2-2'}
	local R=flipList(L)
	local F={'+0+0'}
	local centerPos=TABLE.copy(defaultCenterPos)
	centerPos[6]={[0]={0,0},{1,0},{1,1},{0,1}}
	centerPos[7]={[0]={0,1},{2,0},{0,2},{1,0}}
	ASC={
		centerTex=GC.DO{10,10,
			{'setLW',2},
			{'setCL',1,1,1,.7},
			{'line',1,1,9,9},
			{'line',1,9,9,1},
			{'setLW',1},
			{'setCL',1,1,1},
			{'line',1,1,9,9},
			{'line',1,9,9,1},
		},
		centerPos=centerPos,
		kickTable=TABLE.new({
			[01]=R,[10]=L,[03]=L,[30]=R,
			[12]=R,[21]=L,[32]=L,[23]=R,
			[02]=F,[20]=F,[13]=F,[31]=F,
		},29)
	}
end

local ASC_plus
do
	local L={'+0+0','+1+0','+0-1','+1-1','+0-2','+1-2','+2+0','+2-1','+2-2','-1+0','-1-1','+0+1','+1+1','+2+1','-1-2','-2+0','+0+2','+1+2','+2+2','-2-1','-2-2'}
	local R=flipList(L)
	local F={'+0+0','-1+0','+1+0','+0-1','-1-1','+1-1','+0-2','-1-2','+1-2','-2+0','+2+0','-2-1','+2-1','-2+1','+2+1','+0+2','-1+2','+1+2'}
	local centerPos=TABLE.copy(defaultCenterPos)
	centerPos[6]={[0]={0,0},{1,0},{1,1},{0,1}}
	centerPos[7]={[0]={0,1},{2,0},{0,2},{1,0}}
	ASC_plus={
		centerTex=GC.DO{10,10,
			{'setLW',2},
			{'setCL',1,1,1,.7},
			{'line',1,1,9,9},
			{'line',1,9,9,1},
			{'setLW',1},
			{'setCL',1,1,1},
			{'line',1,1,9,9},
			{'line',1,9,9,1},
			{'fCirc',5,5,3},
		},
		centerPos=centerPos,
		kickTable=TABLE.new({
			[01]=R,[12]=R,[23]=R,[30]=R,
			[10]=L,[21]=L,[32]=L,[03]=L,
			[02]=F,[20]=F,[13]=F,[31]=F,
		},29)
	}
end

local C2
do
	local L={'+0+0','-1+0','+1+0','+0-1','-1-1','+1-1','-2+0','+2+0'}
	C2={
		centerTex=GC.DO{10,10,
			{'setLW',2},
			{'dRect',2,2,6,6},
		},
		kickTable=TABLE.new({
			[01]=L,[10]=L,[12]=L,[21]=L,
			[23]=L,[32]=L,[30]=L,[03]=L,
			[02]=L,[20]=L,[13]=L,[31]=L,
		},29)
	}
end

local C2_sym
do
	local L={'+0+0','-1+0','+1+0','+0-1','-1-1','+1-1','-2+0','+2+0'}
	local R={'+0+0','+1+0','-1+0','+0-1','+1-1','-1-1','+2+0','-2+0'}

	local Z={
		[01]=R,[10]=L,[03]=L,[30]=R,
		[12]=R,[21]=L,[32]=L,[23]=R,
		[02]=R,[20]=L,[13]=L,[31]=R,
	}
	local S=reflect(Z)

	C2_sym={
		centerTex=GC.DO{10,10,
			{'setLW',2},
			{'dRect',1,1,8,8},
			{'fRect',3,3,4,4},
		},
		kickTable={
			Z,S,--Z,S
			Z,S,--J,L
			Z,--T
			noKickSet,--O
			Z,--I

			Z,S,--Z5,S5
			Z,S,--P,Q
			Z,S,--F,E
			Z,Z,Z,Z,--T5,U,V,W
			noKickSet,--X
			Z,S,--J5,L5
			Z,S,--R,Y
			Z,S,--N,H
			Z,--I5

			Z,Z,--I3,C
			Z,Z,--I2,O1
		}
	}
end

local Classic do
	local centerPos=TABLE.copy(defaultCenterPos)
	centerPos[1]={[0]={1,1},{1,0},{1,1},{1,0}}
	centerPos[2]={[0]={1,1},{1,0},{1,1},{1,0}}
	centerPos[7]={[0]={0,2},{1,0},{0,2},{1,0}}
	Classic={
		centerDisp=TABLE.new(false,29),
		centerPos=centerPos,
		kickTable=TABLE.new(noKickSet,29)
	}
end

local Classic_plus do
	local centerPos=TABLE.copy(defaultCenterPos)
	centerPos[1]={[0]={1,1},{1,0},{1,1},{1,0}}
	centerPos[2]={[0]={1,1},{1,0},{1,1},{1,0}}
	centerPos[7]={[0]={0,2},{1,0},{0,2},{1,0}}
	Classic_plus={
		centerDisp=TABLE.new(false,29),
		centerPos=centerPos,
		kickTable=TABLE.new(noKickSet_180,29)
	}
end

local None={
		centerTex=GC.DO{10,10,
			{'setLW',2},
			{'line',2,2,6,6},
		},
	kickTable=TABLE.new(noKickSet_180,29)
}

local None_plus={
		centerTex=GC.DO{10,10,
			{'setLW',2},
			{'line',1,1,7,7},
			{'fRect',2,2,4,4},
		},
	kickTable=TABLE.new(noKickSet,29)
}

local RSlist={
	TRS=TRS,
	SRS=SRS,
	SRS_plus=SRS_plus,
	BiRS=BiRS,
	ASC=ASC,
	ASC_plus=ASC_plus,
	C2=C2,
	C2_sym=C2_sym,
	Classic=Classic,
	Classic_plus=Classic_plus,
	None=None,
	None_plus=None_plus,
}

for _,rs in next,RSlist do
	if not rs.centerDisp then rs.centerDisp=TABLE.new(true,29)end
	if not rs.centerPos then rs.centerPos=defaultCenterPos end
	if not rs.centerTex then rs.centerTex=defaultCenterTex end

	--Make all string vec to the same table vec
	for _,set in next,rs.kickTable do
		if type(set)=='table'then
			for _,list in next,set do
				if type(list[1])=='string'then
					strToVec(list)
				end
			end
		end
	end
end

return RSlist