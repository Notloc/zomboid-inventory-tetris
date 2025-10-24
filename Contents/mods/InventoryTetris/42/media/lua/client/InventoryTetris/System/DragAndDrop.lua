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

-- Cleans out invalid entries
local function cleanDraggedStacks()
    if not ISMouseDrag.dragging then
        return
    end

    -- Clean single stack
    if ISMouseDrag.dragging.items then
        if not ISMouseDrag.dragging.items[1] then
            ISMouseDrag.dragging = nil
        end
        return
    end

    -- Clean multiple stacks
    for i = #ISMouseDrag.dragging, 1, -1 do
        if #ISMouseDrag.dragging[i].items == 0 then
            table.remove(ISMouseDrag.dragging, i)
        end
    end

    if #ISMouseDrag.dragging == 0 then
        ISMouseDrag.dragging = nil
    end
end

function DragAndDrop.getDraggedStack()
    if not ISMouseDrag.dragging then
        return nil
    end

    if ISMouseDrag.dragging[1] then
        return ISMouseDrag.dragging[1]
    end

    cleanDraggedStacks()
    return ISMouseDrag.dragging
end

function DragAndDrop.getDraggedStacks()
    cleanDraggedStacks()
    return ISMouseDrag.dragging
end

return DragAndDrop
