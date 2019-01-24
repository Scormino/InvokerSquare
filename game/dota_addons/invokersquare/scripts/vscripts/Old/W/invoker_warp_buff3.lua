invoker_warp_buff3 = class({})

require("AddonScripts/spells/R/invoker_reconstruction")

function invoker_warp_buff3:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
	return funcs
end

function invoker_warp_buff3:GetModifierConstantManaRegen()
	local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetParent())
	return QWERSystemGetnConstBySpell(Q, W, E, R, "warp", "nManaRegen")
end

function invoker_warp_buff3:OnCreated(data)
	CreateQWEParticle(self, 2, 3, data.nAnim)
end

function invoker_warp_buff3:OnDestroy()
	RemoveQWEParticle(self)
end

function invoker_warp_buff3:IsDeBuff()
	return false
end

function invoker_warp_buff3:IsBuff()
	return true
end

function invoker_warp_buff3:IsHidden()
	return false
end

function invoker_warp_buff3:IsPermanent()
	return false
end