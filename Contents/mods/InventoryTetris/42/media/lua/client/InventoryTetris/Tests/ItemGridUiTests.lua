if not getActivatedMods():contains("\\TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")
local AsyncTest = require("TestFramework/AsyncTest")

local TestHelper = require("InventoryTetris/Tests/TestHelper")
local OPT = require("InventoryTetris/Settings")

TestFramework.registerTestModule("Inventory Tetris", "Item Grid UI Tests", function ()
    local Tests = TestUtils.newTestModule("client/InventoryTetris/Tests/ItemGridUiTests.lua")

    function Tests._setup()
        TestHelper.applyDataPackOverrides()
        TestHelper.applySandboxOverrides(false, false, 45)
    end

    function Tests._teardown()
        TestHelper.removeDataPackOverrides()
        TestHelper.removeSandboxOverrides()

        DragAndDrop.endDrag()
    end


    local playerNum = 0
    local firstGrid = 1

    ---@return ItemGridContainerUI
    local function createContainerGridUi(container)
        local invPage = getPlayerLoot(playerNum).inventoryPane
        local containerGridUi = ItemGridContainerUI:new(container, invPage, playerNum)
        containerGridUi:initialise()
        return containerGridUi
    end

    local function gridToMouseCoord(gridX, gridY)
        local uiX = gridX * OPT.CELL_SIZE - gridX
        local uiY = gridY * OPT.CELL_SIZE - gridY
        return uiX + OPT.CELL_SIZE/2, uiY + OPT.CELL_SIZE/2
    end

    function Tests.test_createGridUi()
        local containerGridUi = createContainerGridUi(TestHelper.createContainerGrid_5x5().inventory)
        local containerGrid = containerGridUi.containerGrid

        TestUtils.assert(containerGridUi ~= nil)
        TestUtils.assert(containerGridUi.gridUis ~= nil and #containerGridUi.gridUis[containerGridUi.inventory])
    end

    function Tests.test_dragging()
        local containerGridUi = createContainerGridUi(TestHelper.createContainerGrid_5x5().inventory)
        local containerGrid = containerGridUi.containerGrid
        local gridUi = containerGridUi.gridUis[containerGridUi.inventory][1]
        local grid = gridUi.grid

        local item = TestHelper.createItem_1x1(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item, 0, 0, firstGrid, false))

        TestUtils.assert(not ISMouseDrag.dragging)

        gridUi:onMouseDown(gridToMouseCoord(0, 0))
        gridUi:onMouseMove(50,50)

        TestUtils.assert(ISMouseDrag.dragging)

        gridUi:onMouseUp(gridToMouseCoord(0, 0))

        TestUtils.assert(not ISMouseDrag.dragging)

        local stack = grid:getStack(0, 0, playerNum)
        TestUtils.assert(stack ~= nil)
        TestUtils.assert(ItemStack.containsItem(stack, item))
    end

    function Tests.test_draggingAndDrop_sameGrid()
        local containerGridUi = createContainerGridUi(TestHelper.createContainerGrid_5x5().inventory)
        local containerGrid = containerGridUi.containerGrid
        local gridUi = containerGridUi.gridUis[containerGridUi.inventory][1]
        local grid = gridUi.grid

        local item = TestHelper.createItem_1x1(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item, 0, 0, firstGrid, false))

        TestUtils.assert(not ISMouseDrag.dragging)

        gridUi:onMouseDown(gridToMouseCoord(0, 0))
        gridUi:onMouseMove(50,50)

        TestUtils.assert(ISMouseDrag.dragging)

        gridUi:onMouseUp(gridToMouseCoord(1, 1))

        TestUtils.assert(not ISMouseDrag.dragging)

        local stack = grid:getStack(1, 1, playerNum)
        TestUtils.assert(stack ~= nil)
        TestUtils.assert(ItemStack.containsItem(stack, item))

        stack = grid:getStack(0, 0, playerNum)
        TestUtils.assert(stack == nil)
    end

    function Tests.test_dragAndDropToStack_sameGrid()
        local containerGridUi = createContainerGridUi(TestHelper.createContainerGrid_5x5().inventory)
        local containerGrid = containerGridUi.containerGrid
        local gridUi = containerGridUi.gridUis[containerGridUi.inventory][1]
        local grid = gridUi.grid

        local item = TestHelper.createItem_1x1_stackable(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item, 0, 0, firstGrid, false))

        local item2 = TestHelper.createItem_1x1_stackable(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item2, 1, 1, firstGrid, false))

        TestUtils.assert(not ISMouseDrag.dragging)

        gridUi:onMouseDown(gridToMouseCoord(0, 0))
        gridUi:onMouseMove(50,50)

        TestUtils.assert(ISMouseDrag.dragging)

        gridUi:onMouseUp(gridToMouseCoord(1, 1))

        TestUtils.assert(not ISMouseDrag.dragging)

        local stack = grid:getStack(1, 1, playerNum)
        TestUtils.assert(stack ~= nil)
        TestUtils.assert(ItemStack.containsItem(stack, item))
        TestUtils.assert(ItemStack.containsItem(stack, item2))

        stack = grid:getStack(0, 0, playerNum)
        TestUtils.assert(stack == nil)
    end


    function Tests.test_dragAndDrop_differentContainers()
        local containerGridUi1 = createContainerGridUi(TestHelper.createContainerGrid_5x5().inventory)
        local containerGrid1 = containerGridUi1.containerGrid
        local gridUi1 = containerGridUi1.gridUis[containerGridUi1.inventory][1]
        local grid1 = gridUi1.grid

        local containerGridUi2 = createContainerGridUi(TestHelper.createContainerGrid_5x5().inventory)
        local containerGrid2 = containerGridUi2.containerGrid
        local gridUi2 = containerGridUi2.gridUis[containerGridUi2.inventory][1]

        local item = TestHelper.createItem_1x1(containerGrid1.inventory)
        TestUtils.assert(containerGrid1:insertItem(item, 0, 0, firstGrid, false))

        TestUtils.assert(not ISMouseDrag.dragging)

        gridUi1:onMouseDown(gridToMouseCoord(0, 0))
        gridUi1:onMouseMove(50,50)

        TestUtils.assert(ISMouseDrag.dragging)

        gridUi2:onMouseUp(gridToMouseCoord(1, 1))

        return AsyncTest:new()
            :repeatUntil(function()
                return TestHelper.isTimedActionQueueEmpty(getSpecificPlayer(playerNum))
            end)
            :next(function()
                TestUtils.assert(not ISMouseDrag.dragging)

                containerGrid2:refresh() -- refresh the grid to update the stack data

                local stack = gridUi2.grid:getStack(1, 1, playerNum)
                TestUtils.assert(stack ~= nil)
                TestUtils.assert(ItemStack.containsItem(stack, item))

                containerGrid1:refresh()
                stack = grid1:getStack(0, 0, playerNum)
                TestUtils.assert(stack == nil)
            end)
    end

    function Tests.test_render()
        local containerGridUi = createContainerGridUi(TestHelper.createContainerGrid_5x5().inventory)
        local containerGrid = containerGridUi.containerGrid

        local item = TestHelper.createItem_1x1(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item, 0, 0, firstGrid, false))

        item = TestHelper.createItem_1x1(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item, 1, 1, firstGrid, false))

        containerGridUi:addToUIManager()
        return AsyncTest.renderTest(containerGridUi):finally(function()
            containerGridUi:removeFromUIManager()
        end)
    end

    function Tests.test_prerender()
        local containerGridUi = createContainerGridUi(TestHelper.createContainerGrid_5x5().inventory)
        local containerGrid = containerGridUi.containerGrid

        local item = TestHelper.createItem_1x1(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item, 0, 0, firstGrid, false))

        item = TestHelper.createItem_1x1(containerGrid.inventory)
        TestUtils.assert(containerGrid:insertItem(item, 1, 1, firstGrid, false))

        containerGridUi:addToUIManager()
        return AsyncTest.prerenderTest(containerGridUi):finally(function()
            containerGridUi:removeFromUIManager()
        end)
    end

    TestFramework.addCodeCoverage(Tests, ItemGridUI, "ItemGridUI")
    TestFramework.addCodeCoverage(Tests, ItemGridContainerUI, "ItemGridContainerUI")
    TestFramework.addCodeCoverage(Tests, ISInventoryTransferAction, "InventoryTransferAction")
    return Tests
end)
