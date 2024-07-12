-- Let the inventory know that it needs to redraw when attaching/detaching items from the hotbar.
---@diagnostic disable: duplicate-set-field

Events.OnGameBoot.Add(function()
    local og_attach_perform = ISAttachItemHotbar.perform
    function ISAttachItemHotbar:perform()
        og_attach_perform(self)
        self.item:getContainer():setDrawDirty(true)
    end

    local og_detach_perform = ISDetachItemHotbar.perform
    function ISDetachItemHotbar:perform()
        og_detach_perform(self)
        self.item:getContainer():setDrawDirty(true)
    end
end)
