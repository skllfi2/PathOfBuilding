"""
Upgraded Generator for PoE1 TreePassivesRU.lua
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
    # 1. Load exact and templates from ModTranslationsRU
    mod_code = open(MOD_FILE, encoding="utf-8").read()
    pos_tpl = mod_code.find('ModTranslationsRU.templates =')
    pos_rules = mod_code.find('ModTranslationsRU.specialRules =')
    exact = dict(re.findall(r'\[\"([^\"]+)\"\]\s*=\s*\"([^\"]+)\"', mod_code[:pos_tpl]))
    tpl = dict(re.findall(r'\[\"([^\"]+)\"\]\s*=\s*\"([^\"]+)\"', mod_code[pos_tpl:pos_rules]))

    # Manual specific overrides for notables / keystones that PoE1 formats specially
    specific_overrides = {
        "Blind Enemies on Hit": "Ослепляет врагов при нанесении удара",
        "Arcane Surge grants 10% more Spell Damage to you": "Колдовской выброс дает вам на 10% больше урона чарами",
        "Arcane Surge grants 20% more Spell Damage to you": "Колдовской выброс дает вам на 20% больше урона чарами",
        "Gain Fanaticism for 4 seconds on reaching Maximum Fanatic Charges": "Дарует Фанатизм на 4 секунды при получении максимума зарядов фанатика",
        "Every second, inflict Withered on nearby Enemies for 15 seconds": "Каждую секунду накладывает Увядание на ближайших врагов на 15 секунд",
        "Nearby Chilled Enemies deal 10% reduced Damage with Hits": "Ближайшие охлажденные враги наносят на 10% меньше урона ударами",
        "Nearby Enemies have -30% to Critical Strike Multiplier": "Ближайшие враги имеют -30% к множителю критического удара",
        "Nearby Enemies have 10% reduced Cooldown Recovery Rate": "Ближайшие враги имеют на 10% меньшую скорость восстановления перезарядки",
        "Nearby Enemy Monsters' Action Speed is at most 92% of base value": "Скорость действий ближайших монстров-врагов составляет максимум 92% от базового значения",
        "Nearby Hindered Enemies deal 15% reduced Damage over Time": "Ближайшие скованные враги наносят на 15% меньше постепенного урона",
        "Unattached Brands gain 20% increased Brand Attachment Range per second, up to 100%": "Неприкрепленные клейма получают 20% увеличение дальности прикрепления в секунду, вплоть до 100%",
        "You and nearby Allies deal 6 to 12 added Physical Damage for each Impale on Enemy": "Вы и ближайшие союзники наносите от 6 до 12 добавочного физического урона за каждый Прокол на враге",
        "20% reduced Damage taken while there are at least two Rare or Unique Enemies nearby": "На 20% меньше получаемого урона пока рядом есть хотя бы два редких или уникальных врага",
        "When you kill a Poisoned Enemy during any Flask Effect, nearby Enemies are Poisoned": "При убийстве отравленного врага во время действия любого флакона ближайшие враги отравляются",
        "Your Action Speed is at least 108% of base value": "Ваша скорость действий составляет как минимум 108% от базовой",
        "Nearby Enemies have 100% reduced Life Regeneration rate": "Ближайшие враги имеют на 100% меньшую скорость регенерации здоровья",
        "Nearby Enemies deal 8% less Elemental Damage": "Ближайшие враги наносят на 8% меньше урона от стихий",
        "-15 Fire, Cold and Lightning Damage taken from Spell Hits per Bark": "-15 получаемого урона от огня, холода и молнии от ударов чарами за каждый слой коры",
        "Every 4 seconds, remove Curses and Elemental Ailments from you": "Каждые 4 секунды снимает с вас проклятия и стихийные состояния",
        "You and nearby Allies Regenerate 1.00% of Life per second": "Вы и ближайшие союзники регенерируете 1.00% здоровья в секунду",
        "You and nearby Allies Regenerate 1% of Life per second": "Вы и ближайшие союзники регенерируете 1% здоровья в секунду",
    }
    exact.update(specific_overrides)

    # 2. Load stat_translations from official dist
    ru_stat = json.load(open(os.path.join(BASE_DIST, "stat_translations", "ru.json"), encoding="utf-8"))
    en_stat = json.load(open(os.path.join(BASE_DIST, "stat_translations", "en.json"), encoding="utf-8"))

    # Single-# patterns
    single_rules = []
    # Two-# patterns
    two_rules = []

    for k, en_text in en_stat.items():
        if k not in ru_stat or not en_text or not ru_stat[k]:
            continue
        en = en_text.strip()
        ru = ru_stat[k].strip()
        if not en or not ru:
            continue

        c_en = en.count('#')
        c_ru = ru.count('#')

        if c_en == 0 and c_ru == 0:
            if en not in exact:
                exact[en] = ru
            continue

        if c_en == 1 and c_ru == 1:
            en_clean = re.sub(r'\s+', ' ', en.replace(r'\n', ' ').replace('\n', ' ')).strip()
            parts = en_clean.split('#')
            esc_pre = re.escape(parts[0])
            esc_suf = re.escape(parts[1])
            pat_str = '^' + esc_pre + r'([%+–\-]?\d+\.?\d*%?|\([^)]+\)%?)' + esc_suf + '$'
            try:
                rx = re.compile(pat_str, re.IGNORECASE)
                single_rules.append((rx, ru))
            except Exception:
                pass
            continue

        if c_en == 2 and c_ru == 2:
            en_clean = re.sub(r'\s+', ' ', en.replace(r'\n', ' ').replace('\n', ' ')).strip()
            parts = en_clean.split('#')
            esc_0 = re.escape(parts[0])
            esc_1 = re.escape(parts[1])
            esc_2 = re.escape(parts[2])
            pat_str = '^' + esc_0 + r'([%+–\-]?\d+\.?\d*%?|\([^)]+\)%?)' + esc_1 + r'([%+–\-]?\d+\.?\d*%?|\([^)]+\)%?)' + esc_2 + '$'
            try:
                rx = re.compile(pat_str, re.IGNORECASE)
                two_rules.append((rx, ru))
            except Exception:
                pass
            continue

    print(f"Loaded {len(exact)} exact phrases, {len(single_rules)} single-# rules, {len(two_rules)} two-# rules")

    # 3. Flavour texts
    en_flavour = json.load(open(os.path.join(BASE_DIST, "flavour", "en.json"), encoding="utf-8"))
    ru_flavour = json.load(open(os.path.join(BASE_DIST, "flavour", "ru.json"), encoding="utf-8"))
    flavour_map = {}
    for k, en in en_flavour.items():
        if k in ru_flavour and en and ru_flavour[k]:
            flavour_map[en.strip().replace('\r', '')] = ru_flavour[k].strip().replace('\r', '')

    # 4. Parse all nodes from tree.lua
    tree_code = open(TREE_FILE, encoding="utf-8").read()
    nodes = re.findall(r'\[\"skill\"\]\s*=\s*(\d+)[^}]+?\[\"stats\"\]\s*=\s*\{([^}]+)\}', tree_code)

    pat_prefix_num = r'^([%+%-]?\d+[\.\d]*%?)\s+(.+)$'

    def translate_line(line: str) -> str:
        # 1. Exact
        if line in exact:
            return exact[line]
        line_clean = re.sub(r'\s+', ' ', line.replace(r'\n', ' ').replace('\n', ' ')).strip()
        if line_clean in exact:
            return exact[line_clean]

        # 2. Single # rules
        for rx, ru_tpl in single_rules:
            m = rx.match(line_clean)
            if m:
                val = m.group(1)
                return ru_tpl.replace('#', val, 1)

        # 3. Two # rules
        for rx, ru_tpl in two_rules:
            m = rx.match(line_clean)
            if m:
                val1, val2 = m.group(1), m.group(2)
                res = ru_tpl.replace('#', val1, 1)
                res = res.replace('#', val2, 1)
                return res

        # 4. Old prefix templates
        if line in tpl:
            return tpl[line]
        m_num = re.match(pat_prefix_num, line)
        if m_num and m_num.group(2) in tpl:
            return m_num.group(1) + ' ' + tpl[m_num.group(2)]

        return line

    skill_stats = {}
    for sid_str, raw in nodes:
        sid = int(sid_str)
        lines = [l.strip() for l in re.findall(r'\"([^\"]+)\"', raw)]
        ru_lines = []
        has_any = False
        for l in lines:
            t = translate_line(l)
            ru_lines.append(t)
            if any('\u0400' <= c <= '\u04FF' for c in t):
                has_any = True
        if has_any:
            skill_stats[sid] = ru_lines

    print(f"Mapped stats for {len(skill_stats)} passive skills")

    # 5. Generate Lua output
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

        f.write("\n-- Initialize stats chunks\n")
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
