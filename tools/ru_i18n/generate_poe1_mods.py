import os
import json
import re

BASE_DIST = r"f:\Development\Dev\mydev\PoB2Fork\PoE2-Localization-Extractor\PathOfExile_Translated\dist\poe1"
STAT_DIR = os.path.join(BASE_DIST, "stat_translations")
OUT_FILE = r"f:\Development\Dev\mydev\PoB1Fork\PathOfBuilding\src\Data\ModTranslationsRU.lua"


def escape_lua_str(s: str) -> str:
    return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '')


def lua_pattern_escape(s: str) -> str:
    magic = "^$()%.[]*+-?"
    res = []
    for ch in s:
        if ch in magic:
            res.append('%' + ch)
        elif ch.isspace():
            res.append('%s+')
        else:
            res.append(ch)
    return ''.join(res)


def main():
    all_pairs = {}

    # 1. Root stat_translations
    root_en = json.load(open(os.path.join(STAT_DIR, "en.json"), encoding="utf-8"))
    root_ru = json.load(open(os.path.join(STAT_DIR, "ru.json"), encoding="utf-8"))
    for k, v in root_en.items():
        if k in root_ru and v and root_ru[k]:
            all_pairs[v.strip()] = root_ru[k].strip()

    # 2. Subdirectories in stat_translations (skill, atlas, active_skill_gem, support_gem, etc.)
    for sub in sorted(os.listdir(STAT_DIR)):
        subpath = os.path.join(STAT_DIR, sub)
        if os.path.isdir(subpath):
            en_f = os.path.join(subpath, "en.json")
            ru_f = os.path.join(subpath, "ru.json")
            if os.path.exists(en_f) and os.path.exists(ru_f):
                s_en = json.load(open(en_f, encoding="utf-8"))
                s_ru = json.load(open(ru_f, encoding="utf-8"))
                for k, v in s_en.items():
                    if k in s_ru and v and s_ru[k]:
                        all_pairs[v.strip()] = s_ru[k].strip()

    # 3. Also load mods (explicit unique / rare mod descriptions)
    mods_en = json.load(open(os.path.join(BASE_DIST, "mods", "en.json"), encoding="utf-8"))
    mods_ru = json.load(open(os.path.join(BASE_DIST, "mods", "ru.json"), encoding="utf-8"))
    for k, v in mods_en.items():
        if k in mods_ru and v and mods_ru[k]:
            all_pairs[v.strip()] = mods_ru[k].strip()

    # Split multi-line entries into individual line pairs
    for en_clean, ru_clean in list(all_pairs.items()):
        if '\n' in en_clean or '\n' in ru_clean:
            en_lines = [l.strip() for l in en_clean.split('\n') if l.strip()]
            ru_lines = [l.strip() for l in ru_clean.split('\n') if l.strip()]
            if len(en_lines) == len(ru_lines):
                for el, rl in zip(en_lines, ru_lines):
                    all_pairs[el] = rl

    exact = {}
    templates = {}
    hash_templates = {}
    special_rules = []

    for en_clean, ru_clean in all_pairs.items():
        if not en_clean or not ru_clean:
            continue
        c_en = en_clean.count('#')
        c_ru = ru_clean.count('#')

        # 1. Exact strings (no placeholder)
        if c_en == 0 and c_ru == 0 and '{0}' not in en_clean:
            exact[en_clean] = ru_clean
            continue

        # 2. Leading number prefix template (e.g. "#% increased Attack Speed")
        m_en = re.match(r'^([\+–\-]?#%?)\s+(.+)$', en_clean)
        if m_en and c_en == 1 and c_ru == 1:
            en_tail = m_en.group(2).strip()
            m_ru = re.match(r'^([\+–\-]?#%?)\s+(.+)$', ru_clean)
            if m_ru and en_tail.count('#') == 0:
                templates[en_tail] = m_ru.group(2).strip()
            elif en_tail.count('#') == 0:
                ru_tpl = ru_clean.replace('#%', '%1').replace('#', '%1')
                templates[en_tail] = ru_tpl

        # 3. Two-number patterns (Adds # to # Fire Damage -> Добавляет от %1 до %2 урона от огня)
        if c_en == 2 and c_ru == 2:
            m_two = re.match(r'^(Adds|Deals)\s+#\s+to\s+#\s+(.+)$', en_clean, re.IGNORECASE)
            m_two_ru = re.match(r'^(Добавляет|Наносит)\s+от\s+#\s+до\s+#\s+(.+)$', ru_clean, re.IGNORECASE)
            if m_two and m_two_ru:
                en_verb = m_two.group(1)
                en_mid = m_two.group(2).strip()
                ru_verb = m_two_ru.group(1)
                ru_mid = m_two_ru.group(2).strip()

                pat = f"^{en_verb}%s+([%+%-]?%(?[%d%.%-–]+%)?%%?)%s+to%s+([%+%-]?%(?[%d%.%-–]+%)?%%?)%s+{lua_pattern_escape(en_mid)}$"
                repl = f"{ru_verb} от %1 до %2 {ru_mid}"
                special_rules.append((pat, repl))

        # 4. Hash templates for fast O(1) canonical matching of all other # patterns
        if c_en >= 1 and c_en == c_ru:
            parts = ru_clean.split('#')
            rebuilt = []
            for i, part in enumerate(parts):
                rebuilt.append(part)
                if i < len(parts) - 1:
                    rebuilt.append(f"%{i+1}")
            ru_indexed = "".join(rebuilt)
            hash_key = en_clean.lower().strip()
            hash_templates[hash_key] = ru_indexed

    # De-duplicate special rules
    seen_pats = set()
    dedup_special = []
    for pat, repl in special_rules:
        if pat not in seen_pats:
            seen_pats.add(pat)
            dedup_special.append((pat, repl))
    special_rules = dedup_special

    print(f"Extracted {len(exact)} exact phrases, {len(templates)} templates, {len(hash_templates)} hash templates, {len(special_rules)} special rules")

    with open(OUT_FILE, "w", encoding="utf-8") as f:
        f.write('''-- Path of Building (PoE1)
-- Module: ModTranslationsRU
-- Russian localization display names and templates for item modifiers.
-- (Implicits, Prefixes, Suffixes, Corrupted mods, Enchants, Eldritch, Crucible, Skills & Atlas).
--
-- IMPORTANT: This is a DISPLAY-ONLY layer. Internal identifiers
-- (modLine.line, modLine.modList, ModDB) remain untouched in English.
-- This module is consulted only when rendering item tooltip mod lines.
--
-- Auto-generated from official PoE1 localization exports.
--
local RULogger = LoadModule("Modules/RULogger")
local TreeNodesRU = LoadModule("Data/TreeNodesRU")
local GemNamesRU = LoadModule("Data/GemNamesRU")

local ModTranslationsRU = {}

--- Exact full line translations
---@type table<string, string>
ModTranslationsRU.exact = {
''')
        for en in sorted(exact.keys()):
            ru = exact[en]
            f.write(f'    ["{escape_lua_str(en)}"] = "{escape_lua_str(ru)}",\n')

        f.write('''};

--- Templates for numeric prefix modifiers (+75 to maximum Life -> +75 к максимуму здоровья, or %1 placeholders)
---@type table<string, string>
ModTranslationsRU.templates = {
''')
        for en in sorted(templates.keys()):
            ru = templates[en]
            f.write(f'    ["{escape_lua_str(en)}"] = "{escape_lua_str(ru)}",\n')

        f.write('''};

--- Hash templates for canonical # patterns (fast O(1) matching for skill stats, atlas passives, etc.)
---@type table<string, string>
ModTranslationsRU.hashTemplates = {
''')
        for en in sorted(hash_templates.keys()):
            ru = hash_templates[en]
            f.write(f'    ["{escape_lua_str(en)}"] = "{escape_lua_str(ru)}",\n')

        f.write('''};

--- Special regex-based rules for multi-number and mid-number modifiers
ModTranslationsRU.specialRules = {
''')
        for pat, repl in special_rules:
            f.write('    {\n')
            f.write(f'        pattern = "{escape_lua_str(pat)}",\n')
            f.write(f'        replacement = "{escape_lua_str(repl)}",\n')
            f.write('    },\n')

        f.write('''};

--- Translates an item mod or skill stat line to Russian.
--- Safe fallback: returns original English line if no translation is found.
---@param line string
---@return string
function ModTranslationsRU:Translate(line)
    if not line or line == "" then
        return line
    end

    local main = _G.main
    local itemLang = (main and main.itemLanguage) or "DUAL"
    if itemLang == "EN" then
        return line
    end

    -- Preserve leading tags ({crafted}, {implicit}, {fractured}, {range:0.5}, etc.)
    local tags = {}
    local core = line
    while true do
        local tag = core:match("^(%b{})%s*")
        if tag then
            table.insert(tags, tag)
            core = core:sub(#tag + 1):gsub("^%s+", "")
        else
            break
        end
    end

    local tagPrefix = #tags > 0 and (table.concat(tags, " ") .. " ") or ""

    -- 1. Exact phrase match
    if self.exact[core] then
        return tagPrefix .. self.exact[core]
    end

    -- 1.1 Dynamic anoint matching: "Allocates <Passive Name>"
    local anointNode = core:match("^Allocates%s+(.+)$")
    if anointNode and not anointNode:find("Jewel%s+socket") then
        local ruNode = (TreeNodesRU and TreeNodesRU.Get and TreeNodesRU:Get(anointNode)) or anointNode
        return tagPrefix .. "Дарует: " .. ruNode
    end

    -- 1.2 Dynamic granted skill matching: "Grants Level X <Skill Name> Skill" / "Grants Skill: Level X <Skill Name>"
    local skillLvl, skillName = core:match("^Grants%s+Level%s+([%d%(%)%-]+)%s+(.+)%s+Skill$")
    if not skillLvl then
        skillLvl, skillName = core:match("^Grants%s+Skill:%s+Level%s+([%d%(%)%-]+)%s+(.+)$")
    end
    if not skillLvl then
        skillLvl, skillName = core:match("^[Gg][Rr][Aa][Nn][Tt][Ss]%s+[Ll][Ee][Vv][Ee][Ll]%s+([%d%(%)%-]+)%s+(.+)%s+[Ss][Kk][Ii][Ll][Ll]$")
    end
    if skillLvl and skillName then
        local ruSkill = (GemNamesRU and GemNamesRU.Get and GemNamesRU:Get(skillName)) or skillName
        return tagPrefix .. "Дарует умение: " .. ruSkill .. " " .. skillLvl .. " уровня"
    end

    -- 1.2.1 Dynamic triggered skill matching: "Triggers Level X <Skill Name> when Equipped"
    local trigLvl, trigSkill = core:match("^Triggers%s+Level%s+([%d%(%)%-]+)%s+(.+)%s+when%s+Equipped$")
    if not trigLvl then
        trigLvl, trigSkill = core:match("^[Tt][Rr][Ii][Gg][Gg][Ee][Rr][Ss]%s+[Ll][Ee][Vv][Ee][Ll]%s+([%d%(%)%-]+)%s+(.+)%s+[Ww][Hh][Ee][Nn]%s+[Ee][Qq][Uu][Ii][Pp][Pp][Ee][Dd]$")
    end
    if trigLvl and trigSkill then
        local ruSkill = (GemNamesRU and GemNamesRU.Get and GemNamesRU:Get(trigSkill)) or trigSkill
        return tagPrefix .. "Сотворяет " .. ruSkill .. " " .. trigLvl .. " уровня, пока предмет надет"
    end

    local trigLvl2, trigSkill2 = core:match("^Triggers%s+Level%s+([%d%(%)%-]+)%s+(.+)$")
    if not trigLvl2 then
        trigLvl2, trigSkill2 = core:match("^[Tt][Rr][Ii][Gg][Gg][Ee][Rr][Ss]%s+[Ll][Ee][Vv][Ee][Ll]%s+([%d%(%)%-]+)%s+(.+)$")
    end
    if trigLvl2 and trigSkill2 then
        local ruSkill = (GemNamesRU and GemNamesRU.Get and GemNamesRU:Get(trigSkill2)) or trigSkill2
        return tagPrefix .. "Вызывает срабатывание: " .. ruSkill .. " " .. trigLvl2 .. " уровня"
    end

    -- 1.3 Direct template match (full phrase in templates table)
    if self.templates[core] then
        return tagPrefix .. self.templates[core]
    end

    -- 2. Range prefix: +(10-19) to maximum Life / +(10-19)% to Fire Resistance
    local rng, rngCore = core:match("^([%+%-]?%(%d+[%-–]%d+%)%%?)%s+(.+)$")
    if rng and rngCore and self.templates[rngCore] then
        local tpl = self.templates[rngCore]
        if tpl:find("%%1") then
            local safeRng = rng:gsub("%%", "%%%%")
            return tagPrefix .. tpl:gsub("%%1", safeRng)
        else
            return tagPrefix .. rng .. " " .. tpl
        end
    end

    -- 3. Numeric prefix: +75 to maximum Life / +35% to Fire Resistance / 12% increased Attack Speed
    local num, numCore = core:match("^([%+%-]?%d+%.?%d*%%?)%s+(.+)$")
    if num and numCore and self.templates[numCore] then
        local tpl = self.templates[numCore]
        if tpl:find("%%1") then
            local safeNum = num:gsub("%%", "%%%%")
            return tagPrefix .. tpl:gsub("%%1", safeNum)
        else
            return tagPrefix .. num .. " " .. tpl
        end
    end

    -- 4. Fast canonical # template match (handles mid-numbers, skill stats, atlas stats)
    local nums = {}
    for n in core:gmatch("([%+%-]?%d+%.?%d*%%?)") do
        table.insert(nums, n)
    end
    if #nums > 0 then
        local norm = core:gsub("[%+%-]?%d+%.?%d*%%", "#%%"):gsub("[%+%-]?%d+%.?%d*", "#"):lower()
        local tpl = self.hashTemplates[norm]
        if not tpl then
            local normNoPercent = norm:gsub("#%%", "#")
            tpl = self.hashTemplates[normNoPercent]
        end
        if tpl then
            local out = tpl
            for i, extractedNum in ipairs(nums) do
                local val = extractedNum
                if out:find("%%" .. i .. "%%") and val:sub(-1) == "%" then
                    val = val:sub(1, -2)
                end
                local safeNum = val:gsub("%%", "%%%%")
                out = out:gsub("%%" .. i, safeNum)
            end
            return tagPrefix .. out
        end
    end

    -- 5. Special multi-number regex rules
    for _, rule in ipairs(self.specialRules) do
        local m1, m2 = core:match(rule.pattern)
        if m1 then
            local safeM1 = m1:gsub("%%", "%%%%")
            local out = rule.replacement:gsub("%%1", safeM1)
            if m2 then
                local safeM2 = m2:gsub("%%", "%%%%")
                out = out:gsub("%%2", safeM2)
            end
            return tagPrefix .. out
        end
    end

    -- 6. Case-insensitive exact & template match fallback
    local coreLower = core:lower()
    if self.exact[coreLower] then
        return tagPrefix .. self.exact[coreLower]
    end
    for eKey, eVal in pairs(self.exact) do
        if eKey:lower() == coreLower then
            return tagPrefix .. eVal
        end
    end
    for tKey, tVal in pairs(self.templates) do
        if tKey:lower() == coreLower then
            if tVal:find("%%1") and num then
                local safeNum = num:gsub("%%", "%%%%")
                return tagPrefix .. tVal:gsub("%%1", safeNum)
            else
                return tagPrefix .. (num and (num .. " ") or "") .. tVal
            end
        end
    end

    -- Log untranslated mod line (source: "MOD")
    local fullLine = tagPrefix .. core
    if RULogger and main and main.logUntranslatedRU then
        RULogger.Log("MOD", fullLine)
    end

    return line
end

return ModTranslationsRU
''')

    print(f"Generated {OUT_FILE} successfully!")


if __name__ == "__main__":
    main()
