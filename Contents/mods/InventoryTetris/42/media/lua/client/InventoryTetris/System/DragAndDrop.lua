-- Tracks the current drag and drop operation for keyboard and mouse players.
-- Main body of the class is part of the EquipmentUI mod.
---@class DragAndDrop
---@field convertItemStackToItem function
---@field startDrag function
---@field prepareDrag function
---@field isDragging function
---@field isDragOwner function
---@field cancelDrag function
---@field endDrag function
---@field getDraggedItem function
---@field convertItemToStack function
---@diagnostic disable-next-line: undefined-global
local DragAndDrop = require("EquipmentUI/DragAndDrop") or DragAndDrop -- Temp fix until EquipmentUI also removes its globals

function DragAndDrop.isDraggedItemRotated()
    return ISMouseDrag.rotateDrag
end

function DragAndDrop.rotateDraggedItem()
    ISMouseDrag.rotateDrag = not ISMouseDrag.rotateDrag
end

local og_prepareDrag = DragAndDrop.prepareDrag
function DragAndDrop.prepareDrag(owner, vanillaStacks, x, y)
    og_prepareDrag(owner, vanillaStacks, x, y)
    ISMouseDrag.rotateDrag = vanillaStacks[1] and vanillaStacks[1].isRotated or vanillaStacks.isRotated
end

function DragAndDrop.getDraggedStack()
    if not ISMouseDrag.dragging then
        return nil
    end

    if ISMouseDrag.dragging[1] then
        return ISMouseDrag.dragging[1]
    end

    return ISMouseDrag.dragging
end

function DragAndDrop.getDraggedStacks()
    return ISMouseDrag.dragging
end

return DragAndDrop
