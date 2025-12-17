local og_canPutIn = ISInventoryPage.canPutIn

---@diagnostic disable-next-line: duplicate-set-field
function ISInventoryPage:canPutIn()
    if SandboxVars.InventoryTetris.EnforceCarryWeight then
        return og_canPutIn(self)
    end

    local playerObj = getSpecificPlayer(self.player)
    local container = self.mouseOverButton and self.mouseOverButton.inventory or nil
    if not container then
        return false
    end
    local items = {}
    local minWeight = 100000
    local dragging = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
    for i,item in ipairs(dragging) do
        local itemOK = true
        if item:isFavorite() and not container:isInCharacterInventory(playerObj) then
            itemOK = false
        end
        if container:isInside(item) then
            itemOK = false
        end
        -- Change from vanilla: check capacity as well to ensure this is *actually* the floor
        if container:getType() == "floor" and container:getCapacity() == 50 and item:getWorldItem() then
            itemOK = false
        end
        if item:getContainer() == container then
            itemOK = false
        end
        if not container:isItemAllowed(item) then
            itemOK = false
        end
        if itemOK then
            table.insert(items, item)
        end
        if item:getUnequippedWeight() < minWeight then
            minWeight = item:getUnequippedWeight()
        end
    end
    if #items == 1 then
        return container:hasRoomFor(playerObj, items[1])
    elseif #items > 0 then
        return container:hasRoomFor(playerObj, minWeight)
    end
    return false
end