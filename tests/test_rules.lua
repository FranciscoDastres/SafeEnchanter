local namespace = {
    ITEM_CLASS_WEAPON = 2,
    ITEM_CLASS_ARMOR = 4,
    ITEM_QUALITY_UNCOMMON = 2,
    ITEM_QUALITY_RARE = 3,
    ITEM_BIND_ON_EQUIP = 2,
}

assert(loadfile("Data.lua"))("SafeEnchanter", namespace)
assert(loadfile("Rules.lua"))("SafeEnchanter", namespace)
assert(loadfile("ActionState.lua"))("SafeEnchanter", namespace)

local function equal(actual, expected, label)
    assert(actual == expected, string.format("%s: expected %s, got %s", label, tostring(expected), tostring(actual)))
end

local armorResults = namespace.Rules.GetOutcomes(2, 4, 100)
equal(#armorResults, 3, "TBC uncommon armor has three outcomes")
equal(armorResults[1].itemID, 22445, "TBC armor yields Arcane Dust")
equal(armorResults[1].chance, 75, "TBC armor dust probability")

local weaponResults = namespace.Rules.GetOutcomes(2, 2, 100)
equal(weaponResults[1].itemID, 22446, "TBC weapon yields Greater Planar Essence")
equal(namespace.Rules.GetOutcomes(2, 4, 70), nil, "unsupported ilvl gap")

local profile = {
    enabled = true,
    qualities = { [2] = true, [3] = false },
    maxItemLevel = 0,
    protectedItemIDs = {},
}
local candidate = {
    itemID = 12345,
    itemLevel = 100,
    quality = 2,
    classID = 4,
    bindType = 2,
    isBound = false,
    inEquipmentSet = false,
}

equal(namespace.Rules.EvaluateCandidate(candidate, profile), true, "valid BoE uncommon")

candidate.isBound = true
local eligible, reason = namespace.Rules.EvaluateCandidate(candidate, profile)
equal(eligible, false, "bound item excluded")
equal(reason, "bound", "bound exclusion reason")
candidate.isBound = false

candidate.quality = 3
equal(namespace.Rules.EvaluateCandidate(candidate, profile), false, "rare disabled by default")
profile.qualities[3] = true
equal(namespace.Rules.EvaluateCandidate(candidate, profile), true, "rare opt-in")

candidate.quality = 2
profile.maxItemLevel = 99
equal(namespace.Rules.EvaluateCandidate(candidate, profile), false, "maximum ilvl")
profile.maxItemLevel = 0

profile.protectedItemIDs[candidate.itemID] = true
equal(namespace.Rules.EvaluateCandidate(candidate, profile), false, "protected item")
profile.protectedItemIDs[candidate.itemID] = nil

local targets = {
    { itemLevel = 100, quality = 2, bag = 2, slot = 1 },
    { itemLevel = 80, quality = 3, bag = 0, slot = 2 },
    { itemLevel = 80, quality = 2, bag = 4, slot = 3 },
}
namespace.Rules.SortTargets(targets)
equal(targets[1].quality, 2, "sort by quality after ilvl")
equal(targets[3].itemLevel, 100, "higher ilvl last")

local actionState = namespace.ActionState:New()
local pending = actionState:Begin({ itemID = 12345 }, 10)
equal(actionState:IsComplete(), false, "new action is incomplete")
equal(actionState:MarkSpellSucceeded(), false, "spell alone does not advance")
equal(actionState:MarkInventoryChanged(), true, "spell plus inventory change advances")
equal(actionState:IsCurrent(pending), true, "pending identity")
equal(actionState:Clear().target.itemID, 12345, "clear returns completed target")
equal(actionState.pending, nil, "clear resets state")

actionState:Begin({ itemID = 54321 }, 20)
equal(actionState:MarkInventoryChanged(), false, "inventory change alone does not advance")
equal(actionState:MarkSpellSucceeded(), true, "event ordering is independent")

print("SafeEnchanter rules tests passed")
