if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")
local AsyncTest = require("TestFramework/AsyncTest")

local TestHelper = require("InventoryTetris/Tests/TestHelper")

TestFramework.registerTestModule("Inventory Tetris", "Item Grid Gravity Tests", function ()
    local Tests = {}

    function Tests._setup()
        TestHelper.applyDataPackOverrides()
        TestHelper.applySandboxOverrides(false, true)
    end

    function Tests._teardown()
        TestHelper.removeDataPackOverrides()
        TestHelper.removeSandboxOverrides()
    end


    local playerNum = 0
    local firstGrid = 1

    function Tests.test_createGrid()
        local playerObj = getSpecificPlayer(0)
        local inv = playerObj:getInventory()
        local containerGrid =  ItemContainerGrid.Create(inv, playerNum)

        TestUtils.assert(containerGrid ~= nil)
        TestUtils.assert(containerGrid.inventory == inv)
        TestUtils.assert(containerGrid.containerDefinition)
    end

    function Tests.test_stacksFall()
        local containerGrid = TestHelper.createContainerGrid_5x5()
        local grid = containerGrid.grids[1]

        local item = TestHelper.createItem_1x1(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item, 0, 0, firstGrid, false))

        local item2 = TestHelper.createItem_1x1(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item2, 1, 0, firstGrid, false))

        local item3 = TestHelper.createItem_1x1(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item3, 2, 0, firstGrid, false))

        local item4 = TestHelper.createItem_1x1(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item4, 3, 0, firstGrid, false))

        TestUtils.assert(grid:getStack(0, 0, playerNum))
        TestUtils.assert(grid:getStack(1, 0, playerNum))
        TestUtils.assert(grid:getStack(2, 0, playerNum))
        TestUtils.assert(grid:getStack(3, 0, playerNum))

        containerGrid.lastPhysics = nil -- Force a refresh without waiting for the next tick
        containerGrid:refresh()

        TestUtils.assert(grid:getStack(0, 0, playerNum) == nil)
        TestUtils.assert(grid:getStack(0, 1, playerNum))
    end

    TestFramework.addCodeCoverage(Tests, ItemGrid, "ItemGrid")
    TestFramework.addCodeCoverage(Tests, ItemContainerGrid, "ItemContainerGrid")
    return Tests
end)
