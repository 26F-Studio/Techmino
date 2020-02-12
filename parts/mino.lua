local O,_=true,false
local L={
	{{_,O,O},{O,O,_}},	--Z
	{{O,O,_},{_,O,O}},	--S
	{{O,O,O},{_,_,O}},	--L
	{{O,O,O},{O,_,_}},	--J
	{{O,O,O},{_,O,_}},	--T
	{{O,O},{O,O}},		--O
	{{O,O,O,O}},		--I
}
local function RotCW(B)
	local N={}
	local r,c=#B,#B[1]--row,col
	for x=1,c do
		N[x]={}
		for y=1,r do
			N[x][y]=B[y][c-x+1]
		end
	end
	return N
end

-- [1,1,1]
-- [0,0,1]--r=2,c=3
--    ↓ (Y inv)
--  [1,1]
--  [1,0]
--  [1,0]

for i=1,#L do
	local B=L[i]
	L[i]={[0]=B}
	B=RotCW(B)L[i][1]=B
	B=RotCW(B)L[i][2]=B
	B=RotCW(B)L[i][3]=B
end
return L