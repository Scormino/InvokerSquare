require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('AddonScripts/SpellSystem')
require('AddonScripts/spells/spheres/spheres')

invoker_expanse_spherebuff = invoker_expanse_spherebuff or class({})



function invoker_expanse_spherebuff:OnRefresh()
	--[[
	local hQWER
	if IsServer() then
		hQWER = ApplyQWERBuffLevels(self) --GetSSOutQWERLevel(self:GetParent())
		RefreshTooltipByEnt(self)	
	end
	hQWER = Sync(hQWER, self)
	]]
	local hQWER = QWERSystem:Apply(self, self:GetCaster())
	self.nDamagePerSphere = GetConst(GetGameConst().expanse.nDamagePerSphere, hQWER)

	SpellSystem:RefreshComplete(self, hQWER)
end

function invoker_expanse_spherebuff:OnCreated(data)
	SpellSystem:BuffOnCreated(self)
	--data = Sync(data)
	local nSphereType = 3
	self.nSphereType = nSphereType
	self.nSphereIndex = data and data.nSphereIndex
	CreateShpereParticle(self, nSphereType, self.nSphereIndex, data and data.nAnim)
end

function invoker_expanse_spherebuff:OnDestroy()
	RemoveSphereParticle(self)
end

function invoker_expanse_spherebuff:DeclareFunctions()
	return {
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
  }
end

function invoker_expanse_spherebuff:GetModifierPreAttack_BonusDamage()
	return self.nDamagePerSphere
end


function invoker_expanse_spherebuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE	--позволяет создать несколько одинаковых баффов
end

function invoker_expanse_spherebuff:GetTexture()
	return 'invoker_expanse'
end

function invoker_expanse_spherebuff:IsDeBuff()
	return false
end

function invoker_expanse_spherebuff:IsBuff()
	return true
end

function invoker_expanse_spherebuff:IsHidden()
	return false
end

function invoker_expanse_spherebuff:IsPermanent()
	return false
end