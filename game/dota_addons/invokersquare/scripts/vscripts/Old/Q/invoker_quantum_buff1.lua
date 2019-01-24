invoker_quantum_buff1 = class({})

require("AddonScripts/spells/R/invoker_reconstruction")

function invoker_quantum_buff1:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

function invoker_quantum_buff1:GetModifierConstantHealthRegen()
	local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetParent())
	return QWERSystemGetnConstBySpell(Q, W, E, R, "quantum", "nHealthRegen")
end

function invoker_quantum_buff1:OnCreated(data)
	CreateQWEParticle(self, 1, 1, data.nAnim)
end

function invoker_quantum_buff1:OnDestroy()
	RemoveQWEParticle(self)
end

function invoker_quantum_buff1:IsDeBuff()
	return false
end

function invoker_quantum_buff1:IsBuff()
	return true
end

function invoker_quantum_buff1:IsHidden()
	return false
end

function invoker_quantum_buff1:IsPermanent()
	return false
end