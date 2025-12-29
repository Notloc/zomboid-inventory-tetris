-- This doesn't do anything in-game, its just some info for my IDE to populate intellisense with

---@class XY
---@field x integer
---@field y integer

---@class WidthHeight
---@field width integer
---@field height integer

---@class ISMouseDrag
---@field dragging any

---@class SandboxVars
---@field InventoryTetris InventoryTetrisVars

---@class InventoryTetrisVars
---@field EnforceCarryWeight boolean
---@field EnableSearch boolean
---@field SearchTime number
---@field UseItemTransferTime boolean
---@field ItemTransferSpeedMultiplier number
---@field BonusGridSize integer
---@field EnableGravity boolean
---@field PreventTardisStacking boolean
---@field SearchBodies number
---@field EncumbranceSlow boolean

---@alias VanillaStack umbrella.ContextMenuItemStack 



-- Declare some built-in functions that do exist, but normally don't in lua 5.1
---@class string
---@field split fun(self:string, separator:string):string[]

---@class stringlib
---@field sort fun(a:string, b:string):boolean

---@class tablelib
---@field wipe fun(t:table)
---@field newarray fun():table