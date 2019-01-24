require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')

forge_spirits_life_giving_fire_aura = forge_spirits_life_giving_fire_aura or class({})

function forge_spirits_life_giving_fire_aura:OnRefresh()
	--[[
	local hQWER	
	if IsServer() then
		--hQWER = GetSSOutQWERLevel(self:GetCaster())
		hQWER = ApplyQWERBuffLevels(self, self:GetCaster())
		RefreshTooltipByEnt(self)	
	end
	hQWER = Sync(hQWER)
	]]
	local hQWER = QWERSystem:Apply(self, self:GetCaster(), 'invoker_forge_spirits')

	self.nMagicResist = GetConst(GetGameConst().forge_spirits_life_giving_fire.nMagicResist, hQWER)
	self.nHealthRegen = GetConst(GetGameConst().forge_spirits_life_giving_fire.nHealthRegen, hQWER)
	
	--self:SetStackCount(hQWER[sQ])

	SpellSystem:RefreshComplete(self, hQWER)
end

function forge_spirits_life_giving_fire_aura:OnCreated()
	SpellSystem:BuffOnCreated(self)
end

function forge_spirits_life_giving_fire_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
end

function forge_spirits_life_giving_fire_aura:GetModifierMagicalResistanceBonus()
	return self.nMagicResist
end


function forge_spirits_life_giving_fire_aura:GetModifierConstantHealthRegen()
	return self.nHealthRegen
end

function forge_spirits_life_giving_fire_aura:GetTexture()
	return "ember_spirit_flame_guard"
end

--[[
function forge_spirits_life_giving_fire_aura:OnRefresh(keys)
	local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetCaster())
	
end

function forge_spirits_life_giving_fire_aura:OnCreated(keys)
	local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetCaster())
	self:SetStackCount(Q)	
end



function forge_spirits_life_giving_fire_aura:GetStatusEffectName()
	return "GeGe"
end
]]
function forge_spirits_life_giving_fire_aura:IsPurgable()
	return false
end

function forge_spirits_life_giving_fire_aura:IsHidden()
	return false
end