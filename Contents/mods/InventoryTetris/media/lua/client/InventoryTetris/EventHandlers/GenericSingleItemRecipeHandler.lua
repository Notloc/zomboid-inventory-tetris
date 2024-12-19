GenericSingleItemRecipeHandler = {}
GenericSingleItemRecipeHandler.call = function(eventData, stack, inventory, playerNum)    
    local playerObj = getSpecificPlayer(playerNum)
    if playerObj:isDriving() then return false end
    
    local item = stack.items[1]
    if not item then return false end

    if item:getType() == "Candle" then return false end -- Requires too much special handling, so we'll just ignore it for now

    local containerList = ISInventoryPaneContextMenu.getContainers(playerObj)
    local recipeList = RecipeManager.getUniqueRecipeItems(item, playerObj, containerList);

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

    local containerGrid = ItemContainerGrid.Create(inventory, playerNum)

    local canBeDoneFromFloor = recipe:isCanBeDoneFromFloor()
    if containerGrid.isOnPlayer then
        recipe:setCanBeDoneFromFloor(true)
    end
    ISInventoryPaneContextMenu.OnCraft(item, recipe, playerNum, false)
    recipe:setCanBeDoneFromFloor(canBeDoneFromFloor)

    return true
end