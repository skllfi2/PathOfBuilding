-- Path of Building
--
-- Module: CalcBreakdownRU
-- Russian localization for calculation breakdown tooltips and tables in Calcs / Sidebar.
--

local CalcBreakdownRU = {}

local typeNames = {
	["Physical"] = "физ. урона",
	["Fire"] = "урона от огня",
	["Cold"] = "урона от холода",
	["Lightning"] = "урона от молнии",
	["Chaos"] = "урона хаосом",
	["Elemental"] = "стихийного урона",
}

local poolNames = {
	["Life"] = "Здоровье",
	["Mana"] = "Мана",
	["Energy Shield"] = "Энерг. щит",
	["Runic Ward"] = "Рунический барьер",
	["Frost Shield Life"] = "Здоровье Морозного щита",
	["Total Spectre Life"] = "Общее здоровье призраков",
	["Total Totem Life"] = "Общее здоровье тотемов",
	["Total Vaal Rejuvenation Totem Life"] = "Общее здоровье тотема омоложения ваал",
	["Total Sentinel of Radiance Life"] = "Общее здоровье Стража сияния",
	["Total Companion Life"] = "Общее здоровье спутника",
	["Total Allied Energy shield"] = "Общий ЭЩ союзников",
	["Elemental Aegis charge"] = "Заряд стихийной эгиды",
	["Shared Aegis charge"] = "Заряд общей эгиды",
	["Shared Guard charge"] = "Заряд общей защиты",
}

CalcBreakdownRU.static = {
	["MCM"] = "MCM",
	["Buff"] = "Эффект",
	["Many Sources"] = "Много источников",
	["More/less"] = "Больше/меньше",
	["Inc/red"] = "Ув./ум.",
	["Contribution from Non-crits:"] = "Вклад некритических ударов:",
	["Contribution from Crits:"] = "Вклад критических ударов:",
	["Effective DoT Multiplier:"] = "Эффективный множитель урон. сост.:",
	["Effective resistance:"] = "Эффективное сопротивление:",
	["Effective DPS modifier:"] = "Эффективный множитель DPS:",
	["Approximate hit chance at:"] = "Прибл. шанс попадания на:",
	["Crit confirmation roll:"] = "Подтверждение крита:",
	["Base damage:"] = "Базовый урон:",
	["Hit damage:"] = "Урон удара:",
	["Non-Crit Dmg Derivation:"] = "Расчёт некрит. урона:",
	["Crit Dmg Derivation:"] = "Расчёт крит. урона:",
	["^8min combined sources + (max combined sources - min combined sources) * average roll"] = "^8мин. сумма + (макс. сумма - мин. сумма) * сред. бросок",
	["min combined sources + (max combined sources - min combined sources) * average roll"] = "мин. сумма + (макс. сумма - мин. сумма) * сред. бросок",
	["Damage from Non-crits:"] = "Урон от некритов:",
	["Damage from Crits:"] = "Урон от критов:",
	["Total base DPS per Poison:"] = "Баз. DPS одного яда:",
	["Average DPS for all Poisons:"] = "Средний DPS всех ядов:",
	["Total base DPS per Ignite:"] = "Баз. DPS одного поджога:",
	["Average DPS for all Ignites:"] = "Средний DPS всех поджогов:",
	["Total base DPS per Bleed:"] = "Баз. DPS одного кровотеч.:",
	["Average DPS for all Bleeds:"] = "Средний DPS всех кровотеч.:",
	["DPS Range:"] = "Диапазон DPS:",
	["The percentage of your max stacks that are applied on average if you are attacking constantly"] = "Средний % макс. стаков при постоянной атаке",
	["Combined chance:"] = "Итоговый шанс:",
	["Regular Hit HeavyStun buildup"] = "Накопл. тяж. оглушения (обычн. удар)",
	["Crit HeavyStun buildup"] = "Накопл. тяж. оглушения (крит)",
	["Average HeavyStun buildup"] = "Сред. накопл. тяж. оглушения",
	["Debuff"] = "Дебафф",
	["Area"] = "Область",
	["Pool"] = "Пул",
	["Incoming"] = "Входящий",
	["Multi"] = "Множ.",
	["Taken"] = "Получено",
	["Total life protected:"] = "Всего защищено здоровья:",
	["Energy Shield Regeneration:"] = "Регенерация ЭЩ:",
	["Ward Regeneration:"] = "Регенерация барьера:",
	["Rage Regeneration:"] = "Регенерация гнева:",
	["Maximum of:"] = "Максимум из:",
	["Regular Hit Freeze buildup"] = "Накопл. заморозки (обычн. удар)",
	["Crit Freeze buildup"] = "Накопл. заморозки (крит)",
	["Average Freeze buildup"] = "Сред. накопл. заморозки",
	["Regular Hit Electrocute buildup"] = "Накопл. электризации (обычн. удар)",
	["Crit Electrocute buildup"] = "Накопл. электризации (крит)",
	["Average Electrocute buildup"] = "Сред. накопл. электризации",
	["Regular Hit Pin buildup"] = "Накопл. пригвождения (обычн. удар)",
	["Crit Pin buildup"] = "Накопл. пригвождения (крит)",
	["Average Pin buildup"] = "Сред. накопл. пригвождения",
	["NOTE: Having any energy shield when the hit occurs grants 50% chance to avoid stun."] = "ПРИМ.: Любой ЭЩ при ударе даёт 50% шанс избежать оглушения.",
	["POB only applies this modifier when ES > Total incoming damage."] = "PoB применяет это только при ЭЩ > Общий входящий урон.",
	["Total leeched per instance:"] = "Всего похищено за эффект:",
	["Rate per instance:"] = "Скорость на эффект:",
	["Maximum leech rate against one target:"] = "Макс. скорость похищения по 1 цели:",
	["Life change prevented by Eternal Life"] = "Изменение здоровья предотвращено Вечной жизнью",
	["Life Loss Prevented"] = "Потеря здоровья предотвращена",
	["Overkill damage"] = "Избыточный урон",
	["Excess recovery applied to Energy Shield"] = "Избыток восстановления применён к ЭЩ",
	["Recharge rate:"] = "Скорость перезарядки:",
	["Effective Recharge rate:"] = "Эфф. скорость перезарядки:",
	["Total damage from the enemy"] = "Общий урон от врага",
	["Total damage taken from the enemy after taken as"] = "Урон от врага после перенаправления",
	["DoT Multiplier:"] = "Множитель урон. сост.:",
	["Total damage taken after mitigation"] = "Итоговый получаемый урон после защиты",
	["Cannot be Stunned"] = "Нельзя оглушить",
	["rounded up to nearest server tick"] = "округлено вверх до тика сервера",
	["Maximum hit damage breakdown"] = "Детализация макс. урона от удара",
	["Final Type"] = "Итоговый тип",
	["Taken As Percent"] = "Доля перенаправления",
	["Total Life Degen"] = "Общая трата здоровья",
	["Total Mana Degen"] = "Общая трата маны",
	["Total Energy Shield Degen"] = "Общая трата ЭЩ",
	["This part of the hit drains the following resources:"] = "Эта часть удара расходует следующие ресурсы:",
	["Assuming cast on every kill/attack/hit"] = "При срабатывании на каждое убийство/атаку/удар",
	["This is the average roll of an ailment affecting the enemy if you are constantly attacking"] = "Средний бросок состояния, наложенного на врага при постоянной атаке",
	["Uses a weighted average formula when stack potential is over 100%"] = "При потенциале стаков > 100% используется средневзвешенная формула",
	["Average Roll:"] = "Средний бросок:",
	["Frost Shield Life"] = "Здоровье Морозного щита",
	["Total Spectre Life"] = "Общее здоровье призраков",
	["Total Totem Life"] = "Общее здоровье тотемов",
	["Total Vaal Rejuvenation Totem Life"] = "Общее здоровье тотема омоложения ваал",
	["Total Sentinel of Radiance Life"] = "Общее здоровье Стража сияния",
	["Total Allied Energy shield"] = "Общий ЭЩ союзников",
	["Elemental Aegis charge"] = "Заряд стихийной эгиды",
	["Shared Aegis charge"] = "Заряд общей эгиды",
	["Shared Guard charge"] = "Заряд общей защиты",
	-- TZ-01: PoE1 headless misses (BD lines)
	["Dmg Derivation:"] = "Расчёт урона:",
	["NOTE: Calculation uses a Weighted Avg formula"] = "ПРИМ.: расчёт использует средневзвешенную формулу",
	["This is the average roll of an ignite affecting the enemy if you are constantly attacking"] = "Это средний бросок поджога, действующего на врага, при постоянной атаке",
	["min combined sources + (max combined sources - min combined sources) * average ignite roll"] = "мин. сумма + (макс. сумма - мин. сумма) * сред. бросок поджога",
}

CalcBreakdownRU.parens = {
	["effective movement speed modifier"] = "эфф. мод. скорости передвижения",
	["physical damage reduction"] = "снижение физ. урона",
	["average damage"] = "средний урон",
	["attack rate"] = "скорость атаки",
	["base life cost"] = "баз. стоимость здоровья",
	["base mana cost"] = "баз. стоимость маны",
	["current config"] = "тек. настройки",
	["chance to apply"] = "шанс наложения",
	["Duration / Attack Time"] = "Длительность / Время атаки",
	["max number of stacks"] = "макс. число стаков",
	["burn rate modifier"] = "мод. скорости горения",
	["portion of damage from non-crits"] = "доля урона от некритов",
	["portion of damage from crits"] = "доля урона от критов",
	["enemy crit effect"] = "эффект крита врага",
	["Number of mitigated hits"] = "Число смягчённых ударов",
	["Chance to even be hit"] = "Шанс вообще получить удар",
	["total average number of hits you can take"] = "среднее число ударов до смерти",
	["maximum mana"] = "макс. мана",
	["percentage of mana to maximum leech rate"] = "% маны в макс. скорость похищения",
	["maximum life"] = "макс. здоровье",
	["percentage of life to maximum leech rate"] = "% здоровья в макс. скорость похищения",
	["maximum energy shield"] = "макс. ЭЩ",
	["percentage of energy shield to maximum leech rate"] = "% ЭЩ в макс. скорость похищения",
	["frost shield limit"] = "лимит Морозного щита",
	["portion taken from frost shield"] = "доля от Морозного щита",
	["portion taken from life and energy shield"] = "доля от здоровья и ЭЩ",
	["total time it would take to die"] = "общее время до гибели",
	["stun multiplier"] = "множитель оглушения",
	["effective enemy stun damage"] = "эфф. урон оглушения врага",
	["stun threshold"] = "порог оглушения",
	["number of hits"] = "число ударов",
	["total burst damage"] = "общий взрывной урон",
	["chance for block to fail"] = "шанс провала блока",
	["chance to be hit by an Average hit"] = "шанс получить обычный удар",
	["of damage taken from an Average hit"] = "урона от обычного удара",
	["multiplier"] = "множитель",
	["aura effect modifier"] = "мод. эффекта ауры",
	["more/less damage taken"] = "больше/меньше получ. урона",
	["base"] = "база",
	["base value"] = "базовое значение",
	["base radius"] = "базовый радиус",
	["base duration"] = "базовая длительность",
	["more/less"] = "больше/меньше",
	["more"] = "больше",
	["inc"] = "ув.",
	["increased/reduced"] = "ув./ум.",
	["total"] = "итого",
	["override"] = "переопределение",
	["from config"] = "из настроек",
	["degen"] = "трата",
	["recovery"] = "восстановление",
	["overflow recovery"] = "избыт. восстановление",
	["converted from"] = "конвертировано из",
	["converted to"] = "конвертировано в",
	["added damage"] = "добавленный урон",
	["added damage multiplier"] = "множ. добавленного урона",
	["ailment duration"] = "длительность состояния",
	["ailment effect modifier"] = "мод. эффекта состояния",
	["ailment magnitude effect"] = "мод. силы состояния",
	["attack time"] = "время атаки",
	["attack time per stage"] = "время атаки за стадию",
	["cast time"] = "время применения",
	["cast time per stage"] = "время применения за стадию",
	["casts per second"] = "применений в секунду",
	["average hit"] = "средний удар",
	["average pvp hit"] = "средний PvP-удар",
	["average instances"] = "среднее число эффектов",
	["average from crits"] = "среднее от критов",
	["average from non-crits"] = "среднее от некритов",
	["average physical hit before mitigation"] = "средний физ. удар до защиты",
	["MH average physical hit before mitigation"] = "средний физ. удар осн. руки до защиты",
	["OH average physical hit before mitigation"] = "средний физ. удар доп. руки до защиты",
	["average life recoup"] = "среднее возмещение здоровья",
	["average mana recoup"] = "среднее возмещение маны",
	["average energy shield recoup"] = "среднее возмещение ЭЩ",
	["average life lost over time"] = "средняя потеря здоровья со временем",
	["avg ailment stacks"] = "среднее число стаков состояния",
	["base damage multiplier"] = "базовый множ. урона",
	["base damage per second"] = "базовый урон в секунду",
	["base cooldown of triggered skill"] = "базовая перезарядка срабатывающего умения",
	["final cooldown of trigger"] = "итоговая перезарядка триггера",
	["final cooldown of triggered skill"] = "итоговая перезарядка срабатывающего умения",
	["biggest of trigger cooldown and triggered skill cooldown"] = "максимум из перезарядки триггера и умения",
	["block effect"] = "эффект блока",
	["bolt count"] = "число болтов",
	["eff. bolt count"] = "эфф. число болтов",
	["effective bolt count"] = "эфф. число болтов",
	["buff expiration multiplier"] = "множитель истечения баффа",
	["chance to hit"] = "шанс попадания",
	["MH chance to hit"] = "шанс попадания осн. руки",
	["OH chance to hit"] = "шанс попадания доп. руки",
	["chance for avoidance to fail"] = "шанс провала избегания",
	["chance for damage avoidance to fail"] = "шанс провала избегания урона",
	["chance for dodge to fail"] = "шанс провала уклонения",
	["chance for evasion to fail"] = "шанс провала уклонения",
	["chance from crits"] = "шанс от критов",
	["chance from non-crits"] = "шанс от некритов",
	["chance to double stun duration"] = "шанс удвоить длит. оглушения",
	["chance to not consume"] = "шанс не потратить",
	["chance to reload instantly"] = "шанс мгновенной перезарядки",
	["channel time multiplier"] = "множитель времени поддержания",
	["cost multiplier"] = "множитель стоимости",
	["crit chance"] = "шанс крита",
	["damage converted from other damage types"] = "урон, конверт. из других типов",
	["damage gained from other damage types"] = "урон, полученный от других типов",
	["damage from crits"] = "урон от критов",
	["damage from non-crits"] = "урон от некритов",
	["debuff expires slower/faster"] = "истечение дебаффа",
	["deflect effect"] = "эффект отклонения",
	["delay modifier"] = "модификатор задержки",
	["dot multiplier for crits"] = "множ. урон. сост. для критов",
	["dot multiplier for non-crits"] = "множ. урон. сост. для некритов",
	["dps multiplier for this skill"] = "множ. DPS для этого умения",
	["DPS multiplier for this skill"] = "множ. DPS для этого умения",
	["DPS of all stacks"] = "DPS всех стаков",
	["Capped ailment DPS"] = "Ограниченный DPS состояния",
	["Capped ailment DPS Range"] = "Диапазон огр. DPS состояния",
	["Uncapped ailment DPS Range"] = "Диапазон неогр. DPS состояния",
	["Uncapped raw ailment DPS"] = "Неогр. чистый DPS состояния",
	["ailment DPS Range"] = "Диапазон DPS состояния",
	["due to dual wielding"] = "из-за парного оружия",
	["duration modifier"] = "модификатор длительности",
	["eff. attack rate"] = "эфф. скорость атаки",
	["eff. attack time"] = "эфф. время атаки",
	["eff. reload time"] = "эфф. время перезарядки",
	["effective reload time"] = "эфф. время перезарядки",
	["effective DPS modifier"] = "эфф. множитель DPS",
	["effective DPS modifier from enemy debuffs"] = "эфф. множитель DPS от дебаффов врага",
	["enemy action speed"] = "скорость действий врага",
	["flat added cooldown"] = "плоская доб. перезарядка",
	["hit rate"] = "частота ударов",
	["hit time"] = "время удара",
	["hit time + cooldown"] = "время удара + перезарядка",
	["hit time override"] = "переопределение времени удара",
	["hits per triggered skill cast"] = "ударов за срабатывание",
	["impale chance"] = "шанс прокола",
	["impale damage multiplier"] = "множ. урона прокола",
	["OH impale damage multiplier"] = "множ. урона прокола доп. руки",
	["impale enemy damage taken"] = "получ. врагом урон от прокола",
	["impale enemy physical damage reduction"] = "сниж. физ. урона врага от прокола",
	["increased duration"] = "ув. длительности",
	["increased effectiveness"] = "ув. эффективности",
	["increased threshold"] = "ув. порога",
	["increased/reduced block recovery"] = "ув./ум. восст. после блока",
	["increased/reduced cooldown recovery"] = "ув./ум. скорости перезарядки",
	["increased/reduced damage taken"] = "ув./ум. получаемого урона",
	["increased/reduced duration"] = "ув./ум. длительности",
	["increased/reduced enemy stun recovery"] = "ув./ум. восст. врага после оглушения",
	["increased/reduced recovery"] = "ув./ум. восстановления",
	["increased/reduced stun duration"] = "ув./ум. длит. оглушения",
	["instance duration"] = "длительность эффекта",
	["inverted hit after penetration"] = "инверт. удар после пробития",
	["non-inverted hit after penetration"] = "обычный удар после пробития",
	["leech rate modifier"] = "мод. скорости похищения",
	["level from gem"] = "уровень камня",
	["level from items"] = "от предметов",
	["level from corruption"] = "от осквернения",
	["level from support"] = "от камней поддержки",
	["lower of cast rates"] = "меньшая из скоростей применения",
	["mana cost conversion"] = "конвертация стоимости маны",
	["minimum channel time"] = "мин. время поддержания",
	["modifiers to enemy damage"] = "модификаторы урона врага",
	["more threshold"] = "больше порога",
	["more/less cost"] = "больше/меньше стоимости",
	["more/less duration"] = "больше/меньше длительности",
	["more/less stun duration"] = "больше/меньше длит. оглушения",
	["multiplier from Unleash"] = "множитель от Высвобождения",
	["negative resistance unaffected by penetration"] = "отриц. сопр. не меняется пробитием",
	["Negative resistance unaffected by penetration"] = "отриц. сопр. не меняется пробитием",
	["Penetration cannot bring resistances below 0"] = "пробитие не опускает сопр. ниже 0",
	["number of stacks, can be overridden in the Configuration tab"] = "число стаков (можно задать в Конфигурации)",
	["over 4 seconds"] = "за 4 секунды",
	["penetration"] = "пробитие",
	["percent of damage recouped"] = "% возмещаемого урона",
	["portion not already taken over time"] = "доля, не растянутая во времени",
	["portion of instances created by crits"] = "доля эффектов от критов",
	["portion of instances created by non-crits"] = "доля эффектов от некритов",
	["portion of instances created by main hand"] = "доля эффектов осн. руки",
	["portion of instances created by off hand"] = "доля эффектов доп. руки",
	["portion of life on low life"] = "доля жизни на низком здоровье",
	["portion taken from life"] = "доля, снимаемая со здоровья",
	["portion taken over 4 seconds instead"] = "доля, растянутая на 4 сек.",
	["quality from gem"] = "качество камня",
	["quality from global modifiers"] = "от глобальных свойств",
	["quality from supports"] = "от камней поддержки",
	["quantity multiplier for this skill"] = "множитель количества для умения",
	["rate modifier"] = "модификатор скорости",
	["recovery rate modifier"] = "модификатор скорости восстановления",
	["regeneration rate modifier"] = "модификатор скорости регенерации",
	["reload time"] = "время перезарядки",
	["repeat count"] = "число повторений",
	["repeated attacks/casts do not count as they don't use mana"] = "повторы не считаются, т.к. не тратят ману",
	["resistance"] = "сопротивление",
	["resistance ignored"] = "игнорирование сопротивления",
	["size of leech destination pool"] = "размер пула похищения",
	["skill alternates weapons"] = "умение чередует оружие",
	["skill cooldown"] = "перезарядка умения",
	["skill hits once with each weapon"] = "удар каждым оружием по разу",
	["skill hits with both weapons at once"] = "удар обоими оружиями сразу",
	["source curse duration"] = "длительность исходного проклятия",
	["source damage"] = "исходный урон",
	["source damage from crits"] = "исходный урон от критов",
	["source damage from non-crits"] = "исходный урон от некритов",
	["square root of area of effect modifier"] = "корень из модификатора области действия",
	["final radius modifier"] = "итоговый модификатор радиуса",
	["stored damage"] = "накопленный урон",
	["suppression effect"] = "эффект подавления",
	["total attack time"] = "общее время атаки",
	["total damage"] = "общий урон",
	["total damage taken during ehp calcs"] = "общий урон в расчёте EHP",
	["total elemental damage taken during ehp calcs"] = "стих. урон в расчёте EHP",
	["total incoming damage"] = "общий входящий урон",
	["total energy shield degen"] = "общая трата ЭЩ",
	["total energy shield regen"] = "общая регенерация ЭЩ",
	["total life degen"] = "общая трата здоровья",
	["total life regen"] = "общая регенерация здоровья",
	["total mana degen"] = "общая трата маны",
	["total mana regen"] = "общая регенерация маны",
	["total runic ward regen"] = "общая реген. рунического барьера",
	["total firing time"] = "общее время стрельбы",
	["trigger rate adjusted for triggering interval"] = "частота с учётом интервала триггера",
	["uptime"] = "время действия",
	["activation modifier"] = "модификатор активации",
	["adjusted for server tick rate"] = "с учётом тика сервера",
	["Base chance"] = "Базовый шанс",
	["Effective chance to trigger"] = "Эфф. шанс срабатывания",
	["Effective source rate"] = "Эфф. частота источника",
	["In game source skill usage duration in seconds"] = "Длительность использования умения в игре (сек.)",
	["Vixen's trigger cooldown"] = "Перезарядка триггера Vixen",
}

local function translateNote(note)
	if CalcBreakdownRU.parens[note] then
		return CalcBreakdownRU.parens[note]
	end
	local rem = note:match("^(%d+) remaining$")
	if rem then return rem .. " осталось" end
	local tot = note:match("^(%d+) total$")
	if tot then return tot .. " всего" end
	local fromSrc = note:match("^base from (.+)$")
	if fromSrc then return "база от " .. fromSrc end
	local dmgFrom = note:match("^damage from (.+)$")
	if dmgFrom then return "урон от " .. dmgFrom end
	local baseCd = note:match("^base cooldown of (.+)$")
	if baseCd then return "баз. перезарядка " .. baseCd end
	local hardCd = note:match("^hard override of cooldown of (.+)$")
	if hardCd then return "жёстк. перезарядка " .. hardCd end
	local leechRate = note:match("^base leech rate is (%d+)%% per second$")
	if leechRate then return "базовая скорость похищения " .. leechRate .. "%/с" end
	local wAvg = note:match("^weighted average from ([%d%.]+%%) inversion chance$")
	if wAvg then return "средневзв. при " .. wAvg .. " шансе инверсии" end
	local penCap = note:match("^penetration cannot bring resistances below ([%+%-]?%d+%%)$")
	if penCap then return "пробитие не опускает сопр. ниже " .. penCap end
	local overSec = note:match("^over (%d+) seconds$")
	if overSec then return "за " .. overSec .. " сек." end
	local projHit = note:match("^(%d+) projectiles hit$")
	if projHit then return "попало снарядов: " .. projHit end
	local dblDmg = note:match("^multiplier from (%d+)%% chance to deal double damage$")
	if dblDmg then return "множ. от " .. dblDmg .. "% шанса двойного урона" end
	local trpDmg = note:match("^multiplier from (%d+)%% chance to deal triple damage$")
	if trpDmg then return "множ. от " .. trpDmg .. "% шанса тройного урона" end
	local ailDeal = note:match("^ailment deals (%d+)%% per second$")
	if ailDeal then return "состояние наносит " .. ailDeal .. "%/с" end
	local totTaken = note:match("^total (.+) damage taken during ehp calcs$")
	if totTaken then return "общий " .. (typeNames[totTaken] or totTaken) .. " в расчёте EHP" end
	local paidLife = note:match("^(%d+%%) paid for with life$")
	if paidLife then return paidLife .. " оплачено здоровьем" end
	local perSec = note:match("^([%d%.]+%%) per second$")
	if perSec then return perSec .. " в секунду" end
	return nil
end

-- ===== TZ-01: dynamic patterns for PoE1 headless misses =====
local curseRu = {
	["Assassin's Mark"] = "Клеймо убийцы",
	["Conductivity"] = "Проводимость",
	["Despair"] = "Отчаяние",
	["Elemental Weakness"] = "Стихийная слабость",
	["Enfeeble"] = "Изнурение",
	["Flammability"] = "Воспламеняемость",
	["Frostbite"] = "Обморожение",
	["Poacher's Mark"] = "Клеймо охотника",
	["Projectile Weakness"] = "Слабость к снарядам",
	["Punishment"] = "Возмездие",
	["Temporal Chains"] = "Цепи времени",
	["Vulnerability"] = "Уязвимость",
	["Warlord's Mark"] = "Клеймо военачальника",
}
local curModRu = {
	["of Elemental Weakness"] = "стихийной слабости",
	["of Enfeeblement"] = "изнурения",
	["of Temporal Chains"] = "цепей времени",
	["of Vulnerability"] = "уязвимости",
}
local cmpStats = {
	["Effective Hit Pool"] = "эфф. пула здоровья",
	["Phys Max Hit"] = "макс. физ. удара",
	["Elemental Max Hit"] = "макс. стих. удара",
	["Chaos Max Hit"] = "макс. удара хаосом",
	["Attack Rate"] = "скорости атаки",
	["Hit DPS"] = "DPS удара",
	["Average Damage"] = "среднего урона",
	["Movement Speed Modifier"] = "мод. скорости передвижения",
	["Evasion rating"] = "уклонения",
	["Armour"] = "брони",
	["Crit Chance"] = "шанса крита",
	["Life Regen"] = "реген. здоровья",
	["Mana Regen"] = "реген. маны",
	["Phys. Damage Reduction"] = "сниж. физ. урона",
	["Total Life"] = "всего здоровья",
	["Hit Chance"] = "шанса попадания",
	["Fire Resistance"] = "сопр. огню",
	["Cold Resistance"] = "сопр. холоду",
	["Lightning Resistance"] = "сопр. молнии",
	["Chaos Resistance"] = "сопр. хаосу",
	["Evasion"] = "уклонения",
	["Life Recoverable"] = "восстанавливаемого здоровья",
}
local incStats = {
	["Action Speed"] = "скорости действий",
	["Projectile Speed"] = "скорости снарядов",
	["Damage"] = "урона",
	["Damage Taken"] = "получаемого урона",
	["Stun Duration on Enemies"] = "длит. оглушения врагов",
	["Armour"] = "брони",
	["Character Size"] = "размера персонажа",
	["Area of Effect"] = "области действия",
	["Physical Damage"] = "физ. урона",
	["Minion Movement Speed"] = "скорости передвижения приспешников",
	["Minion Attack and Cast Speed"] = "скорости атаки и применения приспешников",
}
local moreStats = {
	["Elemental Damage"] = "стихийного урона",
	["Elemental Damage taken"] = "получаемого стихийного урона",
	["Attack Speed"] = "скорости атаки",
	["Cast Speed"] = "скорости применения",
	["Damage"] = "урона",
	["Minion Damage"] = "урона приспешников",
}
local baseMaxRu = {
	["Spiders"] = "пауков",
	["Spectral Tigers"] = "спектральных тигров",
	["Spectral Wolves"] = "спектральных волков",
	["Gale Force"] = "шквала",
}
local ignNoteRu = {
	["Ignite DoT Multi"] = "множ. постеп. урона поджога",
	["chance to ignite"] = "шанс поджога",
	["Ignite Duration / Attack Time"] = "длит. поджога / время атаки",
}
local shrineRu = {
	["Sacrificial Zeal"] = "Жертвенного рвения",
	["Acceleration Shrine"] = "святыни ускорения",
	["Lesser Acceleration Shrine"] = "малой святыни ускорения",
	["Brutal Shrine"] = "святыни мощи",
	["Lesser Brutal Shrine"] = "малой святыни мощи",
	["Diamond Shrine"] = "алмазной святыни",
	["Divine Shrine"] = "божественной святыни",
	["Echoing Shrine"] = "эхо-святыни",
	["Gloom Shrine"] = "сумрачной святыни",
	["Greater Freezing Shrine"] = "большой святыни заморозки",
	["Greater Shocking Shrine"] = "большой святыни поражения",
	["Greater Skeletal Shrine"] = "большой святыни скелетов",
	["Impenetrable Shrine"] = "непробиваемой святыни",
	["Lesser Impenetrable Shrine"] = "малой непробиваемой святыни",
	["Massive Shrine"] = "громадной святыни",
	["Lesser Massive Shrine"] = "малой громадной святыни",
	["Replenishing Shrine"] = "восстанавливающей святыни",
	["Lesser Replenishing Shrine"] = "малой восстанавливающей святыни",
	["Resistance Shrine"] = "святыни сопротивлений",
	["Lesser Resistance Shrine"] = "малой святыни сопротивлений",
	["Resonating Shrine"] = "резонирующей святыни",
	["Blood Shrine of Rats"] = "кровавой святыни крыс",
	["Blood Shrine of Locusts"] = "кровавой святыни саранчи",
	["Blood Shrine of Toads"] = "кровавой святыни жаб",
	["Blood Shrine of Crows"] = "кровавой святыни ворон",
	["Blood Shrine of Bats"] = "кровавой святыни летучих мышей",
}
local dmgTypePlain = {
	Physical = "физ. урона",
	Fire = "урона от огня",
	Cold = "урона от холода",
	Lightning = "урона от молнии",
	Chaos = "урона хаосом",
	Elemental = "стихийного урона",
}
local dmgTypeColored = {
	Fire = "^xB97123урона от огня^7",
	Cold = "^x3F6DB3урона от холода^7",
	Lightning = "^xADAA47урона от молнии^7",
	Chaos = "^xD02090урона хаосом^7",
}
local toRu = {
	["all Elemental Resistances"] = "ко всем стихийным сопротивлениям",
	["all maximum Resistances"] = "ко всем макс. сопротивлениям",
	["Damage over Time Multiplier"] = "к множ. постепенного урона",
	["Chaos Resistance"] = "к сопр. хаосу",
	["enemy Elemental Resistances"] = "к стих. сопротивлениям врага",
}
local sockColRu = { Red = "красных", Green = "зелёных", Blue = "синих", White = "белых" }
local sockColTag = { Red = "^xE05030", Green = "^x70FF70", Blue = "^x7070FF", White = "" }
local chargeKindRu = { Power = "энергии", Frenzy = "ярости", Endurance = "выносливости" }

local function TranslateExtra(coreText, tagless, colorPrefix, trailingSuffix)
	local m1, m2, m3, m4
	-- "N Overkill damage" (keep inner colour codes)
	m1 = tagless:match("^(%d+) Overkill damage$")
	if m1 then
		return colorPrefix .. coreText:gsub("Overkill damage", "избыточного урона") .. trailingSuffix
	end
	-- "= 0.0% over 4 seconds" (Recoup)
	m1, m2 = tagless:match("^=%s*([%d%.]+%%)%s+over%s+(%d+)%s+seconds$")
	if m1 then
		return colorPrefix .. "= " .. m1 .. " за " .. m2 .. " сек." .. trailingSuffix
	end
	-- "TotalPool: 60"
	m1 = tagless:match("^TotalPool:%s*(.+)$")
	if m1 then
		return colorPrefix .. "Общий пул: " .. m1 .. trailingSuffix
	end
	-- "60 ^xE05030Life"
	m1 = tagless:match("^(%d+) Life$")
	if m1 then
		return colorPrefix .. m1 .. " ^xE05030здоровья" .. trailingSuffix
	end
	-- "Ailment mode: Average Damage (can be changed in the Configuration tab)"
	if tagless == "Ailment mode: Average Damage (can be changed in the Configuration tab)" then
		return colorPrefix .. "Режим состояний: средний урон ^8(можно изменить на вкладке «Конфигурация»)" .. trailingSuffix
	end
	-- "* 1.00 (Ignite DoT Multi)" / "* 0.00 (chance to ignite)"
	m1, m2 = tagless:match("^%* ([%d%.]+) %((.+)%)$")
	if m1 then
		return colorPrefix .. "* " .. m1 .. " ^8(" .. (ignNoteRu[m2] or m2) .. ")" .. trailingSuffix
	end
	-- "* (4.00 / 0.83) (Ignite Duration / Attack Time)"
	m1, m2 = tagless:match("^%* (%(%d+%.%d+ / [%d%.]+%)) %((.+)%)$")
	if m1 then
		return colorPrefix .. "* " .. m1 .. " ^8(" .. (ignNoteRu[m2] or m2) .. ")" .. trailingSuffix
	end
	-- "50% (averaging <= 1 ignites)"
	m1, m2 = tagless:match("^([%d%.]+%%) %(averaging <= (%d+) ignites%)$")
	if m1 then
		return colorPrefix .. m1 .. " (в среднем <= " .. m2 .. " поджогов)" .. trailingSuffix
	end
	-- "If attacking constantly, your average strongest Ignite currently achieves N% of its max damage"
	m1 = tagless:match("^If attacking constantly, your average strongest Ignite currently achieves%s*([%d%.]+%%)%s*of its max damage$")
	if m1 then
		return colorPrefix .. "При постоянной атаке ваш средний сильнейший поджог сейчас достигает ^7" .. m1 .. colorPrefix .. " макс. урона" .. trailingSuffix
	end
	-- "Act 10 (-60%)"
	m1, m2 = tagless:match("^Act (%d+) %((%-?%d+%%)%)$")
	if m1 then
		return colorPrefix .. "Акт " .. m1 .. " (" .. m2 .. ")" .. trailingSuffix
	end
	-- Slot labels
	m1 = tagless:match("^Abyssal #(%d+)$")
	if m1 then return colorPrefix .. "Бездна #" .. m1 .. trailingSuffix end
	m1 = tagless:match("^Graft (%d+)$")
	if m1 then return colorPrefix .. "Прививка " .. m1 .. trailingSuffix end
	m1 = tagless:match("^Flask (%d+)$")
	if m1 then return colorPrefix .. "Флакон " .. m1 .. trailingSuffix end
	-- Empty socket colour override
	m1 = tagless:match("^This option allows you to override the default calculation for the number of Empty (%a+) Sockets%.$")
	if m1 then
		return colorPrefix .. "Этот параметр переопределяет стандартный расчёт числа пустых " .. (sockColTag[m1] or "") .. (sockColRu[m1] or m1) .. "^7 гнёзд" .. trailingSuffix
	end
	-- "For reference, a level N monster has M base life, and a level P monster has Q."
	m1, m2, m3, m4 = tagless:match("^For reference, a level (%d+) monster has (%d+) base life, and a level (%d+) monster has (%d+)%.$")
	if m1 then
		return colorPrefix .. "Для справки: у монстра " .. m1 .. " ур. базовое ^xE05030здоровье^7 — " .. m2 .. ", " .. m3 .. " ур. — " .. m4 .. trailingSuffix
	end
	-- "You will automatically be considered to be on Low Life if you have at least N% Life reserved"
	m1 = tagless:match("^You will automatically be considered to be on Low Life if you have at least (%d+)%% Life reserved$")
	if m1 then
		return colorPrefix .. "Низкое ^xE05030здоровье ^7включается автоматически при удержании от " .. m1 .. "% ^xE05030здоровья^7" .. trailingSuffix
	end
	-- "Gained when you take X Damage, up to N stacks."
	m1, m2 = tagless:match("^Gained when you take (%a+) Damage, up to (%d+) stacks%.$")
	if m1 then
		local gtRu = { Physical = "физ.", Elemental = "стихийного" }
		local gtCol = { Physical = "^xB97123", Elemental = "" }
		return colorPrefix .. "Получается при получении " .. (gtCol[m1] or "") .. (gtRu[m1] or m1) .. "^7 урона, до " .. m2 .. " стаков" .. trailingSuffix
	end
	-- "Counts X as self-cast for Balance of Terror without applying it to enemies."
	m1 = tagless:match("^Counts (.+) as self%-cast for Balance of Terror without applying it to enemies%.$")
	if m1 then
		return colorPrefix .. "Считает " .. (curseRu[m1] or m1) .. " самоналоженным для Баланса ужаса, не применяя его к врагам" .. trailingSuffix
	end
	-- "Sets the level of X to apply to the player."
	m1 = tagless:match("^Sets the level of (.+) to apply to the player%.$")
	if m1 then
		return colorPrefix .. "Задаёт уровень наложения «" .. (curseRu[m1] or m1) .. "» на игрока" .. trailingSuffix
	end
	-- "In mid/high tier maps, 'of X' applies level N."
	m1, m2, m3 = tagless:match("^In mid tier maps, 'of (.+)' applies level (%d+)%.$")
	if m1 then
		return colorPrefix .. "На картах среднего тира «" .. (curModRu["of " .. m1] or m1) .. "» даёт " .. m2 .. " уровень" .. trailingSuffix
	end
	m1, m2, m3 = tagless:match("^In high tier maps, 'of (.+)' applies level (%d+)%.$")
	if m1 then
		return colorPrefix .. "На картах высокого тира «" .. (curModRu["of " .. m1] or m1) .. "» даёт " .. m2 .. " уровень" .. trailingSuffix
	end
	-- "The base maximum number of X is N."
	m1, m2 = tagless:match("^The base maximum number of (.+) is (%d+)%.$")
	if m1 then
		return colorPrefix .. "Базовый максимум " .. (baseMaxRu[m1] or m1) .. ": " .. m2 .. trailingSuffix
	end
	-- "Base maximum X is N."
	m1, m2 = tagless:match("^Base maximum (.+) is (%d+)%.$")
	if m1 then
		return colorPrefix .. "Базовый максимум " .. (baseMaxRu[m1] or m1) .. ": " .. m2 .. trailingSuffix
	end
	-- "The default level for normal enemies and standard bosses is N."
	m1 = tagless:match("^The default level for normal enemies and standard bosses is (%d+)%.$")
	if m1 then
		return colorPrefix .. "Стандартный уровень обычных врагов и обычных боссов — " .. m1 .. trailingSuffix
	end
	-- "Maximum N stacks"
	m1 = tagless:match("^Maximum (%d+) stacks$")
	if m1 then
		return colorPrefix .. "Максимум " .. m1 .. " стаков" .. trailingSuffix
	end
	-- "This will enable the X buff."
	m1 = tagless:match("^This will enable the (.+) buff%.$")
	if m1 then
		return colorPrefix .. "Это включит эффект " .. (shrineRu[m1] or m1) .. trailingSuffix
	end
	-- "Gain N% of X Damage as Extra Y Damage"
	m1, m2, m3 = tagless:match("^Gain (%d+)%% of (%a+) Damage as Extra (%a+) Damage$")
	if m1 and dmgTypePlain[m2] and dmgTypePlain[m3] then
		local src, dst
		if coreText:find("%^x", 1, true) then
			src = dmgTypeColored[m2] or dmgTypePlain[m2]
			dst = dmgTypeColored[m3] or dmgTypePlain[m3]
		else
			src = dmgTypePlain[m2]
			dst = dmgTypePlain[m3]
		end
		return colorPrefix .. "Даёт " .. m1 .. "% " .. src .. " как доп. " .. dst .. trailingSuffix
	end
	-- "Regenerate N% of Life per second"
	m1 = tagless:match("^Regenerate ([%d%.]+%%) of Life per second$")
	if m1 then
		return colorPrefix .. "Восстанавливает " .. m1 .. " ^xE05030здоровья ^7в секунду" .. trailingSuffix
	end
	-- "N% of Life Regenerated per second"
	m1 = tagless:match("^([%d%.]+%%) of Life Regenerated per second$")
	if m1 then
		return colorPrefix .. m1 .. " ^xE05030здоровья ^7восстанавливается в секунду" .. trailingSuffix
	end
	-- "N% increased Mana Regeneration Rate"
	m1 = tagless:match("^(%d+)%% increased Mana Regeneration Rate$")
	if m1 then
		return colorPrefix .. m1 .. "% ув. ^x7070FFскорости реген. маны^7" .. trailingSuffix
	end
	-- "N% reduced Effect of Curses on you"
	m1 = tagless:match("^(%d+)%% reduced Effect of Curses on you$")
	if m1 then
		return colorPrefix .. m1 .. "% ум. эффекта проклятий на вас" .. trailingSuffix
	end
	-- "N% inc Damage Taken per stack"
	m1 = tagless:match("^(%d+)%% inc Damage Taken per stack$")
	if m1 then
		return colorPrefix .. m1 .. "% ув. получаемого урона за слой" .. trailingSuffix
	end
	-- "N% reduced Action Speed per stack" / "N% reduced Action Speed"
	m1 = tagless:match("^(%d+)%% reduced Action Speed per stack$")
	if m1 then
		return colorPrefix .. m1 .. "% ум. скорости действий за слой" .. trailingSuffix
	end
	m1 = tagless:match("^(%d+)%% reduced Action Speed$")
	if m1 then
		return colorPrefix .. m1 .. "% ум. скорости действий" .. trailingSuffix
	end
	-- "Deal N% less Damage"
	m1 = tagless:match("^Deal (%d+)%% less Damage$")
	if m1 then
		return colorPrefix .. "Наносят на " .. m1 .. "% меньше урона" .. trailingSuffix
	end
	-- "N% increased X"
	m1, m2 = tagless:match("^(%d+)%% increased (.+)$")
	if m1 and incStats[m2] then
		return colorPrefix .. m1 .. "% ув. " .. incStats[m2] .. trailingSuffix
	end
	-- "N% more/less X"
	m1, m2 = tagless:match("^(%d+)%% more (.+)$")
	if m1 and moreStats[m2] then
		return colorPrefix .. m1 .. "% больше " .. moreStats[m2] .. trailingSuffix
	end
	m1, m2 = tagless:match("^(%d+)%% less (.+)$")
	if m1 and moreStats[m2] then
		return colorPrefix .. m1 .. "% меньше " .. moreStats[m2] .. trailingSuffix
	end
	-- "+N to Maximum X Charges"
	m1, m2 = tagless:match("^%+(%d+) to Maximum (%a+) Charges$")
	if m1 then
		return colorPrefix .. "+" .. m1 .. " к макс. зарядам " .. (chargeKindRu[m2] or m2) .. trailingSuffix
	end
	-- "+N% to X"
	m1, m2 = tagless:match("^%+(%d+)%% to (.+)$")
	if m1 and toRu[m2] then
		return colorPrefix .. "+" .. m1 .. "% " .. toRu[m2] .. trailingSuffix
	end
	-- "N% Stat" (e.g. "+50% Fire Resistance")
	m1, m2 = tagless:match("^([%+%-]?[%d%.]+%%) (.+)$")
	if m1 and cmpStats[m2] then
		return colorPrefix .. m1 .. " " .. cmpStats[m2] .. trailingSuffix
	end
	-- "N Stat (delta%)" (e.g. "+5 Effective Hit Pool (+12.5%)")
	m1, m2, m3 = tagless:match("^([%+%-]?[%d%.]+) (.+) %(([%+%-]?[%d%.]+)%%%)$")
	if m1 and cmpStats[m2] then
		return colorPrefix .. m1 .. " " .. cmpStats[m2] .. " (" .. m3 .. "%)" .. trailingSuffix
	end
	-- "inf Stat (deltainf%)"
	m1, m2, m3 = tagless:match("^([%+%-]?)inf (.+) %(([%+%-]?)inf%%%)$")
	if m1 and cmpStats[m2] then
		return colorPrefix .. m1 .. "inf " .. cmpStats[m2] .. " (" .. m3 .. "inf%)" .. trailingSuffix
	end
	-- "N Stat" (e.g. "-16 Evasion rating", "+15 Armour")
	m1, m2 = tagless:match("^([%+%-]?[%d%.]+) (.+)$")
	if m1 and cmpStats[m2] then
		return colorPrefix .. m1 .. " " .. cmpStats[m2] .. trailingSuffix
	end
	return nil
end

function CalcBreakdownRU.Translate(coreText, tagless, colorPrefix, trailingSuffix)
	local st = CalcBreakdownRU.static[tagless] or CalcBreakdownRU.static[tagless .. ":"]
	if st then
		if trailingSuffix:sub(1, 1) == ":" and st:sub(-1) == ":" then
			st = st:sub(1, -2)
		end
		return colorPrefix .. st .. trailingSuffix
	end

	-- Prefix + optional ^7/^8 + (note)
	local pfx, tag, note = coreText:match("^(.-)%s*(%^%d)%((.+)%)$")
	if not pfx then
		pfx, note = coreText:match("^(.-)%s*%((.+)%)$")
		tag = ""
	end
	if pfx and note then
		local trNote = translateNote(note)
		if trNote then
			local trPfx = poolNames[pfx] or pfx
			return colorPrefix .. trPfx .. (trPfx ~= "" and " " or "") .. tag .. "(" .. trNote .. ")" .. trailingSuffix
		elseif poolNames[pfx] then
			return colorPrefix .. poolNames[pfx] .. " " .. tag .. "(" .. note .. ")" .. trailingSuffix
		end
	end

	-- Non-parenthetical patterns
	local n1 = tagless:match("^Instant Leech:%s*(.+)$")
	if n1 then return colorPrefix .. "Мгновенное похищение: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^Time to reach max:%s*(.+)$")
	if n1 then return colorPrefix .. "Время до максимума: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^Leech rate cap:%s*(.+)$")
	if n1 then return colorPrefix .. "Потолок скорости похищения: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^Time to reach cap:%s*(.+)$")
	if n1 then return colorPrefix .. "Время до потолка: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^Armour contributing to reduction:%s*(.+)$")
	if n1 then return colorPrefix .. "Броня для снижения урона: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^Reduction from Armour:%s*(.+)$")
	if n1 then return colorPrefix .. "Снижение от брони: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^Combined Defence used for reduction:%s*(.+)$")
	if n1 then return colorPrefix .. "Совместная защита для снижения: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^Reduction from combined Defence:%s*(.+)$")
	if n1 then return colorPrefix .. "Снижение от совм. защиты: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^Enemy Hit Damage After Resistance:%s*(.+)$")
	if n1 then return colorPrefix .. "Урон удара врага после сопр.: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^Enemy Hit Damage:%s*(.+)$")
	if n1 then return colorPrefix .. "Урон удара врага: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^Resistance:%s*(.+)$")
	if n1 then return colorPrefix .. "Сопротивление: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^%+ Enemy Pen:%s*(.+)$")
	if n1 then return colorPrefix .. "+ Пробитие врага: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^Enemy Pen:%s*(.+)$")
	if n1 then return colorPrefix .. "Пробитие врага: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^x Taken:%s*(.+)$")
	if n1 then return colorPrefix .. "x Получаемый: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^Taken:%s*(.+)$")
	if n1 then return colorPrefix .. "Получаемый: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^x Spell Suppression:%s*(.+)$")
	if n1 then return colorPrefix .. "x Подавление чар: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^x Deflection:%s*(.+)$")
	if n1 then return colorPrefix .. "x Отклонение: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^%+ Impale:%s*(.+)$")
	if n1 then return colorPrefix .. "+ Прокол: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^%+ Flat:%s*(.+)$")
	if n1 then return colorPrefix .. "+ Плоский: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^Mana through MoM:%s*(.+)$")
	if n1 then return colorPrefix .. "Мана через МоМ: " .. n1 .. trailingSuffix end
	n1 = tagless:match("^Non%-bypassed Energy Shield:%s*(.+)$")
	if n1 then return colorPrefix .. "Необойдённый ЭЩ: " .. n1 .. trailingSuffix end

	local pctArm = tagless:match("^(%d+%%) percent of Armour applies$")
	if pctArm then return colorPrefix .. "Применяется " .. pctArm .. " брони" .. trailingSuffix end
	local pctDef, defType = tagless:match("^(%d+%%) percent of (.+) applies$")
	if pctDef then return colorPrefix .. "Применяется " .. pctDef .. " " .. defType .. trailingSuffix end
	local redType, redVal = tagless:match("^Base (.+) Damage Reduction:%s*(.+)$")
	if redType then return colorPrefix .. "Баз. сниж. " .. (typeNames[redType] or redType) .. ": " .. redVal .. trailingSuffix end
	local totRedType, totRedVal = tagless:match("^Total (.+) Damage Reduction:%s*(.+)$")
	if totRedType then return colorPrefix .. "Итого сниж. " .. (typeNames[totRedType] or totRedType) .. ": " .. totRedVal .. trailingSuffix end
	local baseTakType, baseTakVal = tagless:match("^Base (.+) Damage Taken:%s*(.+)$")
	if baseTakType then return colorPrefix .. "Баз. получ. " .. (typeNames[baseTakType] or baseTakType) .. ": " .. baseTakVal .. trailingSuffix end
	local ovwType, ovwVal = tagless:match("^Enemy Overwhelm (.+) Damage:%s*(.+)$")
	if ovwType then return colorPrefix .. "Преодоление " .. (typeNames[ovwType] or ovwType) .. " врагом: " .. ovwVal .. trailingSuffix end
	local enmType, enmVal = tagless:match("^Enemy (%a+):%s*(.+)$")
	if enmType then return colorPrefix .. "Враг (" .. enmType .. "): " .. enmVal .. trailingSuffix end
	local finType = tagless:match("^Final (.+) Damage taken:?$")
	if finType then return colorPrefix .. "Итого получено " .. (typeNames[finType] or finType) .. ":" .. trailingSuffix end

	-- Average Roll & Buff notes
	local avgStrPct = tagless:match("^If hitting constantly, your average strongest ailment currently achieves%s*([%d%.]+%%)%s*of its max damage$")
	if avgStrPct then return colorPrefix .. "При постоянных ударах сильнейшее состояние в среднем наносит ^7" .. avgStrPct .. colorPrefix .. " от макс. урона" .. trailingSuffix end
	local avgApps = tagless:match("^50%% %(averaging <= (%d+) applications%)$")
	if avgApps then return colorPrefix .. "50% (в среднем <= " .. avgApps .. " наложений)" .. trailingSuffix end
	local buffRest = tagless:match("^Buff,%s*(.+)$")
	if buffRest then return colorPrefix .. "Эффект, " .. buffRest .. trailingSuffix end
	local pctOverSec = tagless:match("^([%d%.]+%%)%s+over%s+(%d+)%s+seconds$")
	if pctOverSec then
		local p1, p2 = tagless:match("^([%d%.]+%%)%s+over%s+(%d+)%s+seconds$")
		return colorPrefix .. p1 .. " за " .. p2 .. " сек." .. trailingSuffix
	end
	local incDmg = tagless:match("^([%d%.]+)%s+incoming damage$")
	if incDmg then return colorPrefix .. incDmg .. " входящего урона" .. trailingSuffix end
	local dmgMult = tagless:match("^x%s*([%d%.]+)%s+damage mult$")
	if dmgMult then return colorPrefix .. "x " .. dmgMult .. " множ. урона" .. trailingSuffix end
	local avgAcc = tagless:match("^Average enemy accuracy:%s*(.+)$")
	if avgAcc then return colorPrefix .. "Сред. меткость врага: " .. avgAcc .. trailingSuffix end
	local effEva = tagless:match("^Effective Evasion:%s*(.+)$")
	if effEva then return colorPrefix .. "Эфф. уклонение: " .. effEva .. trailingSuffix end
	local appEv = tagless:match("^Approximate (.+) chance:%s*(.+)$")
	if appEv then
		local evKind, evVal = tagless:match("^Approximate (.+) chance:%s*(.+)$")
		local kindMap = {
			evade = "уклонения",
			["projectile evade"] = "уклонения от снарядов",
			["spell evade"] = "уклонения от чар",
			["spell projectile evade"] = "уклонения от снарядов чар",
			deflect = "отклонения",
		}
		return colorPrefix .. "Прибл. шанс " .. (kindMap[evKind] or evKind) .. ": " .. evVal .. trailingSuffix
	end
	local dotMod = tagless:match("^Dot Damage Taken modifier:%s*(.+)$")
	if dotMod then return colorPrefix .. "Множ. получ. урон. сост.: " .. dotMod .. trailingSuffix end
	local dotPool = tagless:match("^Total Effective Dot Pool:%s*(.+)$")
	if dotPool then return colorPrefix .. "Общий эфф. пул урон. сост.: " .. dotPool .. trailingSuffix end
	local enmTime = tagless:match("^x%s*([%d%.]+)%s+enemy attack/cast time$")
	if enmTime then return colorPrefix .. "x " .. enmTime .. " ^8время атаки/чар врага" .. trailingSuffix end
	local fromDef, fromVal = tagless:match("^from ([^:]+):%s*(.+)$")
	if fromDef then return colorPrefix .. "от " .. fromDef .. ": " .. fromVal .. trailingSuffix end
	local eqCps = tagless:match("^=%s*([%d%.]+)%s*casts per second$")
	if eqCps then return colorPrefix .. "= " .. eqCps .. " ^8применений в секунду" .. trailingSuffix end
	local enmPhys = tagless:match("^Enemy physical damage reduction:%s*(.+)$")
	if enmPhys then return colorPrefix .. "Сниж. физ. урона врага: " .. enmPhys .. trailingSuffix end
	local portTot = tagless:match("^Portion of total damage:%s*(.+)$")
	if portTot then return colorPrefix .. "Доля от общего урона: " .. portTot .. trailingSuffix end
	local maxAilPct = tagless:match("^([%d%.]+%%)%s+of Maximum ailment DPS$")
	if maxAilPct then return colorPrefix .. maxAilPct .. " от макс. DPS состояния" .. trailingSuffix end
	local chNc = tagless:match("^Chance on Non%-crit:%s*(.+)$")
	if chNc then return colorPrefix .. "Шанс без крита: " .. chNc .. trailingSuffix end
	local chCr = tagless:match("^Chance on Crit:%s*(.+)$")
	if chCr then return colorPrefix .. "Шанс при крите: " .. chCr .. trailingSuffix end
	local minLbl = tagless:match("^Min:%s*(.+)$")
	if minLbl then return colorPrefix .. "Мин.: " .. minLbl .. trailingSuffix end
	local avgLbl = tagless:match("^Avg:%s*(.+)$")
	if avgLbl then return colorPrefix .. "Сред.: " .. avgLbl .. trailingSuffix end
	local cMinLbl = tagless:match("^Crit Min:%s*(.+)$")
	if cMinLbl then return colorPrefix .. "Крит мин.: " .. cMinLbl .. trailingSuffix end
	local cMaxLbl = tagless:match("^Crit Max:%s*(.+)$")
	if cMaxLbl then return colorPrefix .. "Крит макс.: " .. cMaxLbl .. trailingSuffix end
	local cAvgLbl = tagless:match("^Crit Avg:%s*(.+)$")
	if cAvgLbl then return colorPrefix .. "Крит сред.: " .. cAvgLbl .. trailingSuffix end
	local totFrom = tagless:match("^Total from (.+)$")
	if totFrom then return colorPrefix .. "Всего от: " .. totFrom .. trailingSuffix end
	local skType = tagless:match("^Skill type:%s*(.+)$")
	if skType then return colorPrefix .. "Тип умения: " .. skType .. trailingSuffix end
	local gmTag = tagless:match("^Gem tag:%s*(.+)$")
	if gmTag then return colorPrefix .. "Тег камня: " .. gmTag .. trailingSuffix end
	local monTag = tagless:match("^Monster Tag:%s*(.+)$")
	if monTag then return colorPrefix .. "Тег монстра: " .. monTag .. trailingSuffix end
	local inSlot = tagless:match("^When in slot #(%d+)$")
	if inSlot then return colorPrefix .. "В ячейке #" .. inSlot .. trailingSuffix end
	local limTo = tagless:match("^Limited to (.+)$")
	if limTo then return colorPrefix .. "Ограничено: " .. limTo .. trailingSuffix end

	return TranslateExtra(coreText, tagless, colorPrefix, trailingSuffix)
end

return CalcBreakdownRU
