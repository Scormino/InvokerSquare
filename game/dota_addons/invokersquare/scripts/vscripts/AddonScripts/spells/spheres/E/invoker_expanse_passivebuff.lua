require('AddonScripts/ConstUtils')
require('AddonScripts/SpellSystem')

invoker_expanse_passivebuff = invoker_expanse_passivebuff or class({})

function invoker_expanse_passivebuff:OnRefresh()
	--[[
	local hQWER
	if IsServer() then
		hQWER = GetSSOutQWERLevel(self:GetParent())
	end
	hQWER = Sync(hQWER, self)
	]]
	local hQWER = QWERSystem:Apply(self, self:GetParent())



	self.nMoveSpeed = GetConst(GetGameConst().expanse.nMoveSpeed, hQWER)
	self.nVision = GetConst(GetGameConst().expanse.nVision, hQWER)
	SpellSystem:RefreshComplete(self, hQWER)
end

function invoker_expanse_passivebuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BONUS_DAY_VISION
	}
end

function invoker_expanse_passivebuff:GetModifierMoveSpeedBonus_Constant()
	return self.nMoveSpeed
end

function invoker_expanse_passivebuff:GetBonusDayVision()
	return self.nVision
end

function invoker_expanse_passivebuff:OnCreated()
	SpellSystem:BuffOnCreated(self)
end


function invoker_expanse_passivebuff:IsDeBuff()
	return false
end

function invoker_expanse_passivebuff:IsBuff()
	return true
end

function invoker_expanse_passivebuff:IsHidden()
	return true
end

function invoker_expanse_passivebuff:IsPermanent()
	return true
end