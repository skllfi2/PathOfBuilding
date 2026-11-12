"""
Generator for PoE1 ItemNamesRU.lua and GemNamesRU.lua
Reads official PoE1 localization exports from PoE2-Localization-Extractor/PathOfExile_Translated/dist/poe1/
Outputs clean, verified Lua dictionary modules into PathOfBuilding/src/Data/
"""
import json
import os
import sys

BASE_DIST = r"f:\Development\Dev\mydev\PoB2Fork\PoE2-Localization-Extractor\PathOfExile_Translated\dist\poe1"
OUT_DIR = r"f:\Development\Dev\mydev\PoB1Fork\PathOfBuilding\src\Data"


def escape_lua_str(s: str) -> str:
    return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '')


def generate_item_names():
    en_bases = json.load(open(os.path.join(BASE_DIST, "base_items", "en.json"), encoding="utf-8"))
    ru_bases = json.load(open(os.path.join(BASE_DIST, "base_items", "ru.json"), encoding="utf-8"))
    ru_uniques = json.load(open(os.path.join(BASE_DIST, "uniques", "ru.json"), encoding="utf-8"))

    # Map of English Name -> Russian Name
    item_map = {}

    # Base items
    for k, en_name in en_bases.items():
        if k in ru_bases and en_name and ru_bases[k]:
            en_clean = en_name.strip()
            ru_clean = ru_bases[k].strip()
            if en_clean and ru_clean:
                item_map[en_clean] = ru_clean

    # Uniques (keys are already English names!)
    for en_name, ru_name in ru_uniques.items():
        en_clean = en_name.strip()
        ru_clean = ru_name.strip()
        if en_clean and ru_clean:
            item_map[en_clean] = ru_clean

    # Common generic slot & item type categories for PoE1
    generic_types = {
        "Jewel": "Самоцвет",
        "Amulet": "Амулет",
        "Ring": "Кольцо",
        "Belt": "Пояс",
        "Flask": "Флакон",
        "Life Flask": "Флакон жизни",
        "Mana Flask": "Флакон маны",
        "Hybrid Flask": "Гибридный флакон",
        "Utility Flask": "Особый флакон",
        "Helmet": "Шлем",
        "Body Armour": "Доспех",
        "Gloves": "Перчатки",
        "Boots": "Обувь",
        "Shield": "Щит",
        "Quiver": "Колчан",
        "Bow": "Лук",
        "Claw": "Когти",
        "Dagger": "Кинжал",
        "Rune Dagger": "Рунический кинжал",
        "Wand": "Жезл",
        "One Hand Sword": "Одноручный меч",
        "Thrusting One Hand Sword": "Шпага",
        "One Hand Axe": "Одноручный топор",
        "One Hand Mace": "Одноручная булава",
        "Sceptre": "Скипетр",
        "Staff": "Посох",
        "Warstaff": "Воинский посох",
        "Two Hand Sword": "Двуручный меч",
        "Two Hand Axe": "Двуручный топор",
        "Two Hand Mace": "Двуручная булава",
        "Fishing Rod": "Удочка",
        "Map": "Карта",
        "Cluster Jewel": "Кластерный самоцвет",
        "Timeless Jewel": "Вневременной самоцвет",
        "Contract": "Контракт",
        "Blueprint": "Чертёж",
        "Heist Gear": "Снаряжение для Кражи",
        "Trinket": "Украшение",
        "Tincture": "Настойка",
        "Corpse": "Труп",
        "Relic": "Реликвия",
    }
    for k, v in generic_types.items():
        item_map[k] = v

    out_path = os.path.join(OUT_DIR, "ItemNamesRU.lua")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write('''-- Path of Building (PoE1)
-- Item names Russian dictionary
-- Maps base item types, unique items and generic slot categories to their Russian equivalents.
-- Translation source: official Path of Exile 1 localization (PathOfExile_Translated).

local ItemNamesRU = {}

---@type table<string, string>
ItemNamesRU.map = {
''')
        for en in sorted(item_map.keys()):
            ru = item_map[en]
            f.write(f'    ["{escape_lua_str(en)}"] = "{escape_lua_str(ru)}",\n')

        f.write('''};

--- Looks up the Russian translation for an item name.
--- Safe fallback: returns original English name if not found.
---@param enName string|nil
---@return string|nil
function ItemNamesRU:Get(enName)
    if not enName or type(enName) ~= "string" or enName == "" then
        return enName
    end

    local tr = self.map[enName]
    if tr then
        return tr
    end

    -- Strip leading Superior / quality prefixes if present
    local sup = enName:match("^Superior%s+(.+)$")
    if sup and self.map[sup] then
        return "Качественный " .. self.map[sup]
    end

    return enName
end

return ItemNamesRU
''')
    print(f"Generated ItemNamesRU.lua with {len(item_map)} entries -> {out_path}")


def generate_gem_names():
    en_gems = json.load(open(os.path.join(BASE_DIST, "gems", "en.json"), encoding="utf-8"))
    ru_gems = json.load(open(os.path.join(BASE_DIST, "gems", "ru.json"), encoding="utf-8"))

    gem_by_id = {}
    gem_by_name = {}

    for k, en_name in en_gems.items():
        if k in ru_gems and en_name and ru_gems[k]:
            en_clean = en_name.strip()
            ru_clean = ru_gems[k].strip()
            if en_clean and ru_clean:
                gem_by_id[k] = ru_clean
                gem_by_name[en_clean] = ru_clean

    # Common generic tags and types
    generic_tags = {
        "Support": "Поддержка",
        "Active": "Активный",
        "Attack": "Атака",
        "Spell": "Заклинание",
        "Curse": "Проклятие",
        "Aura": "Аура",
        "Minion": "Приспешники",
        "Cast": "Сотворение",
        "Melee": "Ближний бой",
        "Ranged": "Дальний бой",
        "Bow": "Лук",
        "Vaal": "Ваал",
        "Awakened": "Пробуждённый",
    }
    for k, v in generic_tags.items():
        if k not in gem_by_name:
            gem_by_name[k] = v

    out_path = os.path.join(OUT_DIR, "GemNamesRU.lua")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write('''-- Path of Building (PoE1)
-- Module: GemNamesRU
-- Russian localization display names for skill and support gems.
--
-- IMPORTANT: This is a DISPLAY-ONLY layer. Internal identifiers
-- (gemData.id, gemInstance.nameSpec, gemInstance.gemId, grantedEffectId)
-- remain untouched in English for build calculation and save compatibility.
-- This module is consulted only when rendering gem tooltips, lists and controls.
--
-- Auto-generated from official PoE1 localization exports.
--
local GemNamesRU = {}

--- Mapping of gem internal ID -> Russian display name
---@type table<string, string>
GemNamesRU.byGameId = {
''')
        for gid in sorted(gem_by_id.keys()):
            ru = gem_by_id[gid]
            f.write(f'    ["{escape_lua_str(gid)}"] = "{escape_lua_str(ru)}",\n')

        f.write('''};

--- Mapping of English gem name -> Russian display name
---@type table<string, string>
GemNamesRU.byName = {
''')
        for en in sorted(gem_by_name.keys()):
            ru = gem_by_name[en]
            f.write(f'    ["{escape_lua_str(en)}"] = "{escape_lua_str(ru)}",\n')

        f.write('''};

--- Looks up Russian translation for a skill/support gem.
--- Safe fallback: returns original English name if not found.
---@param gemOrName table|string|nil
---@return string|nil
function GemNamesRU:Get(gemOrName)
    if not gemOrName then
        return nil
    end
    local t = type(gemOrName)
    if t == "table" then
        local gid = gemOrName.gameId or gemOrName.id or gemOrName.gemId
        if gid and self.byGameId[gid] then
            return self.byGameId[gid]
        end
        local name = gemOrName.name or gemOrName.nameSpec
        if name and self.byName[name] then
            return self.byName[name]
        end
        return name
    elseif t == "string" then
        return self.byName[gemOrName] or self.byGameId[gemOrName] or gemOrName
    end
    return nil
end

return GemNamesRU
''')
    print(f"Generated GemNamesRU.lua with {len(gem_by_name)} name entries, {len(gem_by_id)} ID entries -> {out_path}")


if __name__ == "__main__":
    generate_item_names()
    generate_gem_names()
