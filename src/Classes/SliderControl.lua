-- Path of Building
--
-- Class: Slider Control
-- Basic slider control.
--
local m_min = math.min
local m_max = math.max
local m_ceil = math.ceil

---@class SliderControl: Control, TooltipHost
local SliderClass = newClass("SliderControl", "Control", "TooltipHost")

-- Fluent theme support (safe degradation: nil if module not yet loaded)
local ThemeFluent = nil
local okTheme, resTheme = pcall(function() return LoadModule("Modules/ThemeFluent") end)
if okTheme and type(resTheme) == "table" then
	ThemeFluent = resTheme
end

-- Resolve Fluent theme colours for the slider, with safe fallback.
local function SliderTheme()
	local sl = ThemeFluent and ThemeFluent.slider or nil
	if not sl then
		return {
			trackBg = { 0.1, 0.1, 0.1, 1 },
			trackBorder = { 0.5, 0.5, 0.5, 1 },
			trackBorderHover = { 1, 1, 1, 1 },
			trackDisabledBg = { 0.08, 0.08, 0.08, 1 },
			trackDisabledBorder = { 0.33, 0.33, 0.33, 1 },
			trackFill = { 0.83, 0.69, 0.22, 1 },
			tick = { 0.33, 0.33, 0.33, 1 },
			knob = { 1, 1, 1, 1 },
			knobBorder = { 0.5, 0.5, 0.5, 1 },
			knobBorderActive = { 1, 1, 1, 1 },
			arrow = { 0.66, 0.66, 0.66, 1 },
			arrowActive = { 1, 1, 1, 1 },
			radius = 3,
		}
	end
	return {
		trackBg = sl.trackBg or { 0.1, 0.1, 0.1, 1 },
		trackBorder = sl.trackBorder or { 0.5, 0.5, 0.5, 1 },
		trackBorderHover = sl.trackBorderHover or { 1, 1, 1, 1 },
		trackDisabledBg = sl.trackDisabledBg or { 0.08, 0.08, 0.08, 1 },
		trackDisabledBorder = sl.trackDisabledBorder or { 0.33, 0.33, 0.33, 1 },
		trackFill = sl.trackFill or { 0.83, 0.69, 0.22, 1 },
		tick = sl.tick or { 0.33, 0.33, 0.33, 1 },
		knob = sl.knob or { 1, 1, 1, 1 },
		knobBorder = sl.knobBorder or { 0.5, 0.5, 0.5, 1 },
		knobBorderActive = sl.knobBorderActive or { 1, 1, 1, 1 },
		arrow = sl.arrow or { 0.66, 0.66, 0.66, 1 },
		arrowActive = sl.arrowActive or { 1, 1, 1, 1 },
		radius = sl.radius or 3,
	}
end

function SliderClass:SliderControl(anchor, rect, changeFunc, scrollWheelSpeedTbl)
	self:Control(anchor, rect)
	self:TooltipHost()
	self.knobSize = self.height - 2
	self.val = 0
	self.changeFunc = changeFunc
	self.scrollWheelSpeedTbl = scrollWheelSpeedTbl or { ["SHIFT"] = 0.25, ["CTRL"] = 0.01, ["DEFAULT"] = 0.05 }
	return self
end

function SliderClass:IsMouseOver()
	if not self:IsShown() then
		return false
	end
	local x, y = self:GetPos()
	local width, height = self:GetSize()
	local cursorX, cursorY = GetCursorPos()
	local mOver = cursorX >= x and cursorY >= y and cursorX < x + width and cursorY < y + height
	local mOverComp
	if mOver then
		local relX = cursorX - x - 2
		local knobX = self:GetKnobXForVal()
		if relX >= knobX and relX < knobX + self.knobSize then
			mOverComp = "KNOB"
		else
			mOverComp = "SLIDE"
		end
	end
	return mOver, mOverComp
end

function SliderClass:GetKnobTravel()
	local width, height = self:GetSize()
	return width - self.knobSize - 2
end

function SliderClass:SetVal(newVal)
	newVal = m_max(0, m_min(1, newVal))
	if newVal ~= self.val then
		self.val = newVal
		if self.changeFunc then
			self.changeFunc(self.val)
		end
	end
end

function SliderClass:GetDivVal(val)
	val = val or self.val
	if self.divCount and self.divCount > 1 then
		local divIndex = m_max(m_ceil(val * self.divCount), 1)
		return divIndex, val * self.divCount - divIndex + 1
	else
		return 1, val
	end
end

function SliderClass:SetValFromKnobX(knobX)
	self:SetVal(knobX / self:GetKnobTravel())
end

function SliderClass:GetKnobXForVal()
	local knobTravel = self:GetKnobTravel()
	return knobTravel * self.val
end

function SliderClass:Draw(viewPort)
	local x, y = self:GetPos()
	local width, height = self:GetSize()
	local enabled = self:IsEnabled()
	local knobTravel = self:GetKnobTravel()
	local theme = SliderTheme()

	if self.dragging and not IsKeyDown("LEFTBUTTON") then
		self.dragging = false
	end
	if self.dragging then
		local cursorX, cursorY = GetCursorPos()
		self:SetValFromKnobX((cursorX - self.dragCX) + self.dragKnobX)
	end
	local mOver, mOverComp = self:IsMouseOver()

	-- Choose colours by state
	local trackBg, trackBorder, knobColor
	if not enabled then
		trackBg, trackBorder, knobColor = theme.trackDisabledBg, theme.trackDisabledBorder, { 0.33, 0.33, 0.33, 1 }
	elseif self.dragging or mOver then
		trackBg, trackBorder, knobColor = theme.trackBg, theme.trackBorderHover, theme.knobBorderActive
	else
		trackBg, trackBorder, knobColor = theme.trackBg, theme.trackBorder, theme.knobBorder
	end

	-- Draw track with Fluent rounded box + safe DrawControlBox degradation
	if type(DrawControlBox) == "function" then
		DrawControlBox(x, y, width, height, theme.radius, trackBg, trackBorder, 1, 0)
	else
		if not enabled then
			SetDrawColor(0.33, 0.33, 0.33)
		elseif self.dragging or mOver then
			SetDrawColor(1, 1, 1)
		else
			SetDrawColor(0.5, 0.5, 0.5)
		end
		DrawImage(nil, x, y, width, height)
		SetDrawColor(0, 0, 0)
		DrawImage(nil, x + 1, y + 1, width - 2, height - 2)
	end

	if enabled then
		if self.divCount then
			SetDrawColor(unpack(theme.tick))
			for d = 0, knobTravel + 0.5, knobTravel / self.divCount do
				DrawImage(nil, x + self.knobSize/2 + d, y + 1, 2, height - 2)
			end
		end
		if self.dragging or mOverComp == "KNOB" then
			SetDrawColor(unpack(theme.arrowActive))
		else
			SetDrawColor(unpack(theme.arrow))
		end
		local knobX = self:GetKnobXForVal()
		if self.divCount then
			local arrowHeight = self.knobSize/2
			main:DrawArrow(x + 1 + knobX + self.knobSize/2, y + height/2 - arrowHeight/2, self.knobSize, arrowHeight, "UP")
			main:DrawArrow(x + 1 + knobX + self.knobSize/2, y + height/2 + arrowHeight/2, self.knobSize, arrowHeight, "DOWN")
		else
			SetDrawColor(unpack(theme.knob))
			DrawImage(nil, x + 2 + knobX, y + 2, self.knobSize - 2, self.knobSize - 2)
			SetDrawColor(unpack(knobColor))
			DrawImage(nil, x + 2 + knobX, y + 2, self.knobSize - 2, self.knobSize - 2, 1) -- knob border via outline
		end
	end
	if enabled and (mOver or self.dragging) then
		SetDrawLayer(nil, 100)
		if self.dragging then
			self:DrawTooltip(x, y, width, height, viewPort, self.val)
		else
			local cursorX, cursorY = GetCursorPos()
			local val = (cursorX - x - 1 - self.knobSize / 2) / knobTravel
			self:DrawTooltip(x, y, width, height, viewPort, m_max(0, m_min(1, val)))
		end
		SetDrawLayer(nil, 0)
	end
end

function SliderClass:OnKeyDown(key)
	if not self:IsShown() or not self:IsEnabled() then
		return
	end
	if key == "LEFTBUTTON" then
		local mOver, mOverComp = self:IsMouseOver()
		if not mOver then
			return
		end
		if not self.dragging then
			self.dragging = true
			local cursorX, cursorY = GetCursorPos()
			self.dragCX = cursorX
			if mOverComp == "SLIDE" then
				local x, y = self:GetPos()
				self:SetValFromKnobX(cursorX - x - 1 - self.knobSize / 2)
			end	
			self.dragKnobX = self:GetKnobXForVal()
		end
	end
	return self
end

function SliderClass:OnKeyUp(key)
	if not self:IsShown() or not self:IsEnabled() then
		return
	end
	if key == "LEFTBUTTON" then
		if self.dragging then
			self.dragging = false
			local cursorX, cursorY = GetCursorPos()
			self:SetValFromKnobX((cursorX - self.dragCX) + self.dragKnobX)
		end
	elseif (not main.invertSliderScrollDirection and key == "WHEELDOWN") or (main.invertSliderScrollDirection and  key == "WHEELUP") or key == "DOWN" or key == "LEFT" then
		if IsKeyDown("SHIFT") then
			self:SetVal(self.val - self.scrollWheelSpeedTbl["SHIFT"])
		elseif IsKeyDown("CTRL") then
			self:SetVal(self.val - self.scrollWheelSpeedTbl["CTRL"])
		else
			self:SetVal(self.val - self.scrollWheelSpeedTbl["DEFAULT"])
		end
	elseif (not main.invertSliderScrollDirection and key == "WHEELUP") or (main.invertSliderScrollDirection and key == "WHEELDOWN") or key == "UP" or key == "RIGHT" then
		if IsKeyDown("SHIFT") then
			self:SetVal(self.val + self.scrollWheelSpeedTbl["SHIFT"])
		elseif IsKeyDown("CTRL") then
			self:SetVal(self.val + self.scrollWheelSpeedTbl["CTRL"])
		else
			self:SetVal(self.val + self.scrollWheelSpeedTbl["DEFAULT"])
		end
	end
end
