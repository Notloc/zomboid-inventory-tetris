Tetris = {
    
}


function Tetris.doTest(key)
    if key == Keyboard.KEY_5 then
        local player = getSpecificPlayer(0);
        local p = TestPanel:new(50, 50, 450, 300, player:getInventory(), 1)
        p:initialise();
        p:addToUIManager();
        p:setVisible(true);
    end
end

Events.OnKeyStartPressed.Add(Tetris.doTest)