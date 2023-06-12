require "Notloc/NotUtil"

TetrisEvents = {}

-- Call Signature: (eventData, droppedStack, fromGrid, targetStack, targetGrid, playerNum)
TetrisEvents.OnStackDroppedOnStack = NotUtil.createEvent("OnStackDroppedOnStack")