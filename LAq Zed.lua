class "LAqZed"

require('DamageLib')

local _shadow = myHero.pos

function LAqZed:__init()
    if myHero.charName ~= "Zed" then return end
    PrintChat("[LAq Zed] Initiated")
    self:LoadSpells()
    self:LoadMenu()
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
end

function LAqZed:LoadSpells()
    Q = {Range = 850, Delay = 0.25, Radius = 50, Speed = 902}
    W = {Range = 650, Delay = 0.25, Radius = 40, Speed = 1600}
    E = {Range = 270, Delay = 0.25, Radius = 135, Speed = 1337000}
    R = {Range = 630, Delay = 0.25, Radius = 0, Speed = 1337000}
    PrintChat("[LAqZed] Spells Loaded")
end

function LAqZed:LoadMenu()
    self.Menu = MenuElement({type = MENU, id = "LAqZed", name = "Lucifers Angel - LAqZed", leftIcon="https://puu.sh/tq0A8/5b42557aa9.png"})

    --[[Combo]]
    self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
    self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
    self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
    self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
    self.Menu.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})
    self.Menu.Combo:MenuElement({id = "RKillable", name = "Only Ult when Killable", value = true})
    self.Menu.Combo:MenuElement({id = "ComboMode", name = "Combo Mode [?]", drop = {"Normal", "Line", "Illuminati", "The Angel [COMING SOON]"}, tooltip = "Must have QWER available to perform 'Line', 'Illuminati', and 'The Angel'"})

    --[[Harass]]
    self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
    self.Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
    self.Menu.Harass:MenuElement({id = "HarassW", name = "Use W", value = true})
    self.Menu.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})
    self.Menu.Harass:MenuElement({id = "LongHarass", name = "Long Harass", value = true})
    self.Menu.Harass:MenuElement({id = "HarassEnergy", name = "Min. Energy", value = 40, min = 0, max = 100})

    --[[Farm]]
    self.Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
    self.Menu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
    self.Menu.Farm:MenuElement({id = "FarmE", name = "Use E", value = true})
    self.Menu.Farm:MenuElement({id = "FarmEnergy", name = "Min. Energy", value = 40, min = 0, max = 100})

    --[[Misc]]
    self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
    self.Menu.Misc:MenuElement({id = "KS", name = "KS with Q", value = true})
    self.Menu.Misc:MenuElement({type = SPACE, id = "TODO", name = "Need things to add - Give feedback."})

	--[[Items]]
	self.Menu:MenuElement({type = MENU, id = "Items", name = "Item Settings"})
	self.Menu.Items:MenuElement({id = "useCut", name = "Bilgewater Cutlass", value = true})
	self.Menu.Items:MenuElement({id = "useBork", name = "Blade of the Ruined King", value = true})
	self.Menu.Items:MenuElement({id = "useGhost", name = "Youmuu's Ghostblade", value = true})
	self.Menu.Items:MenuElement({id = "useGun", name = "Hextech Gunblade", value = true})
	self.Menu.Items:MenuElement({id = "useRedPot", name = "Elixir of Wrath", value = true})
	self.Menu.Items:MenuElement({id = "useTiamat", name = "Tiamat", value = true})
	self.Menu.Items:MenuElement({id = "useHydra", name = "Ravenous Hydra", value = true})
	self.Menu.Items:MenuElement({id = "useTitantic", name = "Titanic Hydra", value = true})

    --[[Draw]]
    self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
    self.Menu.Draw:MenuElement({id = "DrawReady", name = "Draw Only Ready Spells [?]", value = true, tooltip = "Only draws spells when they're ready"})
    self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawLongHarass", name = "Draw Long Harass Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target [?]", value = true, tooltip = "Draws current target"})

    PrintChat("[LAq Zed] Menu Loaded")
end

function aGetItemSlot(unit, id)
  for i = ITEM_1, ITEM_7 do
    if unit:GetItemData(i).itemID == id then
      return i
    end
  end
  return 0 --
end

local function GetDistance(p1,p2)
	return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2) + math.pow((p2.z - p1.z),2))
end

local function CanUseSpell(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end

local ItemTick = GetTickCount()
local CutBlade = aGetItemSlot(myHero,3144)
local bork = aGetItemSlot(myHero,3153)
local ghost = aGetItemSlot(myHero,3142)
local redpot = aGetItemSlot(myHero,2140)
local bluepot = aGetItemSlot(myHero,2139)
local gun = aGetItemSlot(myHero,3146)
local hydra = aGetItemSlot(myHero, 3074)
local tiamat = aGetItemSlot(myHero, 3077)
local titanic = aGetItemSlot(myHero, 3748)
local Item_HK = {}

function LAqZed:Tick()

    local comboTarget = self:GetTarget(Q.Range)
    local harassTarget = self:GetTarget(W.Range + Q.Range)

    if self:Mode() == "Combo" then
        self:Combo(comboTarget)
    elseif self:Mode() == "Harass" then
        self:Harass(harassTarget)
    elseif self:Mode() == "Farm" then
        self:Farm()
    end
end

function LAqZed:useItem(target)

	local ticker = GetTickCount()
	if 	ItemTick + 5000 < ticker then
		Item_HK[ITEM_1] = HK_ITEM_1
		Item_HK[ITEM_2] = HK_ITEM_2
		Item_HK[ITEM_3] = HK_ITEM_3
		Item_HK[ITEM_4] = HK_ITEM_4
		Item_HK[ITEM_5] = HK_ITEM_5
		Item_HK[ITEM_6] = HK_ITEM_6
		Item_HK[ITEM_7] = HK_ITEM_7
		CutBlade = aGetItemSlot(myHero,3144)
		bork = aGetItemSlot(myHero,3153)
		ghost = aGetItemSlot(myHero,3142)
		redpot = aGetItemSlot(myHero,140)
		bluepot = aGetItemSlot(myHero,2139)
		gun = aGetItemSlot(myHero,3146)
		hydra = aGetItemSlot(myHero, 3074)
		tiamat = aGetItemSlot(myHero, 3077)
		titanic = aGetItemSlot(myHero, 3748)
		ItemTick = ticker
	end
	if target.type == Obj_AI_Hero then
		if CutBlade >= 1 and GetDistance(myHero.pos,target.pos) <= 550 + 25 and self.Menu.Items.useCut:Value() then
			if CanUseSpell(CutBlade) then
				Control.CastSpell(Item_HK[CutBlade], target.pos)
			end
		elseif bork >= 1 and GetDistance(myHero.pos,target.pos) <= 550 + 25 and self.Menu.Items.useBork:Value() then
			if CanUseSpell(bork) then
				Control.CastSpell(Item_HK[bork], target.pos)
			end
		end
		if gun >= 1 and GetDistance(myHero.pos,target.pos) <= 690 + 25 and self.Menu.Items.useGun:Value() then
			if CanUseSpell(gun) then
				Control.CastSpell(Item_HK[gun],target.pos)
			end
		end
	end
	if ghost >= 1 and GetDistance(myHero.pos,target.pos) <= 550 + 25 and self.Menu.Items.useGhost:Value() then
		if CanUseSpell(ghost) then
			Control.CastSpell(Item_HK[ghost])
		end
	end
	if redpot >= 1 and GetDistance(myHero.pos,target.pos) <= 550 + 100  and self.Menu.Items.useRedPot:Value() then
		if CanUseSpell(redpot) then
			Control.CastSpell(Item_HK[redpot])
		end
	end
	if hydra >= 1 and GetDistance(myHero.pos, target.pos) <= 270 and self.Menu.Items.useHydra:Value() then
		if CanUseSpell(hydra) then
			Control.CastSpell(Item_HK[hydra])
		end
	elseif tiamat >= 1 and GetDistance(myHero.pos, target.pos) <= 270 and self.Menu.Items.useTiamat:Value() then
		if CanUseSpell(tiamat) then
			Control.CastSpell(Item_HK[tiamat])
		end
	elseif titanic >= 1 and GetDistance(myHero.pos, target.pos) <= 200 and self.Menu.Items.useTitanic:Value() then
		if CanUseSpell(titanic) then
			Control.CastSpell(Item_HK[titanic])
		end
	end
end

function LAqZed:Combo(target)
    local comboMode = self.Menu.Combo.ComboMode:Value()
    if target and self:CanCast(_R) then
        if comboMode == 1 then
            self:NormalCombo(target)
        elseif comboMode == 2 then
            self:LineCombo(target)
        elseif comboMode == 3 then
            self:IlluminatiCombo(target)
        elseif comboMode == 4 then
            self:AngelCombo(target)
        end
    else
        target = self:GetTarget(Q.Range)
        if target then
            self:NormalCombo(target)
        end
    end
end

function LAqZed:NormalCombo(target)
    if target and self:IsValidTarget(target, R.Range + W.Range) then
        if myHero:GetSpellData(_R).name ~= "ZedR2" and self:IsValidTarget(target, R.Range) and self:CanCast(_R) then
            self:CastR(target)
        end
        if myHero:GetSpellData(_W).name == "ZedW2" and self:CanCast(_W) and self.Menu.Combo.ComboW:Value() then
            self:CastW()
        elseif myHero:GetSpellData(_W).name ~= "ZedW2" and self:CanCast(_W) and self.Menu.Combo.ComboW:Value() then
            local castPos = target:GetPrediction(W.Speed, W.Delay)
            self:CastW(castPos)
        elseif self:CanCast(_Q) and self.Menu.Combo.ComboQ:Value() and target.distance < Q.Range then
            local castPos = target:GetPrediction(Q.Speed, Q.Delay)
            self:CastQ(castPos)
        elseif self:CanCast(_E) and self.Menu.Combo.ComboE:Value() and target.distance < E.Range then
            self:CastE()
        end
		self:useItem(target)
    end
end

function LAqZed:LineCombo(target)
    if ((myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_W).mana + myHero:GetSpellData(_E).mana) < myHero.mana) then
        if target and self:IsValidTarget(target, Q.Range) and self:CanCast(_R) and target.distance <= R.Range then -- and myHero:GetSpellData(_R).name == "ZedR"
            self:CastR(target)
            --PrintChat("[Line Combo] Ulting: " .. target.charName)
            if myHero:GetSpellData(_R).name == "ZedR2" then
                DelayAction(function()
                    if self:CanCast(_W) and myHero:GetSpellData(_W).name ~= "ZedW2" and self.Menu.Combo.ComboW:Value() then
                        local linePos = myHero.pos:Extend(target.pos, -2000)
                        self:CastW(linePos)
                    end
                    if self:CanCast(_Q) and self.Menu.Combo.ComboQ:Value() then
                        local castPos = target:GetPrediction(Q.Speed, Q.Delay)
                        self:CastQ(castPos)
                    end
					self:useItem(target)
                end, 0.75)
            end
            if self:CanCast(_E) and self.Menu.Combo.ComboE:Value() then
				if self:CanCast(_W) and myHero:GetSpellData(_W).name == "ZedW2" then
					self:CastE()
				elseif not self:CanCast(_W) then
					self:CastE()
				end
            end
            if myHero:GetSpellData(_W).name == "ZedW2" and self:CanCast(_Q) and not self:CanCast(_E)then
                DelayAction(function()
                    self:CastW()
                end, 1)
            end
        elseif target and self:IsValidTarget(target, R.Range) and not self:CanCast(_R) then
            self:NormalCombo()
        end
    end
end

function LAqZed:IlluminatiCombo(target)
    if ((myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_W).mana + myHero:GetSpellData(_E).mana) < myHero.mana) then
        if target and self:IsValidTarget(target, Q.Range) and self:CanCast(_R) and target.distance <= R.Range then -- and myHero:GetSpellData(_R).name == "ZedR"
            self:CastR(target)
            --PrintChat("[Line Combo] Ulting: " .. target.charName)
            if myHero:GetSpellData(_R).name == "ZedR2" then
                DelayAction(function()
                    if self:CanCast(_W) and myHero:GetSpellData(_W).name ~= "ZedW2" and self.Menu.Combo.ComboW:Value() then
                        local illuminatiPos = myHero.pos:Extend(myHero.pos, -1000)
                        self:CastW(illuminatiPos)
                    end
                    if self:CanCast(_Q) and self.Menu.Combo.ComboQ:Value() then
                        local castPos = target:GetPrediction(Q.Speed, Q.Delay)
                        self:CastQ(castPos)
                    end
                end, 0.75)
            end
            if self:CanCast(_E) and self.Menu.Combo.ComboE:Value() then
				if self:CanCast(_W) and myHero:GetSpellData(_W).name == "ZedW2" then
					self:CastE()
				elseif not self:CanCast(_W) then
					self:CastE()
				end
            end
            if myHero:GetSpellData(_W).name == "ZedW2" and self:CanCast(_Q) and not self:CanCast(_E)then
                DelayAction(function()
                    self:CastW()
                end, 1)
            end
        elseif target and self:IsValidTarget(target, R.Range) and not self:CanCast(_R) then
            self:NormalCombo()
        end
    end
end

function LAqZed:AngelCombo(target)
    PrintChat("Coming Soon")
end

function LAqZed:Harass(target)
    if not (myHero.mana/myHero.maxMana >= self.Menu.Harass.HarassEnergy:Value() / 100) then return end
    if target and self:IsValidTarget(target, W.Range + Q.Range) then
        local targetPos = target.pos
        local harassQ = self.Menu.Harass.HarassQ:Value()
        local harassW = self.Menu.Harass.HarassW:Value()
        local harassE = self.Menu.Harass.HarassE:Value()
        local longHarass = self.Menu.Harass.LongHarass:Value()

        if longHarass then
            if self:CanCast(_Q) and harassQ and self:CanCast(_W) and harassW and myHero:GetSpellData(_W).name ~= "ZedW2" then
                if self:CanCast(_E) and harassE and target.distance < W.Range + E.Range then
                    local qPos = target:GetPrediction(Q.Speed, Q.Delay)
                    local wPos = target:GetPrediction(W.Speed, W.Delay)
                    self:CastW(wPos)
                    DelayAction(function()
                        self:CastE()
                    end, 0.5)
                    DelayAction(function()
                        self:CastQ(qPos)
                    end, 0.75)
                else
                    local qPos = target:GetPrediction(Q.Speed, Q.Delay)
                    local wPos = target:GetPrediction(W.Speed, W.Delay)
                    self:CastW(wPos)
                    DelayAction(function()
                        self:CastQ(qPos)
                    end, 0.75)
                end
            elseif target.distance < Q.Range and self:CanCast(_Q) then
                local qPos = target:GetPrediction(Q.Speed, Q.Delay)
                self:CastQ(qPos)
            end
        end
        if not longHarass then
            if target.distance < Q.Range and self:CanCast(_Q) and harassQ then
                local qPos = target:GetPrediction(Q.Speed, Q.Delay)
                self:CastQ(qPos)
            end
            if target.distance < E.Range and self:CanCast(_E) and harassE then
                self:CastE()
            end
        end
    end
end

function LAqZed:Farm()
    if not (myHero.mana/myHero.maxMana >= self.Menu.Farm.FarmEnergy:Value() / 100) then return end

    if self.Menu.Farm.FarmQ:Value() and self:CanCast(_Q) then
        local minion = self:GetFarmTarget(Q.Range)
        if minion and self:IsValidTarget(minion, Q.Range) then
            local castPos = minion:GetPrediction(Q.Speed, Q.Delay)
            self:CastQ(castPos)
        end
    end

    if self.Menu.Farm.FarmE:Value() and self:CanCast(_E) then
        local minion = self:GetFarmTarget(E.Range)
        if minion and self:IsValidTarget(minion, E.Range) then
            self:CastE()
			self:useItem(minion)
        end
    end

end

function LAqZed:CastQ(position)
    if position then
        --PrintChat(GetTickCount() .. "TRYING TO CAST Q")
        Control.CastSpell(HK_Q, position)
    end
end

function LAqZed:CastW(position)
    if position and MapPosition:inWall(position) == false then
        --PrintChat(GetTickCount() .. "TRYING TO CAST W1")
        Control.CastSpell(HK_W, position)
        if not self:HasBuff(myHero, "ZedWHandler") then
            _shadow = position
        end
    else
        if self:HasBuff(myHero, "ZedWHandler") then
            _shadow = myHero.pos
        end
        --PrintChat(GetTickCount() .. "TRYING TO CAST W2")
        Control.CastSpell(HK_W)
    end
end

function LAqZed:CastE()
    --PrintChat(GetTickCount() .. "TRYING TO CAST E")
    Control.CastSpell(HK_E)
end

function LAqZed:CastR(target)
    if target and self:CanCast(_R) and myHero:GetSpellData(_R).name == "ZedR" then
        --PrintChat(GetTickCount() .. "TRYING TO CAST R1")
        Control.CastSpell(HK_R, target)
    elseif myHero:GetSpellData(_R).name == "ZedR2" then
        --PrintChat(GetTickCount() .. "TRYING TO CAST R2")
        Control.CastSpell(HK_R)
    end
end

function LAqZed:Draw()
    if myHero.dead then return end

    if self.Menu.Draw.DrawReady:Value() then
        if self:IsReady(_Q) and self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, Q.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_W) and self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos, W.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_E) and self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos, E.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_R) and self.Menu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, R.Range, 1, Draw.Color(255, 255, 255, 255))
        end
    else
        if self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, Q.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos, W.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos, E.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, R.Range, 1, Draw.Color(255, 255, 255, 255))
        end
    end

    local textPos = myHero.pos:To2D()

    if self.Menu.Combo.ComboMode:Value() == 1 then
        Draw.Text("Combo Mode: Normal", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 255, 0, 0))
    end
    if self.Menu.Combo.ComboMode:Value() == 2 then
        Draw.Text("Combo Mode: Line", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 255, 0, 0))
    end
    if self.Menu.Combo.ComboMode:Value() == 3 then
        Draw.Text("Combo Mode: Illuminati", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 255, 0, 0))
    end
    if self.Menu.Combo.ComboMode:Value() == 4 then
        Draw.Text("Combo Mode: The Angel", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 255, 0, 0))
    end

    if self.Menu.Draw.DrawLongHarass:Value() then
        Draw.Circle(myHero.pos, W.Range + Q.Range, 1, Draw.Color(63, 191, 84, 255))
    end

    if self.Menu.Draw.DrawTarget:Value() then
        local drawTarget = self:GetTarget(Q.Range)
        if drawTarget then
            Draw.Circle(drawTarget.pos,80,3,Draw.Color(255, 255, 0, 0))
        end
    end
end

function LAqZed:Mode()
    if Orbwalker["Combo"].__active then
        return "Combo"
    elseif Orbwalker["Harass"].__active then
        return "Harass"
    elseif Orbwalker["Farm"].__active then
        return "Farm"
    elseif Orbwalker["LastHit"].__active then
        return "LastHit"
    end
    return ""
end

function LAqZed:GetShadow()
    local shadow
    local shadowName = "Shadow"
    for i = 1, Game.MinionCount() do
        local minion = Game.Minion(i)
        if minion.name == shadowName then
            shadow = minion
            break
        end
    end
    return shadow
end

function LAqZed:GetKillableTarget(range)
    local target
    for i = 1,Game.HeroCount() do
        local hero = Game.Hero(i)
        if self:IsValidTarget(hero, range) and hero.team ~= myHero.team and (getdmg(_R, hero, myHero, 1) + (getdmg(_Q, hero, myHero, 1) * 2) + getdmg(_E, hero, myHero, 1) + (myHero.totalDamage * 2)) > hero.health then
            target = hero
            break
        end
    end
    return target
end

function LAqZed:GetTarget(range)
    local target
    for i = 1,Game.HeroCount() do
        local hero = Game.Hero(i)
        if self:IsValidTarget(hero, range) and hero.team ~= myHero.team then
            target = hero
            break
        end
    end
    return target
end

function LAqZed:GetFarmTarget(range)
    local target
    for j = 1,Game.MinionCount() do
        local minion = Game.Minion(j)
        if self:IsValidTarget(minion, range) and minion.team ~= myHero.team then
            target = minion
            break
        end
    end
    return target
end

function LAqZed:GetPercentHP(unit)
    return 100 * unit.health / unit.maxHealth
end

function LAqZed:GetPercentMP(unit)
    return 100 * unit.mana / unit.maxMana
end

function LAqZed:HasBuff(unit, buffname)
    for K, Buff in pairs(self:GetBuffs(unit)) do
        if Buff.name:lower() == buffname:lower() then
            return true
        end
    end
    return false
end

function LAqZed:GetBuffs(unit)
    self.T = {}
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.count > 0 then
            table.insert(self.T, Buff)
        end
    end
    return self.T
end

function LAqZed:IsReady(spellSlot)
    return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function LAqZed:CheckMana(spellSlot)
    return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function LAqZed:CanCast(spellSlot)
    return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function LAqZed:IsValidTarget(obj, spellRange)
    return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
end

function OnLoad()
    LAqZed()
end
