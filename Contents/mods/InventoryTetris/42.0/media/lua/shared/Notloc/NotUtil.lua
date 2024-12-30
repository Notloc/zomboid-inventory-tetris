NotUtil = NotUtil or {}

function NotUtil.slice(tbl, start, stop)
    local sliced = {}
    for i = start, stop do
        table.insert(sliced, tbl[i])
    end
    return sliced
end

function NotUtil.toTruthMap(tbl)
    local truthMap = {}
    for _, value in pairs(tbl) do
        truthMap[value] = true
    end
    return truthMap
end



---@class SimpleEvent
---@field add fun(self:SimpleEvent, listener: function)
---@field remove fun(self:SimpleEvent, listener: function)
---@field trigger function
---@field private _listeners function[]

---@return SimpleEvent
function NotUtil.createSimpleEvent()
    local event = {}
    event._listeners = {}

    function event:add(func)
        table.insert(self._listeners, func)
    end

    function event:remove(func)
        table.remove(self._listeners, func)
    end

    function event:trigger(...)
        for _, func in ipairs(self._listeners) do
            func(...)
        end
    end

    return event
end



NotUtil.Ui = {}

---@param x number
---@param y number
---@param localSpace ISUIElement
---@param targetSpace ISUIElement
---@return number
---@return number
function NotUtil.Ui.convertCoordinates(x, y, localSpace, targetSpace)
    local x2 = x + localSpace:getAbsoluteX()
    local y2 = y + localSpace:getAbsoluteY()
    x2 = x2 - targetSpace:getAbsoluteX()
    y2 = y2 - targetSpace:getAbsoluteY()
    return x2, y2
end
