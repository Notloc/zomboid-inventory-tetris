require "InventoryTetris/Events"
require "InventoryTetris/ItemGrid/UI/Grid/ItemGridUI_rendering"
require "Notloc/NotUtil"

--ItemGridUI.registerItemHoverColor(TetrisItemCategory.AMMO, TetrisItemCategory.MAGAZINE, ItemGridUI.GENERIC_ACTION_COLOR)


local genericRecipeHandler = {}

genericRecipeHandler.validate = function(eventData, droppedStack, fromInventory, targetStack, targetInventory, playerNum)
    local playerObj = getSpecificPlayer(playerNum)
    if playerObj:isDriving() then return false end
    
    local targetItem = droppedStack.items[1]
    if targetItem:getType() == "Candle" then return false end -- Requires too much special handling, so we'll just ignore it for now


    local containerList = ISInventoryPaneContextMenu.getContainers(playerObj)
    local recipeList = RecipeManager.getUniqueRecipeItems(targetItem, playerObj, containerList);
    

    for i=0,recipeList:size() -1 do
        local recipe = recipeList:get(i)
        local numberOfTimes = RecipeManager.getNumberOfTimesRecipeCanBeDone(recipe, playerObj, containerList, selectedItem)
		local resultItem = InventoryItemFactory.CreateItem(recipe:getResult():getFullType());

        local recipeName = recipe:getName()
        local neededItems = recipe:getNumberOfNeededItem()

        if neededItems == 2 then
            return true
        end

        --local subOption = subMenuCraft:addOption(getText("ContextMenu_One"), targetItem, ISInventoryPaneContextMenu.OnCraft, recipe, playerNum, false);

        if false then
            local tooltip = CraftTooltip.addToolTip();
            tooltip.character = playerObj
            tooltip.recipe = recipe
            -- add it to our current option
            tooltip:setName(recipe:getName());
            if resultItem:getTexture() and resultItem:getTexture():getName() ~= "Question_On" then
                tooltip:setTexture(resultItem:getTexture():getName());
            end
            --subOption.toolTip = tooltip;

            
            -- limit doing a recipe that add multiple items if the dest container has an item limit
            if false and not ISInventoryPaneContextMenu.canAddManyItems(recipe, selectedItem, playerObj) then
                option.notAvailable = true;
                if subMenuCraft then
                    for i,v in ipairs(subMenuCraft.options) do
                        v.notAvailable = true;
                        local tooltip = ISInventoryPaneContextMenu.addToolTip();
                        tooltip.description = getText("Tooltip_CantCraftDriving"); -- FIXME: wrong translation
                        v.toolTip = tooltip;
                    end
                end
                local tooltip = ISInventoryPaneContextMenu.addToolTip();
                tooltip.description = getText("Tooltip_CantCraftDriving"); -- FIXME: wrong translation
                option.toolTip = tooltip;
                return;
            end
        end
	end



    return false
end


genericRecipeHandler.call = function(eventData, droppedStack, fromInventory, targetStack, targetInventory, playerNum)    
    local playerObj = getSpecificPlayer(playerNum)
    if playerObj:isDriving() then return false end
    
    local item1 = droppedStack.items[1]
    local item2 = targetStack.items[1]
    if item1:getType() == "Candle" or item2:getType() == "Candle" then return false end -- Requires too much special handling, so we'll just ignore it for now

    local containerList = ISInventoryPaneContextMenu.getContainers(playerObj)
    local recipeList1 = RecipeManager.getUniqueRecipeItems(item1, playerObj, containerList);
    local recipeList2 = RecipeManager.getUniqueRecipeItems(item2, playerObj, containerList);

    -- Find a recipe that uses both items 
    local recipe = nil
    local seenRecipes = {}
    for i=0,recipeList1:size()-1 do
        local testRecipe = recipeList1:get(i)
        local neededItems = testRecipe:getNumberOfNeededItem()
        if neededItems == 2 then
            seenRecipes[testRecipe] = true
        end
    end

    for i=0,recipeList2:size()-1 do
        local testRecipe = recipeList2:get(i)
        if seenRecipes[testRecipe] then
            recipe = testRecipe
            break
        end
    end

    if not recipe then
        return
    end

    local numberOfTimes = RecipeManager.getNumberOfTimesRecipeCanBeDone(recipe, playerObj, containerList, item1)
    local resultItemType = recipe:getResult():getFullType()

    -- Redetermine the target item, use the stack with the most presence in the target inventories to reduce the chance we use the wrong item.
    local item1Count = fromInventory:FindAll(item1:getType()):size()
    local item2Count = targetInventory:FindAll(item2:getType()):size()

    local targetItem = nil
    if item1Count == 1 and item1Count < item2Count then
        targetItem = item2
    else
        targetItem = item1
    end

    local fromContainerGrid = ItemContainerGrid.Create(fromInventory, playerNum)
    local targetContainerGrid = ItemContainerGrid.Create(targetInventory, playerNum)

    local canBeDoneFromFloor = recipe:isCanBeDoneFromFloor()
    if fromContainerGrid.isOnPlayer and targetContainerGrid.isOnPlayer then
        recipe:setCanBeDoneFromFloor(true)
    end
    ISInventoryPaneContextMenu.OnCraft(targetItem, recipe, playerNum, false)
    recipe:setCanBeDoneFromFloor(canBeDoneFromFloor)

    -- local stack, grid = nil, nil
    -- if resultItemType == item1:getFullType() then
    --     stack, grid = fromContainerGrid:findStackByItem(item1)
    -- elseif resultItemType == item2:getFullType() then
    --     stack, grid = targetContainerGrid:findStackByItem(item2)
    -- end

    -- if stack and grid then
    --     local action = ISInventoryTransferAction:new(playerObj, 
    --     action:setTetrisTarget(stack.x, stack.y, stack.gridIndex, stack.isRotated)
    --     action.tetrisPlaceAnywhere = true
    --     ISTimedActionQueue.add(action)
    -- end
end

TetrisEvents.OnStackDroppedOnStack:add(genericRecipeHandler)
