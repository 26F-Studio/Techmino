local IMG={}
function IMG.init(list)
    IMG.init=nil

    setmetatable(IMG,{__index=function(self,name)
        if type(list[name])=='table' then
            self[name]={}
            for k,v in next,list[name] do
                self[name][k]=love.graphics.newImage(v)
            end
        elseif type(list[name])=='string' then
            self[name]=love.graphics.newImage(list[name])
        else
            LOG("No IMG: "..name)
            self[name]=PAPER
        end
        return self[name]
    end})

    function IMG.loadAll()
        for k in next,list do local _=IMG[k] end
        IMG.loadAll=nil
    end
end
return IMG
