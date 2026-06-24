local namespace = {
    ITEM_CLASS_WEAPON = 2,
    ITEM_CLASS_ARMOR = 4,
    ITEM_QUALITY_UNCOMMON = 2,
    ITEM_QUALITY_RARE = 3,
    ITEM_BIND_ON_EQUIP = 2,
}

local addon = {
    db = {
        profile = {
            enabled = true,
            qualities = { [2] = true, [3] = false },
            maxItemLevel = 0,
            protectedItemIDs = {},
        },
    },
}
namespace.Addon = addon

local items = {
    [1] = { itemID = 1001, hyperlink = "item:1001", quality = 2, isBound = false, isLocked = false },
    [2] = { itemID = 1002, hyperlink = "item:1002", quality = 2, isBound = true, isLocked = false },
    [3] = { itemID = 1003, hyperlink = "item:1003", quality = 3, isBound = false, isLocked = false },
}

NUM_BAG_SLOTS = 0
C_Timer = { After = function(_, callback) callback() end }
C_Container = {
    GetContainerNumSlots = function() return 3 end,
    GetContainerItemInfo = function(_, slot) return items[slot] end,
    GetContainerNumFreeSlots = function() return 1, 0 end,
}
C_Item = {
    GetItemInfo = function(link)
        if link == "item:1001" then
            return "Green Armor", link, 2, 100, 60, "Armor", "Cloth", 1, "INVTYPE_CHEST", 1, 1, 4, 1, 2, 1
        elseif link == "item:1002" then
            return "Bound Armor", link, 2, 80, 55, "Armor", "Cloth", 1, "INVTYPE_CHEST", 2, 1, 4, 1, 2, 1
        elseif link == "item:1003" then
            return "Blue Weapon", link, 3, 90, 60, "Weapon", "Sword", 1, "INVTYPE_WEAPON", 3, 1, 2, 7, 2, 1
        end
    end,
    RequestLoadItemDataByID = function() end,
}
C_EquipmentSet = {
    GetEquipmentSetIDs = function() return {} end,
    GetItemIDs = function() return {} end,
}

assert(loadfile("Data.lua"))("SafeEnchanter", namespace)
assert(loadfile("Rules.lua"))("SafeEnchanter", namespace)

addon.OnTargetsChanged = function(_, targets)
    addon.lastTargets = targets
end

assert(loadfile("Scanner.lua"))("SafeEnchanter", namespace)

namespace.Scanner:ScanNow()
assert(#namespace.TargetList == 1, "default scan should include only one green BoE")
assert(namespace.TargetList[1].itemID == 1001, "green BoE should be first target")
assert(namespace.TargetIndex["0:1"] ~= nil, "target index should contain the bag slot")
assert(namespace.Scanner:HasFreeBagSlot(), "free bag slot should be detected")

addon.db.profile.qualities[3] = true
namespace.Scanner:ScanNow()
assert(#namespace.TargetList == 2, "rare opt-in should add the blue item")
assert(namespace.TargetList[1].itemID == 1003, "lower item level should sort first")

items[3].isLocked = true
assert(namespace.Scanner:IsTargetLocked(namespace.TargetList[1]), "current lock state should be read from the bag")

items[3] = nil
assert(not namespace.Scanner:IsTargetPresent(namespace.TargetList[1]), "removed target should become stale")

print("SafeEnchanter scanner tests passed")
