require("TimedActions/ISBaseTimedAction")

local TetrisLambdaAction = ISBaseTimedAction:derive("TetrisLambdaAction");

function TetrisLambdaAction:new (character, callback, delayMs)
	local o = ISBaseTimedAction.new(self, character);
	o.callback = callback;
	o.delayMs = delayMs;
	o.stopOnWalk = false;
    o.stopOnRun = false;
    o.maxTime = -1;
	return o
end

function TetrisLambdaAction:waitToStart()
	if not self.delayMs then return false end

	self.timer = self.timer or getTimestampMs()
	return self.timer + self.delayMs > getTimestampMs()
end

function TetrisLambdaAction:isValid()
	return true
end

function TetrisLambdaAction:update()
	self:forceComplete()
end

function TetrisLambdaAction:perform()
	if self.callback then
        self.callback();
    end
    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

return TetrisLambdaAction
