local Spinner={
    data={},
    totalFreq=0,

    spinning=false,
    angle=0,
    angV=0,

    chosen=false,
    light=0,
}
Spinner.__index=Spinner
function Spinner:start()
    if not self.spinning then
        self.spinning=true
        self.angle=MATH.tau*math.random()
        self.angV=.62+.26*math.random()
        return true
    end
end
function Spinner:update(dt)
    if self.spinning then
        self.angle=(self.angle+self.angV*dt*60)%MATH.tau
        local dV=
        self.angV>.26 and .0026 or
        self.angV>.12 and .0012 or
        self.angV>.04 and .0004 or
        .0001
        self.angV=self.angV-dV*dt*60
        if self.angV<=0 then
            self.angV=0
            self.spinning=false
            local freq=self.angle%MATH.tau/MATH.tau*self.totalFreq
            for i=1,#self.data do
                local D=self.data[i]
                freq=freq-D.freq
                if freq<=0 then
                    self.chosen=D
                    self.light=1
                    if D.item then
                        self.hook_stop(D.item,D.amount)
                    end
                    break
                end
            end
        end
    else
        if self.light>0 then
            self.light=self.light-dt
        end
    end
end
function Spinner:draw(x,y)
    GC.push('transform')
    GC.translate(x,y)

    -- Draw circle
    GC.setColor(1,1,1)
    GC.setLineWidth(3)
    GC.circle('line',0,0,300)

    -- Draw areas
    GC.setLineWidth(1)
    local freq=0
    for i=1,#self.data do
        GC.line(10,0,290,0)
        local D=self.data[i]
        freq=freq+D.freq
        if D==self.chosen then
            GC.setColor(1,1,1,.5*self.light)
            GC.arc('fill','pie',0,0,300,0,-D.freq*MATH.tau/self.totalFreq)
            GC.setColor(1,1,1)
        end
        local dAng=-MATH.tau*D.freq/self.totalFreq
        GC.rotate(dAng*.5)
        if D.amount>0 then
            setFont(D.font)
            if D.amount==1 then
                GC.mStr(D.disp,170,-D.font*.7)
            else
                GC.mStr(D.disp.."x"..D.amount,170,-D.font*.7)
            end
        end
        GC.rotate(dAng*.5)
    end

    GC.pop()

    -- Draw target pin
    GC.setLineWidth(2)
    GC.setColor(1,.3,.3)
    GC.line(x,y,x+200*math.cos(self.angle),y-200*math.sin(self.angle))
end
function Spinner.new(data,hook_stop)
    local self={}
    setmetatable(self,Spinner)

    local sum=0
    for i=1,#data do
        sum=sum+data[i].freq
        if not data[i].font then data[i].font=30 end
    end
    self.data=data
    self.totalFreq=sum
    self.hook_stop=hook_stop

    return self
end

return Spinner