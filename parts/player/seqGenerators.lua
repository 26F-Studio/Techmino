local ins,rem=table.insert,table.remove
local ceil=math.ceil
local yield=YIELD

local seqGenerators={
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
	his=function(P,seq0)
		local len=#seq0
		local hisLen=ceil(len*.5)
		local history=TABLE.new(0,hisLen)
		while true do
			while #P.nextQueue<6 do
				local r
				for _=1,hisLen do--Reroll up to [hisLen] times
					r=P:RND(len)
					for i=1,hisLen do
						if r==history[i]then
							goto CONTINUE_rollAgain
						end
					end
					do break end
					::CONTINUE_rollAgain::
				end
				if history[1]~=0 then P:getNext(r)end
				rem(history,1)ins(history,r)
			end
			yield()
		end
	end,
	hisPool=function(P,seq0)
		local len=#seq0
		local hisLen=ceil(len*.5)
		local poolLen=5*len

		local history=TABLE.new(0,hisLen)--Indexes of pool
		local droughtTimes=TABLE.new(len,len)--Drought times of seq0
		local pool={}for i=1,len do for _=1,5 do ins(pool,i)end end--5 times indexes of seq0

		while true do
			while #P.nextQueue<6 do
				--Roll mino
				local r--Random index of pool
				for _=1,hisLen do
					r=P:RND(poolLen)
					for i=1,hisLen do
						if pool[r]==history[i]then
							goto CONTINUE_rollAgain
						end
					end
					do break end
					::CONTINUE_rollAgain::
				end

				--Give mino to player & update history
				if history[1]~=0 then P:getNext(seq0[pool[r]])end
				rem(history,1)ins(history,pool[r])

				--Find droughtest(s) minoes
				local droughtList={1}--Droughtst minoes' indexes of seq0
				local maxTime=droughtTimes[1]
				for i=2,len do
					if droughtTimes[i]>maxTime then
						maxTime=droughtTimes[i]
						if #droughtList==1 then droughtList[1]=i else droughtList={i}end
					elseif droughtTimes[i]==maxTime then
						ins(droughtList,i)
					end
				end

				--Update droughtTimes
				for i=1,len do droughtTimes[i]=droughtTimes[i]+1 end
				droughtTimes[pool[r]]=0

				--Update pool
				pool[r]=droughtList[P:RND(#droughtList)]
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
	if type(s)=='function'then
		return s
	elseif type(s)=='string'and seqGenerators[s]then
		return seqGenerators[s]
	else
		LOG.print(
			type(s)=='string'and
			"No sequence mode called "..s or
			"Wrong sequence generator",
		'warn')
		P.gameEnv.sequence='bag'
		return seqGenerators.bag
	end
end