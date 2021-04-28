local ins,rem=table.insert,table.remove
local yield=YIELD

local seqGens={
	none=function()while true do yield()end end,
	bag=function(P,seq0)
		local len=#seq0
		local bag={}
		while true do
			while #P.nextQueue<6 do
				if #bag==0 then
					for i=1,len do
						bag[i]=seq0[len-i+1]
					end
				end
				P:getNext(rem(bag,P:RND(#bag)))
			end
			yield()
		end
	end,
	his4=function(P,seq0)
		local len=#seq0
		local his={0,0,0,0}
		while true do
			while #P.nextQueue<6 do
				for n=1,4 do
					local j,i=0
					repeat
						i=seq0[P:RND(len)]
						j=j+1
					until i~=his[1]and i~=his[2]and i~=his[3]and i~=his[4]or j==4
					his[n]=i
					P:getNext(i)
				end
			end
			yield()
		end
	end,
	c2=function(P,seq0)
		local len=#seq0
		local weight={}
		for i=1,len do weight[i]=0 end

		while true do
			while #P.nextQueue<6 do
				local maxK=1
				for i=1,len do
					weight[i]=weight[i]*.5+P:RND()
					if weight[i]>weight[maxK]then
						maxK=i
					end
				end
				weight[maxK]=weight[maxK]/3.5
				P:getNext(seq0[maxK])
			end
			yield()
		end
	end,
	rnd=function(P,seq0)
		P:getNext(seq0[P:RND(#seq0)])
		while true do
			while #P.nextQueue<6 do
				local len=#seq0
				for i=1,4 do
					local count=0
					repeat
						i=seq0[P:RND(len)]
						count=count+1
					until i~=P.nextQueue[#P.nextQueue].id or count>=len
					P:getNext(i)
				end
			end
			yield()
		end
	end,
	mess=function(P,seq0)
		while true do
			while #P.nextQueue<6 do
				P:getNext(seq0[P:RND(#seq0)])
			end
			yield()
		end
	end,
	reverb=function(P,seq0)
		local bufferSeq,bag={},{}
		while true do
			while #P.nextQueue<6 do
				if #bag==0 then
					for i=1,#seq0 do bufferSeq[i]=seq0[i]end
					repeat
						local r=rem(bufferSeq,P:RND(#bag))
						local p=1
						repeat
							ins(bag,r)
							p=p-.15-P:RND()
						until p<0
					until #bufferSeq==0
					for i=1,#bag do
						bufferSeq[i]=bag[i]
					end
				end
				P:getNext(rem(bag,P:RND(#bag)))
			end
			yield()
		end
	end,
	loop=function(P,seq0)
		local len=#seq0
		local bag={}
		while true do
			while #P.nextQueue<6 do
				if #bag==0 then
					for i=1,len do
						bag[i]=seq0[len-i+1]
					end
				end
				P:getNext(rem(bag))
			end
			yield()
		end
	end,
	fixed=function(P,seq0)
		local seq={}
		for i=#seq0,1,-1 do
			ins(seq,seq0[i])
		end
		while true do
			while #P.nextQueue<6 do
				if seq[1]then
					P:getNext(rem(seq))
				else
					if not(P.cur or P.nextQueue[1]or P.holdQueue[1])then
						P:lose(true)
					end
					break
				end
			end
			yield()
		end
	end,
}
return function(P)--Return a piece-generating funtion for player P
	local s=P.gameEnv.sequence
	if type(s)=="function"then
		return s
	elseif type(s)=="string"and seqGens[s]then
		return seqGens[s]
	else
		LOG.print(
			type(s)=="string"and
			"No sequence mode called "..s or
			"Wrong sequence generator",
		"warn")
		P.gameEnv.sequence="bag"
		return seqGens.bag
	end
end