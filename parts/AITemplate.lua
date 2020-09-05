local AISpeed={60,45,30,24,18,12,8,5,4,3}
return function(type,speedLV,next,hold,node)
	if type=="CC"then
		return{
			type="CC",
			next=next,
			hold=hold,
			delta=AISpeed[speedLV],
			node=node,
		}
	elseif type=="9S"then
		return{
			type="9S",
			delta=math.floor(AISpeed[speedLV]*.5),
		}
	end
end