Events.OnGameStart.Add(function ()
    local og_new = ISMoveablesAction.new

    function ISMoveablesAction:new(character, square, mode, origSpriteName, object, direction, item, moveCursor)
        if moveCursor then
            ISMoveableCursor.tetris_jitTransferItems(character, moveCursor.currentMoveProps, origSpriteName)
        end
        return og_new(self, character, square, mode, origSpriteName, object, direction, item, moveCursor)
    end
end)