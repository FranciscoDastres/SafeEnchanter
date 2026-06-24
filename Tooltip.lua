local _, NS = ...
local Addon = NS.Addon
local L = NS.L

local Tooltip = {}
NS.Tooltip = Tooltip

local function GetItemInfo(item)
    if C_Item and C_Item.GetItemInfo then
        return C_Item.GetItemInfo(item)
    end
    return _G.GetItemInfo(item)
end

local function GetItemIcon(itemID)
    if C_Item and C_Item.GetItemIconByID then
        return C_Item.GetItemIconByID(itemID)
    end
    if type(_G.GetItemIcon) == "function" then
        return _G.GetItemIcon(itemID)
    end
    local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
    return texture
end

local function FormatQuantity(minimum, maximum)
    if minimum == maximum then
        return tostring(minimum)
    end
    return tostring(minimum) .. "-" .. tostring(maximum)
end

local function FormatChance(chance)
    if math.floor(chance) == chance then
        return tostring(chance)
    end
    return string.format("%.1f", chance)
end

function Tooltip:AddPredictions(tooltip)
    if not Addon.db or not Addon.db.profile.showTooltips or tooltip:IsForbidden() then
        return
    end

    local _, itemLink = tooltip:GetItem()
    if not itemLink or tooltip.__SafeEnchanterLink == itemLink then
        return
    end

    local _, _, quality, itemLevel, _, _, _, _, _, _, _, classID = GetItemInfo(itemLink)
    if not quality or (classID ~= NS.ITEM_CLASS_WEAPON and classID ~= NS.ITEM_CLASS_ARMOR) then
        return
    end

    local outcomes = NS.Rules.GetOutcomes(quality, classID, itemLevel)
    if not outcomes then
        return
    end

    tooltip.__SafeEnchanterLink = itemLink
    tooltip:AddLine(" ")
    tooltip:AddLine(L.PREDICTION_HEADER, 0.70, 0.35, 1.00)

    for index = 1, #outcomes do
        local result = outcomes[index]
        local materialName, materialLink = GetItemInfo(result.itemID)
        local icon = GetItemIcon(result.itemID)
        local displayName = materialLink or materialName or ("item:" .. tostring(result.itemID))
        if icon then
            displayName = "|T" .. tostring(icon) .. ":14:14:0:0|t " .. displayName
        end
        tooltip:AddLine(string.format(
            L.PREDICTION_LINE,
            displayName,
            FormatQuantity(result.minQuantity, result.maxQuantity),
            FormatChance(result.chance)
        ), 0.85, 0.85, 0.85)
    end

    tooltip:Show()
end

function Tooltip:ClearMarker(tooltip)
    tooltip.__SafeEnchanterLink = nil
end

function Tooltip:Initialize()
    local function callback(tooltip)
        Tooltip:AddPredictions(tooltip)
    end

    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
        and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, callback)
    else
        if GameTooltip then
            GameTooltip:HookScript("OnTooltipSetItem", callback)
        end
        if ItemRefTooltip then
            ItemRefTooltip:HookScript("OnTooltipSetItem", callback)
        end
    end

    if GameTooltip then
        GameTooltip:HookScript("OnTooltipCleared", function(tip) Tooltip:ClearMarker(tip) end)
    end
    if ItemRefTooltip then
        ItemRefTooltip:HookScript("OnTooltipCleared", function(tip) Tooltip:ClearMarker(tip) end)
    end
end
