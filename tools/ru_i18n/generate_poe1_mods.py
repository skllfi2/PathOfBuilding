"""
Generator for PoE1 ModTranslationsRU.lua
Reads official PoE1 stat_translations from PoE2-Localization-Extractor/PathOfExile_Translated/dist/poe1/stat_translations/
Builds:
1. ModTranslationsRU.exact - exact full line matches without # (e.g. Acrobatics, Keystones, unique mod phrases)
2. ModTranslationsRU.templates - numeric prefix templates (e.g. "to maximum Life" -> "к максимуму здоровья")
3. ModTranslationsRU.specialRules - regex-based multi-number matchers (e.g. "Adds # to # Damage")
4. Translate(line) function supporting tags ({crafted}, {implicit}), ranges +(10-15), numbers +75, and fallback
Outputs verified ModTranslationsRU.lua into src/Data/
"""
import json
import os
import re

BASE_DIST = r"f:\Development\Dev\mydev\PoB2Fork\PoE2-Localization-Extractor\PathOfExile_Translated\dist\poe1"
OUT_FILE = r"f:\Development\Dev\mydev\PoB1Fork\PathOfBuilding\src\Data\ModTranslationsRU.lua"


def escape_lua_str(s: str) -> str:
    return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '')


def main():
    en_stat = json.load(open(os.path.join(BASE_DIST, "stat_translations", "en.json"), encoding="utf-8"))
    ru_stat = json.load(open(os.path.join(BASE_DIST, "stat_translations", "ru.json"), encoding="utf-8"))

    exact = {}
    templates = {}
    special_rules = []

    for k, en_text in en_stat.items():
        if k not in ru_stat or not en_text or not ru_stat[k]:
            continue
        en_clean = en_text.strip()
        ru_clean = ru_stat[k].strip()
        if not en_clean or not ru_clean:
            continue

        # 1. Exact strings (no placeholder)
        if '#' not in en_clean and '{0}' not in en_clean:
            exact[en_clean] = ru_clean
            continue

        # 2. Leading number prefix template (e.g. "#% increased Attack Speed" -> "#% увеличение скорости атаки")
        # Match +#%, +#, #%, # with optional whitespace
        m_en = re.match(r'^([\+–\-]?#%?)\s+(.+)$', en_clean)
        if m_en:
            en_tail = m_en.group(2).strip()
            # Check if RU starts with same placeholder style
            m_ru = re.match(r'^([\+–\-]?#%?)\s+(.+)$', ru_clean)
            if m_ru and en_tail.count('#') == 0:
                ru_tail = m_ru.group(2).strip()
                templates[en_tail] = ru_tail
                continue

        # 3. Two-number patterns (Adds # to # Fire Damage -> Добавляет от %1 до %2 урона от огня)
        if en_clean.count('#') == 2:
            m_two = re.match(r'^(Adds|Deals)\s+#\s+to\s+#\s+(.+)$', en_clean, re.IGNORECASE)
            m_two_ru = re.match(r'^(Добавляет|Наносит)\s+от\s+#\s+до\s+#\s+(.+)$', ru_clean, re.IGNORECASE)
            if m_two and m_two_ru:
                en_verb = m_two.group(1)
                en_mid = m_two.group(2).strip()
                ru_verb = m_two_ru.group(1)
                ru_mid = m_two_ru.group(2).strip()

                # Build regex pattern for Lua: ^Adds (%d+%.?%d*|%([%d%-]+%)) to (%d+%.?%d*|%([%d%-]+%)) <escaped_mid>$
                pat = f"^{en_verb}%s+([%+%-]?%d+%.?%d*|%b())%s+to%s+([%+%-]?%d+%.?%d*|%b())%s+{re.escape(en_mid)}$"
                repl = f"{ru_verb} от %1 до %2 {ru_mid}"
                special_rules.append((pat, repl))
                continue

        # 4. Standalone generic template fallback
        if en_clean.count('#') == 1 and ru_clean.count('#') == 1:
            en_tail = en_clean.replace('#', '').strip()
            ru_tail = ru_clean.replace('#', '').strip()
            if en_tail and ru_tail and len(en_tail) > 3 and en_tail not in templates:
                templates[en_tail] = ru_tail

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

--- Templates for numeric prefix modifiers (+75 to maximum Life -> +75 к максимуму здоровья)
---@type table<string, string>
ModTranslationsRU.templates = {
''')
        for en in sorted(templates.keys()):
            ru = templates[en]
            f.write(f'    ["{escape_lua_str(en)}"] = "{escape_lua_str(ru)}",\n')

        f.write('''};

--- Regex-based rules for multi-number and parameterized modifiers
ModTranslationsRU.specialRules = {
''')
        for pat, repl in special_rules:
            f.write(f'    {{ pattern = "{escape_lua_str(pat)}", replacement = "{escape_lua_str(repl)}" }},\n')

        f.write('''};

--- Translates a single item modifier line to Russian.
--- Safe fallback: returns original English line if not found.
---@param line string|nil
---@return string|nil
function ModTranslationsRU:Translate(line)
    if not line or #line == 0 then
        return line
    end

    -- Extract leading tags like {crafted}, {implicit}, {fractured}, {range:0.5}
    local tags = {}
    local core = line
    while true do
        local tag, rest = core:match("^(%b{})%s*(.*)$")
        if tag and rest then
            table.insert(tags, tag)
            core = rest
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

    -- 2. Special multi-number regex rules
    for _, rule in ipairs(self.specialRules) do
        local m1, m2 = core:match(rule.pattern)
        if m1 and m2 then
            local safeM1 = m1:gsub("%%", "%%%%")
            local safeM2 = m2:gsub("%%", "%%%%")
            local out = rule.replacement:gsub("%%1", safeM1):gsub("%%2", safeM2)
            return tagPrefix .. out
        end
    end

    -- 3. Range prefix: +(10-19) to maximum Life / +(10-19)% to Fire Resistance
    local rng, rngCore = core:match("^([%+%-]?%(%d+[%-–]%d+%)%%?)%s+(.+)$")
    if rng and rngCore and self.templates[rngCore] then
        return tagPrefix .. rng .. " " .. self.templates[rngCore]
    end

    -- 4. Numeric prefix: +75 to maximum Life / +35% to Fire Resistance / 12% increased Attack Speed
    local num, numCore = core:match("^([%+%-]?%d+%.?%d*%%?)%s+(.+)$")
    if num and numCore and self.templates[numCore] then
        return tagPrefix .. num .. " " .. self.templates[numCore]
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
            return tagPrefix .. (num and (num .. " ") or "") .. tVal
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
