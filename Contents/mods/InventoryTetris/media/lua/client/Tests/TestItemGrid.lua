if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")
local AsyncTest = require("TestFramework/AsyncTest")

TestFramework.registerTestModule("Inventory Tetris", "Item Grid Tests", function ()
    local Tests = {}
    TestFramework.addCodeCoverage(Tests, ItemGrid, "ItemGrid")

    Tests.create_grid = function ()
        local playerObj = getSpecificPlayer(0)
        local inv = playerObj:getInventory()
        local conntainerGrid =  ItemContainerGrid.Create(inv, 0)

        TestUtils.assert(conntainerGrid ~= nil)
        TestUtils.assert(conntainerGrid.inventory == inv)
        TestUtils.assert(conntainerGrid.containerDefinition)
    end

    -- Async test
    Tests.async_test_name = function ()
        return AsyncTest:new()
            :next(function ()
                TestUtils.assert(true)
            end)
    end

    return Tests
end)
