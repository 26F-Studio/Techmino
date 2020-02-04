local count=0
BGblockList={}for i=1,16 do BGblockList[i]={}end

function getNewBlock()
    count=count+1
    if count==17 then count=1 end
    local t=BGblockList[count]
    t.bn,t.size=rnd(7),2+3*rnd()
    t.b=blocks[t.bn][rnd(0,3)]
    t.x=rnd(-#t.b[1]*t.size*30+100,1180)
    t.y=-#t.b*30*t.size
    t.v=t.size*(1+rnd())
    return t
end