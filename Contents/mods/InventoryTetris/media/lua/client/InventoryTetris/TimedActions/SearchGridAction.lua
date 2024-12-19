require "TimedActions/ISBaseTimedAction"

SearchGridAction = ISBaseTimedAction:derive("SearchGridAction");

function SearchGridAction:new (character, grid)
	local o = ISBaseTimedAction.new(self, character);
	o.grid = grid;
	o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = -1;
	return o
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
	--self.grid:startSearch(character:getPlayerNum())
    self:startActionAnim()
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

    self.grid:completeSearch(self.character:getPlayerNum())

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end
