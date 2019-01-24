invoker_expanse_passivebuff = class({})

require("AddonScripts/spells/R/invoker_reconstruction")

function invoker_expanse_passivebuff:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
	}
	return funcs
end

function invoker_expanse_passivebuff:GetModifierMoveSpeedBonus_Constant()
	local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetParent())
	return QWERSystemGetnConstBySpell(Q, W, E, R, "expanse", "nMoveSpeed")
end

function invoker_expanse_passivebuff:GetBonusDayVision()
	local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetParent())
	return QWERSystemGetnConstBySpell(Q, W, E, R, "expanse", "nVision")
end

function invoker_expanse_passivebuff:IsDeBuff()
	return false
end

function invoker_expanse_passivebuff:IsBuff()
	return true
end

function invoker_expanse_passivebuff:IsHidden()
	return true
end

function invoker_expanse_passivebuff:IsPermanent()
	return true
end