invoker_quantum_buff2 = class({})

require("AddonScripts/spells/R/invoker_reconstruction")

function invoker_quantum_buff2:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

function invoker_quantum_buff2:GetModifierConstantHealthRegen()
	local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetParent())
	return QWERSystemGetnConstBySpell(Q, W, E, R, "quantum", "nHealthRegen")
end

function invoker_quantum_buff2:OnCreated(data)
	CreateQWEParticle(self, 1, 2, data.nAnim)
end

function invoker_quantum_buff2:OnDestroy()
	RemoveQWEParticle(self)
end

function invoker_quantum_buff2:IsDeBuff()
	return false
end

function invoker_quantum_buff2:IsBuff()
	return true
end

function invoker_quantum_buff2:IsHidden()
	return false
end

function invoker_quantum_buff2:IsPermanent()
	return false
end