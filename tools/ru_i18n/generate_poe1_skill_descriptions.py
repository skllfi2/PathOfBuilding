"""
Generator for PoE1 SkillDescriptionsRU.lua
Reads official PoE1 gem_descriptions from PoE2-Localization-Extractor/PathOfExile_Translated/dist/poe1/gem_descriptions/
Outputs clean, verified SkillDescriptionsRU.lua into src/Data/
"""
import json
import os

BASE_DIST = r"f:\Development\Dev\mydev\PoB2Fork\PoE2-Localization-Extractor\PathOfExile_Translated\dist\poe1"
OUT_FILE = r"f:\Development\Dev\mydev\PoB1Fork\PathOfBuilding\src\Data\SkillDescriptionsRU.lua"


def escape_lua_str(s: str) -> str:
    return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '')


def main():
    en_d = json.load(open(os.path.join(BASE_DIST, "gem_descriptions", "en.json"), encoding="utf-8"))
    ru_d = json.load(open(os.path.join(BASE_DIST, "gem_descriptions", "ru.json"), encoding="utf-8"))

    by_desc = {}
    for k, en_text in en_d.items():
        if k in ru_d and en_text and ru_d[k]:
            en_clean = en_text.strip()
            ru_clean = ru_d[k].strip()
            if en_clean and ru_clean:
                by_desc[en_clean] = ru_clean

    print(f"Mapped {len(by_desc)} unique skill descriptions")

    with open(OUT_FILE, "w", encoding="utf-8") as f:
        f.write('''-- Path of Building (PoE1)
-- Module: SkillDescriptionsRU
-- Russian translations of skill and support gem descriptions.
-- Fallback: returns original English text if no translation found.
--
-- Auto-generated from official PoE1 localization exports.
--
local SkillDescriptionsRU = {}

---@type table<string, string>
SkillDescriptionsRU.byDesc = {
''')
        for en in sorted(by_desc.keys()):
            ru = by_desc[en]
            f.write(f'    ["{escape_lua_str(en)}"] = "{escape_lua_str(ru)}",\n')

        f.write('''};

--- Looks up Russian translation for a skill description.
--- Safe fallback: returns original English description if not found.
---@param desc string|nil
---@return string|nil
function SkillDescriptionsRU:Get(desc)
    if not desc or type(desc) ~= "string" or desc == "" then
        return desc
    end

    local clean = desc:gsub("^%s+", ""):gsub("%s+$", "")
    local tr = self.byDesc[clean] or self.byDesc[desc]
    if tr then
        return tr
    end

    return desc
end

return SkillDescriptionsRU
''')

    print(f"Generated {OUT_FILE}")


if __name__ == "__main__":
    main()
