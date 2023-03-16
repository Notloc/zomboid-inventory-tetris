require "TimedActions/ISBaseTimedAction"

QueuedItemAction = ISBaseTimedAction:derive("QueuedItemAction");

function QueuedItemAction:new(character, item, onPerform, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
    o.character = character;
	o.item = item;
    o.onPerform = onPerform;
    o.maxTime = time or 1

    return o
end

function QueuedItemAction:isValid()
    return true
end

function QueuedItemAction:start()
    ISBaseTimedAction.start(self);
end

function QueuedItemAction:stop()
	ISBaseTimedAction.stop(self);
end

function QueuedItemAction:forceComplete()
	ISBaseTimedAction.perform(self);
end

function QueuedItemAction:forceStop()
	ISBaseTimedAction.stop(self);
end

function QueuedItemAction:perform()
	if self.onPerform then
        self.onPerform(self.character, self.item);
    end
end
