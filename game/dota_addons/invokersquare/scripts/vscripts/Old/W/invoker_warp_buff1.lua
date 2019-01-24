invoker_warp_buff1 = class({})

require("AddonScripts/spells/R/invoker_reconstruction")

function invoker_warp_buff1:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
	return funcs
end

function invoker_warp_buff1:GetModifierConstantManaRegen()
	local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetParent())
	return QWERSystemGetnConstBySpell(Q, W, E, R, "warp", "nManaRegen")
end

function invoker_warp_buff1:OnCreated(data)
	CreateQWEParticle(self, 2, 1, data.nAnim)
end

function invoker_warp_buff1:OnDestroy()
	RemoveQWEParticle(self)
end

function invoker_warp_buff1:IsDeBuff()
	return false
end

function invoker_warp_buff1:IsBuff()
	return true
end

function invoker_warp_buff1:IsHidden()
	return false
end

function invoker_warp_buff1:IsPermanent()
	return false
end