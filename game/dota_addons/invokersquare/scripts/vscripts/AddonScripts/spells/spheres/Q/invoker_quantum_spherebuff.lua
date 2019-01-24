

require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('AddonScripts/SpellSystem')
require('AddonScripts/spells/spheres/spheres')

invoker_quantum_spherebuff = invoker_quantum_spherebuff or class({})



function invoker_quantum_spherebuff:OnRefresh()
	local hQWER = QWERSystem:Apply(self, self:GetCaster())
	self.nHealthRegen = GetConst(GetGameConst().quantum.nHealthRegen, hQWER)

	SpellSystem:RefreshComplete(self, hQWER)
end

function invoker_quantum_spherebuff:DeclareFunctions()
	return {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
  }
end

function invoker_quantum_spherebuff:OnCreated(data)
	SpellSystem:BuffOnCreated(self)
	--data = Sync(data)
	local nSphereType = 1
	self.nSphereType = nSphereType
	self.nSphereIndex = data and data.nSphereIndex
	CreateShpereParticle(self, nSphereType, self.nSphereIndex, data and data.nAnim)
end

function invoker_quantum_spherebuff:OnDestroy()
	RemoveSphereParticle(self)
end




function invoker_quantum_spherebuff:GetModifierConstantHealthRegen()
	return self.nHealthRegen
end






function invoker_quantum_spherebuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE	--позволяет создать несколько одинаковых баффов
end

function invoker_quantum_spherebuff:GetTexture()
	return 'invoker_quantum'
end

function invoker_quantum_spherebuff:IsDeBuff()
	return false
end

function invoker_quantum_spherebuff:IsBuff()
	return true
end

function invoker_quantum_spherebuff:IsHidden()
	return false
end

function invoker_quantum_spherebuff:IsPermanent()
	return false
end
