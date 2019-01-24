require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')

LinkLuaModifier( "forge_spirits_life_giving_fire_aura", "AddonScripts/spells/ForgeSpirit/forge_spirits_life_giving_fire_aura", LUA_MODIFIER_MOTION_NONE )

forge_spirits_life_giving_fire_modifier = forge_spirits_life_giving_fire_modifier or class({})


function forge_spirits_life_giving_fire_modifier:OnRefresh(data)
	self.nRadius = (data and data.nRadius) or self.nRadius
end

function forge_spirits_life_giving_fire_modifier:OnCreated(data)
	SpellSystem:BuffOnCreated(self)
	self:OnRefresh(data)
end

function forge_spirits_life_giving_fire_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE
end

function forge_spirits_life_giving_fire_modifier:IsHidden()
	return true
end

function forge_spirits_life_giving_fire_modifier:IsPurgable()
	return false
end

function forge_spirits_life_giving_fire_modifier:IsAura()
	return true
end

function forge_spirits_life_giving_fire_modifier:GetAuraRadius()
	return self.nRadius
end

function forge_spirits_life_giving_fire_modifier:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function forge_spirits_life_giving_fire_modifier:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function forge_spirits_life_giving_fire_modifier:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function forge_spirits_life_giving_fire_modifier:GetAuraDuration()
	return 0.3
end

function forge_spirits_life_giving_fire_modifier:GetModifierAura()
	return "forge_spirits_life_giving_fire_aura"
end
