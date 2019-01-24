require('AddonScripts/ConstUtils')
require('AddonScripts/SpellSystem')

invoker_quantum_passivebuff = invoker_quantum_passivebuff or class({})

function invoker_quantum_passivebuff:OnRefresh()
	local hQWER = QWERSystem:Apply(self, self:GetCaster())
	self.nHealth = GetConst(GetGameConst().quantum.nHealth, hQWER)
	
	SpellSystem:RefreshComplete(self, hQWER)
end

function invoker_quantum_passivebuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS
	}
end

function invoker_quantum_passivebuff:GetModifierHealthBonus()
	return self.nHealth
end

function invoker_quantum_passivebuff:OnCreated()
	SpellSystem:BuffOnCreated(self)
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