local ins=table.insert

local logs={os.date("Techmino logs  %Y/%m/%d %A")}

local function log(message)
    ins(logs,os.date("[%H:%M:%S] ")..message)
end

local LOG=setmetatable({logs=logs},{
    __call=function(_,message)
        print(message)
        log(message)
    end
})

function LOG.read()
    return table.concat(logs,"\n")
end

return LOG
