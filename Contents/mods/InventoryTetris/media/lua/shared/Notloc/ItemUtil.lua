local ItemUtil = {}

function ItemUtil.canBeRead(item, playerObj)
    -- Not a book
    if not item or item:getCategory() ~= "Literature" or item:canBeWrite() then
        return false
    end
    
    -- Character can't read
    if playerObj:getTraits():isIlliterate() then
        return false
    end

    -- No skill required
    local skillLvlTrained = item:getLvlSkillTrained()
    if skillLvlTrained == -1 then
        return true
    end

    -- Skill too low
    local perk = SkillBook[skillLvlTrained].perk
    if perk and	skillLvlTrained > playerObj:getPerkLevel(perk) + 1 then   
        return false
    end

    return true
end

function ItemUtil.canEat(item)
    return item:getCategory() == "Food" and not item:getScriptItem():isCantEat()
end

function ItemUtil.canEquipItem(item)
    return not ItemUtil.canEat(item) and not item:IsClothing() and not item:isBroken()
end

return ItemUtil
