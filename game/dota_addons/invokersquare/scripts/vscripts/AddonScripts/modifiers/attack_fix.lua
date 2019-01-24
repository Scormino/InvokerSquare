require('AddonScripts/SpellSystem')

attack_fix = attack_fix or class({})


function attack_fix:OnCreated()
	SpellSystem:BuffOnCreated(self)
	self.state = {
		[MODIFIER_STATE_SPECIALLY_DENIABLE] = true
		--[MODIFIER_STATE_NO_TEAM_SELECT] = true
	}
end

function attack_fix:CheckState()
	return self.state
end

function attack_fix:IsDeBuff()
	return false
end

function attack_fix:IsBuff()
	return true
end

function attack_fix:IsHidden()
	return true
end

function attack_fix:IsPermanent()
	return true
end