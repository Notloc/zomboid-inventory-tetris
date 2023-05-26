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
}

TetrisItemCategory.getCategory = function(item)
    local category = item:getDisplayCategory()

    if item:IsInventoryContainer() then
        return TetrisItemCategory.CONTAINER

    elseif item:IsWeapon() or category == "Weapon" then
        if item:getAmmoType() then
            return TetrisItemCategory.RANGED
        else
            return TetrisItemCategory.MELEE
        end

    elseif category == "Ammo" then
        local maxAmmoCount = item:getMaxAmmo()
        if maxAmmoCount > 0 then
            return TetrisItemCategory.MAGAZINE
        else
            return TetrisItemCategory.AMMO
        end

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
    end

    return TetrisItemCategory.MISC
end
