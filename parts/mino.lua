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
local O,_=true,false
local L={
	--Tetramino
	{{_,O,O},{O,O,_}},	--Z
	{{O,O,_},{_,O,O}},	--S
	{{O,O,O},{O,_,_}},	--J
	{{O,O,O},{_,_,O}},	--L
	{{O,O,O},{_,O,_}},	--T
	{{O,O},{O,O}},		--O
	{{O,O,O,O}},		--I

	--Pentomino
	{{_,O,O},{_,O,_},{O,O,_}},	--Z
	{{O,O,_},{_,O,_},{_,O,O}},	--S
	{{O,O,O},{O,O,_}},			--P
	{{O,O,O},{_,O,O}},			--Q
	{{_,O,_},{O,O,O},{O,_,_}},	--F
	{{_,O,_},{O,O,O},{_,_,O}},	--E
	{{O,O,O},{_,O,_},{_,O,_}},	--T
	{{O,O,O},{O,_,O}},			--U
	{{O,O,O},{_,_,O},{_,_,O}},	--V
	{{_,O,O},{O,O,_},{O,_,_}},	--W
	{{_,O,_},{O,O,O},{_,O,_}},	--X
	{{O,O,O,O},{O,_,_,_}},		--J
	{{O,O,O,O},{_,_,_,O}},		--L
	{{O,O,O,O},{_,O,_,_}},		--R
	{{O,O,O,O},{_,_,O,_}},		--Y
	{{_,O,O,O},{O,O,_,_}},		--N
	{{O,O,O,_},{_,_,O,O}},		--H
	{{O,O,O,O,O}},				--I
}
for i=1,#L do
	local B=L[i]
	L[i]={[0]=B}
	B=RotCW(B)L[i][1]=B
	B=RotCW(B)L[i][2]=B
	B=RotCW(B)L[i][3]=B
end
return L