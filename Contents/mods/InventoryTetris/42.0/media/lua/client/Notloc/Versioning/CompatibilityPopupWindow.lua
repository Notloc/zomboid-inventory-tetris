local Version = require("Notloc/Versioning/Version")
local Window = require("Notloc/Versioning/Window")

local WARNING_TEX = getTexture("media/textures/Compatibility/warning.png")
local WARNING_SIZE = 24

local UNEQUAL_TEX = getTexture("media/textures/Compatibility/unequal.png")
local UNEQUAL_SIZE = 24

require("ISUI/ISPanel")
require("ISUI/ISButton")
require("ISUI/ISInventoryPane")
require("ISUI/ISResizeWidget")
require("ISUI/ISMouseDrag")
require("ISUI/ISLayoutManager")
require("defines")

---@class CompatibilityPopupWindow : ISPanel
local CompatibilityPopupWindow = Window:derive("CompatibilityPopupWindow");


function CompatibilityPopupWindow:new (x, y, sourceImage, sourceVersion, targetImage, targetVersion, minTargetVersion)
    local o = {}
    o = Window:new(x, y, 256 + 48 + 24*2, 232, targetImage and "Version Issue Detected" or "Incompatible Mod Detected");
    setmetatable(o, self);
    self.__index = self

    -- The mod that detected the compatibility issue
    o.sourceImage = sourceImage;
    o.sourceVersion = sourceVersion;

    -- The mod that's incompatible and version information if available
    o.targetImage = targetImage;
    o.targetVersion = targetVersion;
    o.minTargetVersion = minTargetVersion;

    o.resizable = false;
    o.incompatibleMods = {};
    return o;
end

function CompatibilityPopupWindow:addModIncompatibility(modName, modId, reason)
    table.insert(self.incompatibleMods, {modName, modId, reason});
end

function CompatibilityPopupWindow:render()
    Window.render(self);

    local TITLEBAR = 20
    local PADDING = 24
    local SPACING = 48
    local IMG_SIZE = 128

    local x = PADDING
    local y = TITLEBAR + PADDING

    -- Draw version compatibility information
    if (self.sourceImage and self.targetImage) then
        self:drawTextureScaledAspect(self.sourceImage, x, y, IMG_SIZE, IMG_SIZE, 1, 1, 1, 1);
        x = x + IMG_SIZE + SPACING
        self:drawTextureScaledAspect(self.targetImage, x, y, IMG_SIZE, IMG_SIZE, 1, 1, 1, 1);

        x = PADDING + IMG_SIZE + SPACING/2 - WARNING_SIZE/2
        y = TITLEBAR + PADDING + IMG_SIZE/2 - WARNING_SIZE/2
        self:drawTexture(WARNING_TEX, x, y, 1, 1, 1, 1);

        x = PADDING + IMG_SIZE + SPACING/2 - UNEQUAL_SIZE/2
        y = TITLEBAR + PADDING + IMG_SIZE/2 - UNEQUAL_SIZE/2 + WARNING_SIZE + 12
        self:drawTexture(UNEQUAL_TEX, x, y, 1, 1, 1, 1);

        x = PADDING
        y = TITLEBAR + PADDING + IMG_SIZE + 12

        self:drawText("Version: " .. Version.format(self.sourceVersion), x, y, 1, 1, 1, 1, UIFont.Medium);

        x = PADDING + IMG_SIZE + SPACING
        local targetVersion = self.targetVersion and Version.format(self.targetVersion) or "Unknown"
        self:drawText("Version: " .. targetVersion, x, y, 1, 0.2, 0.1, 1, UIFont.Medium);
        y = y + PADDING
        self:drawText("Required: " .. Version.format(self.minTargetVersion), x, y, 1, 1, 0, 1, UIFont.Medium);
    else
        self:setWidth(400)
        self:setHeight(400)

        self:drawTextureScaledAspect(self.sourceImage, self:getWidth()/2 - IMG_SIZE/2, y, IMG_SIZE, IMG_SIZE, 1, 1, 1, 1);
        y = y + IMG_SIZE + PADDING

        self:drawText("Incompatible Mod(s) Detected!", x, y, 1, 1, 1, 1, UIFont.Medium);
        y = y + PADDING * 2



        local mouseX = self:getMouseX()
        local mouseY = self:getMouseY()

        local info = nil

        -- Draw list of mods that are incompatible
        for i, mod in ipairs(self.incompatibleMods) do
            self:drawText(mod[1] .. " [ " .. mod[2] .. " ]", x, y, 1, 0.2, 0.1, 1, UIFont.Medium);
            y = y + PADDING
            
            if mod[3] and mouseX > x and mouseX < x + 200 and mouseY > y - PADDING and mouseY < y then
                info = mod[3]
            end
        end

        if info then
            self:doInfoTooltip(mouseX, mouseY + 14, info)
        end

    end
    
end

---@param x any
---@param y any
---@param text string
function CompatibilityPopupWindow:doInfoTooltip(x, y, text)
    self:suspendStencil()

    local lineCount = #text:split("\n")
    local fontHgt = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()
    local width = getTextManager():MeasureStringX(UIFont.Medium, text)
    local height = fontHgt * lineCount
    local pad = 4
    x = x + pad
    y = y + pad
    self:drawRect(x, y, width + pad * 2, height + pad * 2, 1, 0, 0, 0)
    self:drawRectBorder(x, y, width + pad * 2, height + pad * 2, 1, 1, 1, 1)
    self:drawText(text, x + pad, y + pad, 1, 1, 1, 1, UIFont.Medium)

    self:resumeStencil()
end

return CompatibilityPopupWindow
