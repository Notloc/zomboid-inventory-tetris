TetrisDragUtil = {}

function TetrisDragUtil.getDraggedItem()
    -- Only return the item being dragged if it's the only item being dragged
    -- We can't render a list being dragged from the ground
    local itemStack = (ISMouseDrag.dragging and ISMouseDrag.dragStarted) and ISMouseDrag.dragging or nil
    return ItemGridUtil.convertItemStackToItem(itemStack)
end

function TetrisDragUtil.isDraggedItemRotated()
    return ISMouseDrag.rotateDrag
end

function TetrisDragUtil.isDragging()
    return ISMouseDrag.dragStarted and ISMouseDrag.dragging
end

function TetrisDragUtil.prepareDrag(owner, itemStack, x, y)
    ISMouseDrag.dragOwner = owner
    ISMouseDrag.itemStackToDrag = itemStack
    ISMouseDrag.localXStart = x;
    ISMouseDrag.localYStart = y;
    
    ISMouseDrag.rotateDrag = false
    ISMouseDrag.dragStarted = false
end

function TetrisDragUtil.startDrag(owner)
    if owner ~= ISMouseDrag.dragOwner then
        return
    end

    if not ISMouseDrag.dragStarted and ISMouseDrag.itemStackToDrag then
        local x = owner:getMouseX()
        local y = owner:getMouseY()

        local dragLimit = 8
        if math.abs(x - ISMouseDrag.localXStart) > dragLimit or math.abs(y - ISMouseDrag.localYStart) > dragLimit then
            ISMouseDrag.dragStarted = true
            ISMouseDrag.dragging = ISMouseDrag.itemStackToDrag
            ISMouseDrag.itemStackToDrag = nil
        end
    end
end

function TetrisDragUtil.endDrag()
    ISMouseDrag.itemStackToDrag = nil
	ISMouseDrag.dragging = nil;
    ISMouseDrag.dragStarted = false
end

function TetrisDragUtil.cancelDrag(owner)
    if owner ~= ISMouseDrag.dragOwner then
        return
    end
    TetrisDragUtil.endDrag()
end