if not getActivatedMods():contains("\\TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")
local AsyncTest = require("TestFramework/AsyncTest")

local TestHelper = require("InventoryTetris/Tests/TestHelper")

TestFramework.registerTestModule("Inventory Tetris", "Item Grid Window Tests", function ()
    local Tests = TestUtils.newTestModule("client/InventoryTetris/Tests/ItemGridWindowTests.lua")

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

    function Tests.test_createWindowManager()
        local windowManager = TetrisWindowManager:new(getPlayerInventory(0).inventoryPane, playerNum)
        TestUtils.assert(windowManager ~= nil)

        TestUtils.assert(windowManager.inventoryPane == getPlayerInventory(0).inventoryPane)
        TestUtils.assert(windowManager.playerNum == playerNum)
        TestUtils.assert(TetrisWindowManager._instances[windowManager] == true)

        TetrisWindowManager._instances[windowManager] = nil
    end

    function Tests.test_windowClosesOnDeath()
        ---@type TetrisWindowManager
        local windowManager = getPlayerInventory(0).inventoryPane.tetrisWindowManager
        TestUtils.assert(windowManager ~= nil)

        local player = getSpecificPlayer(0)

        return AsyncTest:new()
            :next(function()
                local containerGrid = TestHelper.createContainerGrid_5x5();
                local item = TestHelper.createItem_1x1(containerGrid.inventory);
                containerGrid:insertItem(item, 0, 0, firstGrid, false);

                -- Create a window
                local containerItem = containerGrid.inventory:getContainingItem()
                ---@cast containerItem InventoryContainer
                windowManager:openContainerPopup(containerItem)

                local window = windowManager:findWindowByInventory(containerGrid.inventory)
                TestUtils.assert(window ~= nil)
                TestUtils.assert(window:isVisible())

                TestUtils.assert(window:isRemoved() == false)
                windowManager:onPlayerDeath(player)
                TestUtils.assert(window:isRemoved() == true)
            end)
            :finally(function()
                if player:isDead() == false then
                    TetrisWindowManager._instances[windowManager] = true
                end
            end)
    end

    function Tests.test_closingParentWindowDoesNotOrphanChildWindow()
        local window = nil;
        local innerWindow = nil;
        
        return AsyncTest:new()
            :next(function()
                ---@type TetrisWindowManager
                local windowManager = getPlayerInventory(0).inventoryPane.tetrisWindowManager
                TestUtils.assert(windowManager ~= nil)

                local containerGrid = TestHelper.createContainerGrid_5x5();
                local innerContainerGrid = TestHelper.createContainerGrid_5x5();

                local item = innerContainerGrid.inventory:getContainingItem();
                containerGrid.inventory:addItem(item);
                local inserted = containerGrid:insertItem(item, 0, 0, firstGrid, false);

                TestUtils.assert(inserted)

                -- Create a window
                local containerItem = containerGrid.inventory:getContainingItem()
                ---@cast containerItem InventoryContainer
                windowManager:openContainerPopup(containerItem)

                window = windowManager:findWindowByInventory(containerGrid.inventory)

                -- Create a child window
                local innerContainerItem = innerContainerGrid.inventory:getContainingItem()
                ---@cast innerContainerItem InventoryContainer
                windowManager:openContainerPopup(innerContainerItem)

                innerWindow = windowManager:findWindowByInventory(innerContainerGrid.inventory)

                TestUtils.assert(window ~= nil)
                TestUtils.assert(innerWindow ~= nil)

                window:close();

                TestUtils.assert(windowManager:findWindowByInventory(containerGrid.inventory) == nil)
                TestUtils.assert(windowManager:findWindowByInventory(innerContainerGrid.inventory) ~= nil)
            end):finally(function()
                if window then
                    window:close()
                end
                if innerWindow then
                    innerWindow:close()
                end
            end)
    end

    function Tests.test_windowsNotVisibleInTheInventoryGetClosed()
        local window = nil;
        local innerWindow = nil;

        ---@type TetrisWindowManager
        local windowManager = getPlayerInventory(0).inventoryPane.tetrisWindowManager
        TestUtils.assert(windowManager ~= nil)

        local containerGrid = TestHelper.createContainerGrid_5x5();
        local innerContainerGrid = TestHelper.createContainerGrid_5x5();

        local item = innerContainerGrid.inventory:getContainingItem();
        containerGrid.inventory:addItem(item);
        local inserted = containerGrid:insertItem(item, 0, 0, firstGrid, false);

        TestUtils.assert(inserted)

        -- Create a window
        local containerItem = containerGrid.inventory:getContainingItem()
        ---@cast containerItem InventoryContainer
        windowManager:openContainerPopup(containerItem)

        window = windowManager:findWindowByInventory(containerGrid.inventory)

        -- Create a child window
        local innerContainerItem = innerContainerGrid.inventory:getContainingItem()
        ---@cast innerContainerItem InventoryContainer
        windowManager:openContainerPopup(innerContainerItem)

        innerWindow = windowManager:findWindowByInventory(innerContainerGrid.inventory)

        TestUtils.assert(window ~= nil)
        TestUtils.assert(innerWindow ~= nil)

        windowManager:closeIfInvalid(getPlayerInventory(0))

        TestUtils.assert(windowManager:findWindowByInventory(containerGrid.inventory) == nil)
        TestUtils.assert(windowManager:findWindowByInventory(innerContainerGrid.inventory) == nil)
    end

    function Tests.test_windowClosesIfItsParentNoLongerContainsIt()
        local window = nil;
        local innerWindow = nil;
        local innerInnerWindow = nil;

        local rootContainer = TestHelper.createContainerGrid_5x5().inventory;

        ---@type TetrisWindowManager
        local windowManager = getPlayerInventory(0).inventoryPane.tetrisWindowManager
        TestUtils.assert(windowManager ~= nil)

        local containerGrid = TestHelper.createContainerGrid_5x5();
        local innerContainerGrid = TestHelper.createContainerGrid_5x5();
        local innerInnerContainerGrid = TestHelper.createContainerGrid_5x5();

        local innerInnerItem = innerInnerContainerGrid.inventory:getContainingItem();
        innerContainerGrid.inventory:addItem(innerInnerItem);
        local inserted = innerContainerGrid:insertItem(innerInnerItem, 0, 0, firstGrid, false);
        TestUtils.assert(inserted)

        local innerItem = innerContainerGrid.inventory:getContainingItem();
        containerGrid.inventory:addItem(innerItem);
        local inserted = containerGrid:insertItem(innerItem, 0, 0, firstGrid, false);
        TestUtils.assert(inserted)

        rootContainer:addItem(containerGrid.inventory:getContainingItem());

        -- Create a window
        local containerItem = containerGrid.inventory:getContainingItem()
        ---@cast containerItem InventoryContainer
        windowManager:openContainerPopup(containerItem)
        window = windowManager:findWindowByInventory(containerGrid.inventory)

        -- Create a child window
        local innerContainerItem = innerContainerGrid.inventory:getContainingItem()
        ---@cast innerContainerItem InventoryContainer
        windowManager:openContainerPopup(innerContainerItem)
        innerWindow = windowManager:findWindowByInventory(innerContainerGrid.inventory)

        -- Create a child child window
        local innerInnerContainerItem = innerInnerContainerGrid.inventory:getContainingItem()
        ---@cast innerInnerContainerItem InventoryContainer
        windowManager:openContainerPopup(innerInnerContainerItem)
        innerInnerWindow = windowManager:findWindowByInventory(innerInnerContainerGrid.inventory)
        
        TestUtils.assert(window ~= nil)
        TestUtils.assert(innerWindow ~= nil)
        TestUtils.assert(innerInnerWindow ~= nil)

        for _, child in ipairs(windowManager.childWindows) do
            windowManager:closeIfMovedRecursive(child)
        end

        TestUtils.assert(windowManager:findWindowByInventory(containerGrid.inventory) ~= nil)
        TestUtils.assert(windowManager:findWindowByInventory(innerContainerGrid.inventory) ~= nil)
        TestUtils.assert(windowManager:findWindowByInventory(innerInnerContainerGrid.inventory) ~= nil)

        ---@diagnostic disable-next-line: param-type-mismatch
        containerGrid.inventory:Remove(innerItem)

        for _, child in ipairs(windowManager.childWindows) do
            windowManager:closeIfMovedRecursive(child)
        end

        TestUtils.assert(windowManager:findWindowByInventory(containerGrid.inventory) ~= nil)
        TestUtils.assert(windowManager:findWindowByInventory(innerContainerGrid.inventory) == nil)
        TestUtils.assert(windowManager:findWindowByInventory(innerInnerContainerGrid.inventory) == nil)

        windowManager:closeAll()
    end

    function Tests.test_TwoWindowManagersWhenPlayerIsAlive()
        local player = getSpecificPlayer(0)
        if player:isDead() then
            return
        end

        local count = 0
        for _, _ in pairs(TetrisWindowManager._instances) do
            count = count + 1
        end

        TestUtils.assert(count == 2)
    end

    function Tests.test_ZeroWindowManagersWhenPlayerIsDead()
        local player = getSpecificPlayer(0)
        if not player:isDead() then
            return
        end

        local count = 0
        for _, _ in pairs(TetrisWindowManager._instances) do
            count = count + 1
        end

        TestUtils.assert(count == 0)
    end

    TestFramework.addCodeCoverage(Tests, TetrisWindowManager, "TetrisWindowManager")
    return Tests
end)
