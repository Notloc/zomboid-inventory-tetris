require "InventoryTetris/Events"
require "RecordedMedia/recorded_media"

if not getActivatedMods():contains("KnownAndCollected") then
    return
end

local collectedTex = getTexture("media/textures/InventoryTetris/KnownAndCollected/iconUnCollected.png")
local unknownTex = getTexture("media/textures/InventoryTetris/KnownAndCollected/iconUnKnown.png")
local unavailableTex = getTexture("media/textures/InventoryTetris/KnownAndCollected/iconUnKnownUnavalable.png")
local mediaTex = getTexture("media/textures/InventoryTetris/KnownAndCollected/iconUnKnownMedia.png")
local unKnownUnfinishedTex = getTexture("media/textures/InventoryTetris/KnownAndCollected/iconUnKnownUnfinished.png")

-- Original code adapted from Known and Collected mod
-- All credit goes to UnCheat

local moodleCodes = {
    ANG = true, -- Anger
    BOR = true, -- boredom
    FAT = true, -- fatigue
    HUN = true, -- hunger
    STS = true, -- stress
    FEA = true, -- Fear
    PAN = true, -- Panic
    SIC = true, -- Sickness
    PAI = true, -- Pain
    DRU = true, -- Drunkenness
    THI = true, -- thirst
    UHP = true, -- thirst ? Unhappiness !
}

local isSkillMediaCache = {} 

local function isSkillCode(code)
    local match = string.match(code, "^%u%u%u+")
    return match and not moodleCodes[match]
end

local function determineIfSkillMedia(mediaId)
    local mediaData = RecMedia[mediaId]
    if not mediaData then return false end
    
    for _, line in ipairs(mediaData.lines) do
        if line.codes and line.codes:len() > 0 then
            if isSkillCode(line.codes) then
                return true
            end

            -- try parse multicode from mods separated by ','
            for code in string.gmatch(line.codes, "([^,]+)") do
                if isSkillCode(code) then
                    return true
                end
            end
        end
    end
    return false
end

local function isSkillMedia(mediaId)
    if isSkillMediaCache[mediaId] == nil then
        isSkillMediaCache[mediaId] = determineIfSkillMedia(mediaId)
    end
    return isSkillMediaCache[mediaId]
end

local knownAndCollectedRenderer = {}
knownAndCollectedRenderer.call = function(eventData, drawingContext, item, gridStack, x, y, width, height, playerObj)
    local knownAndCollected = playerObj:getModData().knownAndCollected
    if not knownAndCollected then
        return
    end

    local recordedMedia = knownAndCollectedRenderer.recordedMedia or getZomboidRadio():getRecordedMedia()

    local collectedMap = knownAndCollected.collected or {}
    local collectedMediaMap = knownAndCollected.collectedMedia or {}

    local unCollected = false
    local unKnown = false
    local unKnownUnfinished = false
    local unKnownUnavailable = false
    local unPlayed = false

    if item:isRecordedMedia() then
        local mediaData = item:getMediaData()
        local mediaId = mediaData:getId()

        if not collectedMediaMap[mediaId] then
            unCollected = true
        end

        if not recordedMedia:hasListenedToAll(playerObj, mediaData) then
            if isSkillMedia(mediaId) then
                unKnown = true
            else
                unPlayed = true
            end
        end
    elseif instanceof(item, 'Literature') then
        local _type = item:getFullType()
        local skillBook = SkillBook[item:getSkillTrained()]
        local recipes = item:getTeachedRecipes()

        if skillBook then
            local maxTrained = item:getMaxLevelTrained()
            local minTrained = item:getLvlSkillTrained()
            
            local playerSkillLevel = playerObj:getPerkLevel(skillBook.perk) + 1
            
            if not collectedMap[_type] then
                unCollected = true
            end
            
            local pages = item:getNumberOfPages()
            local readPages = pages > 0 and playerObj:getAlreadyReadPages(_type) or false
            if readPages and readPages ~= pages and maxTrained >= playerSkillLevel then
                if minTrained > playerSkillLevel then
                    unKnownUnavailable = true
                elseif readPages > 0 then
                    unKnownUnfinished = true
                else
                    unKnown = true
                end
            end

        elseif recipes then
            if not collectedMap[_type] then
                unCollected = true
            end
            if not playerObj:getAlreadyReadBook():contains(_type) or not playerObj:getKnownRecipes():containsAll(recipes) then
                unKnown = true
            end
        end
    end

    -- Textures are 13x13
    local right = x+width-15
    local bottom = y+height-15

    if unCollected then
        drawingContext:drawTexture(collectedTex, right+1, y+1, 1, 1, 1, 1)
    end
    
    if unKnown then
        drawingContext:drawTexture(unknownTex, right, bottom, 1, 1, 1, 1)
    
    elseif unKnownUnfinished then
        drawingContext:drawTexture(unKnownUnfinishedTex, right, bottom, 1, 1, 1, 1)
    
    elseif unKnownUnavailable then
        drawingContext:drawTexture(unavailableTex, right, bottom, 1, 1, 1, 1)
    
    elseif unPlayed then
        drawingContext:drawTexture(mediaTex, right, bottom, 1, 1, 1, 1)
    end

end

TetrisEvents.OnPostRenderGridItem:add(knownAndCollectedRenderer)
