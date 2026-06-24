# TBC Anniversary in-game checklist

Run with only SafeEnchanter and its bundled Ace3 libraries enabled first. Enable
Lua errors and taint logging before compatibility testing with other addons.

## Loading and configuration

- Addon loads on Interface 20505 without Lua errors.
- `/safeenchanter config` opens the Ace3 panel.
- Profile changes and `/reload` preserve settings and button position.
- A non-enchanter sees predictions but cannot activate the action button.

## Filters and overlays

- Unbound green BoE armor and weapons are marked.
- White, BoP, soulbound, consumable, epic, equipment-set, protected, and known
  non-disenchantable items are not marked.
- Rare items appear only after explicitly enabling the rare filter.
- The maximum-ilvl setting excludes only items above the configured value.
- Moving, selling, equipping, or sorting a marked item immediately disarms the
  button until the delayed rescan completes.
- Overlay marks update when each standard Blizzard bag opens or refreshes.

## Tooltips and data

- Green armor and weapons show different dust/essence probabilities.
- Blue items show the appropriate shard bracket.
- Vanilla and Outland items resolve localized material names and quantities.
- Repeated tooltip refreshes do not duplicate prediction lines.

## Protected action

- The button shows the exact item, ilvl, and queue size before it is enabled.
- One click targets and destroys only the displayed item.
- No second item is processed without another physical click.
- Cancelling or interrupting the cast leaves the item queued.
- A successful cast advances only after the inventory change is observed.
- The button stays disabled during combat, with full bags, while the item is
  locked, and while a loot window remains open.
- With auto-loot off, the addon does not collect the resulting material.
- Taint logs contain no SafeEnchanter protected-action failures.
