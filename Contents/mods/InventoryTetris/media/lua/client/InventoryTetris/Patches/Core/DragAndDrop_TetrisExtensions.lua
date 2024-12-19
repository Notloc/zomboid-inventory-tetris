require "EquipmentUI/DragAndDrop"

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
