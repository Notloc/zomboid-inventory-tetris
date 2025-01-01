---@enum TetrisItemCategory

TetrisItemCategory = {
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
}

local list = {}
for _, category in pairs(TetrisItemCategory) do
    table.insert(list, category)
end
TetrisItemCategory.list = list

function TetrisItemCategory.getCategory(item)
    local category = item:getDisplayCategory()
    local type = item:getFullType()

    if instanceof(item, "Moveable") then
        return TetrisItemCategory.MOVEABLE

    elseif item:IsInventoryContainer() then
        return TetrisItemCategory.CONTAINER

    elseif item:IsWeapon() or category == "Weapon" then
        if item:getAmmoType() then
            return TetrisItemCategory.RANGED
        else
            return TetrisItemCategory.MELEE
        end

    elseif item:getMaxAmmo() > 0 then
            return TetrisItemCategory.MAGAZINE

    elseif category == "WeaponPart" then
        return TetrisItemCategory.ATTACHMENT

    elseif category == "Ammo" then
        return TetrisItemCategory.AMMO

    elseif category == "Clothing" then
        return TetrisItemCategory.CLOTHING

    elseif category == "Food" or category == "WaterContainer" then
        return TetrisItemCategory.FOOD

    elseif category == "FirstAid" then
        return TetrisItemCategory.HEALING

    elseif category == "Literature" or category == "SkillBook" then
        return TetrisItemCategory.BOOK

    elseif category == "Entertainment" then
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
