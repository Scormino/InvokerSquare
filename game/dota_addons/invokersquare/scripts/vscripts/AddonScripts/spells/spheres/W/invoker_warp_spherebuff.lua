

require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('AddonScripts/SpellSystem')
require('AddonScripts/spells/spheres/spheres')

invoker_warp_spherebuff = invoker_warp_spherebuff or class({})



function invoker_warp_spherebuff:OnRefresh()
	--[[
	local hQWER
	if IsServer() then
		hQWER = ApplyQWERBuffLevels(self) --GetSSOutQWERLevel(self:GetParent()) --SyncQWERBuff(self) 
		RefreshTooltipByEnt(self)
	end
	hQWER = Sync(hQWER, self)
	]]
	local hQWER = QWERSystem:Apply(self, self:GetCaster())
	self.nManaRegen = GetConst(GetGameConst().warp.nManaRegen, hQWER)

	SpellSystem:RefreshComplete(self, hQWER)
end

function invoker_warp_spherebuff:OnCreated(data)
	SpellSystem:BuffOnCreated(self)
	--data = Sync(data)
	local nSphereType = 2
	self.nSphereType = nSphereType
	self.nSphereIndex = data and data.nSphereIndex
	CreateShpereParticle(self, nSphereType, self.nSphereIndex, data and data.nAnim)
end


function invoker_warp_spherebuff:OnDestroy()
	--BuffLevelsFree(self)
	RemoveSphereParticle(self)
end

function invoker_warp_spherebuff:DeclareFunctions()
	return {
    MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
  }
end

function invoker_warp_spherebuff:GetModifierConstantManaRegen()
	return self.nManaRegen
end






function invoker_warp_spherebuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE	--позволяет создать несколько одинаковых баффов
end

function invoker_warp_spherebuff:GetTexture()
	return 'invoker_warp'
end

function invoker_warp_spherebuff:IsDeBuff()
	return false
end

function invoker_warp_spherebuff:IsBuff()
	return true
end

function invoker_warp_spherebuff:IsHidden()
	return false
end

function invoker_warp_spherebuff:IsPermanent()
	return false
end
