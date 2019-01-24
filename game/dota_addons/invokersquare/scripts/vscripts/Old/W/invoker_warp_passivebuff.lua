invoker_warp_passivebuff = class({})

require("AddonScripts/spells/R/invoker_reconstruction")

function invoker_warp_passivebuff:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MANA_BONUS,
	}
	return funcs
end

function invoker_warp_passivebuff:GetModifierManaBonus()
	local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetParent())
	return QWERSystemGetnConstBySpell(Q, W, E, R, "warp", "nMana")
end

function invoker_warp_passivebuff:IsDeBuff()
	return false
end

function invoker_warp_passivebuff:IsBuff()
	return true
end

function invoker_warp_passivebuff:IsHidden()
	return true
end

function invoker_warp_passivebuff:IsPermanent()
	return true
end