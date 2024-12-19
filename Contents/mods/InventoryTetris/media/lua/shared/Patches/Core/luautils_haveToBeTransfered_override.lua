require "luautils"

luautils.tetrisTransferOverride = false

local og_haveToBeTransfered = luautils.haveToBeTransfered
function luautils.haveToBeTransfered(player, item, dontWalk)
	if luautils.tetrisTransferOverride then
		return false
	end
	return og_haveToBeTransfered(player, item, dontWalk)
end