ItemGridTransferUtil = {}

local function removeItemOnCharacter(character, item)
	character:removeAttachedItem(item)
	if not character:isEquipped(item) then 
        return true 
    end
	local addToWorld = character:removeFromHands(item)
	character:removeWornItem(item, false)
	triggerEvent("OnClothingUpdated", character)
	return addToWorld;
end

local function isWorldItem(srcContainer, item)
    return srcContainer:getType() == "floor" and item:getWorldItem() ~= nil
end

local function handleRadio(srcContainer, item)
    if instanceof(item, "Radio") then
        local square = item:getWorldItem():getSquare()
        local _obj = nil
        for i=0, square:getObjects():size()-1 do
            local tObj = square:getObjects():get(i)
            if instanceof(tObj, "IsoRadio") then
                if tObj:getModData().RadioItemID == item:getID() then
                    _obj = tObj
                    break
                end
            end
        end
        if _obj ~= nil then
            local deviceData = _obj:getDeviceData();
            if deviceData then
                item:setDeviceData(deviceData);
            end
            square:transmitRemoveItemFromSquare(_obj)
            square:RecalcProperties();
            square:RecalcAllWithNeighbours(true);
        end
    end
end

local function stopTheMicrowave(srcContainer, destContainer)
    if destContainer:getType() == "microwave" and destContainer:getParent() and destContainer:getParent():Activated() then
        destContainer:getParent():setActivated(false);
    end
    if srcContainer:getType() == "microwave" and srcContainer:getParent() and srcContainer:getParent():Activated() then
        srcContainer:getParent():setActivated(false);
    end
end

function ItemGridTransferUtil.shouldUseGridTransfer(sourceGrid, destinationGrid)
    if not sourceGrid or not destinationGrid then
		return false;
    end

    local srcContainer = sourceGrid.inventory
    local destContainer = destinationGrid.inventory

    if srcContainer:getType() == "TradeUI" or destContainer:getType() == "TradeUI" then
        return false
    end
    if destContainer:getType() == "floor" then
        return false
    end

    return true
end

function ItemGridTransferUtil.isTransferValid(item, sourceGridUi, destinationGridUi, character, rotate)
	if not item or not sourceGridUi or not destinationGridUi or not character then
		return false;
    end

    local srcContainer = sourceGridUi.grid.inventory
    local destContainer = destinationGridUi.grid.inventory

	if not destContainer:isExistYet() or not srcContainer:isExistYet() then
		return false
	end

    if srcContainer:getType() == "TradeUI" or destContainer:getType() == "TradeUI" then
        print("Error: TradeUI transfers should be done by the vanilla ISInventoryTransferAction")
        return false
    end
    if destContainer:getType() == "floor" then
        print("Error: Transfers to the floor should be done by the vanilla ISInventoryTransferAction")
        return false
    end

	local parent = srcContainer:getParent()
	-- Duplication exploit: drag items from a corpse to another container while pickup up the corpse.
	-- ItemContainer:isExistYet() would detect this if SystemDisabler.doWorldSyncEnable was true.
	if instanceof(parent, "IsoDeadBody") and parent:getStaticMovingObjectIndex() == -1 then
		return false
	end

	-- Transfer already happened?
	if destContainer:contains(item) or not srcContainer:contains(item) then
		return false
	end

    -- TODO: MP item limit???
        -- The grid system kind of removes the need enforce a limit on the number of items in a container.
        -- Assuming we don't allow TARDIS containers to contain other TARDIS containers
        -- So we'll leave it out for now.

    if ISTradingUI.instance and ISTradingUI.instance:isVisible() then
        return false;
	end

    if srcContainer == destContainer then 
        return false
    end

    if not destContainer:hasRoomFor(character, item) then
        return false;
    end

    if not srcContainer:isRemoveItemAllowed(item) then
        return false;
    end
    if not destContainer:isItemAllowed(item) then
        return false;
    end

	local x, y = ItemGridUiUtil.findGridPositionOfMouse(destinationGridUi, item, rotate)
	if not ItemGridUtil.isGridPositionValid(destinationGridUi.grid, x, y) then
		return false
	end

	if not destinationGridUi.grid:doesItemFit(item, x, y, rotate) then
		return false
	end

	return item:getContainer() == srcContainer and not destContainer:isInside(item)
end

function ItemGridTransferUtil.transferGridItemMouse(item, sourceGridUi, destinationGridUi, character, rotate)
	if not ItemGridTransferUtil.isTransferValid(item, sourceGridUi, destinationGridUi, character, rotate) then
		return
	end

    local srcContainer = sourceGridUi.grid.inventory
    local destContainer = destinationGridUi.grid.inventory

    -- Validate the transfer (AGAIN), not sure if this works properly without the delay of a timed action
    createItemTransaction(item, srcContainer, destContainer)
	if not isItemTransactionConsistent(item, srcContainer, destContainer) then
		return
	end
    removeItemTransaction(item, srcContainer, destContainer)
    --

    -- Perform the transfer server-side
	if isClient() and not destContainer:isInCharacterInventory(character) then
		destContainer:addItemOnServer(item);
	end
	if isClient() and not srcContainer:isInCharacterInventory(character) then
		srcContainer:removeItemOnServer(item);
	end

    -- Remove the item from the source container
	srcContainer:DoRemoveItem(item);
	srcContainer:setDrawDirty(true);
	srcContainer:setHasBeenLooted(true);

    -- Add the item to the destination container
    -- Handle special cases such as world items, radios, etc.
	destContainer:setDrawDirty(true);
	if isWorldItem(srcContainer, item) then
		handleRadio(srcContainer, item)
		item:getWorldItem():getSquare():transmitRemoveItemFromSquare(item:getWorldItem());
		item:getWorldItem():getSquare():removeWorldObject(item:getWorldItem());
		item:setWorldItem(nil);
		destContainer:AddItem(item);
	else
		destContainer:AddItem(item);

		if character:getInventory() ~= destContainer then
			removeItemOnCharacter(character, item);
		end

		if item:getType() == "CandleLit" then
			local candle = destContainer:AddItem("Base.Candle");
			candle:setUsedDelta(item:getUsedDelta());
			candle:setCondition(item:getCondition());
			candle:setFavorite(item:isFavorite());
			destContainer:Remove(item)
			item = candle;
		end
	end

    stopTheMicrowave(srcContainer, destContainer)

	if destContainer:getParent() and instanceof(destContainer:getParent(), "BaseVehicle") and destContainer:getParent():getPartById(destContainer:getType()) then
		local part = destContainer:getParent():getPartById(destContainer:getType());
		part:setContainerContentAmount(part:getItemContainer():getCapacityWeight());
	end

	if srcContainer:getParent() and instanceof(srcContainer:getParent(), "BaseVehicle") and srcContainer:getParent():getPartById(srcContainer:getType()) then
		local part = srcContainer:getParent():getPartById(srcContainer:getType());
		part:setContainerContentAmount(part:getItemContainer():getCapacityWeight());
	end

	if instanceof(srcContainer:getParent(), "IsoDeadBody") then
		item:setAttachedSlot(-1);
		item:setAttachedSlotType(nil);
		item:setAttachedToModel(nil);
	end

	if instanceof(destContainer:getParent(), 'IsoMannequin') then
		local mannequin = destContainer:getParent()
		mannequin:wearItem(item, character)
	end
	
	-- Hack for giving cooking XP.
	if instanceof(item, "Food") then
		item:setChef(character:getFullName())
	end
	if destContainer:getType() == "stonefurnace" then
		item:setWorker(character:getFullName());
	end
	
	sourceGridUi.grid:removeItemFromGrid(item)
	
	if rotate then 
		ItemGridUtil.rotateItem(item)
	end
	local x, y = ItemGridUiUtil.findGridPositionOfMouse(destinationGridUi, item)
	destinationGridUi.grid:insertItemIntoGrid(item, x, y)

	ISInventoryPage.renderDirty = true

	-- do the overlay sprite
	if not isClient() then
		if srcContainer:getParent() and srcContainer:getParent():getOverlaySprite() then
			ItemPicker.updateOverlaySprite(srcContainer:getParent())
		end
		if destContainer:getParent() then
			ItemPicker.updateOverlaySprite(destContainer:getParent())
		end
	end
end

function ItemGridTransferUtil.moveGridItemMouse(item, sourceGridUi, destinationGridUi, rotate)
	local x, y = ItemGridUiUtil.findGridPositionOfMouse(destinationGridUi, item, rotate)
	if not ItemGridUtil.isGridPositionValid(destinationGridUi, x, y) then
		return
	end

	local originalX, originalY = ItemGridUtil.getItemPosition(item)

	sourceGridUi.grid:removeItemFromGrid(item)

	if rotate then
		ItemGridUtil.rotateItem(item)
	end
	if not destinationGridUi.grid:doesItemFit(item, x, y) then
		if rotate then
			ItemGridUtil.rotateItem(item)
		end
		sourceGridUi.grid:insertItemIntoGrid(item, originalX, originalY)
	else
		destinationGridUi.grid:insertItemIntoGrid(item, x, y)
	end
end
