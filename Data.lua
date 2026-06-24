local _, NS = ...

-- Probabilities are approximate. The table is intentionally restricted to
-- Vanilla and Burning Crusade materials available on the Anniversary client.
-- Reference dataset reviewed against DisenchantBuddy v2.6.1 (2026-05-18)
-- and the documented Classic/TBC disenchanting brackets.

local M = {
    STRANGE_DUST = 10940,
    SOUL_DUST = 11083,
    VISION_DUST = 11137,
    DREAM_DUST = 11176,
    ILLUSION_DUST = 16204,
    LESSER_MAGIC_ESSENCE = 10938,
    GREATER_MAGIC_ESSENCE = 10939,
    LESSER_ASTRAL_ESSENCE = 10998,
    GREATER_ASTRAL_ESSENCE = 11082,
    LESSER_MYSTIC_ESSENCE = 11134,
    GREATER_MYSTIC_ESSENCE = 11135,
    LESSER_NETHER_ESSENCE = 11174,
    GREATER_NETHER_ESSENCE = 11175,
    LESSER_ETERNAL_ESSENCE = 16202,
    GREATER_ETERNAL_ESSENCE = 16203,
    SMALL_GLIMMERING_SHARD = 10978,
    LARGE_GLIMMERING_SHARD = 11084,
    SMALL_GLOWING_SHARD = 11138,
    LARGE_GLOWING_SHARD = 11139,
    SMALL_RADIANT_SHARD = 11177,
    LARGE_RADIANT_SHARD = 11178,
    SMALL_BRILLIANT_SHARD = 14343,
    LARGE_BRILLIANT_SHARD = 14344,
    NEXUS_CRYSTAL = 20725,
    ARCANE_DUST = 22445,
    LESSER_PLANAR_ESSENCE = 22447,
    GREATER_PLANAR_ESSENCE = 22446,
    SMALL_PRISMATIC_SHARD = 22448,
    LARGE_PRISMATIC_SHARD = 22449,
    VOID_CRYSTAL = 22450,
}

local function outcome(itemID, chance, minimum, maximum)
    return {
        itemID = itemID,
        chance = chance,
        minQuantity = minimum,
        maxQuantity = maximum,
    }
end

local function rule(quality, classID, minimum, maximum, outcomes)
    return {
        quality = quality,
        classID = classID,
        minItemLevel = minimum,
        maxItemLevel = maximum,
        outcomes = outcomes,
    }
end

local Q_UNCOMMON = 2
local Q_RARE = 3
local WEAPON = 2
local ARMOR = 4

local rules = {
    -- Uncommon armor.
    rule(Q_UNCOMMON, ARMOR, 1, 15, {
        outcome(M.STRANGE_DUST, 80, 1, 2), outcome(M.LESSER_MAGIC_ESSENCE, 20, 1, 2),
    }),
    rule(Q_UNCOMMON, ARMOR, 16, 20, {
        outcome(M.STRANGE_DUST, 75, 2, 3), outcome(M.GREATER_MAGIC_ESSENCE, 20, 1, 2), outcome(M.SMALL_GLIMMERING_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, ARMOR, 21, 25, {
        outcome(M.STRANGE_DUST, 75, 4, 6), outcome(M.LESSER_ASTRAL_ESSENCE, 15, 1, 2), outcome(M.SMALL_GLIMMERING_SHARD, 10, 1, 1),
    }),
    rule(Q_UNCOMMON, ARMOR, 26, 30, {
        outcome(M.SOUL_DUST, 75, 1, 2), outcome(M.GREATER_ASTRAL_ESSENCE, 20, 1, 2), outcome(M.LARGE_GLIMMERING_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, ARMOR, 31, 35, {
        outcome(M.SOUL_DUST, 75, 2, 5), outcome(M.LESSER_MYSTIC_ESSENCE, 20, 1, 2), outcome(M.SMALL_GLOWING_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, ARMOR, 36, 40, {
        outcome(M.VISION_DUST, 75, 1, 2), outcome(M.GREATER_MYSTIC_ESSENCE, 20, 1, 2), outcome(M.LARGE_GLOWING_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, ARMOR, 41, 45, {
        outcome(M.VISION_DUST, 75, 2, 5), outcome(M.LESSER_NETHER_ESSENCE, 20, 1, 2), outcome(M.SMALL_RADIANT_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, ARMOR, 46, 50, {
        outcome(M.DREAM_DUST, 75, 1, 2), outcome(M.GREATER_NETHER_ESSENCE, 20, 1, 2), outcome(M.LARGE_RADIANT_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, ARMOR, 51, 55, {
        outcome(M.DREAM_DUST, 75, 2, 6), outcome(M.LESSER_ETERNAL_ESSENCE, 20, 1, 2), outcome(M.SMALL_BRILLIANT_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, ARMOR, 56, 60, {
        outcome(M.ILLUSION_DUST, 75, 1, 2), outcome(M.GREATER_ETERNAL_ESSENCE, 20, 1, 2), outcome(M.LARGE_BRILLIANT_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, ARMOR, 61, 65, {
        outcome(M.ILLUSION_DUST, 75, 2, 5), outcome(M.GREATER_ETERNAL_ESSENCE, 20, 2, 3), outcome(M.LARGE_BRILLIANT_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, ARMOR, 79, 99, {
        outcome(M.ARCANE_DUST, 75, 2, 4), outcome(M.LESSER_PLANAR_ESSENCE, 22, 2, 4), outcome(M.SMALL_PRISMATIC_SHARD, 3, 1, 1),
    }),
    rule(Q_UNCOMMON, ARMOR, 100, 120, {
        outcome(M.ARCANE_DUST, 75, 2, 5), outcome(M.GREATER_PLANAR_ESSENCE, 22, 1, 2), outcome(M.LARGE_PRISMATIC_SHARD, 3, 1, 1),
    }),

    -- Uncommon weapons.
    rule(Q_UNCOMMON, WEAPON, 1, 15, {
        outcome(M.LESSER_MAGIC_ESSENCE, 80, 1, 2), outcome(M.STRANGE_DUST, 20, 1, 2),
    }),
    rule(Q_UNCOMMON, WEAPON, 16, 20, {
        outcome(M.GREATER_MAGIC_ESSENCE, 75, 1, 2), outcome(M.STRANGE_DUST, 20, 2, 3), outcome(M.SMALL_GLIMMERING_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, WEAPON, 21, 25, {
        outcome(M.LESSER_ASTRAL_ESSENCE, 75, 1, 2), outcome(M.STRANGE_DUST, 15, 4, 6), outcome(M.SMALL_GLIMMERING_SHARD, 10, 1, 1),
    }),
    rule(Q_UNCOMMON, WEAPON, 26, 30, {
        outcome(M.GREATER_ASTRAL_ESSENCE, 75, 1, 2), outcome(M.SOUL_DUST, 20, 1, 2), outcome(M.LARGE_GLIMMERING_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, WEAPON, 31, 35, {
        outcome(M.LESSER_MYSTIC_ESSENCE, 75, 1, 2), outcome(M.SOUL_DUST, 20, 2, 5), outcome(M.SMALL_GLOWING_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, WEAPON, 36, 40, {
        outcome(M.GREATER_MYSTIC_ESSENCE, 75, 1, 2), outcome(M.VISION_DUST, 20, 1, 2), outcome(M.LARGE_GLOWING_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, WEAPON, 41, 45, {
        outcome(M.LESSER_NETHER_ESSENCE, 75, 1, 2), outcome(M.VISION_DUST, 20, 2, 5), outcome(M.SMALL_RADIANT_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, WEAPON, 46, 50, {
        outcome(M.GREATER_NETHER_ESSENCE, 75, 1, 2), outcome(M.DREAM_DUST, 20, 1, 2), outcome(M.LARGE_RADIANT_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, WEAPON, 51, 55, {
        outcome(M.LESSER_ETERNAL_ESSENCE, 75, 1, 2), outcome(M.DREAM_DUST, 20, 2, 5), outcome(M.SMALL_BRILLIANT_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, WEAPON, 56, 60, {
        outcome(M.GREATER_ETERNAL_ESSENCE, 75, 1, 2), outcome(M.ILLUSION_DUST, 20, 1, 2), outcome(M.LARGE_BRILLIANT_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, WEAPON, 61, 65, {
        outcome(M.GREATER_ETERNAL_ESSENCE, 75, 2, 3), outcome(M.ILLUSION_DUST, 20, 2, 5), outcome(M.LARGE_BRILLIANT_SHARD, 5, 1, 1),
    }),
    rule(Q_UNCOMMON, WEAPON, 79, 99, {
        outcome(M.LESSER_PLANAR_ESSENCE, 75, 2, 3), outcome(M.ARCANE_DUST, 22, 2, 3), outcome(M.SMALL_PRISMATIC_SHARD, 3, 1, 1),
    }),
    rule(Q_UNCOMMON, WEAPON, 100, 120, {
        outcome(M.GREATER_PLANAR_ESSENCE, 75, 1, 2), outcome(M.ARCANE_DUST, 22, 2, 5), outcome(M.LARGE_PRISMATIC_SHARD, 3, 1, 1),
    }),

    -- Rare armor and weapons share the same result table.
    rule(Q_RARE, nil, 1, 25, { outcome(M.SMALL_GLIMMERING_SHARD, 100, 1, 1) }),
    rule(Q_RARE, nil, 26, 30, { outcome(M.LARGE_GLIMMERING_SHARD, 100, 1, 1) }),
    rule(Q_RARE, nil, 31, 35, { outcome(M.SMALL_GLOWING_SHARD, 100, 1, 1) }),
    rule(Q_RARE, nil, 36, 40, { outcome(M.LARGE_GLOWING_SHARD, 100, 1, 1) }),
    rule(Q_RARE, nil, 41, 45, { outcome(M.SMALL_RADIANT_SHARD, 100, 1, 1) }),
    rule(Q_RARE, nil, 46, 50, { outcome(M.LARGE_RADIANT_SHARD, 100, 1, 1) }),
    rule(Q_RARE, nil, 51, 55, { outcome(M.SMALL_BRILLIANT_SHARD, 100, 1, 1) }),
    rule(Q_RARE, nil, 56, 74, {
        outcome(M.LARGE_BRILLIANT_SHARD, 99.5, 1, 1), outcome(M.NEXUS_CRYSTAL, 0.5, 1, 1),
    }),
    rule(Q_RARE, nil, 75, 99, {
        outcome(M.SMALL_PRISMATIC_SHARD, 99.5, 1, 1), outcome(M.NEXUS_CRYSTAL, 0.5, 1, 1),
    }),
    rule(Q_RARE, nil, 100, 117, {
        outcome(M.LARGE_PRISMATIC_SHARD, 99.5, 1, 1), outcome(M.VOID_CRYSTAL, 0.5, 1, 1),
    }),
}

NS.Data = {
    Materials = M,
    Rules = rules,
    BlockedItemIDs = {
        [11287] = true, -- Lesser Magic Wand
        [11288] = true, -- Greater Magic Wand
        [11289] = true, -- Lesser Mystic Wand
        [11290] = true, -- Greater Mystic Wand
        [20406] = true, -- Twilight Cultist Mantle
        [20407] = true, -- Twilight Cultist Robe
        [20408] = true, -- Twilight Cultist Cowl
    },
    Source = {
        name = "Classic/TBC disenchanting brackets",
        reviewed = "2026-06-24",
        probabilitiesAreApproximate = true,
    },
}
