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
