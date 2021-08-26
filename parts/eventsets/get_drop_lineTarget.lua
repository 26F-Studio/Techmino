return setmetatable({},{
    __index=function(self,k)
        assert(type(k)=='number'and k>0)
        self[k]=function(P)
            if P.stat.row>=k then
                P:win('finish')
            end
        end
        return self[k]
    end
})