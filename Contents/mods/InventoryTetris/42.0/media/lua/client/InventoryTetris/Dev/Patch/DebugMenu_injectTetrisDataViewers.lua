---@diagnostic disable: duplicate-set-field
Events.OnGameBoot.Add(function()
    local ogSetup = ISDebugMenu.setupButtons
    function ISDebugMenu:setupButtons()
        self:addButtonInfo("Tetris Item Info", function() TetrisItemViewer.OnOpenPanel() end, "MAIN");
        self:addButtonInfo("Tetris Container Info", function() TetrisContainerViewer.OnOpenPanel() end, "MAIN");
        ogSetup(self)
    end
end)