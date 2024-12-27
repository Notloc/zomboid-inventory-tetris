Events.OnGameBoot.Add(function()
    local ogSetup = ISDebugMenu.setupButtons
    function ISDebugMenu:setupButtons()
        self:addButtonInfo("Tetris Info", function() TetrisItemViewer.OnOpenPanel() end, "MAIN");
        ogSetup(self)
    end
end)