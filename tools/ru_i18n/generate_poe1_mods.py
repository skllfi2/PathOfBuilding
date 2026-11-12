"""
Generator for PoE1 ModTranslationsRU.lua
Reads official PoE1 stat_translations from PoE2-Localization-Extractor/PathOfExile_Translated/dist/poe1/stat_translations/
Builds:
1. ModTranslationsRU.exact - exact full line matches without #
2. ModTranslationsRU.templates - numeric prefix templates, including reordered %1 placeholders
3. ModTranslationsRU.specialRules - regex-based mid-number and two-number matchers
4. Translate(line) function supporting tags, ranges, numbers, %1 substitution, and logging
"""
import json
import os
import re

BASE_DIST = r"f:\Development\Dev\mydev\PoB2Fork\PoE2-Localization-Extractor\PathOfExile_Translated\dist\poe1"
OUT_FILE = r"f:\Development\Dev\mydev\PoB1Fork\PathOfBuilding\src\Data\ModTranslationsRU.lua"


def escape_lua_str(s: str) -> str:
    return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '')


def lua_pattern_escape(s: str) -> str:
    # Lua pattern magic characters: ^ $ ( ) % . [ ] * + - ?
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
    en_stat = json.load(open(os.path.join(BASE_DIST, "stat_translations", "en.json"), encoding="utf-8"))
    ru_stat = json.load(open(os.path.join(BASE_DIST, "stat_translations", "ru.json"), encoding="utf-8"))

    exact = {}
    templates = {}
    special_rules = []

    # Important keywords for middle-# patterns to keep special_rules focused and fast
    MID_KEYWORDS = (
        'minion', 'gain', 'regenerate', 'retaliation', 'allies', 'enemies',
        'projectiles', 'damage taken', 'life per enemy', 'mana per enemy',
        'withered', 'gale force', 'impale', 'action speed', 'elemental resistances',
        'critical strike multiplier', 'cooldown recovery', 'curse', 'brand',
        'per poison', 'per frenzy', 'per power', 'per endurance', 'per gale'
    )

    for k, en_text in en_stat.items():
        if k not in ru_stat or not en_text or not ru_stat[k]:
            continue
        en_clean = en_text.strip()
        ru_clean = ru_stat[k].strip()
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
            # If RU also starts with #%, strip prefix
            m_ru = re.match(r'^([\+–\-]?#%?)\s+(.+)$', ru_clean)
            if m_ru and en_tail.count('#') == 0:
                templates[en_tail] = m_ru.group(2).strip()
                continue
            # If RU has # inside (e.g. "На #% больше урона"), store with %1
            if en_tail.count('#') == 0:
                # Replace #% or # with %1
                ru_tpl = ru_clean.replace('#%', '%1').replace('#', '%1')
                templates[en_tail] = ru_tpl
                continue

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
                continue

        # 4. Mid-number patterns for common PoE mods
        if c_en == 1 and c_ru == 1:
            en_lower = en_clean.lower()
            if any(kw in en_lower for kw in MID_KEYWORDS):
                clean_for_pat = en_clean.replace('#%', '#')
                parts = clean_for_pat.split('#')
                esc_pre = lua_pattern_escape(parts[0].strip())
                esc_suf = lua_pattern_escape(parts[1].strip())
                pat = f"^{esc_pre}%s+([%+%-]?%(?[%d%.%-–]+%)?%%?)" + (f"%s+{esc_suf}$" if esc_suf else "$")
                repl = ru_clean.replace('#%', '%1').replace('#', '%1')
                special_rules.append((pat, repl))
                continue

    # De-duplicate special rules
    seen_pats = set()
    dedup_special = []
    for pat, repl in special_rules:
        if pat not in seen_pats:
            seen_pats.add(pat)
            dedup_special.append((pat, repl))
    special_rules = dedup_special

    print(f"Extracted {len(exact)} exact phrases, {len(templates)} templates, {len(special_rules)} special rules")

    with open(OUT_FILE, "w", encoding="utf-8") as f:
        f.write('''-- Path of Building (PoE1)
-- Module: ModTranslationsRU
-- Russian localization display names and templates for item modifiers.
-- (Implicits, Prefixes, Suffixes, Corrupted mods, Enchants, Eldritch & Crucible).
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

--- Special regex-based rules for multi-number and mid-number modifiers
ModTranslationsRU.specialRules = {
''')
        for pat, repl in special_rules:
            f.write('    {\n')
            f.write(f'        pattern = "{escape_lua_str(pat)}",\n')
            f.write(f'        replacement = "{escape_lua_str(repl)}",\n')
            f.write('    },\n')

        f.write('''};

--- Translates an item mod line to Russian.
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
    if skillLvl and skillName then
        local ruSkill = (GemNamesRU and GemNamesRU.Get and GemNamesRU:Get(skillName)) or skillName
        return tagPrefix .. "Дарует умение: " .. ruSkill .. " " .. skillLvl .. " уровня"
    end

    -- 1.3 Direct template match (full phrase in templates table)
    if self.templates[core] then
        return tagPrefix .. self.templates[core]
    end

    -- 2. Special multi-number / mid-number regex rules
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

    -- 3. Range prefix: +(10-19) to maximum Life / +(10-19)% to Fire Resistance
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

    -- 4. Numeric prefix: +75 to maximum Life / +35% to Fire Resistance / 12% increased Attack Speed
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

    -- 5. Case-insensitive exact & template match fallback
    local coreLower = core:lower()
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

    print(f"Generated {OUT_FILE}")


if __name__ == "__main__":
    main()
