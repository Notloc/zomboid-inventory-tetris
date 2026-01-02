local ItemContainerGrid = require("InventoryTetris/Model/ItemContainerGrid")

local GenericSingleItemRecipeHandler = {}
function GenericSingleItemRecipeHandler.call(eventData, stack, inventory, playerNum)    
    local playerObj = getSpecificPlayer(playerNum)
    if playerObj:isDriving() then return false end

    local item = stack.items[1]
    if not item then return false end

    if item:getType() == "Candle" then return false end -- Requires too much special handling, so we'll just ignore it for now

    local containerList = ISInventoryPaneContextMenu.getContainers(playerObj)
    if not containerList then return false end
    
    local recipeList = RecipeManager.getUniqueRecipeItems(item, playerObj, containerList);

    ---@type Recipe[]
    local singleItemRecipes = {}

    for i=0,recipeList:size()-1 do
        local testRecipe = recipeList:get(i)
        local neededItems = testRecipe:getNumberOfNeededItem()
        if neededItems == 1 then
            table.insert(singleItemRecipes, testRecipe)
        end
    end

    if #singleItemRecipes ~= 1 then
        return false
    end

    local recipe = singleItemRecipes[1]

    local numberOfTimes = RecipeManager.getNumberOfTimesRecipeCanBeDone(recipe, playerObj, containerList, item)
    local resultItemType = recipe:getResult():getFullType()
    local containerGrid = ItemContainerGrid.GetOrCreate(inventory, playerNum)

    -- TODO: Patch to make more recipes succeed?

    ISInventoryPaneContextMenu.OnCraft(item, recipe, playerNum, false)
    return true
end

return GenericSingleItemRecipeHandler
