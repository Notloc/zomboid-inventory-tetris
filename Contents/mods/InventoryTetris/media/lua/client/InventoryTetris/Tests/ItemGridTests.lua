if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")
local AsyncTest = require("TestFramework/AsyncTest")

local TestHelper = require("InventoryTetris/Tests/TestHelper")

TestFramework.registerTestModule("Inventory Tetris", "Item Grid Tests", function ()
    local Tests = {}

    function Tests._setup()
        TestHelper.applyDataPackOverrides()
    end

    function Tests._teardown()
        TestHelper.removeDataPackOverrides()
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

    function Tests.test_insertItem()
        local containerGrid = TestHelper.createContainerGrid_5x5()
        local item = TestHelper.createItem_1x1(containerGrid.inventory)

        local inserted = containerGrid:insertItem(item, 0, 0, firstGrid, false)
        TestUtils.assert(inserted)

        local stack = containerGrid.grids[1]:getStack(0, 0, playerNum)
        TestUtils.assert(stack and stack.count == 1)
        TestUtils.assert(ItemStack.containsItem(stack, item))

        item = TestHelper.createItem_1x1(containerGrid.inventory)

        inserted = containerGrid:insertItem(item, 4, 5, firstGrid, false)
        TestUtils.assert(not inserted)

        inserted = containerGrid:insertItem(item, 5, 4, firstGrid, false)
        TestUtils.assert(not inserted)
    end

    function Tests.test_removeItem()
        local containerGrid = TestHelper.createContainerGrid_5x5()
        local item = TestHelper.createItem_1x1(containerGrid.inventory)

        local inserted = containerGrid:insertItem(item, 0, 0, firstGrid, false)
        TestUtils.assert(inserted)

        local stack = containerGrid.grids[firstGrid]:getStack(0, 0, playerNum)
        TestUtils.assert(stack and stack.count == 1)
        TestUtils.assert(ItemStack.containsItem(stack, item))

        local removed = containerGrid:removeItem(item)
        TestUtils.assert(removed)

        stack = containerGrid.grids[firstGrid]:getStack(0, 0, playerNum)
        TestUtils.assert(stack == nil)

        removed = containerGrid:removeItem(item)
        TestUtils.assert(not removed)
    end

    function Tests.test_moveStack()
        local containerGrid = TestHelper.createContainerGrid_5x5()
        local grid = containerGrid.grids[firstGrid]

        local item = TestHelper.createItem_1x1(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item, 0, 0, firstGrid, false))

        local stack = grid:getStack(0, 0, playerNum)
        local moved = grid:moveStack(stack, 1, 1, false)
        TestUtils.assert(moved)

        local movedStack = grid:getStack(1, 1, playerNum)
        TestUtils.assert(movedStack == stack)

        moved = grid:moveStack(stack, 5, 5, false)
        TestUtils.assert(not moved)

        stack = grid:getStack(1, 1, playerNum)
        TestUtils.assert(stack == movedStack)
    end

    function Tests.test_findStackByItem()
        local containerGrid = TestHelper.createContainerGrid_5x5()
        local grid = containerGrid.grids[firstGrid]

        local item = TestHelper.createItem_1x1(containerGrid.inventory)

        local stack = grid:findStackByItem(item)
        TestUtils.assert(stack == nil)

        TestUtils.assert(containerGrid:insertItem(item, 0, 0, firstGrid, false))

        stack = grid:findStackByItem(item)
        TestUtils.assert(stack and ItemStack.containsItem(stack, item))
    end

    TestFramework.addCodeCoverage(Tests, ItemGrid, "ItemGrid")
    TestFramework.addCodeCoverage(Tests, ItemContainerGrid, "ItemContainerGrid")
    return Tests
end)
