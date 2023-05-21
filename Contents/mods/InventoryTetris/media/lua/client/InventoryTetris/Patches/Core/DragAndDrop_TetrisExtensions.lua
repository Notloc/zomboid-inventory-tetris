require "EquipmentUI/DragAndDrop"

function DragAndDrop.isDraggedItemRotated()
    return ISMouseDrag.rotateDrag
end

function DragAndDrop.rotateDraggedItem()
    ISMouseDrag.rotateDrag = not ISMouseDrag.rotateDrag
end

local og_prepareDrag = DragAndDrop.prepareDrag
function DragAndDrop.prepareDrag(owner, vanillaStack, x, y)
    og_prepareDrag(owner, vanillaStack, x, y)
    ISMouseDrag.rotateDrag = vanillaStack.isRotated
end