-- This doesn't do anything in-game, its just some info for my IDE to populate intellisense with

---@class Vector2Lua
---@field x number
---@field y number

---@class Size2D
---@field width number
---@field height number

---@class ISMouseDrag
---@field dragging any

---@class SandboxVars
---@field InventoryTetris InventoryTetrisVars

---@class InventoryTetrisVars
---@field EnforceCarryWeight boolean
---@field EnabledSearch boolean
---@field SearchTime number
---@field UseItemTransferTime boolean
---@field ItemTransferSpeedMultiplier number
---@field BonusGridSize number
---@field EnableGravity boolean
---@field PreventTardisStacking boolean
---@field SearchBodies number

-- Declare some built-in functions that do exist, but normally don't in lua 5.1
---@class string
---@field split fun(self:string, separator:string):string[]

---@class stringlib
---@field sort fun(a:string, b:string):boolean

---@class tablelib
---@field wipe fun(t:table)