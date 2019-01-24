require('AddonScripts/SpellSystem')
FirstStopMoves = FirstStopMoves or class({})

function FirstStopMoves:OnCreated()
	SpellSystem:BuffOnCreated(self)
	self.state = {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		--[MODIFIER_STATE_SILENCED] = true
	}
end

function FirstStopMoves:CheckState()
	return self.state
end

function FirstStopMoves:IsDeBuff()
	return false
end

function FirstStopMoves:IsBuff()
	return true
end

function FirstStopMoves:IsHidden()
	return false
end

function FirstStopMoves:IsPermanent()
	return true
end