local ins,rem=table.insert,table.remove
local max=math.max

local mesList={}
local mesIcon={
    check=GC.DO{40,40,
        {'setLW',10},
        {'setCL',0,0,0},
        {'line',4,19,15,30,36,9},
        {'setLW',6},
        {'setCL',.7,1,.6},
        {'line',5,20,15,30,35,10},
    },
    info=GC.DO{40,40,
        {'setCL',.2,.25,.85},
        {'fCirc',20,20,15},
        {'setCL',1,1,1},
        {'setLW',2},
        {'dCirc',20,20,15},
        {'fRect',18,11,4,4},
        {'fRect',18,17,4,12},
    },
    broadcast=GC.DO{40,40,
        {'setCL',1,1,1},
        {'fRect',2,4,36,26,3},
        {'fPoly',2,27,2,37,14,25},
        {'setCL',.5,.5,.5},
        {'fRect',6,11,4,4,1},{'fRect',14,11,19,4,1},
        {'fRect',6,19,4,4,1},{'fRect',14,19,19,4,1},
    },
    warn=GC.DO{40,40,
        {'setCL',.95,.83,.4},
        {'fPoly',20.5,1,0,38,40,38},
        {'setCL',0,0,0},
        {'dPoly',20.5,1,0,38,40,38},
        {'fRect',17,10,7,18,2},
        {'fRect',17,29,7,7,2},
        {'setCL',1,1,1},
        {'fRect',18,11,5,16,2},
        {'fRect',18,30,5,5,2},
    },
    error=GC.DO{40,40,
        {'setCL',.95,.3,.3},
        {'fCirc',20,20,19},
        {'setCL',0,0,0},
        {'dCirc',20,20,19},
        {'setLW',6},
        {'line',10.2,10.2,29.8,29.8},
        {'line',10.2,29.8,29.8,10.2},
        {'setLW',4},
        {'setCL',1,1,1},
        {'line',11,11,29,29},
        {'line',11,29,29,11},
    },
    music=GC.DO{40,40,
        {'setLW',2},
        {'dRect',1,3,38,34,3},
        {'setLW',4},
        {'line',21,26,21,10,28,10},
        {'fElps',17,26,6,5},
    },
}

local MES={}
local backColors={
    check={.3,.6,.3,.7},
    broadcast={.3,.3,.6,.8},
    warn={.4,.4,.2,.9},
    error={.4,.2,.2,.9},
    music={.2,.4,.4,.9},
    other={.5,.5,.5,.7},
}
function MES.new(icon,str,time)
    local color=backColors.other
    if type(icon)=='string' then
        color=TABLE.shift(backColors[icon] or color)
        icon=mesIcon[icon]
    end
    local text=GC.newText(FONT.get(30),str)
    local w=math.max(text:getWidth()+(icon and 45 or 5),200)+15
    local h=math.max(text:getHeight(),46)+2
    local k=h>400 and 1/math.min(h/400,2.6) or 1

    ins(mesList,1,{
        startTime=.26,
        endTime=.26,
        time=time or 3,

        color=color,
        text=text,icon=icon,
        w=w,h=h,k=k,
        y=-h,
    })
end

function MES.update(dt)
    for i=#mesList,1,-1 do
        local m=mesList[i]
        if m.startTime>0 then
            m.startTime=max(m.startTime-dt,0)
        elseif m.time>0 then
            m.time=max(m.time-dt,0)
        elseif m.endTime>0 then
            m.endTime=m.endTime-dt
        else
            rem(mesList,i)
        end
        if i>1 then
            local _m=mesList[i-1]
            m.y=MATH.expApproach(m.y,_m.y+_m.h*_m.k+3,dt*26)
        else
            m.y=MATH.expApproach(m.y,3,dt*26)
        end
    end
end

function MES.draw()
    if #mesList>0 then
        GC.setLineWidth(2)
        for i=1,#mesList do
            local m=mesList[i]
            local a=3.846*(m.endTime-m.startTime)
            GC.push('transform')
            GC.translate(3+SCR.safeX,m.y)
            GC.scale(m.k)

            GC.setColor(m.color[1],m.color[2],m.color[3],m.color[4]*a)
            GC.rectangle('fill',0,0,m.w,m.h,8)
            GC.setColor(.62,.62,.62,a*.626)
            GC.rectangle('line',1,1,m.w-2,m.h-2,4)
            GC.setColor(1,1,1,a)
            if m.icon then
                GC.draw(m.icon,4,4,nil,40/m.icon:getWidth(),40/m.icon:getHeight())
            end
            GC.simpY(m.text,m.icon and 50 or 10,m.h/2)
            GC.pop()
        end
    end
end

function MES.traceback()
    local mes=
        debug.traceback('',1)
        :gsub(': in function',', in')
        :gsub(':',' ')
        :gsub('\t','')
    MES.new('error',mes:sub(
        mes:find("\n",2)+1,
        mes:find("\n%[C%], in 'xpcall'")
    ),5)
end

return MES
