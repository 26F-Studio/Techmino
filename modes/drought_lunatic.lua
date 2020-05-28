local rnd,min,rem=math.random,math.min,table.remove
return{
	color=color.red,
	env={
		drop=20,lock=60,
		sequence=function(P)
			for i=1,3 do P:getNext(7)end
		end,
		freshMethod=function(P)
			if not P.next[1] then
				local height=freeRow.get(0)
				local max=#P.field
				for x=1,10 do
					local h=max
					while P.field[h][x]==0 and h>1 do
						h=h-1
					end
					height[x]=h
				end--get heights
				height[11]=999

				local res={1,1,2,2,3,4}
				local d=0
				local A
				for i=1,10 do
					d=d+height[i]
				end
				if d<40 or P.stat.row>2*42 then
					A=#res+1
					for i=A,A+5 do
						res[i]=1
						res[i+6]=2
					end
					goto END
				end

				--give I when no hole
				d=-999--height difference
				--A=hole mark
				for x=2,11 do
					local _=height[x]-height[x-1]
					if d<-2 and _>2 then
						A=true
					end
					d=_
				end
				if not A then
					A=#res+1
					res[A]=7
					res[A+1]=7
					res[A+2]=7
				end

				--give O when no d=0/give T when no d=1
				d=0--d=0 count
				A=0--d=1 count
				for x=2,10 do
					local _=height[x]-height[x-1]
					if _==0 then
						d=d+1
					elseif _==1 or _==-1 then
						A=A+1
					end
				end
				if d<3 then
					A=#res+1
					res[A]=6
					res[A+1]=6
					res[A+2]=6
				end
				if A<3 then
					A=#res+1
					res[A]=5
					res[A+1]=5
					res[A+2]=5
					res[A+3]=5
					res[A+4]=5
				end

				::END::
				freeRow.discard(height)
				P:getNext(res[rnd(#res)])
			end
		end,
		target=100,dropPiece=PLY.reach_winCheck,
		next=1,hold=false,
		ospin=false,
		freshLimit=15,
		bg="glow",bgm="reason",
	},
	pauseLimit=true,
	load=function()
		PLY.newPlayer(1,340,15)
	end,
	mesDisp=function(P,dx,dy)
		setFont(70)
		local R=100-P.stat.row
		mStr(R>=0 and R or 0,-81,280)
	end,
	score=function(P)return{min(P.stat.row,100),P.stat.time}end,
	scoreDisp=function(D)return D[1].." Lines   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		if L>=100 then
			local T=P.stat.time
			return
			T<=70 and 5 or
			T<=110 and 4 or
			T<=160 and 3 or
			T<=240 and 2 or
			1
		else
			return
			L>=50 and 1 or
			L>=10 and 0
		end
	end,
}