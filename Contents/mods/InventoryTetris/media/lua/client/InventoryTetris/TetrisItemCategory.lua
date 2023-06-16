TetrisItemCategory = {
    MELEE = "MELEE_WEAPON",
    RANGED = "RANGED_WEAPON",
    AMMO = "AMMO",
    MAGAZINE = "MAGAZINE",
    FOOD = "FOOD",
    DRINK = "DRINK",
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

TetrisItemCategory.getCategory = function(item)
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
    
    elseif category == "Ammo" then
        return TetrisItemCategory.AMMO

    elseif category == "Clothing" then
        return TetrisItemCategory.CLOTHING

    elseif category == "Food" then
        return TetrisItemCategory.FOOD

    elseif category == "FirstAid" then
        return TetrisItemCategory.HEALING

    elseif category == "Literature" or category == "SkillBook" then
        return TetrisItemCategory.BOOK

    elseif category == "Entertainment" then
        return TetrisItemCategory.ENTERTAINMENT
    
    elseif category == "Key" then
        return TetrisItemCategory.KEY
    
    elseif string.find(type, "Seed") then 
        return TetrisItemCategory.SEED
    end

    return TetrisItemCategory.MISC
end
