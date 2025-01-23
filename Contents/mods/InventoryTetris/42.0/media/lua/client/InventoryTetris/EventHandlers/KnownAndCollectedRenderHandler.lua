require("InventoryTetris/Events")
require("RecordedMedia/recorded_media")

if not getActivatedMods():contains("KnownAndCollected") and not getActivatedMods():contains("\\KnownAndCollected") then
    return
end

-- You will need to require InventoryTetris' settings in order to calculate the cell size
local SETTINGS = require("InventoryTetris/Settings")

-- Disable KnownAndCollected's rendering and InventoryTetris' checkmark rendering
Events.OnGameBoot.Add(function()
    ---@diagnostic disable-next-line: undefined-global
    KnownAndCollected:disableRender()
    ItemGridUI.doLiteratureCheckmark = false
end)

-- Textures per supported scale. I was lazy for 0.75 and 1.5 scales, so they both use the 1x textures
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
local unKnownEntertainmentTex = {
    [0.5]=getTexture("media/textures/InventoryTetris/KnownAndCollected/0.5x/iconUnKnownEntertainment.png"),
    [1]=getTexture("media/textures/InventoryTetris/KnownAndCollected/1x/iconUnKnownEntertainment.png"),
    [2]=getTexture("media/textures/InventoryTetris/KnownAndCollected/2x/iconUnKnownEntertainment.png"),
    [3]=getTexture("media/textures/InventoryTetris/KnownAndCollected/3x/iconUnKnownEntertainment.png"),
    [4]=getTexture("media/textures/InventoryTetris/KnownAndCollected/4x/iconUnKnownEntertainment.png"),
}
local unKnownFlierTex = {
    [0.5]=getTexture("media/textures/InventoryTetris/KnownAndCollected/0.5x/iconUnKnownFlier.png"),
    [1]=getTexture("media/textures/InventoryTetris/KnownAndCollected/1x/iconUnKnownFlier.png"),
    [2]=getTexture("media/textures/InventoryTetris/KnownAndCollected/2x/iconUnKnownFlier.png"),
    [3]=getTexture("media/textures/InventoryTetris/KnownAndCollected/3x/iconUnKnownFlier.png"),
    [4]=getTexture("media/textures/InventoryTetris/KnownAndCollected/4x/iconUnKnownFlier.png"),
}
local unKnownMapTex = {
    [0.5]=getTexture("media/textures/InventoryTetris/KnownAndCollected/0.5x/iconUnKnownMap.png"),
    [1]=getTexture("media/textures/InventoryTetris/KnownAndCollected/1x/iconUnKnownMap.png"),
    [2]=getTexture("media/textures/InventoryTetris/KnownAndCollected/2x/iconUnKnownMap.png"),
    [3]=getTexture("media/textures/InventoryTetris/KnownAndCollected/3x/iconUnKnownMap.png"),
    [4]=getTexture("media/textures/InventoryTetris/KnownAndCollected/4x/iconUnKnownMap.png"),
}

-- Cache for immutable information about items to reduce the number of function calls
local itemDataCache = {}
local function getItemData(item, itemType)
    local isRecordedMedia = item:isRecordedMedia()
    local isLiterature = instanceof(item, 'Literature')

    local data = {
        isRecordedMedia = isRecordedMedia,
        isLiterature = isLiterature,
        isMap = item:IsMap(),
    }

    itemDataCache[itemType] = data
    return data
end


-- Original code adapted from Known and Collected mod
-- All credit goes to UnCheat

local KnownAndCollectedRenderer = {}
function KnownAndCollectedRenderer.call(eventData, drawingContext, renderInstructions, instructionCount, playerObj)
    local kacModData = playerObj:getModData().knownAndCollected
    if not kacModData then
        return
    end

    ---@diagnostic disable-next-line: undefined-global
    local kAC = KnownAndCollected

    local recordedMedia = KnownAndCollectedRenderer.recordedMedia or getZomboidRadio():getRecordedMedia()
    local collectedMap = kacModData.collected or {}
    local collectedMediaMap = kacModData.collectedMedia or {}

    local CELL_SIZE = SETTINGS.CELL_SIZE

    for r=1,instructionCount do
        local instruction = renderInstructions[r]
        local hidden = instruction[9]

        if not hidden then
            local stack = instruction[1]
            local item = instruction[2]
            local x = instruction[3]
            local y = instruction[4]
            local w = instruction[5]
            local h = instruction[6]

            local width = w*CELL_SIZE
            local height = h*CELL_SIZE

            local itemType = stack.itemType
            local itemData = itemDataCache[itemType] or getItemData(item, itemType)

            local unCollected = false
            local unKnown = false
            local unKnownUnfinished = false
            local unKnownUnavailable = false
            local unPlayed = false
            local unKnownFlier = false
            local unKnownMap = false
            local unKnownEntertainment = false

            if itemData.isRecordedMedia then
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
            elseif itemData.isLiterature then
                local skillBook = SkillBook[item:getSkillTrained()]
                local recipes = item:getTeachedRecipes()
                local printMedia = item:getModData().printMedia
                if skillBook then
                    local maxTrained = item:getMaxLevelTrained()
                    local minTrained = item:getLvlSkillTrained()

                    local playerSkillLevel = playerObj:getPerkLevel(skillBook.perk) + 1

                    if not collectedMap[itemType] then
                        unCollected = true
                    end

                    local pages = item:getNumberOfPages()
                    local readPages = pages > 0 and playerObj:getAlreadyReadPages(itemType) or false
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
                    if not collectedMap[itemType] then
                        unCollected = true
                    end
                    if not playerObj:getAlreadyReadBook():contains(itemType) or not playerObj:getKnownRecipes():containsAll(recipes) then
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
                    local title = item:getModData().literatureTitle
                    unKnownEntertainment = title and not playerObj:isLiteratureRead(title)

                    if title and not kAC.isCollected(kAC,title) then
                        unCollected = true
                    end
                end
            elseif itemData.isMap then
                if not kAC.isCollected(kAC,itemType) then
                    unCollected = true
                end
                if not kAC.isKnownMap(kAC,itemType) then
                    unKnownMap = true
                end
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

            local javaObject = drawingContext.javaObject

            if unCollected then
                javaObject:DrawTexture(collectedTex[index], right+1, y+1, 1)
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
            elseif unKnownEntertainment then
                bottomRightTex = unKnownEntertainmentTex
            elseif unKnownFlier then
                bottomRightTex = unKnownFlierTex
            elseif unKnownMap then
                bottomRightTex = unKnownMapTex
            end

            if bottomRightTex then
                javaObject:DrawTexture(bottomRightTex[index], right, bottom, 1)
            end
        end
    end
end

TetrisEvents.OnPostRenderGrid:add(KnownAndCollectedRenderer)
