-- Tracks the current drag and drop operation for controller players.
ControllerDragAndDrop = {}

ControllerDragAndDrop.dragging = {}
ControllerDragAndDrop.draggingTetris = {}
ControllerDragAndDrop.dragOwner = {}
ControllerDragAndDrop.rotateDrag = {}

ControllerDragAndDrop.ownersForCancel = {}

function ControllerDragAndDrop.isDragging(playerNum)
    return ControllerDragAndDrop.dragging[playerNum] ~= nil
end

function ControllerDragAndDrop.isDragOwner(playerNum, testOwner)
    return ControllerDragAndDrop.dragOwner[playerNum] == testOwner
end

function ControllerDragAndDrop.isDraggedItemRotated(playerNum)
    return ControllerDragAndDrop.rotateDrag[playerNum]
end

function ControllerDragAndDrop.rotateDraggedItem(playerNum)
    ControllerDragAndDrop.rotateDrag[playerNum] = not ControllerDragAndDrop.rotateDrag[playerNum]
end

function ControllerDragAndDrop.getDraggedStack(playerNum)
    return ControllerDragAndDrop.dragging[playerNum]
end

function ControllerDragAndDrop.getDraggedTetrisStack(playerNum)
    return ControllerDragAndDrop.draggingTetris[playerNum]
end

function ControllerDragAndDrop.getDraggedItem(playerNum)
    local stack = ControllerDragAndDrop.dragging[playerNum]
    return DragAndDrop.convertItemStackToItem(stack)
end

function ControllerDragAndDrop.startDrag(playerNum, owner, tetrisStack, vanillaStack)
    ControllerDragAndDrop.dragging[playerNum] = vanillaStack
    ControllerDragAndDrop.draggingTetris[playerNum] = tetrisStack
    ControllerDragAndDrop.dragOwner[playerNum] = owner
    ControllerDragAndDrop.rotateDrag[playerNum] = vanillaStack[1] and vanillaStack[1].isRotated or vanillaStack.isRotated
end

function ControllerDragAndDrop.endDrag(playerNum)
    ControllerDragAndDrop.dragging[playerNum] = nil
    ControllerDragAndDrop.draggingTetris[playerNum] = nil
    ControllerDragAndDrop.dragOwner[playerNum] = nil
    ControllerDragAndDrop.rotateDrag[playerNum] = nil
    ControllerDragAndDrop.ownersForCancel = {}
end
