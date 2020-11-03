local AISpeed={60,50,40,30,20,14,10,6,4,3}
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
			delta=math.floor(AISpeed[speedLV]),
		}
	end
end