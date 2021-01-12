class "LAUdyr"

require('DamageLib')

function LAUdyr:__init()
    if myHero.charName ~= "Udyr" then return end
    PrintChat("[LA Godyr] Initiated")
    self:LoadSpells()
    self:LoadMenu()
    AACounter = 0
    RTime = 0
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
    GOS:OnAttackComplete(function()
        if self:HasBuff(myHero, "udyrphoenixstance") == true then
            AACounter = AACounter+1
        end
    end)
end

function LAUdyr:LoadSpells()
    Q = {Range = 600, Delay = .09, Radius = 0, Speed = math.huge}
    W = {Range = 600, Delay = .09, Radius = 0, Speed = math.huge}
    E = {Range = 600, Delay = .09, Radius = 0, Speed = math.huge}
    R = {Range = 325, Delay = .09, Radius = 0, Speed = math.huge}
    PrintChat("[LA Godyr] Spells Loaded")
end

function LAUdyr:LoadMenu()
    self.Menu = MenuElement({type = MENU, id = "LAUdyr", name = "LA Godyr", leftIcon="https://raw.githubusercontent.com/D-Cire/GoS/Ext/Haha.png"})

    --[[Playstyle Settings]]
    self.Menu:MenuElement({type = MENU, id = "Style", name = "Playstyle Settings"})
    self.Menu.Style:MenuElement({id = "QMax", name = "Are you maxing Q?", value = true})
    self.Menu.Style:MenuElement({id = "RMax", name = "Are you maxing R?", value = true})

    --[[Combo]]
    self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
    self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
    self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
    self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
    self.Menu.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})

    --[[Clear]]
    self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear Settings"})
    self.Menu.Clear:MenuElement({id = "ClearQ", name = "Use Q", value = true})
    self.Menu.Clear:MenuElement({id = "ClearW", name = "Use W", value = true})
    self.Menu.Clear:MenuElement({id = "ClearE", name = "Use E", value = true})
    self.Menu.Clear:MenuElement({id = "ClearR", name = "Use R", value = true})
    self.Menu.Clear:MenuElement({type = MENU, id = "ManaSettings", name = "Mana Settings"})
    self.Menu.Clear.ManaSettings:MenuElement({id = "ManaQ", name = "Min Mana for Q", value = 20, min = 1, max = 100, step = 5})
    self.Menu.Clear.ManaSettings:MenuElement({id = "ManaW", name = "Min Mana for W", value = 20, min = 1, max = 100, step = 5})
    self.Menu.Clear.ManaSettings:MenuElement({id = "ManaE", name = "Min Mana for E", value = 20, min = 1, max = 100, step = 5})
    self.Menu.Clear.ManaSettings:MenuElement({id = "ManaR", name = "Min Mana for R", value = 20, min = 1, max = 100, step = 5})

    --[[Flee]]
    self.Menu:MenuElement({type = MENU, id = "Flee", name = "Trick2Flee"})
    self.Menu.Flee:MenuElement({id = "FleeW", name = "Use W", value = true})
    self.Menu.Flee:MenuElement({id = "FleeE", name = "Use E", value = true})

    --[[Gapclose]]
    self.Menu:MenuElement({type = MENU, id = "Gapclose", name = "Gapclose"})
    self.Menu.Gapclose:MenuElement({id = "GapW", name = "Use W", value = true})
    self.Menu.Gapclose:MenuElement({id = "GapE", name = "Use E", value = true})

    PrintChat("[LA Godyr] Menu Loaded")
end

function LAUdyr:Tick()
    if myHero.dead then return end

    if GOS.GetMode() == "Combo" then
        self:Combo()
    elseif GOS.GetMode() == "Clear" then
        self:Farm()
    elseif GOS.GetMode() == "Flee" then
        self:Flee()
    end

    if RTime <= GetTickCount() and myHero:GetSpellData(_R).currentCd > 0 then
        AACounter = 0
        RTime = GetTickCount()+(myHero:GetSpellData(_R).cd*1000)
    end
end

function LAUdyr:Combo()
    target = GOS:GetTarget(1000)

    if target then
        if self.Menu.Combo.ComboE:Value() and self:CanCast(_E) and self:HasBuff(target, "udyrbearstuncheck") == false then
            self:CastE()
        elseif self:HasBuff(myHero, "udyrbearstance") == false or self:HasBuff(target, "udyrbearstuncheck") == true then
            if self.Menu.Style.QMax:Value() then
                if self.Menu.Combo.ComboQ:Value() and self:CanCast(_Q) and self:HasBuff(myHero, "udyrtigerpunch") == false then
                    self:CastQ()
                end
            elseif self.Menu.Style.RMax:Value() then
                if self.Menu.Combo.ComboR:Value() and self:CanCast(_R) and self:HasBuff(myHero, "UdyrPheonixActivation") == false then
                    self:CastR()
                end
            elseif self.Menu.Combo.ComboW:Value() and self:CanCast(_W) then
                self:CastW()
            end
        end
    elseif self.Menu.Gapclose.GapE:Value() and self:CanCast(_E) then
        self:CastE()
    elseif self.Menu.Gapclose.GapW:Value() and self:CanCast(_W) then
        self:CastW()
    end
end

function LAUdyr:Farm()
    target = self:GetFarmTarget(600)

    if target then
        if self.Menu.Style.RMax:Value() then
            if self.Menu.Clear.ClearW:Value() and self:CanCast(_W) and self:GetPercentMP(myHero) >= self.Menu.Clear.ManaSettings.ManaW:Value() then
                if self:currentStance() == "pheonix" then
                    if AACounter >= 4  then
                        self:CastW()
                    elseif self:CanCast(_R) and RTime + 1500 <= GetTickCount() then
                        self:CastW()
                    end
                elseif self:currentStance() ~= "pheonix" then
                    self:CastW()
                end
            elseif self.Menu.Clear.ClearR:Value() and self:CanCast(_R)  and self:GetPercentMP(myHero) >= self.Menu.Clear.ManaSettings.ManaR:Value() then
                if self:currentStance() == "pheonix" and AACounter >= 4 then
                    self:CastR()
                elseif self:currentStance() ~= "pheonix" then
                    self:CastR()
                end
            elseif self.Menu.Clear.ClearQ:Value() and self:CanCast(_Q)  and self:GetPercentMP(myHero) >= self.Menu.Clear.ManaSettings.ManaQ:Value() then
                if self:currentStance() == "pheonix" then
                    if AACounter >= 4 then
                        self:CastQ()
                    elseif RTime + 1500 <= GetTickCount() then
                        self:CastQ()
                    end
                elseif self:currentStance() ~= "pheonix" then
                    self:CastQ()
                end
            end
        elseif self.Menu.Style.QMax:Value() then
            if self.Menu.Clear.ClearW:Value() and self:CanCast(_W)  and self:GetPercentMP(myHero) >= self.Menu.Clear.ManaSettings.ManaW:Value() then
                self:CastW()
            elseif self.Menu.Clear.ClearQ:Value() and self:CanCast(_Q)  and self:GetPercentMP(myHero) >= self.Menu.Clear.ManaSettings.ManaQ:Value() then
                self:CastQ()
            elseif self.Menu.Clear.ClearR:Value() and self:CanCast(_R) and self:GetPercentMP(myHero) >= self.Menu.Clear.ManaSettings.ManaR:Value()  and self:HasBuff(myHero, "udyrtigerpunch") == false then
                self:CastR()
            end
        else
            print("[LA Godyr]You have no skill max priority - please set one in the playstyle menu")
        end
    end
end

function LAUdyr:Flee()
    if self.Menu.Flee.FleeE:Value() and self:CanCast(_E) then
        self:CastE()
    elseif self.Menu.Flee.FleeW:Value() and self:CanCast(_W) then
        self:CastW()
    end
end

function LAUdyr:CastQ()
    Control.CastSpell(HK_Q)
end

function LAUdyr:CastW()
    Control.CastSpell(HK_W)
end

function LAUdyr:CastE()
    Control.CastSpell(HK_E)
end

function LAUdyr:CastR()
    Control.CastSpell(HK_R)
end

function LAUdyr:Draw()
    if myHero.dead then return end
end

function LAUdyr:GetFarmTarget(range)
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

function LAUdyr:GetPercentHP(unit)
    return 100 * unit.health / unit.maxHealth
end

function LAUdyr:GetPercentMP(unit)
    return 100 * unit.mana / unit.maxMana
end

function LAUdyr:HasBuff(unit, buffname)
    for K, Buff in pairs(self:GetBuffs(unit)) do
        if Buff.name:lower() == buffname:lower() then
            return true
        end
    end
    return false
end

function LAUdyr:currentStance()
    if self:HasBuff(myHero, "udyrtigerstance") == true then
        return "tiger"
    elseif self:HasBuff(myHero, "udyrturtlestance") == true  then
        return "turtle"
    elseif self:HasBuff(myHero, "udyrbearstance") == true  then
        return "bear"
    elseif self:HasBuff(myHero, "udyrphoenixstance") == true  then
        return "pheonix"
    else
        return "none"
    end
end

-- [[udyrbearactivation udyrturtleactivation udyrtigerpunch UdyrPheonixActivation]]

function LAUdyr:GetBuffs(unit)
    self.T = {}
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.count > 0 then
            table.insert(self.T, Buff)
        end
    end
    return self.T
end

function LAUdyr:IsReady(spellSlot)
    return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function LAUdyr:CheckMana(spellSlot)
    return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function LAUdyr:CanCast(spellSlot)
    return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function LAUdyr:IsValidTarget(obj, spellRange)
    return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
end

function OnLoad()
    LAUdyr()
end
