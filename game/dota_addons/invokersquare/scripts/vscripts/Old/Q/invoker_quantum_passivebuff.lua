invoker_quantum_passivebuff = class({})

require("AddonScripts/spells/R/invoker_reconstruction")

function invoker_quantum_passivebuff:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

function invoker_quantum_passivebuff:GetModifierHealthBonus()
	local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetParent())
	return QWERSystemGetnConstBySpell(Q, W, E, R, "quantum", "nHealth")
end

function invoker_quantum_passivebuff:IsDeBuff()
	return false
end

function invoker_quantum_passivebuff:IsBuff()
	return true
end

function invoker_quantum_passivebuff:IsHidden()
	return true
end

function invoker_quantum_passivebuff:IsPermanent()
	return true
end