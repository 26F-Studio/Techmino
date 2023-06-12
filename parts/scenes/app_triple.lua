local gc=love.graphics
local setColor,rectangle=gc.setColor,gc.rectangle

local int,rnd=math.floor,math.random
local ins,rem=table.insert,table.remove

local setFont,mStr=FONT.set,GC.mStr

local tileColor={
    [-2]=COLOR.R,  -- Bomb
    [-1]=COLOR.H,   -- Stone
    {.39, 1.0, .39},-- Tile 1
    {.39, .39, 1.0},-- Tile 2
    {1.0, .70, .31},-- Tile 3
    {.94, .31, .31},-- Tile 4
    {.00, .71, .12},-- Tile 5
    {.90, .20, .90},-- Tile 6
    {.94, .47, .39},-- Tile 7
    {.90, .00, .00},-- Tile 8
    {.86, .86, .31},-- Tile 9
    {.78, .31, .00},-- Tile 10
    {.78, .55, .04},-- Tile 11
    {.12, .12, .51},-- Tile 12
}
local textColor={
    [-2]=COLOR.dR,
    [-1]=COLOR.dH,
    {.26, .66, .26},
    {.26, .26, .66},
    {.66, .46, .20},
    {.62, .20, .20},
    {.00, .48, .08},
    {.60, .14, .60},
    {.62, .32, .26},
    {.60, .00, .00},
    {.58, .58, .20},
    {.52, .20, .00},
    {.52, .36, .20},
    {.08, .80, .34},
}
local tileTexts=setmetatable({
    [-2]="B",
    [-1]="×",
},{__index=function(self,k) self[k]=k return k end})

local player={x=340,y=90}

function player:newTile()
    local r=rnd()
    if r<.006 then
        return self.maxTile
    elseif r<.026 then
        return -2
    else
        local t=1
        if rnd()<.3 then
            t=t+1
            if rnd()<.3 then t=t+1 end
        end
        if self.maxTile>=4 and rnd()<.3 then
            t=t+1
            if self.maxTile>=6 and rnd()<.3 then
                t=t+1
                if self.maxTile>=8 and rnd()<.3 then
                    t=t+1
                end
            end
        end
        return t
    end
end

function player:reset()
    self.progress={}
    self.state=0
    self.time=0
    self.startTime=false
    self.score=0
    self.maxTile=3

    self.nexts,self.hold={self:newTile(),self:newTile(),self:newTile()},false
    self.selectX,self.selectY=false,false
    self.board={}
    for y=1,6 do
        self.board[y]={}
        for x=1,6 do
            self.board[y][x]=0
        end
    end
    self.board[1][1]=false
    for _,n in next,{-1,-1,1,1,2,2,3,3} do
        local x,y
        repeat
            x,y=rnd(6),rnd(6)
        until not (x==1 and y==1) and self.board[y][x]==0
        self.board[y][x]=n
    end
end

function player:merge(b,v,y,x)
    if b[y] and v==b[y][x] then
        ins(self.mergedTiles,{y,x})
        b[y][x]=0
        return 1
        +self:merge(b,v,y,x-1)
        +self:merge(b,v,y,x+1)
        +self:merge(b,v,y-1,x)
        +self:merge(b,v,y+1,x)
    else
        return 0
    end
end

local function availablePos(b,t)
    return
        t>0 and b==0 or
        t==-2 and b~=0
end
local function newMergeFX(y,x,tile)
    local r,g,b
    if tile==-2 then r,g,b=1,.6,.3 end
    SYSFX.newShade(3,player.x+100*x-100,player.y+100*y-100,100,100,r,g,b)
end
function player:click(y,x)
    if y==1 and x==1 then
        self.nexts[1],self.hold=self.hold,self.nexts[1]
        SFX.play('hold')
        if not self.nexts[1] then
            rem(self.nexts,1)
            ins(self.nexts,self:newTile())
        end
    elseif y~=self.selectY or x~=self.selectX then
        if availablePos(self.board[y][x],self.nexts[1]) then
            self.selectX,self.selectY=x,y
        else
            self.selectX,self.selectY=false,false
        end
    elseif y==self.selectY and x==self.selectX then
        if not availablePos(self.board[y][x],self.nexts[1]) then return end
        if self.state==0 then
            self.state=1
            self.startTime=TIME()
        end

        if self.nexts[1]==-2 then
            self.board[y][x]=0
            SFX.play('clear_2')
            rem(self.nexts,1)
            ins(self.nexts,self:newTile())
            newMergeFX(y,x,-2)
        else
            self.board[y][x]=rem(self.nexts,1)
            SFX.play('touch')

            local merged
            repeat-- ::REPEAT_merge::
                local repeating
                local cur=self.board[y][x]
                local b1=TABLE.shift(self.board)
                self.mergedTiles={}
                local count=self:merge(b1,cur,y,x)
                if count>2 then
                    merged=true
                    self.board=b1
                    b1[y][x]=cur+1

                    if cur+1>self.maxTile then
                        self.maxTile=cur+1
                        if self.maxTile>=6 then
                            ins(self.progress,("%s - %.3fs"):format(self.maxTile,TIME()-player.startTime))
                        end
                        SFX.play('reach')
                    end

                    local getScore=4^cur*count
                    self.score=self.score+getScore
                    TEXT.show(getScore,player.x+self.selectX*100-50,player.y+self.selectY*100-50,40,'score',1.626/math.log(getScore,3))
                    for i=1,#self.mergedTiles do
                        newMergeFX(self.mergedTiles[i][1],self.mergedTiles[i][2],cur+1)
                    end
                    repeating=true-- goto REPEAT_merge
                end
            until not repeating

            ins(self.nexts,self:newTile())

            self.selectX,self.selectY=false,false

            if merged then
                SFX.play('lock')
                if cur>=4 then
                    SFX.play(
                        cur>=8 and 'ren_mega' or
                        cur>=7 and 'spin_3' or
                        cur>=6 and 'spin_2' or
                        cur>=5 and 'spin_1' or
                        'spin_0'
                    )
                end
            else
                for i=1,6 do
                    if TABLE.find(self.board[i],0) then
                        return
                    end
                end
                self.state=2
                SFX.play('fail')
            end
        end
    else
        self.selectX,self.selectY=x,y
    end
end

local function drawTile(x,y,v)
    if v and v~=0 then
        setColor(tileColor[v])
        rectangle('fill',x*100-100,y*100-100,100,100)
        setColor(textColor[v])
        mStr(tileTexts[v],x*100-50,y*100-92)
    end
end
function player:drawBoard()
    gc.push('transform')
    gc.translate(self.x,self.y)

    -- Board background
    setColor(COLOR.dX)
    rectangle("fill",0,0,600,600)


    -- Hold slot
    setColor(0,1,1,.4)
    rectangle("fill",0,0,100,100)
    gc.setLineWidth(10)
    setColor(COLOR.lC)
    rectangle("line",5,5,90,90)

    -- Hold tile
    setFont(60)
    drawTile(1,1,self.hold)

    -- Board tiles
    local b=self.board
    for y=1,6 do for x=1,6 do
        drawTile(x,y,b[y][x])
    end end

    -- Board lines
    setColor(COLOR.Z)
    gc.setLineWidth(2)
    for x=1,5 do gc.line(x*100,0,x*100,600) end
    for y=1,5 do gc.line(0,y*100,600,y*100) end
    gc.setLineWidth(6)
    rectangle("line",0,0,600,600)

    -- Select box
    if self.selectX then
        local c=tileColor[self.nexts[1]]
        setColor(c[1],c[2],c[3],.6+.3*math.sin(TIME()*9.29))
        rectangle("line",self.selectX*100-95,self.selectY*100-95,90,90)
    end

    gc.pop()
end

local scene={}

function scene.enter()
    player:reset()
    BGM.play('truth')
end

function scene.mouseClick(x,y)
    x,y=int((x-player.x)/100)+1,int((y-player.y)/100)+1
    if x>=1 and x<=6 and y>=1 and y<=6 then
        player:click(y,x)
    end
end
function scene.touchClick(x,y)
    scene.mouseClick(x,y)
end
function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='up' or key=='down' or key=='left' or key=='right' then
        if not player.selectX then
            player.selectX,player.selectY=3,3
        else
            if key=='up' then player.selectY=math.max(player.selectY-1,1)
            elseif key=='down' then player.selectY=math.min(player.selectY+1,6)
            elseif key=='left' then player.selectX=math.max(player.selectX-1,1)
            elseif key=='right' then player.selectX=math.min(player.selectX+1,6)
            end
        end
    elseif key=='x' or key=='space' then
        if not player.selectX then
            player.selectX,player.selectY=3,3
        else
            local y,x=player.selectY,player.selectX
            player:click(player.selectY,player.selectX)
            player.selectY,player.selectX=y,x
        end
    elseif key=='w' then
        love.mousepressed(love.mouse.getPosition())
    elseif key=='z' or key=='q' then
        player:click(1,1)
    elseif key=='r' then
        if player.state~=1 or tryReset() then
            player:reset()
        end
    elseif key=='escape' then
        if tryBack() then
            SCN.back()
        end
    end
end

function scene.update()
    if player.state==1 then
        player.time=TIME()-player.startTime
    end
end

function scene.draw()
    setFont(40)
    setColor(1,1,1)
    gc.print(("%.3f"):format(player.time),1026,50)
    gc.print(player.score,1026,100)

    -- Progress time list
    setFont(25)
    setColor(.7,.7,.7)
    for i=1,#player.progress do
        gc.print(player.progress[i],1000,140+30*i)
    end

    gc.push('transform')
    gc.translate(745,13)
    setColor(COLOR.Z)
    gc.setLineWidth(4)
    gc.rectangle("line",-5,-5,200,70)
    for i=1,3 do
        setColor(tileColor[player.nexts[i]])
        rectangle('fill',65*i-65,0,60,60)
        setFont(40)
        setColor(textColor[player.nexts[i]])
        mStr(player.nexts[i],65*i-35,0)
    end
    gc.pop()

    player:drawBoard()
end

scene.widgetList={
    WIDGET.newButton{name='reset',x=160,y=100,w=180,h=100,color='lG',font=50,fText=CHAR.icon.retry_spin,code=pressKey'r'},
    WIDGET.newButton{name='back', x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}
return scene
