
  --get the addon namespace
  local addon, ns = ...

  --get oUF namespace (just in case needed)
  local oUF = ns.oUF or oUF

  --get the config
  local cfg = ns.cfg

  --get the functions
  local func = ns.func

  --get the unit container
  local unit = ns.unit

  ---------------------------------------------
  -- UNIT SPECIFIC FUNCTIONS
  ---------------------------------------------

  --init parameters
  local initUnitParameters = function(self)
    self:SetFrameStrata("BACKGROUND")
    self:SetFrameLevel(1)
    self:SetSize(self.cfg.width, self.cfg.height)
    self:SetScale(self.cfg.scale)
    self:SetPoint(self.cfg.pos.a1,self.cfg.pos.af,self.cfg.pos.a2,self.cfg.pos.x,self.cfg.pos.y)
    self:RegisterForClicks("AnyDown")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    func.applyDragFunctionality(self)
    self:SetHitRectInsets(10,10,10,10)
  end

  --actionbar background
  local createArtwork = function(self)
    local t = self:CreateTexture(nil,"BACKGROUND",nil,-8)
    t:SetAllPoints(self)
    t:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\target")
  end

  --make a sound when target gets selected
  local playTargetSound = function(self,event)
    if event == "PLAYER_TARGET_CHANGED" then
      if (UnitExists(self.unit)) then
        if (UnitIsEnemy(self.unit, "player")) then
          PlaySound("igCreatureAggroSelect")
        elseif ( UnitIsFriend("player", self.unit)) then
          PlaySound("igCharacterNPCSelect")
        else
          PlaySound("igCreatureNeutralSelect")
        end
      else
        PlaySound("INTERFACESOUND_LOSTTARGETUNIT")
      end
    end
  end

  --create health frames
  local createHealthFrame = function(self)

    local cfg = self.cfg.health

    --health
    local h = CreateFrame("StatusBar", nil, self)
    h:SetPoint("TOP",0,-21.9)
    h:SetPoint("LEFT",24.5,0)
    h:SetPoint("RIGHT",-24.5,0)
    h:SetPoint("BOTTOM",0,28.7)

    h:SetStatusBarTexture(cfg.texture)
    h.bg = h:CreateTexture(nil,"BACKGROUND",nil,-6)
    h.bg:SetTexture(cfg.texture)
    h.bg:SetAllPoints(h)

    h.glow = h:CreateTexture(nil,"OVERLAY",nil,-5)
    h.glow:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\target_hpglow")
    h.glow:SetAllPoints(self)
    h.glow:SetVertexColor(0,0,0,1)

    h.highlight = h:CreateTexture(nil,"OVERLAY",nil,-4)
    h.highlight:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\target_highlight")
    h.highlight:SetAllPoints(self)

    self.Health = h
    self.Health.Smooth = true
  end

  --create power frames
  local createPowerFrame = function(self)

    local cfg = self.cfg.power

    --power
    local h = CreateFrame("StatusBar", nil, self)
    h:SetPoint("TOP",0,-38.5)
    h:SetPoint("LEFT",24.5,0)
    h:SetPoint("RIGHT",-24.5,0)
    h:SetPoint("BOTTOM",0,21.9)

    h:SetStatusBarTexture(cfg.texture)

    h.bg = h:CreateTexture(nil,"BACKGROUND",nil,-6)
    h.bg:SetTexture(cfg.texture)
    h.bg:SetAllPoints(h)

    h.glow = h:CreateTexture(nil,"OVERLAY",nil,-5)
    h.glow:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\target_ppglow")
    h.glow:SetAllPoints(self)
    h.glow:SetVertexColor(0,0,0,1)

    self.Power = h
    self.Power.Smooth = true

  end

  --create the elite head texture
  local bubblehead
  local createBubbleHead = function(self)
    local headsize = 80
    local head = self.Health:CreateTexture(nil,"OVERLAY",nil,-4)
    head:SetTexture("")
    head:SetWidth(headsize)
    head:SetHeight(headsize/2)
    head:SetPoint("BOTTOM",0,-32)
    bubblehead = head
    bubblehead:Hide()
  end

  --create health power strings
  local createHealthPowerStrings = function(self)

    local name = func.createFontString(self, cfg.font, 16, "THINOUTLINE")
    name:SetPoint("BOTTOM", self, "TOP", 0, 0)
    name:SetPoint("LEFT", self.Health, 0, 0)
    name:SetPoint("RIGHT", self.Health, 0, 0)
    self.Name = name

    local hpval = func.createFontString(self.Health, cfg.font, 11, "THINOUTLINE")
    hpval:SetPoint("RIGHT", -2,0)

    local ppval = func.createFontString(self.Health, cfg.font, 11, "THINOUTLINE")
    ppval:SetPoint("LEFT", 2,0)

    local classtext = func.createFontString(self, cfg.font, 13, "THINOUTLINE")
    classtext:SetPoint("BOTTOM", self, "TOP", 0, -15)

    self:Tag(name, "[diablo:name]")
    self:Tag(hpval, self.cfg.health.tag or "")
    self:Tag(ppval, self.cfg.power.tag or "")
    self:Tag(classtext, "[diablo:classtext]")

  end

  --check for interruptable spellcast
  local checkShield = function(self, unit)
    if self.Shield:IsShown() and UnitCanAttack("player", unit) then
      --show shield
      self:SetStatusBarColor(self.cfg.color.shieldbar.r,self.cfg.color.shieldbar.g,self.cfg.color.shieldbar.b,self.cfg.color.shieldbar.a)
      self.bg:SetVertexColor(self.cfg.color.shieldbg.r,self.cfg.color.shieldbg.g,self.cfg.color.shieldbg.b,self.cfg.color.shieldbg.a)
      self.Spark:SetVertexColor(0.8,0.8,0.8,1)
      self.background:SetDesaturated(1)
    else
      --no shield
      self:SetStatusBarColor(self.cfg.color.bar.r,self.cfg.color.bar.g,self.cfg.color.bar.b,self.cfg.color.bar.a)
      self.bg:SetVertexColor(self.cfg.color.bg.r,self.cfg.color.bg.g,self.cfg.color.bg.b,self.cfg.color.bg.a)
      self.Spark:SetVertexColor(0.8,0.6,0,1)
      self.background:SetDesaturated(nil)
    end
  end

  --check for interruptable spellcast
  local checkCast = function(bar, unit, name, rank, castid)
    checkShield(bar, unit)
  end

  --check for interruptable spellcast
  local checkChannel = function(bar, unit, name, rank)
    checkShield(bar, unit)
  end

  --create buffs
  local createBuffs = function(self)
    local f = CreateFrame("Frame", nil, self)
    f.size = self.cfg.auras.size
    f.num = 40
    f:SetHeight((f.size+5)*4)
    f:SetWidth((f.size+5)*10)
    f:SetPoint(self.cfg.auras.buffs.pos.a1, self, self.cfg.auras.buffs.pos.a2, self.cfg.auras.buffs.pos.x, self.cfg.auras.buffs.pos.y)
    f.initialAnchor = self.cfg.auras.buffs.initialAnchor
    f["growth-x"] = self.cfg.auras.buffs.growthx
    f["growth-y"] = self.cfg.auras.buffs.growthy
    f.spacing = 5
    f.onlyShowPlayer = self.cfg.auras.onlyShowPlayerBuffs
    self.Buffs = f
  end

  --create debuff func
  local createDebuffs = function(self)
    local f = CreateFrame("Frame", nil, self)
    f.size = self.cfg.auras.size
    f.num = 40
    f:SetHeight((f.size+5)*4)
    f:SetWidth((f.size+5)*10)
    f:SetPoint(self.cfg.auras.debuffs.pos.a1, self, self.cfg.auras.debuffs.pos.a2, self.cfg.auras.debuffs.pos.x, self.cfg.auras.debuffs.pos.y)
    f.initialAnchor = self.cfg.auras.debuffs.initialAnchor
    f["growth-x"] = self.cfg.auras.debuffs.growthx
    f["growth-y"] = self.cfg.auras.debuffs.growthy
    f.spacing = 5
    f.showDebuffType = self.cfg.auras.showDebuffType
    f.onlyShowPlayer = self.cfg.auras.onlyShowPlayerDebuffs
    self.Debuffs = f
  end

  --create combo
  local createComboBar = function(self)

    self.ComboPoints = {}

    local t
    local bar = CreateFrame("Frame","oUF_DiabloComboPoints",self)
    local w = 64*(MAX_COMBO_POINTS+2)
    local h = 64
    --bar:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    bar:SetPoint(self.cfg.combobar.pos.a1,self.cfg.combobar.pos.af,self.cfg.combobar.pos.a2,self.cfg.combobar.pos.x,self.cfg.combobar.pos.y)
    bar:SetWidth(w)
    bar:SetHeight(h)

    --color
    bar.color = self.cfg.combobar.color

    --left edge
    t = bar:CreateTexture(nil,"BACKGROUND",nil,-8)
    t:SetSize(64,64)
    t:SetPoint("LEFT",0,0)
    t:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\combo_left")
    bar.leftEdge = t

    --right edge
    t = bar:CreateTexture(nil,"BACKGROUND",nil,-8)
    t:SetSize(64,64)
    t:SetPoint("RIGHT",0,0)
    t:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\combo_right")
    bar.rightEdge = t

    for i = 1, MAX_COMBO_POINTS do

      local orb = CreateFrame("Frame",nil,bar)
      self.ComboPoints[i] = orb

      orb:SetSize(64,64)
      orb:SetPoint("LEFT",i*64,0)

      local orbSizeMultiplier = 0.85
      if i == MAX_COMBO_POINTS then
        --orbSizeMultiplier = 0.9
      end

      --bar background
      orb.barBg = orb:CreateTexture(nil,"BACKGROUND",nil,-8)
      orb.barBg:SetSize(64,64)
      orb.barBg:SetPoint("CENTER")
      orb.barBg:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\combo_bar_bg")

      --orb background
      orb.bg = orb:CreateTexture(nil,"BACKGROUND",nil,-7)
      orb.bg:SetSize(128*orbSizeMultiplier,128*orbSizeMultiplier)
      orb.bg:SetPoint("CENTER")
      orb.bg:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\combo_orb_bg")

      --orb filling
      orb.fill = orb:CreateTexture(nil,"BACKGROUND",nil,-6)
      orb.fill:SetSize(128*orbSizeMultiplier,128*orbSizeMultiplier)
      orb.fill:SetPoint("CENTER")
      orb.fill:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\combo_orb_fill1")
      orb.fill:SetVertexColor(self.cfg.combobar.color.r,self.cfg.combobar.color.g,self.cfg.combobar.color.b)
      --orb.fill:SetBlendMode("ADD")

      --orb border
      orb.border = orb:CreateTexture(nil,"BACKGROUND",nil,-5)
      orb.border:SetSize(128*orbSizeMultiplier,128*orbSizeMultiplier)
      orb.border:SetPoint("CENTER")
      orb.border:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\combo_orb_border")

      --orb glow
      orb.glow = orb:CreateTexture(nil,"BACKGROUND",nil,-4)
      orb.glow:SetSize(128*orbSizeMultiplier,128*orbSizeMultiplier)
      orb.glow:SetPoint("CENTER")
      orb.glow:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\combo_orb_glow")
      orb.glow:SetVertexColor(self.cfg.combobar.color.r,self.cfg.combobar.color.g,self.cfg.combobar.color.b)
      orb.glow:SetBlendMode("BLEND")

      --orb highlight
      orb.highlight = orb:CreateTexture(nil,"BACKGROUND",nil,-3)
      orb.highlight:SetSize(128*orbSizeMultiplier,128*orbSizeMultiplier)
      orb.highlight:SetPoint("CENTER")
      orb.highlight:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\combo_orb_highlight")

    end

    bar:SetScale(self.cfg.combobar.scale)
    func.applyDragFunctionality(bar)
    self.ComboBar = bar

  end

  ---------------------------------------------
  -- UNIT SPECIFIC TAG
  ---------------------------------------------

  oUF.Tags.Methods["diablo:classtext"] = function(unit)
    bubblehead:Hide()
    local string, tmpstring, sp = "", "", " "
    if UnitLevel(unit) == 0 then
      string = "Haxx, unit undefined"
    elseif UnitLevel(unit) ~= -1 then
      string = UnitLevel(unit)
    else
      string = "??"
    end
    string = string..sp
    local unitrace = UnitRace(unit)
    local creatureType = UnitCreatureType(unit)
    if unitrace and UnitIsPlayer(unit) then
      string = string..unitrace..sp
    end
    if creatureType and not UnitIsPlayer(unit) then
      string = string..creatureType..sp
    end
    local unit_classification = UnitClassification(unit)
    if unit_classification == "worldboss" or UnitLevel(unit) == -1 then
      tmpstring = "Boss"
      bubblehead:Show()
      bubblehead:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\d3_head_skull")
    elseif unit_classification == "rare" or unit_classification == "rareelite" then
      tmpstring = "Rare"
      bubblehead:Show()
      bubblehead:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\d3_head_diablo")
      if unit_classification == "rareelite" then
        tmpstring = tmpstring.." Elite"
      end
    elseif unit_classification == "elite" then
      tmpstring = "Elite"
      bubblehead:Show()
      bubblehead:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\d3_head_new")
    end
    if tmpstring ~= "" then
      tmpstring = tmpstring..sp
    end
    string = string..tmpstring
    tmpstring = ""
    local localizedClass, englishClass = UnitClass(unit)

    if localizedClass and UnitIsPlayer(unit) then
      string = string..localizedClass..sp
    end
    return string
  end


  ---------------------------------------------
  -- TARGET STYLE FUNC
  ---------------------------------------------

  local function createStyle(self)

    --apply config to self
    self.cfg = cfg.units.target
    self.cfg.style = "target"

    self.cfg.width = 256
    self.cfg.height = 64

    --init
    initUnitParameters(self)

    --create the art
    createArtwork(self)

    --createhealthPower
    createHealthFrame(self)
    createPowerFrame(self)

    --sound
    self:RegisterEvent("PLAYER_TARGET_CHANGED", playTargetSound)
    self.Health:SetScript("OnShow",function(s)
      playTargetSound(self,"PLAYER_TARGET_CHANGED")
    end)

    --create bubblehead
    createBubbleHead(self)

    --health power strings
    createHealthPowerStrings(self)

    --health power update
    self.Health.PostUpdate = func.updateHealth
    self.Power.PostUpdate = func.updatePower

    --auras
    if self.cfg.auras.show then
      createBuffs(self)
      createDebuffs(self)
      self.Buffs.PostCreateIcon = func.createAuraIcon
      self.Debuffs.PostCreateIcon = func.createAuraIcon
      if self.cfg.auras.desaturateDebuffs then
        self.Debuffs.PostUpdateIcon = func.postUpdateDebuff
      end
    end

    --castbar
    if self.cfg.castbar.show then
      func.createCastbar(self)
      self.Castbar.cfg = self.cfg.castbar
      self.Castbar.PostCastStart = checkCast
      self.Castbar.PostChannelStart = checkChannel

    end

    --combobar
    if self.cfg.combobar.show then
      createComboBar(self)
    end

    --debuffglow
    func.createDebuffGlow(self)

    --icons
    self.RaidIcon = func.createIcon(self,"BACKGROUND",24,self.Name,"BOTTOM","TOP",0,0,-1)

    --create portrait
    if self.cfg.portrait.show then
      func.createStandAlonePortrait(self)
    end

    --add heal prediction
    func.healPrediction(self)

    --add self to unit container (maybe access to that unit is needed in another style)
    unit.target = self

  end

  ---------------------------------------------
  -- SPAWN TARGET UNIT
  ---------------------------------------------

  if cfg.units.target.show then
    oUF:RegisterStyle("diablo:target", createStyle)
    oUF:SetActiveStyle("diablo:target")
    oUF:Spawn("target", "oUF_DiabloTargetFrame")
  end