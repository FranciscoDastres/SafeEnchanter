local _, NS = ...
local Addon = NS.Addon

local Scanner = {}
NS.Scanner = Scanner

local scanToken = 0

local function GetContainerItemInfo(bag, slot)
    if C_Container and C_Container.GetContainerItemInfo then
        return C_Container.GetContainerItemInfo(bag, slot)
    end

    if type(_G.GetContainerItemInfo) == "function" then
        local icon, count, locked, quality, readable, lootable, link, filtered, noValue, itemID, isBound = _G.GetContainerItemInfo(bag, slot)
        if not itemID then
            return nil
        end
        return {
            iconFileID = icon,
            stackCount = count,
            isLocked = locked,
            quality = quality,
            isReadable = readable,
            hasLoot = lootable,
            hyperlink = link,
            isFiltered = filtered,
            hasNoValue = noValue,
            itemID = itemID,
            isBound = isBound,
        }
    end

    return nil
end

local function GetContainerNumSlots(bag)
    if C_Container and C_Container.GetContainerNumSlots then
        return C_Container.GetContainerNumSlots(bag)
    end
    if type(_G.GetContainerNumSlots) == "function" then
        return _G.GetContainerNumSlots(bag)
    end
    return 0
end

local function GetItemInfo(item)
    if C_Item and C_Item.GetItemInfo then
        return C_Item.GetItemInfo(item)
    end
    return _G.GetItemInfo(item)
end

local function RequestItem(itemID)
    if C_Item and C_Item.RequestLoadItemDataByID then
        C_Item.RequestLoadItemDataByID(itemID)
    elseif type(_G.GetItemInfo) == "function" then
        _G.GetItemInfo(itemID)
    end
end

local function GetItemGUID(bag, slot)
    if not (C_Item and C_Item.GetItemGUID and ItemLocation and ItemLocation.CreateFromBagAndSlot) then
        return nil
    end

    local ok, guid = pcall(C_Item.GetItemGUID, ItemLocation:CreateFromBagAndSlot(bag, slot))
    if ok then
        return guid
    end
    return nil
end

local function BuildEquipmentSetItemIDs()
    local protected = {}
    if not (C_EquipmentSet and C_EquipmentSet.GetEquipmentSetIDs and C_EquipmentSet.GetItemIDs) then
        return protected
    end

    local setIDs = C_EquipmentSet.GetEquipmentSetIDs() or {}
    for index = 1, #setIDs do
        local itemIDs = C_EquipmentSet.GetItemIDs(setIDs[index]) or {}
        for _, itemID in pairs(itemIDs) do
            if type(itemID) == "number" and itemID > 0 then
                protected[itemID] = true
            end
        end
    end
    return protected
end

function Scanner:GetSlotInfo(bag, slot, equipmentSetItemIDs)
    local containerInfo = GetContainerItemInfo(bag, slot)
    if not containerInfo or not containerInfo.itemID or not containerInfo.hyperlink then
        return nil, false
    end

    local itemName, itemLink, quality, itemLevel, _, itemType, itemSubType, _, equipLocation,
        texture, _, classID, subClassID, bindType, expansionID = GetItemInfo(containerInfo.hyperlink)

    if not itemName then
        RequestItem(containerInfo.itemID)
        return nil, true
    end

    return {
        bag = bag,
        slot = slot,
        itemID = containerInfo.itemID,
        itemGUID = GetItemGUID(bag, slot),
        itemName = itemName,
        itemLink = itemLink or containerInfo.hyperlink,
        itemLevel = itemLevel,
        quality = quality or containerInfo.quality,
        classID = classID,
        subClassID = subClassID,
        bindType = bindType,
        isBound = containerInfo.isBound == true,
        isLocked = containerInfo.isLocked == true,
        inEquipmentSet = equipmentSetItemIDs[containerInfo.itemID] == true,
        itemType = itemType,
        itemSubType = itemSubType,
        equipLocation = equipLocation,
        texture = texture or containerInfo.iconFileID,
        expansionID = expansionID,
    }, false
end

function Scanner:ScanNow()
    if not Addon.db then
        return
    end

    local targets = {}
    local index = {}
    local missingData = false
    local setItemIDs = BuildEquipmentSetItemIDs()
    local finalBag = tonumber(NUM_BAG_SLOTS) or 4

    for bag = 0, finalBag do
        local slots = GetContainerNumSlots(bag)
        for slot = 1, slots do
            local item, missing = self:GetSlotInfo(bag, slot, setItemIDs)
            missingData = missingData or missing
            if item then
                local eligible = NS.Rules.EvaluateCandidate(item, Addon.db.profile)
                if eligible then
                    targets[#targets + 1] = item
                end
            end
        end
    end

    NS.Rules.SortTargets(targets)
    for targetIndex = 1, #targets do
        local target = targets[targetIndex]
        index[NS.Rules.MakeTargetKey(target.bag, target.slot)] = target
    end

    NS.TargetList = targets
    NS.TargetIndex = index
    Addon:OnTargetsChanged(targets)

    if missingData then
        self:ScheduleScan(0.5)
    end
end

function Scanner:ScheduleScan(delay)
    scanToken = scanToken + 1
    local token = scanToken
    C_Timer.After(delay or 0.15, function()
        if token == scanToken then
            Scanner:ScanNow()
        end
    end)
end

function Scanner:IsTargetPresent(target)
    if not target then
        return false
    end

    local info = GetContainerItemInfo(target.bag, target.slot)
    if not info or info.itemID ~= target.itemID then
        return false
    end

    local guid = GetItemGUID(target.bag, target.slot)
    if target.itemGUID and guid then
        return target.itemGUID == guid
    end

    return info.hyperlink == target.itemLink
end

function Scanner:IsTargetLocked(target)
    if not target then
        return true
    end
    local info = GetContainerItemInfo(target.bag, target.slot)
    return not info or info.isLocked == true
end

function Scanner:HasFreeBagSlot()
    local getter = C_Container and C_Container.GetContainerNumFreeSlots or _G.GetContainerNumFreeSlots
    if type(getter) ~= "function" then
        return true
    end

    local finalBag = tonumber(NUM_BAG_SLOTS) or 4
    for bag = 0, finalBag do
        local free = getter(bag)
        if type(free) == "number" and free > 0 then
            return true
        end
    end
    return false
end

function Scanner:PrimeMaterialCache()
    for _, itemID in pairs(NS.Data.Materials) do
        RequestItem(itemID)
    end
end
