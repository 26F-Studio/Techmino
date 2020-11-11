local rnd=math.random
local ins,rem=table.insert,table.remove

local freshMethod
local freshPrepare={
	rnd=function(P)
		local bag=P.gameEnv.bag
		P:getNext(bag[rnd(#bag)])
		freshMethod.rnd(P)
	end,
	fixed=function(P)
		local bag=P.gameEnv.bag
		local L=#bag
		for i=1,L do
			P.seqData[i]=bag[L+1-i]
		end
		while #P.next<6 do
			if P.seqData[1]then
				P:getNext(rem(P.seqData))
			else
				break
			end
		end
	end,
}
freshMethod={
	none=NULL,
	bag=function(P)
		local bag=P.seqData
		while #P.next<6 do
			if #bag==0 then--Copy a new bag
				local bag0=P.gameEnv.bag
				for i=1,#bag0 do bag[i]=bag0[i]end
			end
			P:getNext(rem(bag,P:RND(#bag)))
		end
	end,
	his4=function(P)
		while #P.next<6 do
			local bag=P.gameEnv.bag
			local L=#bag
			for n=1,4 do
				local j,i=0
				repeat
					i=bag[P:RND(L)]
					j=j+1
				until i~=P.seqData[1]and i~=P.seqData[2]and i~=P.seqData[3]and i~=P.seqData[4]or j==4
				P.seqData[n]=i
				P:getNext(i)
			end
		end
	end,
	rnd=function(P)
		while #P.next<6 do
			local bag=P.gameEnv.bag
			local L=#bag
			for i=1,4 do
				local count=0
				repeat
					i=bag[P:RND(L)]
					count=count+1
				until i~=P.next[#P.next].id or count>=L
				P:getNext(i)
			end
		end
	end,
	reverb=function(P)
		local seq=P.seqData
		while #P.next<6 do
			if #seq==0 then
				local bag0=P.gameEnv.bag
				for i=1,#bag0 do seq[i]=bag0[i]end
				local bag={}
				repeat
					local r=rem(seq,P:RND(#bag))
					local p=1
					repeat
						ins(bag,r)
						p=p-.15-P:RND()
					until p<0
				until #seq==0
				for i=1,#bag do
					seq[i]=bag[i]
				end
			end
			P:getNext(rem(seq))
		end
	end,
	loop=function(P)
		while #P.next<6 do
			if #P.seqData==0 then
				local bag=P.gameEnv.bag
				local L=#bag
				for i=1,L do
					P.seqData[i]=bag[L+1-i]
				end
			end
			P:getNext(rem(P.seqData))
		end
	end,
	fixed=function(P)
		while #P.next<6 do
			if P.seqData[1]then
				P:getNext(rem(P.seqData))
			else
				if not(P.cur or P.hd)then P:lose(true)end
				return
			end
		end
	end,
}
local function prepareSequence(P)--Call freshPrepare and set newNext
	local ENV=P.gameEnv
	if type(ENV.sequence)=="string"then
		P.newNext=freshMethod[ENV.sequence]
		if freshPrepare[ENV.sequence]then
			freshPrepare[ENV.sequence](P)
		else
			P:newNext()
		end
	else
		if type(ENV.freshMethod)=="function"then
			if ENV.sequence then ENV.sequence(P)end
			P.newNext=ENV.freshMethod
		else
			LOG.print("Wrong sequence generator code","warn")
			ENV.sequence="bag"
			prepareSequence(P)
		end
	end
end
return prepareSequence