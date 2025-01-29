---@diagnostic disable: inject-field

---@enum TetrisItemCategory
local TetrisItemCategory = {
    MELEE = "MELEE_WEAPON",
    RANGED = "RANGED_WEAPON",
    AMMO = "AMMO",
    MAGAZINE = "MAGAZINE",
    ATTACHMENT = "ATTACHMENT",
    FOOD = "FOOD",
    CLOTHING = "CLOTHING",
    CONTAINER = "CONTAINER",
    HEALING = "HEALING",
    BOOK = "BOOK",
    ENTERTAINMENT = "ENTERTAINMENT",
    KEY = "KEY",
    MISC = "MISC",
    SEED = "SEED",
    MOVEABLE = "MOVEABLE",
    CORPSEANIMAL = "CORPSEANIMAL",
}

local list = {}
for _, category in pairs(TetrisItemCategory) do
    table.insert(list, category)
end
TetrisItemCategory.list = list

TetrisItemCategory._categoryCache = {}

---@param item InventoryItem
function TetrisItemCategory.getCategory(item)
    local type = item:getFullType()
    local category = TetrisItemCategory._categoryCache[type]
    if not category then
        category = TetrisItemCategory._getCategoryInternal(item, type)
        TetrisItemCategory._categoryCache[type] = category
    end
    return category
end

---@param item InventoryItem
---@param type string
function TetrisItemCategory._getCategoryInternal(item, type)
    local displayCategory = item:getDisplayCategory()
    local category = item:getCategory()

    if instanceof(item, "Moveable") then
        return TetrisItemCategory.MOVEABLE

    elseif type == "Base.CorpseAnimal" then
        return TetrisItemCategory.CORPSEANIMAL

    elseif item:IsInventoryContainer() then
        return TetrisItemCategory.CONTAINER

    elseif displayCategory == "FirstAid" or displayCategory == "FirstAidWeapon" then
        return TetrisItemCategory.HEALING

    elseif item:IsWeapon() then
        ---@cast item HandWeapon
        if item:getAmmoType() or item:isRanged() then
            return TetrisItemCategory.RANGED
        else
            return TetrisItemCategory.MELEE
        end

    elseif item:getMaxAmmo() > 0 then
            return TetrisItemCategory.MAGAZINE

    elseif instanceof(item, "WeaponPart") or displayCategory == "WeaponPart" then
        return TetrisItemCategory.ATTACHMENT

    elseif displayCategory == "Ammo" then -- TODO: Compile a map of ammo types instead of checking displayCategory
        return TetrisItemCategory.AMMO

    elseif item:IsClothing() then
        return TetrisItemCategory.CLOTHING

    elseif item:IsFood() or displayCategory == "WaterContainer" or displayCategory == "Water" then -- TODO: Check the fluidContainer instead for water?
        return TetrisItemCategory.FOOD

    elseif displayCategory == "Literature" or displayCategory == "SkillBook" then
        return TetrisItemCategory.BOOK

    elseif displayCategory == "Entertainment" then
        return TetrisItemCategory.ENTERTAINMENT

    elseif category == "Key" then
        return TetrisItemCategory.KEY

    elseif string.find(type, "Seed") and not string.find(type, "Paste") then
        return TetrisItemCategory.SEED
    end

    return TetrisItemCategory.MISC
end

TetrisItemCategory.categoryIcons = {
    [TetrisItemCategory.MELEE] = getTexture("media/textures/InventoryTetris/Categories/MELEE.png"),
    [TetrisItemCategory.RANGED] = getTexture("media/textures/InventoryTetris/Categories/RANGED.png"),
    [TetrisItemCategory.AMMO] = getTexture("media/textures/InventoryTetris/Categories/AMMO.png"),
    [TetrisItemCategory.MAGAZINE] = getTexture("media/textures/InventoryTetris/Categories/MAGAZINE.png"),
    [TetrisItemCategory.FOOD] = getTexture("media/textures/InventoryTetris/Categories/FOOD.png"),
    [TetrisItemCategory.CLOTHING] = getTexture("media/textures/InventoryTetris/Categories/CLOTHING.png"),
    [TetrisItemCategory.CONTAINER] = getTexture("media/textures/InventoryTetris/Categories/CONTAINER.png"),
    [TetrisItemCategory.HEALING] = getTexture("media/textures/InventoryTetris/Categories/HEALING.png"),
    [TetrisItemCategory.BOOK] = getTexture("media/textures/InventoryTetris/Categories/BOOK.png"),
    [TetrisItemCategory.ENTERTAINMENT] = getTexture("media/textures/InventoryTetris/Categories/ENTERTAINMENT.png"),
    [TetrisItemCategory.KEY] = getTexture("media/textures/InventoryTetris/Categories/KEY.png"),
    [TetrisItemCategory.MISC] = getTexture("media/textures/InventoryTetris/Categories/MISC.png"),
    [TetrisItemCategory.SEED] = getTexture("media/textures/InventoryTetris/Categories/SEED.png"),
    [TetrisItemCategory.MOVEABLE] = getTexture("media/textures/InventoryTetris/Categories/MOVEABLE.png"),
}

function TetrisItemCategory.getCategoryIcon(category)
    return TetrisItemCategory.categoryIcons[category]
end

return TetrisItemCategory
