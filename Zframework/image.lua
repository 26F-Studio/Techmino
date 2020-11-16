local IMG={
	batteryImage="/mess/power.png",
	title="mess/title.png",
	title_color="mess/title_colored.png",
	dialCircle="mess/dialCircle.png",
	dialNeedle="mess/dialNeedle.png",
	lifeIcon="mess/life.png",
	badgeIcon="mess/badge.png",
	spinCenter="mess/spinCenter.png",
	ctrlSpeedLimit="mess/ctrlSpeedLimit.png",
	speedLimit="mess/speedLimit.png",
	pay1="mess/pay1.png",
	pay2="mess/pay2.png",

	miyaCH="miya/ch.png",
	miyaF1="miya/f1.png",
	miyaF2="miya/f2.png",
	miyaF3="miya/f3.png",
	miyaF4="miya/f4.png",

	electric="mess/electric.png",
	hbm="mess/hbm.png",
}
local list={}
local count=0
for k,_ in next,IMG do
	count=count+1
	list[count]=k
end
function IMG.getCount()
	return count
end
function IMG.loadOne(_)
	local N=list[_]
	IMG[N]=love.graphics.newImage("media/image/"..IMG[N])
end
function IMG.loadAll()
	for i=1,count do
		IMG.loadOne(i)
	end
end
return IMG