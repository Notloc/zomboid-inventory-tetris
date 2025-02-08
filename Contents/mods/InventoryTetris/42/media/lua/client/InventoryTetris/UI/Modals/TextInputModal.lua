local Window = require ("InventoryTetris/UI/Windows/Window")

---@class TextInputModal : Window
local TextInputModal = Window:derive("TextModal")

---@param x number
---@param y number
---@param title string
---@param description string
---@param target any
---@param onAccept any
---@param onCancel any
---@return TextInputModal
function TextInputModal:new(x, y, title, description, target, onAccept, onCancel)
    local o = Window.new(self, x, y, 300, 200)
    o.title = title
    o.description = description
    o.target = target
    o.onAccept = onAccept
    o.onCancel = onCancel

    ---@type TextInputModal
    return o
end

function TextInputModal:createChildren()
    Window.createChildren(self)

    local descriptionLabel = ISLabel:new(20, 20, 20, self.description, 1, 1, 1, 1, nil, true)
    descriptionLabel:initialise()
    self:addChild(descriptionLabel)
    self.descriptionLabel = descriptionLabel

    local textField = ISTextEntryBox:new("", 20, 40, 100, 20)
    textField:initialise()
    self:addChild(textField)
    self.textField = textField

    local acceptButton = ISButton:new(20, 70, 100, 20, "Accept", self, TextInputModal._onAccept)
    acceptButton:initialise()
    self:addChild(acceptButton)
    self.acceptButton = acceptButton

    local cancelButton = ISButton:new(20, 100, 100, 20, "Cancel", self, TextInputModal._onCancel)
    cancelButton:initialise()
    self:addChild(cancelButton)
    self.cancelButton = cancelButton
end

function TextInputModal:_onAccept()
    if self.onAccept then
        self.onAccept(self.target, self.textField:getText())
    end
    self:close()
end

function TextInputModal:_onCancel()
    if self.onCancel then
        self.onCancel(self.target)
    end
    self:close()
end

return TextInputModal
