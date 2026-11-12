-- Path of Building
--
-- Class: Check Box Control
-- Basic check box control.
--
---@class CheckBoxControl: Control, TooltipHost
local CheckBoxClass = newClass("CheckBoxControl", "Control", "TooltipHost")

-- Fluent theme support (safe degradation: nil if module not yet loaded)
local ThemeFluent = nil
local okTheme, resTheme = pcall(function() return LoadModule("Modules/ThemeFluent") end)
if okTheme and type(resTheme) == "table" then
	ThemeFluent = resTheme
end

function CheckBoxClass:CheckBoxControl(anchor, rect, label, changeFunc, tooltipText, initialState)
	rect[4] = rect[3] or 0
	self:Control(anchor, rect)
	self:TooltipHost(tooltipText)
	self.label = label
	self.labelWidth = DrawStringWidth(self.width - 4, "VAR", label or "") + 5
	self.labelRight = false
	self.changeFunc = changeFunc
	self.state = initialState
	return self
end

function CheckBoxClass:IsMouseOver()
	if not self:IsShown() then
		return false
	end
	local x, y = self:GetPos()
	local width, height = self:GetSize()
	local cursorX, cursorY = GetCursorPos()

	-- Include the label in the clickable area.
	local label = self:GetProperty("label")
	if label then
		if not self.labelRight then
			x = x - self.labelWidth
		end
		width = width + self.labelWidth
	end
	return cursorX >= x and cursorY >= y and cursorX < x + width and cursorY < y + height
end

-- Resolve Fluent theme colours for the checkbox, with safe fallback.
local function CheckBoxTheme()
	local t = ThemeFluent and ThemeFluent.colors or nil
	if not t then
		return {
			bgChecked = { 0.75, 0.75, 0.75, 1 },
			bgCheckedHover = { 1, 1, 1, 1 },
			bgCheckedPressed = { 0.5, 0.5, 0.5, 1 },
			bgUnchecked = { 0.1, 0.1, 0.1, 1 },
			bgDisabled = { 0.08, 0.08, 0.08, 1 },
			border = { 0.5, 0.5, 0.5, 1 },
			borderHover = { 1, 1, 1, 1 },
			borderDisabled = { 0.33, 0.33, 0.33, 1 },
			check = { 0, 0, 0, 1 },
			radius = 3,
		}
	end
	return {
		bgChecked = t.checkbox.bgChecked or { 0.75, 0.75, 0.75, 1 },
		bgCheckedHover = t.checkbox.bgCheckedHover or { 1, 1, 1, 1 },
		bgCheckedPressed = t.checkbox.bgCheckedPressed or { 0.5, 0.5, 0.5, 1 },
		bgUnchecked = t.checkbox.bgUnchecked or { 0.1, 0.1, 0.1, 1 },
		bgDisabled = t.checkbox.bgDisabled or { 0.08, 0.08, 0.08, 1 },
		border = t.checkbox.border or { 0.5, 0.5, 0.5, 1 },
		borderHover = t.checkbox.borderHover or { 1, 1, 1, 1 },
		borderDisabled = t.checkbox.borderDisabled or { 0.33, 0.33, 0.33, 1 },
		check = t.checkbox.check or { 0, 0, 0, 1 },
		radius = t.checkbox.radius or 3,
	}
end

function CheckBoxClass:Draw(viewPort, noTooltip)
	local x, y = self:GetPos()
	local size = self.width
	local enabled = self:IsEnabled()
	local mOver = self:IsMouseOver()

	local theme = CheckBoxTheme()

	-- Choose colours by state
	local bg, border
	if not enabled then
		bg, border = theme.bgDisabled, theme.borderDisabled
	elseif self.state then
		if self.clicked and mOver then
			bg, border = theme.bgCheckedPressed, theme.border
		elseif mOver then
			bg, border = theme.bgCheckedHover, theme.borderHover
		else
			bg, border = theme.bgChecked, theme.border
		end
	else
		if mOver then
			bg, border = theme.bgUnchecked, theme.borderHover
		else
			bg, border = theme.bgUnchecked, theme.border
		end
	end

	-- Fluent rounded control box with safe DrawControlBox degradation
	if type(DrawControlBox) == "function" then
		DrawControlBox(x, y, size, size, theme.radius, bg, border, 1, 0)
	else
		if not enabled then
			SetDrawColor(0.33, 0.33, 0.33)
		elseif mOver then
			SetDrawColor(1, 1, 1)
		elseif self.borderFunc then
			local r, g, b = self.borderFunc()
			SetDrawColor(r, g, b)
		else
			SetDrawColor(0.5, 0.5, 0.5)
		end
		DrawImage(nil, x, y, size, size)
		if not enabled then
			SetDrawColor(0, 0, 0)
		elseif self.clicked and mOver then
			SetDrawColor(0.5, 0.5, 0.5)
		elseif mOver then
			SetDrawColor(0.33, 0.33, 0.33)
		else
			SetDrawColor(0, 0, 0)
		end
		DrawImage(nil, x + 1, y + 1, size - 2, size - 2)
	end

	if self.state then
		if not enabled then
			SetDrawColor(0.33, 0.33, 0.33)
		elseif mOver then
			SetDrawColor(1, 1, 1)
		else
			SetDrawColor(unpack(theme.check))
		end
		main:DrawCheckMark(x + size/2, y + size/2, size * 0.8)
	end
	if enabled then
		SetDrawColor(1, 1, 1)
	else
		SetDrawColor(0.33, 0.33, 0.33)
	end
	local label = self:GetProperty("label")
	if label and self.labelRight then
		DrawString(x + self.width + 5, y + 2, nil, size - 4, "VAR", label)
	elseif label then
		DrawString(x - 5, y + 2, "RIGHT_X", size - 4, "VAR", label)
	end
	if mOver and not noTooltip then
		SetDrawLayer(nil, 100)
		self:DrawTooltip(x, y, size, size, viewPort, self.state)
		SetDrawLayer(nil, 0)
	end
end

function CheckBoxClass:OnKeyDown(key)
	if not self:IsShown() or not self:IsEnabled() then
		return
	end
	if key == "LEFTBUTTON" then
		self.clicked = true
	end
	return self
end

function CheckBoxClass:OnKeyUp(key)
	if not self:IsShown() or not self:IsEnabled() then
		return
	end
	if key == "LEFTBUTTON" then
		if self:IsMouseOver() then
			self.state = not self.state
			if self.changeFunc then
				self.changeFunc(self.state)
			end
		end
	end
	self.clicked = false
end
