local AISpeed={60,50,45,35,25,15,9,6,4,3}
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