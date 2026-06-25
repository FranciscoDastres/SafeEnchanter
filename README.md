# SafeEnchanter

SafeEnchanter is a manual-assisted disenchanting addon for **WoW: The Burning
Crusade Classic Anniversary 2.5.5** (`Interface 20505`). It scans the player's
bags, marks conservative disenchant candidates, predicts the possible materials,
and exposes one secure action for the item currently shown.

## Safety model

- One physical click attempts to disenchant exactly one displayed item.
- The protected action is a `SecureActionButtonTemplate` with spell `13262` and
  fixed `target-bag` and `target-slot` attributes.
- Inventory scans, timers, and events never cast a spell or use an item.
- The queue advances only after the spell and inventory change are confirmed.
- Loot is never collected automatically.
- The button is disabled in combat, while loot is open, when bags are full, or
  when the target is stale or locked.

This design is intended to remain inside the normal WoW addon security model. It
is not a certification or guarantee from Blizzard, and Blizzard may change or
disable addon APIs at any time.

## Default filters

- Unbound Bind-on-Equip weapons and armor only.
- Uncommon items enabled.
- Rare items opt-in.
- Epic items are never added to the action queue in this version.
- Equipment-set items, crafted enchanting wands, known non-disenchantable items,
  and user-protected item IDs are excluded.
- Optional maximum item-level filter; `0` means no maximum.

Predictions cover Vanilla and TBC material brackets and are approximate. There
is deliberately no prediction for uncommon items in the ilvl 66-78 gap, where
the source tables do not define a valid Anniversary result bracket.

## Installation

Copy the complete `SafeEnchanter` directory to:

```text
World of Warcraft/_anniversary_/Interface/AddOns/SafeEnchanter
```

The final directory must contain `SafeEnchanter.toc` and the bundled `Libs`
directory. Restart WoW or run `/reload` after installing.

## Commands

- `/safeenchanter config` or `/se config` opens the Ace3 configuration.
- `/safeenchanter rescan` rebuilds the informational queue.
- `/safeenchanter show`, `/safeenchanter hide`, and `/safeenchanter toggle`
  control the action panel.

Drag the small handle above the action button to reposition it. Use the close
button on the action panel to hide it when idle, then left-click the minimap
button to show it again. Right-click the minimap button to open options.

## Development checks

The pure rules tests can run outside WoW with a Lua interpreter:

```bash
lua tests/test_rules.lua
lua tests/test_scanner.lua
```

All protected behavior still requires an in-game test on TBC Anniversary. The
manual checklist is in `tests/IN_GAME_CHECKLIST.md`.

## Data provenance

The factual material IDs, ilvl brackets, quantities, and approximate
probabilities were reviewed on 2026-06-24 against the Classic/TBC disenchanting
tables and DisenchantBuddy v2.6.1. Item names are never hardcoded; WoW resolves
them from item IDs in the active locale.
