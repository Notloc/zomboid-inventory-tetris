if not getActivatedMods():contains("\\TEST_FRAMEWORK") or not isDebugEnabled() then return end

local TestFramework = require("TestFramework/TestFramework")
TestFramework.registerFileForReload("client/InventoryTetris/Tests/TestHelper.lua")

local TestHelper = {}

TestHelper.playerNum = 0

TestHelper.containers = {
    ["2x2"] = {name="Base.Bag_FannyPackFront", x=2, y=2},
    ["5x5"] = {name="Base.Bag_Schoolbag", x=5, y=5},
    ["8x8"] = {name="Base.Bag_ALICEpack_Army", x=8, y=8},
}

TestHelper.items = {
    ["1x1"] = {name="Base.Bandage", x=1, y=1, stack=1},
    ["2x2"] = {name="Base.Pot", x=2, y=2, stack=1},
    ["1x3"] = {name="Base.BaseballBat", x=1, y=3, stack=1},
    ["1x1_s"] = {name="Base.Paperclip", x=1, y=1, stack=99},
}

TestHelper.devToolOverrideStack = {}

-- Overrides the data pack definitions with known values for testing
function TestHelper.applyDataPackOverrides()
    for _, data in pairs(TestHelper.containers) do
        local item = instanceItem(data.name)

        ---@cast item InventoryContainer
        local container = item:getItemContainer()
        local containerKey = TetrisContainerData._getContainerKey(container)

        TetrisContainerData._containerDefinitions[containerKey] = {
            gridDefinitions = {{
                size = {width = data.x, height = data.y},
                position = {x = 0, y = 0},
            }}
        }
    end

    for _, data in pairs(TestHelper.items) do
        local item = instanceItem(data.name)
        TetrisItemData._itemData[item:getFullType()] = {
            width = data.x,
            height = data.y,
            maxStackSize = data.stack,
        }
    end

    TestHelper.devToolOverrideStack[#TestHelper.devToolOverrideStack+1] = {
        disableItemOverrides = TetrisDevTool.disableItemOverrides,
        disableContainerOverrides = TetrisDevTool.disableContainerOverrides,
    }

    TetrisDevTool.disableItemOverrides = true
    TetrisDevTool.disableContainerOverrides = true
end

function TestHelper.removeDataPackOverrides()
    for _, data in pairs(TestHelper.containers) do
        local item = instanceItem(data.name)

        ---@cast item InventoryContainer
        local container = item:getItemContainer()
        local containerKey = TetrisContainerData._getContainerKey(container)

        TetrisContainerData._containerDefinitions[containerKey] = nil
    end

    for _, data in pairs(TestHelper.items) do
        local item = instanceItem(data.name)
        TetrisItemData._itemData[item:getFullType()] = nil
    end

    local overrides = TestHelper.devToolOverrideStack[#TestHelper.devToolOverrideStack]
    TestHelper.devToolOverrideStack[#TestHelper.devToolOverrideStack] = nil
    TetrisDevTool.disableItemOverrides = overrides.disableItemOverrides
    TetrisDevTool.disableContainerOverrides = overrides.disableContainerOverrides
end


TestHelper.sandboxOverrideStack = {}
function TestHelper.applySandboxOverrides(searchMode, gravityMode, searchTime)
    TestHelper.sandboxOverrideStack[#TestHelper.sandboxOverrideStack+1] = {
        searchMode = SandboxVars.InventoryTetris.EnableSearch,
        gravityMode = SandboxVars.InventoryTetris.EnableGravity,
        searchTime = SandboxVars.InventoryTetris.SearchTime,
    }

    SandboxVars.InventoryTetris.EnableSearch = searchMode
    SandboxVars.InventoryTetris.EnableGravity = gravityMode
    SandboxVars.InventoryTetris.SearchTime = searchTime
end

function TestHelper.removeSandboxOverrides()
    local overrides = TestHelper.sandboxOverrideStack[#TestHelper.sandboxOverrideStack]
    TestHelper.sandboxOverrideStack[#TestHelper.sandboxOverrideStack] = nil

    if not overrides then return end

    SandboxVars.InventoryTetris.EnableSearch = overrides.searchMode
    SandboxVars.InventoryTetris.EnableGravity = overrides.gravityMode
    SandboxVars.InventoryTetris.SearchTime = overrides.searchTime
end


---@return ItemContainerGrid
function TestHelper.createContainerGridFromItem(item)
    if type(item) == "string" then
        item = instanceItem(item)
    end

    local container = item:getItemContainer()
    local containerGrid =  ItemContainerGrid.CreateTemp(container, TestHelper.playerNum)
    return containerGrid
end

---@return ItemContainerGrid
function TestHelper.createContainerGrid_8x8()
    return TestHelper.createContainerGridFromItem(TestHelper.containers["8x8"].name)
end

---@return ItemContainerGrid
function TestHelper.createContainerGrid_5x5()
    return TestHelper.createContainerGridFromItem(TestHelper.containers["5x5"].name)
end

---@return ItemContainerGrid
function TestHelper.createContainerGrid_2x2()
    return TestHelper.createContainerGridFromItem(TestHelper.containers["2x2"].name)
end

---@return InventoryItem
function TestHelper.createItem_1x1(inventory)
    return inventory:AddItem(TestHelper.items["1x1"].name)
end

---@return InventoryItem
function TestHelper.createItem_2x2(inventory)
    return inventory:AddItem(TestHelper.items["2x2"].name)
end

---@return InventoryItem
function TestHelper.createItem_1x3(inventory)
    return inventory:AddItem(TestHelper.items["1x3"].name)
end

---@return InventoryItem
function TestHelper.createItem_1x1_stackable(inventory)
    return inventory:AddItem(TestHelper.items["1x1_s"].name)
end


function TestHelper.isTimedActionQueueEmpty(player)
    local actionQueue = ISTimedActionQueue.getTimedActionQueue(player)
    return #actionQueue.queue == 0 and not actionQueue.current
end

return TestHelper
