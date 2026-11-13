-- Path of Building
--
-- Module: Gem Tooltip
-- Shared renderer for gem-style tooltips.

local m_max = math.max

local GemNamesRU = LoadModule("Data/GemNamesRU")
local SkillDescriptionsRU = LoadModule("Data/SkillDescriptionsRU")
local UITranslationsRU = LoadModule("Data/UITranslationsRU")
local ModTranslationsRU = LoadModule("Data/ModTranslationsRU")

local GEM_TAGS_RU = {
	["AoE"] = "Область",
	["Area"] = "Область",
	["Melee"] = "Ближний бой",
	["Physical"] = "Физ.",
	["Fire"] = "Огонь",
	["Cold"] = "Холод",
	["Lightning"] = "Молния",
	["Chaos"] = "Хаос",
	["Duration"] = "Длительность",
	["Attack"] = "Атака",
	["Spell"] = "Чары",
	["Projectile"] = "Снаряд",
	["Slam"] = "Мощный удар",
	["Strike"] = "Удар",
	["Warcry"] = "Боевой клич",
	["Buff"] = "Эффект",
	["Aura"] = "Аура",
	["Minion"] = "Приспешники",
	["Totem"] = "Тотем",
	["Channelling"] = "Потоковое",
	["Nova"] = "Кольцо",
	["Hazard"] = "Опасность",
	["Persistent"] = "Постоянное",
	["Meta"] = "Мета",
	["Trigger"] = "Срабатывание",
	["Curse"] = "Проклятие",
	["Mark"] = "Метка",
	["Trap"] = "Ловушка",
	["Mine"] = "Мина",
	["Orb"] = "Сфера",
	["Companion"] = "Спутник",
	["Travel"] = "Перемещение",
	["Guard"] = "Оборона",
	["Shapeshift"] = "Перевоплощение",
	["Bear"] = "Медведь",
	["Wolf"] = "Волк",
	["Wyvern"] = "Виверна",
	["Payoff"] = "Расплата",
	["Detonator"] = "Подрыв",
	["Herald"] = "Вестник",
	["Lineage"] = "Родословная",
	["Support"] = "Поддержка",
	["Sustained"] = "Поддерживаемое",
	["Storm"] = "Буря",
	["Exceptional"] = "Исключительное",
	["Vainglory"] = "Суетливое",
	["Vaal"] = "ВААЛ",
	["Golem"] = "Голем",
	["Endurance"] = "Выносливость",
	["Frenzy"] = "Ярость",
	["Power"] = "Сила",
}

local GEM_TYPES_RU = {
	["Active"] = "Камень умения",
	["Support"] = "Камень поддержки",
}

local function translateTagString(tagStr)
	if not tagStr or tagStr == "" then return tagStr end
	local out = { }
	for tag in tagStr:gmatch("[^,]+") do
		local t = tag:match("^%s*(.-)%s*$")
		out[#out + 1] = GEM_TAGS_RU[t] or t
	end
	return table.concat(out, ", ")
end

local function trLabel(label)
	if UITranslationsRU then
		return UITranslationsRU:Get(label) or label
	end
	return label
end

---@class GemTooltip
local GemTooltip = { }

local function getFontSizes()
	return main.showFlavourText and 18 or 16, main.showFlavourText and 24 or 20
end

local function addGemHeader(tooltip, gemInstance, grantedEffect)
	local fontSizeBig, fontSizeTitle = getFontSizes()
	local iconNameIndent = "            "
	local iconTagIndent = "                     "
	local itemLang = (main and main.itemLanguage) or "DUAL"
	local enTitle = grantedEffect.name
	local ruTitle = (itemLang ~= "EN" and GemNamesRU) and GemNamesRU:Get(gemInstance.gemData) or nil

	if itemLang == "RU" then
		tooltip:AddLine(fontSizeTitle, colorCodes.GEM .. iconNameIndent .. (ruTitle or enTitle), "FONTIN SC")
	elseif itemLang == "DUAL" and ruTitle and ruTitle ~= enTitle then
		tooltip:AddLine(fontSizeTitle, colorCodes.GEM .. iconNameIndent .. ruTitle, "FONTIN SC")
		tooltip:AddLine(fontSizeBig, "^8" .. iconTagIndent .. "(" .. enTitle .. ")", "FONTIN SC")
	else
		tooltip:AddLine(fontSizeTitle, colorCodes.GEM .. iconNameIndent .. enTitle, "FONTIN SC")
	end

	local displayType = grantedEffect.support and "Support" or "Active"
	if itemLang ~= "EN" and GEM_TYPES_RU[displayType] then
		displayType = GEM_TYPES_RU[displayType]
	end
	tooltip:AddLine(fontSizeBig, (colorCodes.GEMINFO or "^x6F9A98") .. iconTagIndent .. displayType, "FONTIN SC")
	tooltip:AddSeparator(8)

	if gemInstance.gemData.tagString then
		local dispTags = gemInstance.gemData.tagString
		if itemLang ~= "EN" then
			dispTags = translateTagString(dispTags)
		end
		tooltip:AddLine(fontSizeBig, "^x7F7F7F" .. iconTagIndent .. dispTags, "FONTIN SC")
	end
end


local reservationMap = {
		manaReservationFlat = "Mana",
		manaReservationPercent = "ManaPercent",
		lifeReservationFlat = "Life",
		lifeReservationPercent = "LifePercent",
	}

---@param tooltip Tooltip
---@param build Build
---@param gemInstance any
---@param grantedEffect any
---@param addLevel boolean
---@param addReq boolean
---@param mergeStatsFrom any
local function addCommonGemInfo(tooltip, build, gemInstance, grantedEffect, addLevel, addReq, mergeStatsFrom)
	local fontSizeBig = main.showFlavourText and 18 or 16
	local displayInstance = gemInstance.displayEffect or gemInstance
	local grantedEffectLevel = grantedEffect.levels[displayInstance.level] or {}
	if addLevel then
		local globalLevels = displayInstance.globalLevel or 0
		local itemLevels = displayInstance.itemLevel or 0
		local supportLevels = displayInstance.supportLevel or 0
		local maxLevel = gemInstance.level >= (gemInstance.gemData.naturalMaxLevel or math.huge) and " (Max)" or ""
		if itemLevels ~= 0 or globalLevels ~= 0 or supportLevels ~= 0 then
			tooltip:AddLine(fontSizeBig, trLabel("^x7F7F7FLevel:") .. " " .. colorCodes.MAGIC .. displayInstance.level, "FONTIN SC")
			tooltip:AddLine(fontSizeBig, string.format("^7%d Levels from Gem%s", gemInstance.level, maxLevel), "FONTIN SC")
			for _, source in ipairs({ { itemLevels, "Item" }, { globalLevels, "Global Modifiers" }, { supportLevels, "Supports" } }) do
				if source[1] ~= 0 then
					tooltip:AddLine(fontSizeBig, (source[1] > 0 and colorCodes.MAGIC or colorCodes.WARNING) .. string.format("%+d Levels from %s", source[1], source[2]), "FONTIN SC")
				end
			end
			if displayInstance.level ~= gemInstance.level + itemLevels + globalLevels + supportLevels then
				tooltip:AddLine(fontSizeBig, "^x7F7F7FLimited to Level " .. displayInstance.level, "FONTIN SC")
			end
		else
			tooltip:AddLine(fontSizeBig, string.format(trLabel("^x7F7F7FLevel:") .. " ^7%d%s", gemInstance.level, maxLevel), "FONTIN SC")
		end
	end
	if grantedEffect.support then
		if grantedEffectLevel.manaMultiplier then
			tooltip:AddLine(fontSizeBig,
				string.format("^x7F7F7FCost & Reservation Multiplier: ^7%d%%", grantedEffectLevel.manaMultiplier + 100),
				"FONTIN SC")
		end
		local reservation
		for name, res in pairs(reservationMap) do
			if grantedEffectLevel[name] then
				reservation = (reservation and (reservation .. ", ") or "") ..
				data.costs[isValueInArrayPred(data.costs, function(v) return v.Resource == res end)].ResourceString:gsub(
				"{0}", string.format("%d", grantedEffectLevel[name]))
			end
		end
		if reservation then
			tooltip:AddLine(fontSizeBig, "^x7F7F7FReservation Override: ^7" .. reservation, "FONTIN SC")
		end
		if grantedEffectLevel.cooldown then
			local string = string.format(trLabel("^x7F7F7FCooldown Time:") .. " ^7%.2f sec", grantedEffectLevel.cooldown)
			if grantedEffectLevel.storedUses and grantedEffectLevel.storedUses > 1 then
				string = string .. string.format(" (%d uses)", grantedEffectLevel.storedUses)
			end
			tooltip:AddLine(fontSizeBig, string, "FONTIN SC")
		end
	else
		local reservation
		for name, res in pairs(reservationMap) do
			if grantedEffectLevel[name] then
				reservation = (reservation and (reservation .. ", ") or "") ..
				data.costs[isValueInArrayPred(data.costs, function(v) return v.Resource == res end)].ResourceString:gsub(
				"{0}", string.format("%d", grantedEffectLevel[name]))
			end
		end
		if reservation then
			tooltip:AddLine(fontSizeBig, trLabel("^x7F7F7FReservation:") .. " ^7" .. reservation, "FONTIN SC")
		end
		local cost
		for _, res in ipairs(data.costs) do
			if grantedEffectLevel.cost and grantedEffectLevel.cost[res.Resource] then
				cost = (cost and (cost .. ", ") or "") ..
				res.ResourceString:gsub("{0}",
					string.format("%g", round(grantedEffectLevel.cost[res.Resource] / res.Divisor, 2)))
			end
		end
		if cost then
			tooltip:AddLine(fontSizeBig, "^x7F7F7FCost: ^7" .. cost, "FONTIN SC")
		end
		if grantedEffectLevel.cooldown then
			local string = string.format(trLabel("^x7F7F7FCooldown Time:") .. " ^7%.2f sec", grantedEffectLevel.cooldown)
			if grantedEffectLevel.storedUses and grantedEffectLevel.storedUses > 1 then
				string = string .. string.format(" (%d uses)", grantedEffectLevel.storedUses)
			end
			tooltip:AddLine(fontSizeBig, string, "FONTIN SC")
		end
		if grantedEffectLevel.vaalStoredUses then
			tooltip:AddLine(fontSizeBig,
				string.format("^x7F7F7FCan Store ^7%d ^x7F7F7FUse (%d Souls)", grantedEffectLevel.vaalStoredUses,
					grantedEffectLevel.vaalStoredUses * grantedEffectLevel.cost.Soul), "FONTIN SC")
		end
		if grantedEffectLevel.soulPreventionDuration then
			tooltip:AddLine(fontSizeBig,
				string.format("^x7F7F7FSoul Gain Prevention: ^7%d sec", grantedEffectLevel.soulPreventionDuration),
				"FONTIN SC")
		end
		if gemInstance.gemData.tags.attack then
			if grantedEffectLevel.attackSpeedMultiplier then
				tooltip:AddLine(fontSizeBig,
					string.format("^x7F7F7FAttack Speed: ^7%d%% of base", grantedEffectLevel.attackSpeedMultiplier + 100),
					"FONTIN SC")
			end
			if grantedEffectLevel.attackTime then
				tooltip:AddLine(fontSizeBig,
					string.format("^x7F7F7FAttack Time: ^7%.2f sec", grantedEffectLevel.attackTime / 1000), "FONTIN SC")
			end
			if grantedEffectLevel.baseMultiplier then
				tooltip:AddLine(fontSizeBig,
					string.format("^x7F7F7FAttack Damage: ^7%g%% of base", grantedEffectLevel.baseMultiplier * 100),
					"FONTIN SC")
			end
		else
			if grantedEffect.castTime > 0 then
				tooltip:AddLine(fontSizeBig, string.format(trLabel("^x7F7F7FCast Time:") .. " ^7%.2f sec", grantedEffect.castTime),
					"FONTIN SC")
			else
				tooltip:AddLine(fontSizeBig, trLabel("^x7F7F7FCast Time:") .. " ^7Instant", "FONTIN SC")
			end
		end
		if grantedEffectLevel.critChance then
			tooltip:AddLine(fontSizeBig,
				string.format("^x7F7F7FCritical Strike Chance: ^7%.2f%%", grantedEffectLevel.critChance), "FONTIN SC")
		end
		if grantedEffectLevel.damageEffectiveness then
			tooltip:AddLine(fontSizeBig,
				string.format("^x7F7F7FEffectiveness of Added Damage: ^7%d%%",
					grantedEffectLevel.damageEffectiveness * 100), "FONTIN SC")
		end
	end
	if addReq then
		if gemInstance.quality > 0 then
			tooltip:AddLine(fontSizeBig, string.format("^x7F7F7FQuality: +%s%d%%", colorCodes.MAGIC, gemInstance.quality), "FONTIN SC")
		end
		for _, source in ipairs({
			{ displayInstance.itemQuality or 0, "Item" },
			{ displayInstance.globalQuality or 0, "Global Modifiers" },
			{ displayInstance.supportQuality or 0, "Supports" },
			{ displayInstance.socketQuality or 0, "Socket Colour" },
		}) do
			if source[1] ~= 0 then
				tooltip:AddLine(fontSizeBig, (source[1] > 0 and colorCodes.MAGIC or colorCodes.WARNING) .. string.format("%+d%% Quality from %s", source[1], source[2]), "FONTIN SC")
			end
		end
	end
	tooltip:AddSeparator(10)
	if addReq then
		local reqLevel = grantedEffect.levels[gemInstance.level] and
		grantedEffect.levels[gemInstance.level].levelRequirement or 1
		local reqStr = calcLib.getGemStatRequirement(reqLevel, grantedEffect.support, gemInstance.gemData.reqStr)
		local reqDex = calcLib.getGemStatRequirement(reqLevel, grantedEffect.support, gemInstance.gemData.reqDex)
		local reqInt = calcLib.getGemStatRequirement(reqLevel, grantedEffect.support, gemInstance.gemData.reqInt)
		build:AddRequirementsToTooltip(tooltip, reqLevel, reqStr, reqDex, reqInt)
	end
	if grantedEffect.description then
		local itemLang = (main and main.itemLanguage) or "DUAL"
		local desc = grantedEffect.description
		if itemLang ~= "EN" and SkillDescriptionsRU then
			desc = SkillDescriptionsRU:Get(desc) or desc
		end
		tooltip:AddLine(fontSizeBig, colorCodes.GEM .. desc, "FONTIN SC")
	end
	if build.data.describeStats then
		tooltip:AddSeparator(10)
		local stats = calcLib.buildSkillInstanceStats(displayInstance, grantedEffect)
		if mergeStatsFrom then
			for stat, val in pairs(calcLib.buildSkillInstanceStats(displayInstance, mergeStatsFrom)) do
				stats[stat] = (stats[stat] or 0) + val
			end
		end
		local descriptions, lineMap = build.data.describeStats(stats, grantedEffect.statDescriptionScope)
		for _, line in ipairs(descriptions) do
			local trLine = line
			if itemLang ~= "EN" and ModTranslationsRU and ModTranslationsRU.Translate then
				trLine = ModTranslationsRU:Translate(line)
			end
			local source = grantedEffect.statMap[lineMap[line]] or build.data.skillStatMap[lineMap[line]]
			if source then
				if launch.devModeAlt then
					local devText = lineMap[line]
					if source[1] then
						if not source[1].value then
							source[1].value = lineMap[line]
						end
						devText = modLib.formatMod(source[1])
					end
					trLine = trLine .. " ^2" .. devText
				end
				tooltip:AddLine(fontSizeBig, colorCodes.MAGIC .. trLine, "FONTIN SC")
			else
				if launch.devModeAlt then
					trLine = trLine .. " ^1" .. lineMap[line]
				end
				local lineFormatted = colorCodes.UNSUPPORTED .. trLine
				lineFormatted = main.notSupportedModTooltips and (lineFormatted .. main.notSupportedTooltipText) or lineFormatted
				tooltip:AddLine(fontSizeBig, lineFormatted, "FONTIN SC")
			end
		end
	end
end

---@class GemToolTipOptions
---@field skipRequirements? boolean
---@param tooltip Tooltip
---@param build Build
---@param gemInstance any
---@param options? GemToolTipOptions
function GemTooltip.AddGemTooltip(tooltip, build, gemInstance, options)
	options = options or { }
	local fontSizeBig, fontSizeTitle = getFontSizes()
	local skipRequirements = options.skipRequirements
	tooltip.center = true
	tooltip.color = colorCodes.GEM
	tooltip.maxWidth = 600
	tooltip.tooltipHeader = "GEM"
	tooltip.gemIcon = gemInstance.gemData.grantedEffect.icon

	local primary = gemInstance.gemData.grantedEffect
	local secondary = gemInstance.gemData.secondaryGrantedEffect

	if secondary and (not secondary.support or gemInstance.gemData.secondaryEffectName) then
		local grantedEffect = gemInstance.gemData.VaalGem and secondary or primary
		local grantedEffectSecondary = gemInstance.gemData.VaalGem and primary or secondary
		addGemHeader(tooltip, gemInstance, grantedEffect)
		addCommonGemInfo(tooltip, build, gemInstance, grantedEffect, true, not skipRequirements)
		tooltip:AddSeparator(10)
		tooltip:AddLine(fontSizeTitle,
			colorCodes.GEM .. (gemInstance.gemData.secondaryEffectName or grantedEffectSecondary.name), "FONTIN SC")
		tooltip:AddSeparator(10)
		addCommonGemInfo(tooltip, build, gemInstance, grantedEffectSecondary)
	else
		local grantedEffect = gemInstance.gemData.grantedEffect
		addGemHeader(tooltip, gemInstance, grantedEffect)
		if grantedEffect.legacy then
			tooltip:AddLine(fontSizeTitle, colorCodes.WARNING .. "Legacy Gem", "FONTIN SC")
			tooltip:AddLine(fontSizeBig, colorCodes.WARNING .. "Gem only exists in Standard League", "FONTIN SC")
			tooltip:AddSeparator(10)
		end
		addCommonGemInfo(tooltip, build, gemInstance, grantedEffect, true, not skipRequirements,
			secondary and secondary.support and secondary)
	end
	if primary.flavourText and main.showFlavourText then
		tooltip:AddSeparator(10)
		for _, line in ipairs(primary.flavourText) do
			tooltip:AddLine(fontSizeBig, colorCodes.UNIQUE .. line, "FONTIN SC ITALIC")
		end
	end
end

return GemTooltip
