local BaseScope = {}

function BaseScope:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.instances = {}
    return o
end

function BaseScope:execute(callback, scopeInstance)
    if not scopeInstance then
        scopeInstance = {}
    end

    table.insert(self.instances, scopeInstance)
    local values = {pcall(callback)}
    table.remove(self.instances)

    local passed = table.remove(values, 1)
    if not passed then
        error(values[1])
    end
    return values
end

function BaseScope:getInstance()
    return self.instances[#self.instances]
end

function BaseScope:isActive()
    return #self.instances > 0
end

return BaseScope
