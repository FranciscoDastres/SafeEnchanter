local addonName, NS = ...

NS.ADDON_NAME = addonName
NS.VERSION = "0.1.0"
NS.DISENCHANT_SPELL_ID = 13262
NS.ITEM_CLASS_WEAPON = 2
NS.ITEM_CLASS_ARMOR = 4
NS.ITEM_QUALITY_UNCOMMON = 2
NS.ITEM_QUALITY_RARE = 3
NS.ITEM_BIND_ON_EQUIP = 2

NS.Addon = LibStub("AceAddon-3.0"):NewAddon(
    "SafeEnchanter",
    "AceConsole-3.0"
)

NS.TargetList = {}
NS.TargetIndex = {}
