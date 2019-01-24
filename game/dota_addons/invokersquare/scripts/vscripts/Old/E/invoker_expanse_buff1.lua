invoker_expanse_buff1 = class({})

require("AddonScripts/spells/R/invoker_reconstruction")

function invoker_expanse_buff1:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
	return funcs
end

function invoker_expanse_buff1:GetModifierPreAttack_BonusDamage()
	local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetParent())
	return QWERSystemGetnConstBySpell(Q, W, E, R, "expanse", "nDamagePerSphere")
end

function invoker_expanse_buff1:OnCreated(data)
	CreateQWEParticle(self, 3, 1, data.nAnim)
end

function invoker_expanse_buff1:OnDestroy()
	RemoveQWEParticle(self)
end

function invoker_expanse_buff1:IsDeBuff()
	return false
end

function invoker_expanse_buff1:IsBuff()
	return true
end

function invoker_expanse_buff1:IsHidden()
	return false
end

function invoker_expanse_buff1:IsPermanent()
	return false
end