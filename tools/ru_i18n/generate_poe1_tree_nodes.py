"""
Generator for PoE1 TreeNodesRU.lua
Combines:
1. passives/en.json & passives/ru.json (3574 passive nodes)
2. cluster_jewel_notables/en.json & ru.json (309 notables)
3. Ascendancy classes & characters (19 ascendancies + 7 base classes)
4. Fallback overrides for legacy ascendancy notables (Deadly Infusion, Ambush and Assassinate, etc.)
5. Extracts all skill IDs and names from src/TreeData/3_26/tree.lua
Outputs verified TreeNodesRU.lua module into src/Data/
"""
import json
import os
import re

BASE_DIST = r"f:\Development\Dev\mydev\PoB2Fork\PoE2-Localization-Extractor\PathOfExile_Translated\dist\poe1"
TREE_FILE = r"f:\Development\Dev\mydev\PoB1Fork\PathOfBuilding\src\TreeData\3_26\tree.lua"
OUT_FILE = r"f:\Development\Dev\mydev\PoB1Fork\PathOfBuilding\src\Data\TreeNodesRU.lua"


def escape_lua_str(s: str) -> str:
    return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '')


def main():
    en_passives = json.load(open(os.path.join(BASE_DIST, "passives", "en.json"), encoding="utf-8"))
    ru_passives = json.load(open(os.path.join(BASE_DIST, "passives", "ru.json"), encoding="utf-8"))
    en_clusters = json.load(open(os.path.join(BASE_DIST, "cluster_jewel_notables", "en.json"), encoding="utf-8"))
    ru_clusters = json.load(open(os.path.join(BASE_DIST, "cluster_jewel_notables", "ru.json"), encoding="utf-8"))

    # Map of English Name -> Russian Name
    by_name = {}

    for k, en in en_passives.items():
        if k in ru_passives and en and ru_passives[k]:
            by_name[en.strip()] = ru_passives[k].strip()

    for k, en in en_clusters.items():
        if k in ru_clusters and en and ru_clusters[k]:
            by_name[en.strip()] = ru_clusters[k].strip()

    # Base classes & Ascendancies in PoE1
    classes_and_ascendancies = {
        "Scion": "Дворянка",
        "Marauder": "Дикарь",
        "Ranger": "Охотница",
        "Witch": "Ведьма",
        "Duelist": "Дуэлянт",
        "Templar": "Жрец",
        "Shadow": "Бандит",
        # Ascendancies
        "Ascendant": "Вознесшаяся",
        "Juggernaut": "Покоритель",
        "Berserker": "Берсерк",
        "Chieftain": "Вождь",
        "Raider": "Налётчица",
        "Deadeye": "Снайпер",
        "Pathfinder": "Следопыт",
        "Necromancer": "Некромант",
        "Elementalist": "Маг стихий",
        "Occultist": "Оккультистка",
        "Slayer": "Палач",
        "Gladiator": "Гладиатор",
        "Champion": "Чемпион",
        "Inquisitor": "Инквизитор",
        "Hierophant": "Иерофант",
        "Guardian": "Защитник",
        "Assassin": "Убийца",
        "Trickster": "Плут",
        "Saboteur": "Диверсант",
    }
    by_name.update(classes_and_ascendancies)

    # Legacy / special notables overrides
    overrides = {
        "Deadly Infusion": "Губительное насыщение",
        "Ambush and Assassinate": "Засада и ликвидация",
        "Noxious Strike": "Губительный удар",
        "Harness the Void": "Использование Пустоты",
        "Fatal Flourish": "Росчерк смерти",
        "Indomitable Resolve": "Неукротимая решимость",
        "Nine Lives": "Девять жизней",
        "Fury of Nature": "Ярость природы",
        "Searing Purity": "Опаляющая чистота",
    }
    by_name.update(overrides)

    # Masteries and wheel small passives
    try:
        from mastery_dict import mastery_translations
        by_name.update(mastery_translations)
    except ImportError:
        import sys
        sys.path.append(os.path.dirname(__file__))
        from mastery_dict import mastery_translations
        by_name.update(mastery_translations)

    # Parse all tree.lua files to map skill IDs directly across all versions
    import glob
    by_skill = {}
    for t_path in glob.glob(r"f:\Development\Dev\mydev\PoB1Fork\PathOfBuilding\src\TreeData\*\tree.lua"):
        t_code = open(t_path, encoding="utf-8", errors="ignore").read()
        node_blocks = re.findall(r'\[\"skill\"\]\s*=\s*(\d+)[^}]+?\[\"name\"\]\s*=\s*\"([^\"]+)\"', t_code)
        for sid_str, name in node_blocks:
            sid = int(sid_str)
            clean_name = name.strip()
            if clean_name in by_name:
                by_skill[sid] = by_name[clean_name]

    print(f"Mapped {len(by_name)} unique names, {len(by_skill)} tree skill IDs across all tree versions")

    with open(OUT_FILE, "w", encoding="utf-8") as f:
        f.write('''-- Path of Building (PoE1)
-- Module: TreeNodesRU
-- Russian localization display names for passive skill tree nodes.
-- (Keystones, Notables, Basic/Normal passives, Masteries, Ascendancies and Cluster Jewels).
--
-- IMPORTANT: This is a DISPLAY-ONLY layer. Internal identifiers
-- (node.id, node.skill, node.sd, node.mods) remain untouched in English.
-- This module is consulted only when rendering node tooltips and passive tree search.
--
-- Auto-generated from official PoE1 localization exports.
--
local TreeNodesRU = {}

--- Mapping of node skill/hash ID -> Russian display name
---@type table<number, string>
TreeNodesRU.bySkill = {
''')
        for sid in sorted(by_skill.keys()):
            ru = by_skill[sid]
            f.write(f'    [{sid}] = "{escape_lua_str(ru)}",\n')

        f.write('''};

--- Mapping of English node name -> Russian display name
---@type table<string, string>
TreeNodesRU.byName = {
''')
        for en in sorted(by_name.keys()):
            ru = by_name[en]
            f.write(f'    ["{escape_lua_str(en)}"] = "{escape_lua_str(ru)}",\n')

        f.write('''};

--- Looks up Russian translation for a tree node.
--- Safe fallback: returns original English name if not found.
---@param node table|string|number|nil
---@return string|nil
function TreeNodesRU:Get(node)
    if not node then
        return nil
    end
    local t = type(node)
    if t == "table" then
        if node.skill and self.bySkill[node.skill] then
            return self.bySkill[node.skill]
        end
        if node.dn and self.byName[node.dn] then
            return self.byName[node.dn]
        end
        if node.name and self.byName[node.name] then
            return self.byName[node.name]
        end
        return node.dn or node.name
    elseif t == "number" then
        return self.bySkill[node]
    elseif t == "string" then
        return self.byName[node] or node
    end
    return nil
end

return TreeNodesRU
''')

    print(f"Generated {OUT_FILE}")


if __name__ == "__main__":
    main()
