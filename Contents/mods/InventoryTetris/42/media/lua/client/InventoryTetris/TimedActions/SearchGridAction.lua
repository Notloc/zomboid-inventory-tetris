require("TimedActions/ISBaseTimedAction")

local SearchGridAction = ISBaseTimedAction:derive("SearchGridAction");

function SearchGridAction:new (character, grid)
	local o = ISBaseTimedAction.new(self, character);
	o.grid = grid;
	o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = o:getDuration();
	return o
end

function SearchGridAction:getDuration()
	if self.character:isTimedActionInstant() then
		return 1;
	end
	return -1;
end

function SearchGridAction:isValid()
	return true
end

function SearchGridAction:startActionAnim()
    self:setActionAnim("Loot");
	self:setAnimVariable("LootPosition", "");
	self:setOverrideHandModels(nil, nil);
	self.character:clearVariable("LootPosition");

    local cont = self.grid.inventory

    if cont:getContainerPosition() then
		self:setAnimVariable("LootPosition", cont:getContainerPosition());
	end
	if cont:getType() == "freezer" and cont:getFreezerPosition() then
		self:setAnimVariable("LootPosition", cont:getFreezerPosition());
	end
	if instanceof(cont:getParent(), "IsoDeadBody") or cont:getType() == "floor" then
		self:setAnimVariable("LootPosition", "Low");
	end
	if cont:getContainingItem() and cont:getContainingItem():getWorldItem() then
		self:setAnimVariable("LootPosition", "Low");
	end
end

function SearchGridAction:start()
    self:startActionAnim()
	self.grid:resetSearchTimer(self.character:getPlayerNum())
end

function SearchGridAction:update()
	if self.grid:updateSearch(self.character, self.character:getPlayerNum()) then
        self:forceComplete()
    end
end

function SearchGridAction:stop()
	if self.sound then
		self.character:getEmitter():stopSound(self.sound)
	end
    ISBaseTimedAction.stop(self);
end

function SearchGridAction:perform()
	if self.sound then
		self.character:getEmitter():stopSound(self.sound)
	end

	local playerNum = self.character:getPlayerNum()
	self.grid:completeSearch(playerNum)

	-- we need to update our needSearch variable when a search is completed
	---- TODO: Possibly a better way to propagate this?
	getPlayerInventory(playerNum):checkTetrisSearch()
	getPlayerLoot(playerNum):checkTetrisSearch()

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

return SearchGridAction;
