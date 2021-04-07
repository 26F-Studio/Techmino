local next,type=next,type
local TABLE={}

--Copy [1~#] elements
function TABLE.shift(org)
	local L={}
	for i=1,#org do
		if type(org[i])~="table"then
			L[i]=org[i]
		else
			L[i]=TABLE.shift(org[i])
		end
	end
	return L
end

--Copy all elements
function TABLE.copy(org)
	local L={}
	for k,v in next,org do
		if type(v)~="table"then
			L[k]=v
		else
			L[k]=TABLE.copy(v)
		end
	end
	return L
end

--For all things in G if same type in base, push to base
function TABLE.update(G,base)
	for k,v in next,G do
		if type(v)==type(base[k])then
			if type(v)=="table"then
				TABLE.update(v,base[k])
			else
				base[k]=v
			end
		end
	end
end

--For all things in G if no val in base, push to base
function TABLE.complete(G,base)
	for k,v in next,G do
		if base[k]==nil then
			base[k]=v
		elseif type(v)=="table"and type(base[k])=="table"then
			TABLE.complete(v,base[k])
		end
	end
end

--Remove positive integer index of table
function TABLE.cut(G)
	for i=#G,1,-1 do
		G[i]=nil
	end
end

--Clear table
function TABLE.clear(G)
	for k in next,G do
		G[k]=nil
	end
end

--Re-index string value of a table
function TABLE.reIndex(org)
	for k,v in next,org do
		if type(v)=="string"then
			org[k]=org[v]
		end
	end
end
return TABLE