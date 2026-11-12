-- Path of Building
--
-- Class: Section Control
-- Section box with label
--

---@class SectionControl: Control
local SectionClass = newClass("SectionControl", "Control")

-- Fluent theme support (safe degradation: nil if module not yet loaded)
local ThemeFluent = nil
local okTheme, resTheme = pcall(function() return LoadModule("Modules/ThemeFluent") end)
if okTheme and type(resTheme) == "table" then
	ThemeFluent = resTheme
end

-- Resolve Fluent theme colours for the section, with safe fallback.
local function SectionTheme()
	local t = ThemeFluent and ThemeFluent.colors or nil
	if not t then
		return {
			bg = { 0.16, 0.16, 0.17, 1 },
			border = { 0.5, 0.5, 0.5, 1 },
			labelBg = { 0.16, 0.16, 0.17, 1 },
			labelText = { 1, 1, 1, 1 },
			radius = 4,
		}
	end
	return {
		bg = t.section.bg or { 0.16, 0.16, 0.17, 1 },
		border = t.section.border or { 0.5, 0.5, 0.5, 1 },
		labelBg = t.section.labelBg or { 0.16, 0.16, 0.17, 1 },
		labelText = t.section.labelText or { 1, 1, 1, 1 },
		radius = t.section.radius or 4,
	}
end

function SectionClass:SectionControl(anchor, rect, label)
	self:Control(anchor, rect)
	self.label = label
	return self
end

function SectionClass:Draw()
	local x, y = self:GetPos()
	local width, height = self:GetSize()
	local theme = SectionTheme()

	-- Fluent section card with safe DrawControlBox degradation
	if type(DrawControlBox) == "function" then
		SetDrawLayer(nil, -10)
		DrawControlBox(x, y, width, height, theme.radius, theme.bg, theme.border, 1, 0)
		SetDrawLayer(nil, 0)
	else
		SetDrawLayer(nil, -10)
		SetDrawColor(0.66, 0.66, 0.66)
		DrawImage(nil, x, y, width, height)
		SetDrawColor(0.1, 0.1, 0.1)
		DrawImage(nil, x + 2, y + 2, width - 4, height - 4)
		SetDrawLayer(nil, 0)
	end

	local label = self:GetProperty("label")
	local labelWidth = DrawStringWidth(14, "VAR", label)
	SetDrawColor(unpack(theme.labelBg))
	DrawImage(nil, x + 6, y - 8, labelWidth + 6, 18)
	SetDrawColor(0, 0, 0)
	DrawImage(nil, x + 7, y - 7, labelWidth + 4, 16)
	SetDrawColor(unpack(theme.labelText))
	DrawString(x + 9, y - 6, "LEFT", 14, "VAR", label)
end
