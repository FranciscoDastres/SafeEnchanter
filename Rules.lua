local _, NS = ...

local Rules = {}
NS.Rules = Rules

function Rules.GetOutcomes(quality, classID, itemLevel)
    if type(itemLevel) ~= "number" then
        return nil
    end

    for index = 1, #NS.Data.Rules do
        local rule = NS.Data.Rules[index]
        if rule.quality == quality
            and (rule.classID == nil or rule.classID == classID)
            and itemLevel >= rule.minItemLevel
            and itemLevel <= rule.maxItemLevel then
            return rule.outcomes
        end
    end

    return nil
end

function Rules.EvaluateCandidate(item, profile)
    if not profile or not profile.enabled then
        return false, "disabled"
    end

    if item.quality ~= NS.ITEM_QUALITY_UNCOMMON and item.quality ~= NS.ITEM_QUALITY_RARE then
        return false, "quality"
    end
    if not profile.qualities or not profile.qualities[item.quality] then
        return false, "quality"
    end
    if item.classID ~= NS.ITEM_CLASS_WEAPON and item.classID ~= NS.ITEM_CLASS_ARMOR then
        return false, "class"
    end
    if item.isBound then
        return false, "bound"
    end
    if item.bindType ~= NS.ITEM_BIND_ON_EQUIP then
        return false, "binding"
    end

    local maximum = tonumber(profile.maxItemLevel) or 0
    if maximum > 0 and item.itemLevel > maximum then
        return false, "level"
    end
    if profile.protectedItemIDs and profile.protectedItemIDs[item.itemID] then
        return false, "protected"
    end
    if item.inEquipmentSet then
        return false, "equipment-set"
    end
    if NS.Data.BlockedItemIDs[item.itemID] then
        return false, "blocked"
    end

    local outcomes = Rules.GetOutcomes(item.quality, item.classID, item.itemLevel)
    if not outcomes then
        return false, "no-data"
    end

    item.outcomes = outcomes
    return true
end

function Rules.SortTargets(targets)
    table.sort(targets, function(left, right)
        if left.itemLevel ~= right.itemLevel then
            return left.itemLevel < right.itemLevel
        end
        if left.quality ~= right.quality then
            return left.quality < right.quality
        end
        if left.bag ~= right.bag then
            return left.bag < right.bag
        end
        return left.slot < right.slot
    end)
    return targets
end

function Rules.MakeTargetKey(bag, slot)
    return tostring(bag) .. ":" .. tostring(slot)
end
