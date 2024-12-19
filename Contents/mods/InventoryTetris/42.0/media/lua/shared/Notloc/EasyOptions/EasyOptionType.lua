---@enum EasyOptionType
local EasyOptionType = {
    HIDDEN = "hidden",
    DROPDOWN = "dropdown",
    CHECKBOX = "checkbox",
}

EasyOptionType.isModOptionsSupported = function(type)
    return type == EasyOptionType.DROPDOWN or type == EasyOptionType.CHECKBOX
end

return EasyOptionType
