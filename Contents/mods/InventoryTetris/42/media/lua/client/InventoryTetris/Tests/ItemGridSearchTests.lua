if not getActivatedMods():contains("\\TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")
local AsyncTest = require("TestFramework/AsyncTest")

local TestHelper = require("InventoryTetris/Tests/TestHelper")

TestFramework.registerTestModule("Inventory Tetris", "Item Grid Search Tests", function ()
    local Tests = TestUtils.newTestModule("client/InventoryTetris/Tests/ItemGridSearchTests.lua")

    function Tests._setup()
        TestHelper.applyDataPackOverrides()
        TestHelper.applySandboxOverrides(true, false, 2)
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
        local containerGrid =  ItemContainerGrid.GetOrCreate(inv, playerNum)

        TestUtils.assert(containerGrid ~= nil)
        TestUtils.assert(containerGrid.inventory == inv)
        TestUtils.assert(containerGrid.containerDefinition)
    end

    function Tests.test_stacksAreHidden()
        local containerGrid = TestHelper.createContainerGrid_5x5()
        local item = TestHelper.createItem_1x1(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item, 0, 0, firstGrid, false))

        local stack = containerGrid.grids[1]:getStack(0, 0, playerNum)
        TestUtils.assert(stack == nil)

        stack = containerGrid.grids[1]:getStackInternal(0, 0)
        TestUtils.assert(stack and stack.count == 1)
        TestUtils.assert(ItemStack.containsItem(stack, item))
    end

    function Tests.test_searching()
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

        TestUtils.assert(grid:isUnsearched(playerNum))
        TestUtils.assert(grid:getStack(0, 0, playerNum) == nil)
        TestUtils.assert(grid:getStack(1, 0, playerNum) == nil)
        TestUtils.assert(grid:getStack(2, 0, playerNum) == nil)
        TestUtils.assert(grid:getStack(3, 0, playerNum) == nil)

        return AsyncTest:new()
            :next(function()
                local playerObj = getSpecificPlayer(playerNum)
                ISTimedActionQueue.add(SearchGridAction:new(playerObj, grid))
            end)
            :repeatUntil(function()
                return not grid:isUnsearched(playerNum)
            end)
            :next(function()
                TestUtils.assert(not grid:isUnsearched(playerNum))
                TestUtils.assert(grid:getStack(0, 0, playerNum) ~= nil)
                TestUtils.assert(grid:getStack(1, 0, playerNum) ~= nil)
                TestUtils.assert(grid:getStack(2, 0, playerNum) ~= nil)
                TestUtils.assert(grid:getStack(3, 0, playerNum) ~= nil)
            end)
    end

    TestFramework.addCodeCoverage(Tests, ItemGrid, "ItemGrid")
    TestFramework.addCodeCoverage(Tests, ItemContainerGrid, "ItemContainerGrid")
    return Tests
end)
