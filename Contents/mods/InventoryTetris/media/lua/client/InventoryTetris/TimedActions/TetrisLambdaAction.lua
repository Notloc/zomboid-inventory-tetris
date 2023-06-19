require "TimedActions/ISBaseTimedAction"

TetrisLambdaAction = ISBaseTimedAction:derive("TetrisLambdaAction");

function TetrisLambdaAction:new (character, callback)
	local o = ISBaseTimedAction.new(self, character);
	o.callback = callback;
	o.stopOnWalk = false;
    o.stopOnRun = false;
    o.maxTime = -1;
	return o
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
