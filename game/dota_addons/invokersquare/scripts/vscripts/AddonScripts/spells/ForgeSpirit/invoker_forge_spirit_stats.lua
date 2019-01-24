require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')

invoker_forge_spirit_stats = invoker_forge_spirit_stats or class({})

function invoker_forge_spirit_stats:OnRefresh()
	local eForge = self:GetParent()
	--[[
	local hQWER
	if IsServer() then
		hQWER = GetSSOutQWERLevel(self:GetParent())
	end
	hQWER = Sync(hQWER)
	]]
	local hQWER = QWERSystem:Apply(self, eForge, 'invoker_forge_spirits')
	if IsServer() then
		local nBaseDamage = GetConst(GetGameConst().invoker_forge_spirits.nBaseDamage, hQWER)
		local nHPMax = GetConst(GetGameConst().invoker_forge_spirits.nHPMax, hQWER)
		local nArmorPhysical = GetConst(GetGameConst().invoker_forge_spirits.nArmorPhysical, hQWER)
		eForge:SetBaseDamageMin(nBaseDamage) 
		eForge:SetBaseDamageMax(nBaseDamage)
		eForge:SetBaseMaxHealth(nHPMax)
		eForge:SetPhysicalArmorBaseValue(nArmorPhysical)
	end
	self.nBaseAttackSpeedTime = GetConst(GetGameConst().invoker_forge_spirits.nBaseAttackSpeedTime, hQWER)
	self.nAttackRange = GetConst(GetGameConst().invoker_forge_spirits.nAttackRange, hQWER)

	SpellSystem:RefreshComplete(self, hQWER)
end



function invoker_forge_spirit_stats:OnCreated()
	SpellSystem:BuffOnCreated(self)
end

function invoker_forge_spirit_stats:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end

function invoker_forge_spirit_stats:GetModifierBaseAttackTimeConstant()
	return self.nBaseAttackSpeedTime
end

function invoker_forge_spirit_stats:GetModifierAttackRangeBonus()
	return self.nAttackRange
end



function invoker_forge_spirit_stats:IsDeBuff()
	return false
end

function invoker_forge_spirit_stats:IsBuff()
	return true
end

function invoker_forge_spirit_stats:IsHidden()
	return true
end

function invoker_forge_spirit_stats:IsPermanent()
	return true
end