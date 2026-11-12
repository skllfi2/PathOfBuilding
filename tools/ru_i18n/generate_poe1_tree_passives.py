"""
Generator for PoE1 TreePassivesRU.lua
Builds:
1. TreePassivesRU.statsBySkill - table of Russian stat line arrays for each tree passive node skill ID.
   Chunks functions into batches of <= 150 entries to avoid LuaJIT 200 local variables limit.
2. TreePassivesRU.flavourBySkill - table of Russian flavour texts for ascendancies/keystones.
3. Fallback GetStats(node) and GetFlavour(node) methods.
Outputs verified TreePassivesRU.lua into src/Data/
"""
import json
import os
import re

TREE_FILE = r"f:\Development\Dev\mydev\PoB1Fork\PathOfBuilding\src\TreeData\3_26\tree.lua"
BASE_DIST = r"f:\Development\Dev\mydev\PoB2Fork\PoE2-Localization-Extractor\PathOfExile_Translated\dist\poe1"
MOD_FILE = r"f:\Development\Dev\mydev\PoB1Fork\PathOfBuilding\src\Data\ModTranslationsRU.lua"
OUT_FILE = r"f:\Development\Dev\mydev\PoB1Fork\PathOfBuilding\src\Data\TreePassivesRU.lua"


def escape_lua_str(s: str) -> str:
    return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '')


def main():
    # 1. Load ModTranslationsRU for translating stat lines
    mod_code = open(MOD_FILE, encoding="utf-8").read()
    pos_tpl = mod_code.find('ModTranslationsRU.templates =')
    pos_rules = mod_code.find('ModTranslationsRU.specialRules =')
    exact = dict(re.findall(r'\[\"([^\"]+)\"\]\s*=\s*\"([^\"]+)\"', mod_code[:pos_tpl]))
    tpl = dict(re.findall(r'\[\"([^\"]+)\"\]\s*=\s*\"([^\"]+)\"', mod_code[pos_tpl:pos_rules]))

    # 2. Load flavour texts
    en_flavour = json.load(open(os.path.join(BASE_DIST, "flavour", "en.json"), encoding="utf-8"))
    ru_flavour = json.load(open(os.path.join(BASE_DIST, "flavour", "ru.json"), encoding="utf-8"))
    flavour_map = {}
    for k, en in en_flavour.items():
        if k in ru_flavour and en and ru_flavour[k]:
            clean_en = en.strip().replace('\r', '')
            clean_ru = ru_flavour[k].strip().replace('\r', '')
            flavour_map[clean_en] = clean_ru

    # 3. Parse tree.lua
    tree_code = open(TREE_FILE, encoding="utf-8").read()
    nodes = re.findall(r'\[\"skill\"\]\s*=\s*(\d+)[^}]+?\[\"stats\"\]\s*=\s*\{([^}]+)\}', tree_code)

    pat = r'^([%+%-]?\d+[\.\d]*%?)\s+(.+)$'

    skill_stats = {}
    for sid_str, raw in nodes:
        sid = int(sid_str)
        lines = [l.strip() for l in re.findall(r'\"([^\"]+)\"', raw)]
        ru_lines = []
        has_any = False
        for l in lines:
            if l in exact:
                ru_lines.append(exact[l])
                has_any = True
            elif l in tpl:
                ru_lines.append(tpl[l])
                has_any = True
            else:
                m = re.match(pat, l)
                if m and m.group(2) in tpl:
                    ru_lines.append(m.group(1) + ' ' + tpl[m.group(2)])
                    has_any = True
                else:
                    ru_lines.append(l)
        if has_any:
            skill_stats[sid] = ru_lines

    print(f"Mapped stats for {len(skill_stats)} passive skills")

    # 4. Generate Lua file with chunked functions
    CHUNK_SIZE = 120
    sorted_skills = sorted(skill_stats.keys())
    chunks = [sorted_skills[i:i + CHUNK_SIZE] for i in range(0, len(sorted_skills), CHUNK_SIZE)]

    with open(OUT_FILE, "w", encoding="utf-8") as f:
        f.write('''-- Path of Building (PoE1)
-- Module: TreePassivesRU
-- Russian localization for passive skill tree node stats and flavour text.
--
-- Auto-generated from official PoE1 localization exports.
-- DISPLAY-ONLY LAYER. Internal IDs remain in English.
--
local TreePassivesRU = {}

--- statsBySkill[skill] = { "RU stat line 1", "RU stat line 2", ... }
---@type table<number, string[]>
TreePassivesRU.statsBySkill = {}

--- flavourBySkill[skill] = "RU flavour text"
---@type table<number, string>
TreePassivesRU.flavourBySkill = {}
''')

        for idx, chunk in enumerate(chunks):
            f.write(f"\nlocal function init_stats_{idx + 1}(S)\n")
            f.write("    local t = {\n")
            for sid in chunk:
                f.write(f"        [{sid}] = {{\n")
                for line in skill_stats[sid]:
                    f.write(f'            "{escape_lua_str(line)}",\n')
                f.write("        },\n")
            f.write("    }\n")
            f.write("    for k, v in pairs(t) do S[k] = v end\n")
            f.write("end\n")

        f.write("\n-- Initialize stat chunks\n")
        for idx in range(len(chunks)):
            f.write(f"init_stats_{idx + 1}(TreePassivesRU.statsBySkill)\n")

        f.write('''
--- Looks up Russian translated stats for a passive tree node.
--- Safe fallback: returns nil if no translation found.
---@param node table|number|nil
---@return string[]|nil
function TreePassivesRU:GetStats(node)
    if not node then
        return nil
    end
    local sid = type(node) == "table" and node.skill or node
    if sid and self.statsBySkill[sid] then
        return self.statsBySkill[sid]
    end
    return nil
end

--- Looks up Russian flavour text for a node.
---@param node table|number|nil
---@return string|nil
function TreePassivesRU:GetFlavour(node)
    if not node then
        return nil
    end
    local sid = type(node) == "table" and node.skill or node
    if sid and self.flavourBySkill[sid] then
        return self.flavourBySkill[sid]
    end
    return nil
end

return TreePassivesRU
''')

    print(f"Generated {OUT_FILE} with {len(chunks)} chunks")


if __name__ == "__main__":
    main()
