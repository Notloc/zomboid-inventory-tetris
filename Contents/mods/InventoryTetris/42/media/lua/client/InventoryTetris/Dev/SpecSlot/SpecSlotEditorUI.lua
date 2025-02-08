local Window = require("InventoryTetris/UI/Windows/Window")
local TextInputModal = require("InventoryTetris/UI/Modals/TextInputModal")
local SpecSlot = require("InventoryTetris/Model/SpecSlot")

---@class SpecSlotEditor : Window
---@field specSlotData table<string, SpecSlot>
local SpecSlotEditor = Window:derive("SpecSlotEditor")

---@param x number
---@param y number
---@return SpecSlotEditor
function SpecSlotEditor:new(x, y, specSlotData)
    local o = Window.new(self, x, y, 300, 300)
    o.title = "Spec Slot Editor"

    o.specSlotData = specSlotData

    ---@type SpecSlotEditor
    return o
end


function SpecSlotEditor:createChildren()
    Window.createChildren(self)

    local specSlotLabel = ISLabel:new(20, 20, 20, "Spec Slot:", 1, 1, 1, 1, nil, true)
    specSlotLabel:initialise()
    self:addChild(specSlotLabel)
    self.specSlotLabel = specSlotLabel

    local comboBox = ISComboBox:new(20, 40, 100, 20, self, SpecSlotEditor.onComboBoxChange)
    comboBox:initialise()
    self:addChild(comboBox)
    self.specSlotComboBox = comboBox

    self:repopulateComboBox()

    local addSpecSlotButton = ISButton:new(20, 70, 100, 20, "Add Spec Slot", self, SpecSlotEditor.onAddSpecSlotButton)
    addSpecSlotButton:initialise()
    self:addChild(addSpecSlotButton)
    self.addSpecSlotButton = addSpecSlotButton


end

function SpecSlotEditor:repopulateComboBox()
    self.specSlotComboBox:clear()
    for key, data in pairs(self.specSlotData) do
        self.specSlotComboBox:addOption(key)
    end
end

function SpecSlotEditor:onComboBoxChange()
    local selected = self.specSlotComboBox:getSelectedText()
    print("Selected: " .. selected)
end

function SpecSlotEditor:onAddSpecSlotButton()
    local modal = TextInputModal:new(0, 0, "Add New Spec Slot", "Enter the name of the new spec slot", self, SpecSlotEditor.addSpecSlot)
    modal:initialise()
    modal:addToUIManager()
end

function SpecSlotEditor:addSpecSlot(name)
    if self.specSlotData[name] then
        print("Error", "Spec Slot with name " .. name .. " already exists")
        return
    end

    self.specSlotData[name] = {

    }

    self:repopulateComboBox()
end

return SpecSlotEditor