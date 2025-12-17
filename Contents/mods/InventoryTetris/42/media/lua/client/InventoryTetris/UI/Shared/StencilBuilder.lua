require("ISUI/ISUIElement");

--- Helps build stencil buffers for UI elements.
--- Insert the setupElement before the target elements for stenciling
--- Insert the teardownElement after the target elements to clear the stencil state.
--- @class StencilBuilder
--- @field public stencilWidth number
--- @field public stencilHeight number
--- @field public setupElement ISUIElement
--- @field public tearDownElement ISUIElement
local StencilBuilder = {}

---@param stencilWidth number
---@param stencilHeight number
---@return StencilBuilder
function StencilBuilder:new(stencilWidth, stencilHeight)
    ---@type StencilBuilder
    local o = {
        stencilWidth = stencilWidth,
        stencilHeight = stencilHeight,
        setupElement = ISUIElement:new(0, 0, 0, 0),
        tearDownElement = ISUIElement:new(0, 0, 0, 0),
    }

    o.setupElement.prerender = function(self) StencilBuilder._setup(self, o) end
    o.tearDownElement.prerender = function(self) StencilBuilder.teardown(self) end

    setmetatable(o, self);
    self.__index = self;

    return o;
end

function StencilBuilder._setup(uiElement, stencilBuilder)
    uiElement:setStencilRect(0, 0, stencilBuilder.stencilWidth, stencilBuilder.stencilHeight)
end

function StencilBuilder.teardown(uiElement)
    uiElement:clearStencilRect()
end

return StencilBuilder
