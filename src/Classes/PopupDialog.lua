-- Path of Building
--
-- Class: Popup Dialog
-- Popup Dialog Box with a configurable list of controls
--
local m_floor = math.floor
local m_max = math.max
local m_min = math.min

---@class PopupDialog: ControlHost, Control
local PopupDialogClass = newClass("PopupDialog", "ControlHost", "Control")

-- Fluent theme support (safe degradation: nil if module not yet loaded)
local ThemeFluent = nil
local okTheme, resTheme = pcall(function() return LoadModule("Modules/ThemeFluent") end)
if okTheme and type(resTheme) == "table" then
	ThemeFluent = resTheme
end

-- Resolve Fluent theme colours for the dialog, with safe fallback.
local function DialogTheme()
	local dlg = ThemeFluent and ThemeFluent.dialog or nil
	if not dlg then
		return {
			bg = { 0.16, 0.16, 0.17, 1 },
			border = { 0.5, 0.5, 0.5, 1 },
			title = { 1, 1, 1, 1 },
			radius = 8,
			shadowBlur = 10,
		}
	end
	return {
		bg = dlg.bg or { 0.16, 0.16, 0.17, 1 },
		border = dlg.border or { 0.5, 0.5, 0.5, 1 },
		title = dlg.title or { 1, 1, 1, 1 },
		radius = dlg.radius or 8,
		shadowBlur = dlg.shadowBlur or 10,
	}
end

function PopupDialogClass:PopupDialog(width, height, title, controls, enterControl, defaultControl,
									escapeControl, scrollBarFunc, resizeFunc)
	self:ControlHost()
	self:Control(nil, {0, 0, width, height})
	self.x = function()
		local width = self:GetSize()
		return m_max(0, m_floor((main.screenW - width) / 2))
	end
	self.y = function()
		return m_max(10, m_floor((main.screenH - self:GetEffectiveHeight()) / 2))
	end
	self.title = title
	self.controls = controls
	self.enterControl = enterControl
	self.escapeControl = escapeControl
	for id, control in pairs(self.controls) do
		if not control.anchor.point then
			control:SetAnchor("TOP", self, "TOP")
		elseif not control.anchor.other then
			control.anchor.other = self
		elseif type(control.anchor.other) ~= "table" then
			control.anchor.other = self.controls[control.anchor.other]
		end
	end
	if defaultControl then
		self:SelectControl(self.controls[defaultControl])
	end
	-- allow scrollbar functionality inside of popups
	self.scrollBarFunc = scrollBarFunc
	-- allow resizing of popup
	self.resizeFunc = resizeFunc
	return self
end

function PopupDialogClass:GetEffectiveHeight()
	local rawH = self:GetProperty("height") or 0
	return m_min(rawH, main.screenH - 20)
end

function PopupDialogClass:GetSize()
	local width = self:GetProperty("width")
	local height = self:GetEffectiveHeight()
	return width, height
end

function PopupDialogClass:Draw(viewPort)
	local x, y = self:GetPos()
	local width, height = self:GetSize()
	local effectiveH = self:GetEffectiveHeight()
	local theme = DialogTheme()

	-- Draw dialog background with Fluent rounded box + safe DrawControlBox degradation
	if type(DrawControlBox) == "function" then
		DrawControlBox(x, y, width, effectiveH, theme.radius, theme.bg, theme.border, 1, theme.shadowBlur)
	else
		SetDrawColor(0.8, 0.8, 0.8)
		DrawImage(nil, x, y, width, effectiveH)
		SetDrawColor(0.1, 0.1, 0.1)
		DrawImage(nil, x + 2, y + 2, width - 4, effectiveH - 4)
	end
	-- Draw dialog title box
	local title = self:GetProperty("title")
	local titleWidth = DrawStringWidth(16, "VAR", title)
	local titleX = x + m_floor((width - titleWidth - 8) / 2)
	SetDrawColor(1, 1, 1)
	DrawImage(nil, titleX, y - 10, titleWidth + 8, 24)
	SetDrawColor(0, 0, 0)
	DrawImage(nil, titleX + 2, y - 8, titleWidth + 4, 20)
	SetDrawColor(unpack(theme.title))
	DrawString(titleX + 4, y - 7, "LEFT", 16, "VAR", title)
	-- Keep the content scrollbar in sync with the live dialog height so a
	-- shrunk dialog scrolls its content instead of clipping it
	local scrollBar = self.controls.scrollBar
	if scrollBar and scrollBar.SetContentDimension and scrollBar.conDim then
		local viewDim = effectiveH - 65
		if viewDim > 0 then
			scrollBar.height = viewDim
			scrollBar:SetContentDimension(scrollBar.conDim, viewDim)
		end
	end
	if self.scrollBarFunc then
		self.scrollBarFunc()
	end
	if self.resizeFunc then
		self.resizeFunc()
	end
	-- Draw controls
	self:DrawControls(viewPort)
end

function PopupDialogClass:ProcessInput(inputEvents, viewPort)
	self:ProcessControlsInput(inputEvents, viewPort)
	for id, event in ipairs(inputEvents) do
		if event.type == "KeyDown" then
			if event.key == "ESCAPE" then
				if self.escapeControl then
					self.controls[self.escapeControl]:Click()
				else
					main:ClosePopup()
				end
				return
			elseif event.key == "RETURN" then
				if self.enterControl then
					self.controls[self.enterControl]:Click()
					return
				end
			end
		elseif self.scrollBarFunc and event.type == "KeyUp" then
			if self.controls.scrollBar:IsScrollDownKey(event.key) then
				self.controls.scrollBar:Scroll(1)
			elseif self.controls.scrollBar:IsScrollUpKey(event.key) then
				self.controls.scrollBar:Scroll(-1)
			end
		end
	end
end
