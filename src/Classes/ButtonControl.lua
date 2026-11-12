-- Path of Building
--
-- Class: Button Control
-- Basic button control.
--
---@class ButtonControl: Control, TooltipHost
local ButtonClass = newClass("ButtonControl", "Control", "TooltipHost")

-- Fluent theme support (safe degradation: nil if module not yet loaded)
local ThemeFluent = nil
local okTheme, resTheme = pcall(function() return LoadModule("Modules/ThemeFluent") end)
if okTheme and type(resTheme) == "table" then
	ThemeFluent = resTheme
end

function ButtonClass:ButtonControl(anchor, rect, label, onClick, onHover, forceTooltip)
	self:Control(anchor, rect)
	self:TooltipHost()
	self.label = label
	self.onClick = onClick
	self.onHover = onHover
	self.forceTooltip = forceTooltip
	return self
end

function ButtonClass:Click()
	if self:IsShown() and self:IsEnabled() then
		self.onClick()
	end
end

function ButtonClass:SetImage(path)
	if path then
		self.image = NewImageHandle()
		self.image:Load(path)
	else
		self.image = nil
	end
end

function ButtonClass:IsMouseOver()
	if not self:IsShown() then
		return false
	end
	return self:IsMouseInBounds()
end

-- Resolve Fluent theme colours for the button, with safe fallback.
local function ButtonTheme()
	local b = ThemeFluent and ThemeFluent.button or nil
	if not b then
		return {
			bg = { 0.1, 0.1, 0.1, 1 },
			bgHover = { 0.15, 0.15, 0.15, 1 },
			bgPressed = { 0.08, 0.08, 0.08, 1 },
			bgDisabled = { 0.08, 0.08, 0.08, 1 },
			border = { 0.5, 0.5, 0.5, 1 },
			borderHover = { 1, 1, 1, 1 },
			borderPressed = { 1, 1, 1, 1 },
			borderDisabled = { 0.33, 0.33, 0.33, 1 },
			text = { 1, 1, 1, 1 },
			textDisabled = { 0.33, 0.33, 0.33, 1 },
			radius = 4,
		}
	end
	return {
		bg = b.bg or { 0.1, 0.1, 0.1, 1 },
		bgHover = b.bgHover or { 0.15, 0.15, 0.15, 1 },
		bgPressed = b.bgPressed or { 0.08, 0.08, 0.08, 1 },
		bgDisabled = b.bgDisabled or { 0.08, 0.08, 0.08, 1 },
		border = b.border or { 0.5, 0.5, 0.5, 1 },
		borderHover = b.borderHover or { 1, 1, 1, 1 },
		borderPressed = b.borderPressed or { 1, 1, 1, 1 },
		borderDisabled = b.borderDisabled or { 0.33, 0.33, 0.33, 1 },
		text = b.text or { 1, 1, 1, 1 },
		textDisabled = b.textDisabled or { 0.33, 0.33, 0.33, 1 },
		radius = b.radius or 4,
	}
end

function ButtonClass:Draw(viewPort, noTooltip)
	local x, y = self:GetPos()
	local width, height = self:GetSize()
	local enabled = self:IsEnabled()
	local mOver = self:IsMouseOver()
	local locked = self:GetProperty("locked")

	local theme = ButtonTheme()

	-- Choose colours by state
	local bg, border, textCol
	if not enabled then
		bg, border, textCol = theme.bgDisabled, theme.borderDisabled, theme.textDisabled
	elseif self.clicked and mOver then
		bg, border, textCol = theme.bgPressed, theme.borderPressed, theme.text
	elseif mOver or locked then
		bg, border, textCol = theme.bgHover, theme.borderHover, theme.text
	else
		bg, border, textCol = theme.bg, theme.border, theme.text
	end

	-- Fluent rounded control box with safe DrawControlBox degradation
	if type(DrawControlBox) == "function" then
		DrawControlBox(x, y, width, height, theme.radius, bg, border, 1, 0)
	else
		if not enabled then
			SetDrawColor(0.33, 0.33, 0.33)
		elseif mOver or locked then
			SetDrawColor(1, 1, 1)
		else
			SetDrawColor(0.5, 0.5, 0.5)
		end
		DrawImage(nil, x, y, width, height)
		if not enabled then
			SetDrawColor(0, 0, 0)
		elseif self.clicked and mOver then
			SetDrawColor(0.5, 0.5, 0.5)
		elseif mOver or locked then
			SetDrawColor(0.33, 0.33, 0.33)
		else
			SetDrawColor(0, 0, 0)
		end
		DrawImage(nil, x + 1, y + 1, width - 2, height - 2)
	end

	if self.image then
		if enabled then
			SetDrawColor(1, 1, 1)
		else
			SetDrawColor(0.33, 0.33, 0.33)
		end
		DrawImage(self.image, x + 2, y + 2, width - 4, height - 4)
		if self.clicked and mOver then
			SetDrawColor(1, 1, 1, 0.5)
			DrawImage(nil, x + 1, y + 1, width - 2, height - 2)
		end
	end
	SetDrawColor(unpack(textCol))
	local label = self:GetProperty("label")
	if label == "+" then
		DrawImage(nil, x + width * 0.2, y + height * 0.45, width * 0.6, height * 0.1)
		DrawImage(nil, x + width * 0.45, y + height * 0.2, width * 0.1, height * 0.6)
	elseif label == "-" then
		DrawImage(nil, x + width * 0.2, y + height * 0.45, width * 0.6, height * 0.1)
	elseif label == "x" then
		DrawImageQuad(nil, x + width * 0.2, y + height * 0.3, x + width * 0.3, y + height * 0.2, x + width * 0.8, y + height * 0.7, x + width * 0.7, y + height * 0.8)
		DrawImageQuad(nil, x + width * 0.7, y + height * 0.2, x + width * 0.8, y + height * 0.3, x + width * 0.3, y + height * 0.8, x + width * 0.2, y + height * 0.7)
	else
		local overSize = self.overSizeText or 0
		DrawString(x + width / 2, y + 2 - overSize, "CENTER_X", height - 4 + overSize * 2, "VAR", label)
	end
	if mOver then
		if not noTooltip or self.forceTooltip then
			SetDrawLayer(nil, 100)
			self:DrawTooltip(x, y, width, height, viewPort)
			SetDrawLayer(nil, 0)
		end
		if self.onHover ~= nil then
			return self.onHover()
		end
	end
end

function ButtonClass:OnKeyDown(key)
	if not self:IsShown() or not self:IsEnabled() then
		return
	end
	if key == "LEFTBUTTON" then
		self.clicked = true
	elseif self.enterFunc then
		self.enterFunc()
	end
	return self
end

function ButtonClass:OnKeyUp(key)
	if not self:IsShown() or not self:IsEnabled() then
		return
	end
	if key == "LEFTBUTTON" and self.clicked then
		self.clicked = false
		if self:IsMouseOver() then
			return self.onClick()
		end
	end
	self.clicked = false
end
