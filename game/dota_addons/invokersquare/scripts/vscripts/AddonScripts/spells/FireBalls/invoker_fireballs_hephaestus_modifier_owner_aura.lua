require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')

invoker_fireballs_hephaestus_modifier_owner_aura = invoker_fireballs_hephaestus_modifier_owner_aura or class({})

function invoker_fireballs_hephaestus_modifier_owner_aura:OnRefresh(data)
	if data then
		self.nRange = data.nRange
	end
end

function invoker_fireballs_hephaestus_modifier_owner_aura:OnCreated(data)
	SpellSystem:BuffOnCreated(self)
	self:OnRefresh(data)
end

function invoker_fireballs_hephaestus_modifier_owner_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE
end

function invoker_fireballs_hephaestus_modifier_owner_aura:IsHidden()
	return true
end

function invoker_fireballs_hephaestus_modifier_owner_aura:IsPurgable()
	return false
end

function invoker_fireballs_hephaestus_modifier_owner_aura:IsAura()
	return true
end

function invoker_fireballs_hephaestus_modifier_owner_aura:GetAuraRadius()
	return self.nRange
end

function invoker_fireballs_hephaestus_modifier_owner_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function invoker_fireballs_hephaestus_modifier_owner_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH --DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function invoker_fireballs_hephaestus_modifier_owner_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES
end

function invoker_fireballs_hephaestus_modifier_owner_aura:GetAuraDuration()
	return 0.1
end

function invoker_fireballs_hephaestus_modifier_owner_aura:GetModifierAura()
	return "invoker_fireballs_hephaestus_modifier_aura"
end
