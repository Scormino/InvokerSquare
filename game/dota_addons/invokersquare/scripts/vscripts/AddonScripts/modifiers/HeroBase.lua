require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')

HeroBase = HeroBase or class({})



function HeroBase:OnRefresh()
	--[[
	local hQWER
	if IsServer() then
		hQWER = GetSSOutQWERLevel(self:GetParent())
	end
	hQWER = Sync(hQWER)
	]]
	local hQWER = QWERSystem:Apply(self, self:GetParent())
	

	local nLevel = self:GetParent():GetLevel()
	local QAttackTime = -GetConst(GetGameConst().quantum.nAttackTime, hQWER)	
	local BaseAttackTime = GetConst(GetGameConst().HeroStats.nAttackTime, nLevel)
	self.nAttackTime = BaseAttackTime + QAttackTime

	local ExpanseModifier = -GetConst(GetGameConst().expanse.nAttackAnimationTime, hQWER)	
	local BaseAttackAnimation = GetConst(GetGameConst().HeroStats.nAttackAnimationTime, nLevel)
	self.nAttackAnimationTime = BaseAttackAnimation + ExpanseModifier

	self.nDamage = GetConst(GetGameConst().HeroStats.nDamage, nLevel)
	self.nAttackRange = GetConst(GetGameConst().HeroStats.nAttackRange, nLevel)
	self.nProjectileSpeed = GetConst(GetGameConst().HeroStats.nProjectileSpeed, nLevel)
	self.nHealth = GetConst(GetGameConst().HeroStats.nHealth, nLevel) - 1
	self.nHealthRegen = GetConst(GetGameConst().HeroStats.nHealthRegen, nLevel)
	self.nMana = GetConst(GetGameConst().HeroStats.nMana, nLevel) - 1
	self.nManaRegen = GetConst(GetGameConst().HeroStats.nManaRegen, nLevel)
	self.nMoveSpeed = GetConst(GetGameConst().HeroStats.nMoveSpeed, nLevel)

	SpellSystem:RefreshComplete(self, hQWER)
end

function HeroBase:OnCreated()
	SpellSystem:BuffOnCreated(self)
end

function HeroBase:DeclareFunctions()
	local hFuncs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,

		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_BASE_MANA_REGEN,

		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_RESPAWN,
	}
	return hFuncs
end


function HeroBase:GetModifierBaseAttack_BonusDamage()
	return self.nDamage
end


function HeroBase:GetModifierBaseAttackTimeConstant()
	return self.nAttackTime
end

function HeroBase:GetModifierAttackPointConstant()
	return self.nAttackAnimationTime
end

function HeroBase:GetModifierAttackRangeBonus()
	return self.nAttackRange
end

function HeroBase:GetModifierProjectileSpeedBonus()
	return self.nProjectileSpeed
end

function HeroBase:GetModifierHealthBonus()
	return self.nHealth
end

function HeroBase:GetModifierConstantHealthRegen()
	return self.nHealthRegen
end

function HeroBase:GetModifierManaBonus()
	return self.nMana
end

function HeroBase:GetModifierBaseRegen()
	return self.nManaRegen
end

function HeroBase:GetModifierMoveSpeedBonus_Constant()
	--print('HeroBase:self.nMoveSpeed=', self.nMoveSpeed, ', IsServer=', IsServer())
	return self.nMoveSpeed
end

function HeroBase:GetModifierMoveSpeedBonus_Constant()
	--print('HeroBase:self.nMoveSpeed=', self.nMoveSpeed, ', IsServer=', IsServer())
	return self.nMoveSpeed
end


function HeroBase:OnRespawn(keys)
	if IsServer() and hMode and hMode.ExpSystem then
		hMode.ExpSystem.Refresh()
	end
end








function HeroBase:IsPurgable()
	return false
end

function HeroBase:IsHidden()
	return true
end

function HeroBase:IsPermanent()
	return true
end

