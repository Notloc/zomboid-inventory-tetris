if not getActivatedMods():contains("\\TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")
local AsyncTest = require("TestFramework/AsyncTest")

local TestHelper = require("InventoryTetris/Tests/TestHelper")

TestFramework.registerTestModule("Inventory Tetris", "Item Grid Tests", function ()
    local Tests = TestUtils.newTestModule("client/InventoryTetris/Tests/ItemGridTests.lua")

    function Tests._setup()
        TestHelper.applyDataPackOverrides()
        TestHelper.applySandboxOverrides(false, false, 10)
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

        containerGrid = TestHelper.createContainerGrid_2x2()
        item = TestHelper.createItem_1x3(containerGrid.inventory)

        inserted = containerGrid:insertItem(item, 0, 0, firstGrid, false)
        TestUtils.assert(not inserted)

        inserted = containerGrid:insertItem(item, 0, 0, firstGrid, true)
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

    function Tests.test_updateGridPositions_autoposition()
        local containerGrid = TestHelper.createContainerGrid_5x5()
        local grid = containerGrid.grids[firstGrid]

        local item1 = TestHelper.createItem_1x1(containerGrid.inventory)
        local item2 = TestHelper.createItem_1x1(containerGrid.inventory)
        local item3 = TestHelper.createItem_1x1(containerGrid.inventory)
        local item4 = TestHelper.createItem_1x1(containerGrid.inventory)
        local item5 = TestHelper.createItem_1x1(containerGrid.inventory)
        local item6 = TestHelper.createItem_2x2(containerGrid.inventory)

        containerGrid:_updateGridPositions()

        TestUtils.assert(containerGrid:findStackByItem(item1))
        TestUtils.assert(containerGrid:findStackByItem(item2))
        TestUtils.assert(containerGrid:findStackByItem(item3))
        TestUtils.assert(containerGrid:findStackByItem(item4))
        TestUtils.assert(containerGrid:findStackByItem(item5))
        TestUtils.assert(containerGrid:findStackByItem(item6))

        local stackableItem = TestHelper.createItem_1x1_stackable(containerGrid.inventory)

        containerGrid:_updateGridPositions()

        local stack = containerGrid:findStackByItem(stackableItem)
        TestUtils.assert(stack and stack.count == 1)

        local item = nil
        for i=1, 20 do
            item = TestHelper.createItem_1x1_stackable(containerGrid.inventory)
        end

        containerGrid:_updateGridPositions()

        local otherStack = containerGrid:findStackByItem(item)
        TestUtils.assert(otherStack and stack == otherStack)
        TestUtils.assert(otherStack and otherStack.count == 21)
    end

    function Tests.test_updateGridPositions_overflow()
        local containerGrid = TestHelper.createContainerGrid_2x2()
        local item = TestHelper.createItem_1x3(containerGrid.inventory)

        containerGrid:_updateGridPositions()
        TestUtils.assert(containerGrid:findStackByItem(item) == nil)

        TestUtils.assert(#containerGrid.overflow == 1)

        local overflowStack = containerGrid.overflow[1]
        TestUtils.assert(overflowStack and overflowStack.count == 1)
        TestUtils.assert(ItemStack.containsItem(overflowStack, item))
    end

    function Tests.test_willStackOverlapSelf()
        local containerGrid = TestHelper.createContainerGrid_5x5()
        local grid = containerGrid.grids[firstGrid]

        local item = TestHelper.createItem_1x1(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item, 0, 0, firstGrid, false))

        local stack = grid:getStack(0, 0, playerNum)
        local overlaps = grid:willStackOverlapSelf(stack, 0, 0)
        TestUtils.assert(overlaps)

        overlaps = grid:willStackOverlapSelf(stack, 1, 1)
        TestUtils.assert(not overlaps)

        grid:removeItem(item)

        item = TestHelper.createItem_2x2(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item, 1, 1, firstGrid, false))

        stack = grid:getStack(1, 1, playerNum)
        overlaps = grid:willStackOverlapSelf(stack, 1, 1)
        TestUtils.assert(overlaps)

        overlaps = grid:willStackOverlapSelf(stack, 2, 2)
        TestUtils.assert(overlaps)

        overlaps = grid:willStackOverlapSelf(stack, 3, 3)
        TestUtils.assert(not overlaps)

        overlaps = grid:willStackOverlapSelf(stack, 0, 0)
        TestUtils.assert(overlaps)

        grid:removeItem(item)

        local rotated = true
        local notRotated = false

        item = TestHelper.createItem_1x3(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item, 1, 0, firstGrid, notRotated))

        stack = grid:getStack(1, 0, playerNum)

        overlaps = grid:willStackOverlapSelf(stack, 1, 0, notRotated)
        TestUtils.assert(overlaps)

        overlaps = grid:willStackOverlapSelf(stack, 1, 0, rotated)
        TestUtils.assert(overlaps)

        overlaps = grid:willStackOverlapSelf(stack, 2, 0, notRotated)
        TestUtils.assert(not overlaps)

        overlaps = grid:willStackOverlapSelf(stack, 2, 0, rotated)
        TestUtils.assert(not overlaps)

        overlaps = grid:willStackOverlapSelf(stack, 0, 0, notRotated)
        TestUtils.assert(not overlaps)

        overlaps = grid:willStackOverlapSelf(stack, 0, 0, rotated)
        TestUtils.assert(overlaps)

        overlaps = grid:willStackOverlapSelf(stack, 0, 1, notRotated)
        TestUtils.assert(not overlaps)

        overlaps = grid:willStackOverlapSelf(stack, 0, 1, rotated)
        TestUtils.assert(overlaps)
    end

    function Tests.test_isEmpty()
        local containerGrid = TestHelper.createContainerGrid_5x5()
        local grid = containerGrid.grids[firstGrid]

        TestUtils.assert(grid:isEmpty())

        local item = TestHelper.createItem_1x1(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item, 0, 0, firstGrid, false))

        TestUtils.assert(not grid:isEmpty())

        grid:removeItem(item)

        TestUtils.assert(grid:isEmpty())
    end

    TestFramework.addCodeCoverage(Tests, ItemGrid, "ItemGrid")
    TestFramework.addCodeCoverage(Tests, ItemContainerGrid, "ItemContainerGrid")
    return Tests
end)
