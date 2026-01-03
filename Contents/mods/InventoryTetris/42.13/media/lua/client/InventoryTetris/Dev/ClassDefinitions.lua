-- This doesn't do anything in-game, its just some info for my IDE to populate intellisense with

---@class XY
---@field x integer
---@field y integer

---@class WidthHeight
---@field width integer
---@field height integer

---@class RGBA
---@field r number
---@field g number
---@field b number
---@field a number

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
---@field DevMode boolean

---@alias VanillaStack umbrella.ContextMenuItemStack 

-- From EquipmentUI
---@class (partial) ISUIElement
---@field public drawTextureCenteredAndSquare fun(self: ISUIElement, texture: Texture, x: number, y: number, targetSizePixels: number, alpha: number, r: number, g: number, b: number)
---@field public isMouseOverAnyUI fun(): boolean

-- Declare some built-in functions that do exist, but normally don't in lua 5.1
---@class string
---@field split fun(self:string, separator:string):string[]

---@class stringlib
---@field sort fun(a:string, b:string):boolean

---@class tablelib
---@field wipe fun(t:table)
---@field newarray fun():table