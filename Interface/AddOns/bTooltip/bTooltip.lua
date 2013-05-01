local addonName, ns = ...

local bTooltip_font = STANDARD_TEXT_FONT

local cursor = 			false
local colorStatusBar = 	true
local TARGET = 			"|cfffed100"..TARGET..":|r "
local TARGETYOU = 		"<You>"
local worldBoss = 		"??"
local rareElite = 		"Rare+"
local rare = 			"Rare"
local hideTitle = 		false
local ClassColors = 	{}
local Reaction = 		{}

local backdropColor = {0.08,0.08,0.1,0.92}
local backdropBorderColor = {0.3,0.3,0.33,1}
local tooltipPosition = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -10, 180 }
local tooltipScale = 0.9

local class = select(2, UnitClass('player'))
local SymbiosisTip = CreateFrame('GameTooltip', 'SymbiosisTip', UIParent, 'GameTooltipTemplate')

local symbiosis = {
	gain = {
		['DEATHKNIGHT'] = { ['DK_BLOOD']            = 113072, ['DK_FROST']          = 113516, ['DK_UNHOLY']         = 113516, },
		['HUNTER']      = { ['HUNTER_BM']           = 113073, ['HUNTER_MM']         = 113073, ['HUNTER_SV']         = 113073, },
		['MAGE']        = { ['MAGE_ARCANE']         = 113074, ['MAGE_FIRE']         = 113074, ['MAGE_FROST']        = 113074, },
		['MONK']        = { ['MONK_BREW']           = 113306, ['MONK_MIST']         = 127361, ['MONK_WIND']         = 113275, },
		['PALADIN']     = { ['PALADIN_HOLY']        = 113269, ['PALADIN_PROT']      = 122287, ['PALADIN_RET']       = 113075, },
		['PRIEST']      = { ['PRIEST_DISC']         = 113506, ['PRIEST_HOLY']       = 113506, ['PRIEST_SHADOW']     = 113277, },
		['ROGUE']       = { ['ROGUE_ASS']           = 113613, ['ROGUE_COMBAT']      = 113613, ['ROGUE_SUB']         = 113613, },
		['SHAMAN']      = { ['SHAMAN_ELE']          = 113286, ['SHAMAN_ENHANCE']    = 113286, ['SHAMAN_RESTO']      = 113289, },
		['WARLOCK']     = { ['WARLOCK_AFFLICTION']  = 113295, ['WARLOCK_DEMO']      = 113295, ['WARLOCK_DESTRO']    = 113295, },
		['WARRIOR']     = { ['WARRIOR_ARMS']        = 122294, ['WARRIOR_FURY']      = 122294, ['WARRIOR_PROT']      = 122286, },
	},
	grant = {
		['DEATHKNIGHT'] =   { ['DRUID_BALANCE'] = 110570, ['DRUID_FERAL'] = 122282, ['DRUID_GUARDIAN'] = 122285, ['DRUID_RESTO'] = 110575, },
		['HUNTER'] =        { ['DRUID_BALANCE'] = 110588, ['DRUID_FERAL'] = 110597, ['DRUID_GUARDIAN'] = 110600, ['DRUID_RESTO'] = 19263, },
		['MAGE'] =          { ['DRUID_BALANCE'] = 110621, ['DRUID_FERAL'] = 110693, ['DRUID_GUARDIAN'] = 110694, ['DRUID_RESTO'] = 110696, },
		['MONK'] =          { ['DRUID_BALANCE'] = 126458, ['DRUID_FERAL'] = 128844, ['DRUID_GUARDIAN'] = 126453, ['DRUID_RESTO'] = 126456, },
		['PALADIN'] =       { ['DRUID_BALANCE'] = 110698, ['DRUID_FERAL'] = 110700, ['DRUID_GUARDIAN'] = 110701, ['DRUID_RESTO'] = 122288, },
		['PRIEST'] =        { ['DRUID_BALANCE'] = 110707, ['DRUID_FERAL'] = 110715, ['DRUID_GUARDIAN'] = 110717, ['DRUID_RESTO'] = 110718, },
		['ROGUE'] =         { ['DRUID_BALANCE'] = 110788, ['DRUID_FERAL'] = 110730, ['DRUID_GUARDIAN'] = 122289, ['DRUID_RESTO'] = 110791, },
		['SHAMAN'] =        { ['DRUID_BALANCE'] = 110802, ['DRUID_FERAL'] = 110807, ['DRUID_GUARDIAN'] = 110803, ['DRUID_RESTO'] = 110806, },
		['WARLOCK'] =       { ['DRUID_BALANCE'] = 122291, ['DRUID_FERAL'] = 110810, ['DRUID_GUARDIAN'] = 122290, ['DRUID_RESTO'] = 112970, },
		['WARRIOR'] =       { ['DRUID_BALANCE'] = 122292, ['DRUID_FERAL'] = 112997, ['DRUID_GUARDIAN'] = 113002, ['DRUID_RESTO'] = 113004, },
	}
}

local PowerBarColor = {
	[0] = { r = 48/255, g = 113/255, b = 191/255}, -- Mana
	[1] = { r = 255/255, g = 1/255, b = 1/255}, -- Rage
	[2] = { r = 255/255, g = 178/255, b = 0}, -- Focus
	[3] = { r = 1, g = 1, b = 34/255}, -- Energy
	[4] = {	r = 1, g = 1, b = 34/255}, --Chi
	[5] = {	r = .55, g = .57, b = .61}, --Runes
	[6] = { r = 1, g = 0, b = 34/255}, -- Runic Power
	[7] = { r = .8, g = .6, b = 0}, --Ammoslot
	[8] = { r = 0, g = .55, b = .5}, --Fuel
	[9] = { r = .55, g = .57, b = .61}, --Steam
	[10] = { r = .60, g = .09, b = .17}, --Pyrite
}

GameTooltipHeaderText:SetFont(bTooltip_font, 14, 'THINOUTLINE')
GameTooltipText:SetFont(bTooltip_font, 12, 'THINOUTLINE')
Tooltip_Small:SetFont(bTooltip_font, 11, 'THINOUTLINE')
--Tooltip_Small:SetShadowColor(0,0,0,1)
--Tooltip_Small:SetShadowOffset(1, -1)

function GameTooltip_ShowStatusBar(self, min, max, value, text, r, g, b, a)
	self:AddLine(" ")
	local numLines = self:NumLines()
	if not self.numStatusBars then self.numStatusBars = 0 end
	if not self.shownStatusBars then self.shownStatusBars = 0 end
	local index = self.shownStatusBars + 1
	local name = self:GetName().."StatusBar"..index
	local statusBar = _G[name]
	if not statusBar then
		self.numStatusBars = self.numStatusBars + 1
		statusBar = CreateFrame("StatusBar", name, self)

		statusBar:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8', edgeFile = 'Interface\\Buttons\\WHITE8x8',  tiled = false, edgeSize = 1, insets = {left=-1, right=-1, top=-1, bottom=-1} })
		statusBar:SetBackdropColor(0, 0, 0, 0.5)
		statusBar:SetBackdropBorderColor(0, 0, 0, 0.5)

		statusBar:SetStatusBarTexture("Interface\\AddOns\\oUF_Diablo\\media\\statusbar256_3") --Interface\\RAIDFRAME\\Raid-Bar-Hp-Fill
		statusBar.text = statusBar.text or statusBar:CreateFontString(name.."Text", 'OVERLAY', 'Tooltip_Small')
		statusBar.text:SetAllPoints()
		statusBar.text:SetJustifyH('CENTER')
	end
	_G[name.."Text"]:SetText(text and text or "")
	_G[name.."Text"]:Show()
	statusBar:SetSize(128, 10)
	statusBar:SetStatusBarColor(r, g, b, a)
	statusBar:SetMinMaxValues(min, max)
	statusBar:SetValue(value)
	statusBar:Show()
	statusBar:ClearAllPoints()
	statusBar:SetPoint("LEFT", self:GetName().."TextLeft"..numLines, "LEFT", 0, -2)
	statusBar:SetPoint("RIGHT", self, "RIGHT", -9, 0)
	statusBar:Show()
	self.shownStatusBars = index
	self:SetMinimumWidth(140)
end


local StatNames = {	ITEM_MOD_SPIRIT_SHORT, ITEM_MOD_DODGE_RATING_SHORT,	ITEM_MOD_PARRY_RATING_SHORT, ITEM_MOD_HIT_RATING_SHORT, ITEM_MOD_CRIT_RATING_SHORT, ITEM_MOD_HASTE_RATING_SHORT, ITEM_MOD_EXPERTISE_RATING_SHORT, ITEM_MOD_MASTERY_RATING_SHORT }
local reforgeIDs = {
	{1, 2}, {1, 3}, {1, 4}, {1, 5}, {1, 6}, {1, 7}, {1, 8},
	{2, 1}, {2, 3}, {2, 4}, {2, 5}, {2, 6}, {2, 7}, {2, 8},
	{3, 1}, {3, 2}, {3, 4}, {3, 5}, {3, 6}, {3, 7}, {3, 8},
	{4, 1},{4, 2},{4, 3},{4, 5},{4, 6},{4, 7},{4, 8},
	{5, 1},{5, 2},{5, 3},{5, 4},{5, 6},{5, 7},{5, 8},
	{6, 1},{6, 2},{6, 3},{6, 4},{6, 5},{6, 7},{6, 8},
	{7, 1},{7, 2},{7, 3},{7, 4},{7, 5},{7, 6},{7, 8},
	{8, 1},{8, 2},{8, 3},{8, 4},{8, 5},{8, 6},{8, 7},
}

local fixvalue = function(v)
  if v > 1E10 then
    return (floor(v/1E9)).."b"
  elseif v > 1E9 then
    return (floor((v/1E9)*10)/10).."b"
  elseif v > 1E7 then
    return (floor(v/1E6)).."m"
  elseif v > 1E6 then
    return (floor((v/1E6)*10)/10).."m"
  elseif v > 1E4 then
    return (floor(v/1E3)).."k"
  elseif v > 1E3 then
    return (floor((v/1E3)*10)/10).."k"
  else
    return v
  end
end

local GetHexColor = function(color)
	return ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
end

for class, color in pairs(RAID_CLASS_COLORS) do
	ClassColors[class] = GetHexColor(RAID_CLASS_COLORS[class])
end

for i = 1, #FACTION_BAR_COLORS do
	Reaction[i] = GetHexColor(FACTION_BAR_COLORS[i])
end

local function getTargetLine(unit)
	if UnitIsUnit(unit, "player") then
		return ("|cffff0000%s|r"):format(TARGETYOU)
	elseif UnitIsPlayer(unit, "player")then
		return ClassColors[select(2, UnitClass(unit, "player"))]..UnitName(unit).."|r"
	elseif UnitReaction(unit, "player") then
		return ("%s%s|r"):format(Reaction[UnitReaction(unit, "player")], UnitName(unit))
	else
		return ("|cffffffff%s|r"):format(UnitName(unit))
	end
end

function GameTooltip_UnitColor(unit)
	local r, g, b
	local reaction = UnitReaction(unit, "player")
	if reaction then
		r = FACTION_BAR_COLORS[reaction].r
		g = FACTION_BAR_COLORS[reaction].g
		b = FACTION_BAR_COLORS[reaction].b
	else
		r = 1.0
		g = 1.0
		b = 1.0
	end
	if UnitPlayerControlled(unit) then
		if UnitCanAttack(unit, "player") then
			if not UnitCanAttack("player", unit) then
				r = 1.0
				g = 1.0
				b = 1.0
			else
				r = FACTION_BAR_COLORS[2].r
				g = FACTION_BAR_COLORS[2].g
				b = FACTION_BAR_COLORS[2].b
			end
		elseif UnitCanAttack("player", unit) then
			r = FACTION_BAR_COLORS[4].r
			g = FACTION_BAR_COLORS[4].g
			b = FACTION_BAR_COLORS[4].b
		elseif UnitIsPVP(unit) then
			r = FACTION_BAR_COLORS[6].r
			g = FACTION_BAR_COLORS[6].g
			b = FACTION_BAR_COLORS[6].b
		end
	end
	if UnitIsPlayer(unit) then
		local class = select(2, UnitClass(unit))
		if class then
			r = RAID_CLASS_COLORS[class].r
			g = RAID_CLASS_COLORS[class].g
			b = RAID_CLASS_COLORS[class].b
		end
	end
	return r, g, b
end

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	local unit = (select(2, self:GetUnit())) or (GetMouseFocus() and GetMouseFocus():GetAttribute("unit")) or (UnitExists("mouseover") and "mouseover") or nil
	self.unit = nil

	if unit then
		self.unit = unit

		local name = UnitName(unit)
		local ricon = GetRaidTargetIndex(unit)
		local level = UnitLevel(unit)
		local color = GetQuestDifficultyColor(level)
		local textLevel = ("%s%d|r"):format(GetHexColor(color), level)
		local pattern = ""
		if level == "??" or level == -1 then
			textLevel = "|cffff0000??|r"
		end

		GameTooltipTextLeft1:SetFontObject(GameTooltipHeaderText)

		if UnitIsPlayer(unit) then
			local unitRace = UnitRace(unit)
			local _, unitClass = UnitClass(unit)
			if UnitSex(unit) == 2 then
				unitClass = LOCALIZED_CLASS_NAMES_MALE[unitClass]
			else
				unitClass = LOCALIZED_CLASS_NAMES_FEMALE[unitClass]
			end

			if UnitIsAFK(unit) then
				self:AppendText(" |cff00cc00AFK|r")
			elseif UnitIsDND(unit) then
				self:AppendText(" |cff00cc00DND|r")
			end

			for i = 2, GameTooltip:NumLines() do
				if _G["GameTooltipTextLeft"..i]:GetText():find(unitRace) then
					pattern = pattern.." %s %s, %s"
					_G["GameTooltipTextLeft"..i]:SetText((pattern):format(textLevel, unitRace, unitClass):trim())
					break
				end
			end

			if ricon then
				local text = GameTooltipTextLeft1:GetText()
				GameTooltipTextLeft1:SetText(("%s %s"):format(ICON_LIST[ricon].."18|t", text))
			end

			local title = UnitPVPName(unit)
			if title and hideTitle then
				local text = GameTooltipTextLeft1:GetText()
				title = title:gsub(name, "")
				text = text:gsub(title, "")
				if text then GameTooltipTextLeft1:SetText(text) end
			end

			local unitGuild = GetGuildInfo((unit=="player") and UnitName(unit) or unit)
			local text = GameTooltipTextLeft2:GetText()
			if unitGuild and text and text:find("^"..unitGuild) then
				GameTooltipTextLeft2:SetTextColor(255/255, 20/255, 200/255, 1)
			end
		else
			local text = GameTooltipTextLeft2:GetText()
			local reaction = UnitReaction(unit, "player")
			if reaction and text and not text:find(LEVEL) then
				GameTooltipTextLeft2:SetTextColor(FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b)
			end
			if level ~= 0 then
				local class = UnitClassification(unit)
				if class == "worldboss" then
					textLevel = ("|cffff0000%s|r"):format(worldBoss)
				elseif class == "rareelite" then
					if level == -1 then
						textLevel = ("|cffff0000??+|r %s"):format(rareElite)
					else
						textLevel = ("%s%d+|r %s"):format(GetHexColor(color), level, rareElite)
					end
				elseif class == "elite" then
					if level == -1 then
						textLevel = "|cffff0000??+|r"
					else
						textLevel = ("%s%d+|r"):format(GetHexColor(color), level)
					end
				elseif class == "rare" then
					if level == -1 then
						textLevel = ("|cffff0000??|r %s"):format(rare)
					else
						textLevel = ("%s%d|r %s"):format(GetHexColor(color), level, rare)
					end
				end
				local creatureType = UnitCreatureType(unit)
				for i = 2, GameTooltip:NumLines() do
					if _G["GameTooltipTextLeft"..i]:GetText():find(LEVEL) then
						pattern = pattern.." %s %s"
						_G["GameTooltipTextLeft"..i]:SetText((pattern):format(textLevel, creatureType or ""):trim())
						break
					end
				end
			end
		end

		if UnitFactionGroup(unit) then
			GameTooltipTextLeft1:SetText('|TInterface\\TargetingFrame\\UI-PVP-'..select(1, UnitFactionGroup(unit))..'.blp:16:16:-2:0:64:64:0:40:0:40|t'..GameTooltipTextLeft1:GetText())
			for i = 2, GameTooltip:NumLines() do
				if _G["GameTooltipTextLeft"..i]:GetText():find(select(2, UnitFactionGroup(unit))) then
					_G["GameTooltipTextLeft"..i]:SetText('')
					break
				end
			end
		end

		if (UnitExists(unit .. "target")) then
			local text = ("%s%s"):format(TARGET, getTargetLine(unit.."target"))
			GameTooltip:AddLine(text)
		end

		if UnitIsPVP(unit) then
			for i = 2, GameTooltip:NumLines() do
				if _G["GameTooltipTextLeft"..i]:GetText() and _G["GameTooltipTextLeft"..i]:GetText():find(PVP) then
					_G["GameTooltipTextLeft"..i]:SetText('')
					break
				end
			end
		end

		if colorStatusBar then
			local r, g, b = GameTooltip_UnitColor(unit)
			GameTooltipStatusBar:SetStatusBarColor(r, g, b)
		end

		if (UnitIsDead(unit) or UnitIsGhost(unit)) then
			GameTooltip_ClearStatusBars(self)
		end

		-- statusbars
		GameTooltipStatusBar:Hide()
		local minv, maxv = UnitHealth(unit), UnitHealthMax(unit)
		if maxv > 0 then
			--local hp = fixvalue(minv).."/"..fixvalue(minv)
			local hp = fixvalue(minv)
			local r, g, b = GameTooltip_UnitColor(unit)
			GameTooltip_ShowStatusBar(self, 0, maxv, minv, minv > 0 and hp or "", r, g, b, 1)
		end

		if select(1, UnitPowerType(unit)) == 0 then
			local minv, maxv = UnitPower(unit), UnitPowerMax(unit)
			if maxv > 0 then
				--local pp = fixvalue(minv).."/"..fixvalue(minv)
				local pp = fixvalue(minv)
				local color = PowerBarColor[UnitPowerType(unit)]
				GameTooltip_ShowStatusBar(self, 0, maxv, minv, minv > 0 and pp or "", color.r, color.g, color.b, 1)
			end
		end

		-- symbiosis
		if UnitIsPlayer(unit) and not UnitIsEnemy(unit, 'player') then
			local already = false
			for i=1,40 do if select(11, UnitAura(unit, i, 'HELPFUL')) == 110309 then already = true break end end
			local uclass = select(2, UnitClass(unit))
			local spec = SPEC_CORE_ABILITY_TEXT[select(1, GetSpecializationInfo(GetSpecialization() or 1))]
			local spellID = (class == 'DRUID' and uclass ~= 'DRUID') and symbiosis.grant[uclass][spec] or (class ~= 'DRUID' and uclass == 'DRUID') and symbiosis.grant[class][spec]
			local name, _, icon = GetSpellInfo(spellID)
			if already then
				GameTooltip:AddLine(' ')
				GameTooltip:AddLine('|cff3eea23'..select(1, GetSpellInfo(110309))..' already buffed|r')
			end
			if icon then
				GameTooltip:AddLine(' ')
				GameTooltip:AddDoubleLine('|T'..icon..':16:16:0:0:64:64:4:60:4:60|t '..name, '|cff3eea23'..select(1, GetSpellInfo(110309))..'|r')
				self:Show()
				if self.aura then self.aura:SetSize(self:GetWidth(), 0) end
			end
		end
	end

	self:Show()
	if self.aura then self.aura:SetSize(self:GetWidth(), 0) end
end)

local Tooltips = {GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3}
for i, v in ipairs(Tooltips) do
	v:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8', edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',  tiled = false, edgeSize = 16, insets = {left=3, right=3, top=3, bottom=3} })
	v:SetScale(tooltipScale)

	hooksecurefunc(v, "SetUnitAura", function(self, unit, index, filter)
		local _, _, _, _, _, _, _, _, _, _, spell = UnitAura(unit, index, filter)
		if spell then
			self:AddDoubleLine("|cffad3fddSpell ID|r", spell)
			self:Show()
		end
	end)

	v:SetScript("OnShow", function(self)
		self:SetBackdropColor(unpack(backdropColor))
		self:SetBackdropBorderColor(unpack(backdropBorderColor))
		self.unit = nil
		local name, item = self:GetItem()
		local unit = (select(2, self:GetUnit())) or nil
		if item then
			local _, _, Color, Ltype, itemID, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name = item:find( "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")

			self:AddDoubleLine("|cffad3fddItem ID|r", itemID)

			local quality = select(3, GetItemInfo(item))
			if(quality) then
				local r, g, b = GetItemQualityColor(quality)
				self:SetBackdropBorderColor(r, g, b)
			end

			local regions = {self:GetRegions()}
			local itemLink = select(2, GetItemInfo(item))
			for i = 1, #regions do
				local region = regions[i]
				if region and region:GetObjectType() == "FontString" then
					local text = region:GetText()
					if text and text == REFORGED then
						local rid = tonumber(itemLink:match("item:%d+:%d+:%d+:%d+:%d+:%d+:%-?%d+:%-?%d+:%d+:(%d+)"))
						local info = reforgeIDs[rid - 113 + 1]
						if info[1] and info[2] then
							region:SetText(text.." ("..StatNames[info[1]].." -> "..StatNames[info[2]]..")")
						end
					end
				end
			end
		else
			local _, _, sid = self:GetSpell()
			if sid then
				self:AddDoubleLine("|cffad3fddSpell ID|r", sid)
			end
		end

		for i = 1, select('#', self:GetRegions()) do
			local obj = select(i, self:GetRegions())
			if (obj and obj:GetObjectType() == 'FontString') then
				if obj:GetName():find('Left') then
					obj:SetJustifyH('LEFT')
				elseif obj:GetName():find('Right') then
					obj:SetJustifyH('RIGHT')
				end
			end
		end

	end)
end

GameTooltip:HookScript("OnTooltipCleared", function(self)
	self.unit = nil
	GameTooltip_ClearStatusBars(self)
end)

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	local frame = GetMouseFocus()
	if cursor and frame == WorldFrame then
		tooltip:SetOwner(parent, "ANCHOR_CURSOR")
	else
		tooltip:SetOwner(parent, "ANCHOR_NONE")
		tooltip:SetPoint(unpack(tooltipPosition))
	end
	tooltip.default = 1
end)

hooksecurefunc("SetItemRef", function(link, text, button)
	local icon
	local type, id = string.match(link, "^([a-z]+):(%d+)")
	if( type == "item" ) then
		icon = select(10, GetItemInfo(link))
	elseif( type == "spell" or type == "enchant" ) then
		icon = select(3, GetSpellInfo(id))
	elseif( type == "achievement" ) then
		icon = select(10, GetAchievementInfo(id))
	elseif( type == "quest" ) then
		ItemRefTooltip:AddDoubleLine("|cffad3fddQuest ID|r", id)
		ItemRefTooltip:Show()
	end

	if( not icon ) then
		ItemRefTooltipTexture10:Hide()

		ItemRefTooltipTextLeft1:ClearAllPoints()
		ItemRefTooltipTextLeft1:SetPoint("TOPLEFT", ItemRefTooltip, "TOPLEFT", 8, -10)

		ItemRefTooltipTextLeft2:ClearAllPoints()
		ItemRefTooltipTextLeft2:SetPoint("TOPLEFT", ItemRefTooltipTextLeft1, "BOTTOMLEFT", 0, -2)
		return
	end

	ItemRefTooltipTexture10:ClearAllPoints()
	ItemRefTooltipTexture10:SetPoint("TOPLEFT", ItemRefTooltip, "TOPLEFT", 8, -7)
	ItemRefTooltipTexture10:SetTexture(icon)
	ItemRefTooltipTexture10:SetHeight(20)
	ItemRefTooltipTexture10:SetWidth(20)
	ItemRefTooltipTexture10:Show()
	ItemRefTooltipTexture10:SetTexCoord(.1,.9,.1,.9)

	ItemRefTooltipTextLeft1:ClearAllPoints()
	ItemRefTooltipTextLeft1:SetPoint("TOPLEFT", ItemRefTooltipTexture10, "TOPLEFT", 24, -2)

	ItemRefTooltipTextLeft2:ClearAllPoints()
	ItemRefTooltipTextLeft2:SetPoint("TOPLEFT", ItemRefTooltip, "TOPLEFT", 8, -28)

	local textRight = ItemRefTooltipTextLeft1:GetRight()
	local closeLeft = ItemRefCloseButton:GetLeft()

	if( closeLeft <= textRight ) then
		ItemRefTooltip:SetWidth(ItemRefTooltip:GetWidth() + (textRight - closeLeft))
	end
end)

local specialTooltipList = {
  WorldMapTooltip,
  DropDownList1MenuBackdrop,
  DropDownList2MenuBackdrop,
}
--scale the tooltip
for i, frame in ipairs(specialTooltipList) do
	frame:SetScale(tooltipScale)
end