require("InventoryTetris/Events")
require("RecordedMedia/recorded_media")

if not getActivatedMods():contains("KnownAndCollected") and not getActivatedMods():contains("\\KnownAndCollected") then
    return
end

local SETTINGS = require("InventoryTetris/Settings")

Events.OnGameBoot.Add(function()
    ---@diagnostic disable-next-line: undefined-global
    KnownAndCollected:disableRender()
end)

local collectedTex = {
    [0.5]=getTexture("media/textures/InventoryTetris/KnownAndCollected/0.5x/iconUnCollected.png"),
    [1]=getTexture("media/textures/InventoryTetris/KnownAndCollected/1x/iconUnCollected.png"),
    [2]=getTexture("media/textures/InventoryTetris/KnownAndCollected/2x/iconUnCollected.png"),
    [3]=getTexture("media/textures/InventoryTetris/KnownAndCollected/3x/iconUnCollected.png"),
    [4]=getTexture("media/textures/InventoryTetris/KnownAndCollected/4x/iconUnCollected.png"),
}
local unknownTex = {
    [0.5]=getTexture("media/textures/InventoryTetris/KnownAndCollected/0.5x/iconUnKnown.png"),
    [1]=getTexture("media/textures/InventoryTetris/KnownAndCollected/1x/iconUnKnown.png"),
    [2]=getTexture("media/textures/InventoryTetris/KnownAndCollected/2x/iconUnKnown.png"),
    [3]=getTexture("media/textures/InventoryTetris/KnownAndCollected/3x/iconUnKnown.png"),
    [4]=getTexture("media/textures/InventoryTetris/KnownAndCollected/4x/iconUnKnown.png"),
}
local unavailableTex = {
    [0.5]=getTexture("media/textures/InventoryTetris/KnownAndCollected/0.5x/iconUnKnownUnavalable.png"),
    [1]=getTexture("media/textures/InventoryTetris/KnownAndCollected/1x/iconUnKnownUnavalable.png"),
    [2]=getTexture("media/textures/InventoryTetris/KnownAndCollected/2x/iconUnKnownUnavalable.png"),
    [3]=getTexture("media/textures/InventoryTetris/KnownAndCollected/3x/iconUnKnownUnavalable.png"),
    [4]=getTexture("media/textures/InventoryTetris/KnownAndCollected/4x/iconUnKnownUnavalable.png"),
}
local mediaTex = {
    [0.5]=getTexture("media/textures/InventoryTetris/KnownAndCollected/0.5x/iconUnKnownMedia.png"),
    [1]=getTexture("media/textures/InventoryTetris/KnownAndCollected/1x/iconUnKnownMedia.png"),
    [2]=getTexture("media/textures/InventoryTetris/KnownAndCollected/2x/iconUnKnownMedia.png"),
    [3]=getTexture("media/textures/InventoryTetris/KnownAndCollected/3x/iconUnKnownMedia.png"),
    [4]=getTexture("media/textures/InventoryTetris/KnownAndCollected/4x/iconUnKnownMedia.png"),
}
local unKnownUnfinishedTex = {
    [0.5]=getTexture("media/textures/InventoryTetris/KnownAndCollected/0.5x/iconUnKnownUnfinished.png"),
    [1]=getTexture("media/textures/InventoryTetris/KnownAndCollected/1x/iconUnKnownUnfinished.png"),
    [2]=getTexture("media/textures/InventoryTetris/KnownAndCollected/2x/iconUnKnownUnfinished.png"),
    [3]=getTexture("media/textures/InventoryTetris/KnownAndCollected/3x/iconUnKnownUnfinished.png"),
    [4]=getTexture("media/textures/InventoryTetris/KnownAndCollected/4x/iconUnKnownUnfinished.png"),
}


-- Original code adapted from Known and Collected mod
-- All credit goes to UnCheat

local KnownAndCollectedRenderer = {}
function KnownAndCollectedRenderer.call(eventData, drawingContext, item, gridStack, x, y, width, height, playerObj)
    local kacModData = playerObj:getModData().knownAndCollected
    if not kacModData then
        return
    end

    ---@diagnostic disable-next-line: undefined-global
    local kAC = KnownAndCollected

    local recordedMedia = KnownAndCollectedRenderer.recordedMedia or getZomboidRadio():getRecordedMedia()

    local collectedMap = kacModData.collected or {}
    local collectedMediaMap = kacModData.collectedMedia or {}

    local unCollected = false
    local unKnown = false
    local unKnownUnfinished = false
    local unKnownUnavailable = false
    local unPlayed = false
    local unKnownFlier = false
    local unKnownMap = false
    local unKnownEntertainment = false

    if item:isRecordedMedia() then
        local mediaData = item:getMediaData()
        local mediaId = mediaData:getId()

        if not collectedMediaMap[mediaId] then
            unCollected = true
        end

        if not recordedMedia:hasListenedToAll(playerObj, mediaData) then
            if kAC.isSkillMedia(mediaId) then
                unKnown = true
            else
                unPlayed = true
            end
        end
    elseif instanceof(item, 'Literature') then
        local _type = item:getFullType()
        local skillBook = SkillBook[item:getSkillTrained()]
        local recipes = item:getTeachedRecipes()
        local printMedia = item:getModData().printMedia
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
        elseif printMedia then
            if not kAC.isCollected(kAC,printMedia) then
                unCollected = true
            end
            if not kAC.isKnownPrintMedia(kAC,printMedia) then
                unKnownFlier = true
            end
        else
            title = item:getModData().literatureTitle
            unKnownEntertainment = title and not playerObj:isLiteratureRead(title)

            if title and not kAC.isCollected(kAC,title) then
                unCollected = true
            end
        end
    elseif item:IsMap() then
        local _type = item:getFullType()
        if not kAC.isCollected(kAC,_type) then
            unCollected = true
        end
        if not kAC.isKnownMap(kAC,_type) then
            unKnownMap = true
        end
    end

    if unKnownMap or unKnownFlier or unKnownEntertainment then
        unKnown = true
    end

    local scale = SETTINGS.SCALE
    local index = scale
    if index == 0.75 or index == 1.5 then
        index = 1
    end

    local texSize = 12*scale
    if scale == 1.5 then
        texSize = 12
    end

    local right = x+width-2 - texSize
    local bottom = y+height-2 - texSize

    ---@cast drawingContext ISUIElement

    if unCollected then
        drawingContext:drawTexture(collectedTex[index], right+1, y+1, 1, 1, 1, 1)
    end

    local bottomRightTex = nil
    if unKnown then
        bottomRightTex = unknownTex
    elseif unKnownUnfinished then
        bottomRightTex = unKnownUnfinishedTex
    elseif unKnownUnavailable then
        bottomRightTex = unavailableTex
    elseif unPlayed then
        bottomRightTex = mediaTex
    end

    if bottomRightTex then
        drawingContext:drawTexture(bottomRightTex[index], right, bottom, 1, 1, 1, 1)
    end
end

TetrisEvents.OnPostRenderGridItem:add(KnownAndCollectedRenderer)
