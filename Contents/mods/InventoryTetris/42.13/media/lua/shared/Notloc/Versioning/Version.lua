---@class ModVersion
local Version = {}
Version.__index = Version

---@param major number
---@param minor number
---@param patch number
---@param stage string|nil
---@return ModVersion
function Version:new(major, minor, patch, stage)
    local o = setmetatable({}, self)
    o.major = major
    o.minor = minor
    o.patch = patch
    o.stage = stage
    return o
end

function Version.isBelow(version, major, minor, patch)
    if version == nil then
        return true
    end

    if version.major < major then
        return true
    elseif version.major > major then
        return false
    end

    if minor == nil then
        return false
    end

    if version.minor < minor then
        return true
    elseif version.minor > minor then
        return false
    end

    if patch == nil then
        return false
    end

    local vPatch = version.patch or version.revision or 0

    if vPatch < patch then
        return true
    elseif vPatch > patch then
        return false
    end

    return false
end

function Version.format(version)
    local formatted = string.format("%d.%d.%d", version.major, version.minor, version.patch or 0)
    if version.stage then
        formatted = string.format("%s %s", formatted, version.stage)
    end
    return formatted
end

return Version
