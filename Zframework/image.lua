local IMG={}
function IMG.init(list)
    IMG.init=nil

    setmetatable(IMG,{__index=function(self,name)
        if type(list[name])=='table'then
            self[name]={}
            for i=1,#list[name]do
                self[name][i]=love.graphics.newImage(list[name][i])
            end
        elseif type(list[name])=='string'then
            self[name]=love.graphics.newImage(list[name])
        else
            LOG("No IMG: "..name)
            self[name]=PAPER
        end
        return self[name]
    end})

    function IMG.loadAll()
        for k in next,list do local _=IMG[k]end
        IMG.loadAll=nil
    end
end
return IMG
