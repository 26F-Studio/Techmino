local host=
    -- '127.0.0.1'
    -- '192.168.114.102'
    'game.techmino.org'
local port='10026'
local path='/tech/socket/v1'

-- lua + LÖVE threading websocket client
-- Original pure lua ver. by flaribbit and Particle_G
-- Threading version by MrZ

local type=type
local timer=love.timer.getTime
local CHN=love.thread.newChannel()
local CHN_getCount,CHN_push,CHN_pop=CHN.getCount,CHN.push,CHN.pop
local TRD=love.thread.newThread("\n")
local TRD_isRunning=TRD.isRunning

local WS={}
local wsList=setmetatable({},{
    __index=function(l,k)
        local ws={
            real=false,
            status='dead',
            lastPongTime=timer(),
            sendTimer=0,
            alertTimer=0,
            pongTimer=0,
        }
        l[k]=ws
        return ws
    end
})

function WS.switchHost(_1,_2,_3)
    for k in next,wsList do
        WS.close(k)
    end
    host=_1
    port=_2 or port
    path=_3 or path
end

function WS.connect(name,subPath,body,timeout)
    if wsList[name]and wsList[name].thread then
        wsList[name].thread:release()
    end
    local ws={
        real=true,
        thread=love.thread.newThread('Zframework/websocket_thread.lua'),
        triggerCHN=love.thread.newChannel(),
        sendCHN=love.thread.newChannel(),
        readCHN=love.thread.newChannel(),
        lastPingTime=0,
        lastPongTime=timer(),
        pingInterval=6,
        status='connecting',--'connecting', 'running', 'dead'
        sendTimer=0,
        alertTimer=0,
        pongTimer=0,
    }
    wsList[name]=ws
    ws.thread:start(ws.triggerCHN,ws.sendCHN,ws.readCHN)
    CHN_push(ws.sendCHN,host)
    CHN_push(ws.sendCHN,port)
    CHN_push(ws.sendCHN,path..subPath)
    CHN_push(ws.sendCHN,body or"")
    CHN_push(ws.sendCHN,timeout or 2.6)
end

function WS.status(name)
    local ws=wsList[name]
    return ws.status or'dead'
end

function WS.getTimers(name)
    local ws=wsList[name]
    return ws.pongTimer,ws.sendTimer,ws.alertTimer
end

function WS.setPingInterval(name,time)
    local ws=wsList[name]
    ws.pingInterval=math.max(time or 2.6,2.6)
end

function WS.alert(name)
    local ws=wsList[name]
    ws.alertTimer=2.6
end

local OPcode={
    continue=0,
    text=1,
    binary=2,
    close=8,
    ping=9,
    pong=10,
}
local OPname={
    [0]='continue',
    [1]='text',
    [2]='binary',
    [8]='close',
    [9]='ping',
    [10]='pong',
}
function WS.send(name,message,op)
    if type(message)=='string'then
        local ws=wsList[name]
        if ws.real and ws.status=='running'then
            CHN_push(ws.sendCHN,op and OPcode[op]or 2)--2=binary
            CHN_push(ws.sendCHN,message)
            ws.lastPingTime=timer()
            ws.sendTimer=1
        end
    else
        MES.new('error',"Attempt to send non-string value!")
        MES.traceback()
    end
end

function WS.read(name)
    local ws=wsList[name]
    if ws.real and ws.status~='connecting'and CHN_getCount(ws.readCHN)>=2 then
        local op,message=CHN_pop(ws.readCHN),CHN_pop(ws.readCHN)
        if op==8 then--8=close
            ws.status='dead'
        elseif op==9 then--9=ping
            WS.send(name,message or"",'pong')
        end
        ws.lastPongTime=timer()
        ws.pongTimer=1
        return message,OPname[op]or op
    end
end

function WS.close(name)
    local ws=wsList[name]
    if ws.real then
        CHN_push(ws.sendCHN,8)--close
        CHN_push(ws.sendCHN,"")
        ws.status='dead'
    end
end

function WS.update(dt)
    local time=timer()
    for name,ws in next,wsList do
        if ws.real and ws.status~='dead'then
            if TRD_isRunning(ws.thread)then
                if CHN_getCount(ws.triggerCHN)==0 then
                    CHN_push(ws.triggerCHN,0)
                end
                if ws.status=='connecting'then
                    local mes=CHN_pop(ws.readCHN)
                    if mes then
                        if mes=='success'then
                            ws.status='running'
                            ws.lastPingTime=time
                            ws.lastPongTime=time
                            ws.pongTimer=1
                        else
                            ws.status='dead'
                            MES.new('warn',text.wsFailed..": "..(mes=="timeout"and text.netTimeout or mes))
                        end
                    end
                elseif ws.status=='running'then
                    if time-ws.lastPingTime>ws.pingInterval then
                        WS.send(name,"",'pong')
                    end
                    if time-ws.lastPongTime>6+2*ws.pingInterval then
                        WS.close(name)
                    end
                end
                if ws.sendTimer>0 then ws.sendTimer=ws.sendTimer-dt end
                if ws.pongTimer>0 then ws.pongTimer=ws.pongTimer-dt end
                if ws.alertTimer>0 then ws.alertTimer=ws.alertTimer-dt end
            else
                ws.status='dead'
                local err=ws.thread:getError()
                if err then
                    err=err:sub((err:find(":",(err:find(":")or 0)+1)or 0)+1,(err:find("\n")or 0)-1)
                    MES.new('warn',text.wsClose..err)
                    WS.alert(name)
                end
            end
        end
    end
end

return WS
