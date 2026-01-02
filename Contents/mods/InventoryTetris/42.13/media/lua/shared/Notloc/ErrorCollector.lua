---@class ErrorCollector
---@field errors string[]
local ErrorCollector = {}
ErrorCollector.__index = ErrorCollector

---@return ErrorCollector
function ErrorCollector:new()
    local o = setmetatable({}, self)
    o.errors = {}
    return o
end

function ErrorCollector:add(errorMessage)
    table.insert(self.errors, errorMessage)
end

function ErrorCollector:hasErrors()
    return #self.errors > 0
end

function ErrorCollector:goBoom()
    if not self:hasErrors() then
        return
    end

    for _, errorMessage in ipairs(self.errors) do
        pcall(function() error(errorMessage) end)
    end
end

return ErrorCollector
