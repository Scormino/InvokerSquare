require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')

local sFireModifier = 'invoker_fireballs_hephaestus_modifier_fire'

invoker_fireballs_hephaestus_modifier_aura = invoker_fireballs_hephaestus_modifier_aura or class({})

function invoker_fireballs_hephaestus_modifier_aura:OnRefresh()
	self.hQWER = QWERSystem:Apply(self, self:GetCaster(), 'invoker_fireBalls_hephaestus')

	self.sTextureName = GetConst(GetGameConst().invoker_fireBalls_hephaestus.sFlameTextureName, self.hQWER)
	self.nAddStackPerThink = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nAddStackPerThink, self.hQWER) --Добавление Кол-ва стаков за тик
	self.nAuraIntervalThink = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nAuraIntervalThink, self.hQWER)
	self.nBuffDuration = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nBuffDuration, self.hQWER)
	self.nMaxStacks = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nMaxStacks, self.hQWER)

	self:StartIntervalThink(self.nAuraIntervalThink)
	self:OnIntervalThink()

	SpellSystem:RefreshComplete(self, hQWER)
end



function invoker_fireballs_hephaestus_modifier_aura:OnIntervalThink()
	if IsServer() then
		local eUnit = self:GetParent()

		if eUnit:IsAlive() then
			local nStacks = self.nAddStackPerThink
			local eFireModifier = eUnit:FindModifierByName(sFireModifier)
			if eFireModifier then
				nStacks = nStacks + eFireModifier:GetStackCount()
			end
			nStacks = math.min(nStacks, self.nMaxStacks)
			eFireModifier = SpellSystem:ApplyBuff({
					eParent = eUnit,
					eCaster = self:GetCaster(),
					sBuff = sFireModifier,
					hStats = {duration = self.nBuffDuration}
				}
			)
			--eFireModifier = eUnit:AddNewModifier(self:GetCaster(), nil, sFireModifier, {duration = self.nBuffDuration})

			eFireModifier:SetStackCount(nStacks)
		end
		eUnit:EmitSound('sounds/weapons/hero/batrider/batrider_firefly_loop.vsnd')
	end
end

function invoker_fireballs_hephaestus_modifier_aura:OnCreated()
	SpellSystem:BuffOnCreated(self)
	--self:OnRefresh()
end

function invoker_fireballs_hephaestus_modifier_aura:GetTexture()
	return self.sTextureName
end

function invoker_fireballs_hephaestus_modifier_aura:IsPurgable()
	return false
end

function invoker_fireballs_hephaestus_modifier_aura:IsHidden()
	return false
end

function invoker_fireballs_hephaestus_modifier_aura:IsDeBuff()
	return true
end
--[[
function invoker_fireballs_hephaestus_modifier_aura:IsBuff()
	return true
end
]]