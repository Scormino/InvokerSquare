require('AddonScripts/ModifierSync')
require('AddonScripts/SpellSystem')

dummy = dummy or class({})


--require('AddonScripts/ConstUtils')
--require('Gamemodes/ClassicMode/QWERSystem')

function dummy:OnCreated(hData)
	SpellSystem:BuffOnCreated(self)

	self.MODIFIER_STATE_NO_HEALTH_BAR = true
	if hData.MODIFIER_STATE_NO_HEALTH_BAR ~= nil then
		self.MODIFIER_STATE_NO_HEALTH_BAR = hData.MODIFIER_STATE_NO_HEALTH_BAR
	end
	if hData.MODIFIER_STATE_NOT_ON_MINIMAP == 1 then
		self.MODIFIER_STATE_NOT_ON_MINIMAP = true
	end
	if hData.MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES == 1 then
		self.MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES = true
	end

	self.params = {
		--[MODIFIER_STATE_PROVIDES_VISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = self.MODIFIER_STATE_NO_HEALTH_BAR,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = self.MODIFIER_STATE_NOT_ON_MINIMAP,
		[MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = self.MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES
		--[MODIFIER_STATE_NO_TEAM_SELECT] = true
	}
end

function dummy:CheckState()
	return self.params
end

function dummy:IsPurgable()
	return false
end

function dummy:IsHidden()
	return true
end

function dummy:IsPermanent()
	return true
end

