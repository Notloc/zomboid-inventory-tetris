require("TimedActions/ISBaseTimedAction")

---@class SearchGridAction : ISBaseTimedAction
---@field public grid ItemGrid
local SearchGridAction = ISBaseTimedAction:derive("SearchGridAction");

---@param character IsoPlayer
---@param grid ItemGrid
---@return SearchGridAction
function SearchGridAction:new (character, grid)
	---@type SearchGridAction
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
    self:startActionAnim()
	self.grid:resetSearchTimer(self.character:getPlayerNum())
end

function SearchGridAction:update()
	if self.grid:updateSearch(self.character, self.character:getPlayerNum()) then
        self:forceComplete()
    end
end

function SearchGridAction:perform()
	local playerNum = self.character:getPlayerNum()
	self.grid:completeSearch(playerNum)

	-- we need to update our needSearch variable when a search is completed
	local inv = getPlayerInventory(playerNum)
	if inv then
		inv:checkTetrisSearch()
	end
	local loot = getPlayerLoot(playerNum)
	if loot then
		loot:checkTetrisSearch()
	end

	ISBaseTimedAction.perform(self);
end

return SearchGridAction;
