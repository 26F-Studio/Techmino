function copyList(org)
	local L={}
	for i=1,#org do
		if type(org[i])~="table"then
			L[i]=org[i]
		else
			L[i]=copyList(org[i])
		end
	end
	return L
end
function copyTable(org)
	local L={}
	for k,v in next,org do
		if type(v)~="table"then
			L[k]=v
		else
			L[k]=copyTable(v)
		end
	end
	return L
end
function addToTable(G,base)--For all things in G if same type in base, push to base
	for k,v in next,G do
		if type(v)==type(base[k])then
			if type(v)=="table"then
				addToTable(v,base[k])
			else
				base[k]=v
			end
		end
	end
end
function completeTable(G,base)--For all things in G if no val in base, push to base
	for k,v in next,G do
		if base[k]==nil then
			base[k]=v
		elseif type(v)=="table"and type(base[k])=="table"then
			completeTable(v,base[k])
		end
	end
end