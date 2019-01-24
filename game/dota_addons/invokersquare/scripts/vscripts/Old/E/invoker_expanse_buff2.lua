invoker_expanse_buff2 = class({})

require("AddonScripts/spells/R/invoker_reconstruction")

function invoker_expanse_buff2:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
	return funcs
end

function invoker_expanse_buff2:GetModifierPreAttack_BonusDamage()
	local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetParent())
	return QWERSystemGetnConstBySpell(Q, W, E, R, "expanse", "nDamagePerSphere")
end
function invoker_expanse_buff2:OnCreated(data)
	CreateQWEParticle(self, 3, 2, data.nAnim)
end

function invoker_expanse_buff2:OnDestroy()
	RemoveQWEParticle(self)
end

function invoker_expanse_buff2:IsDeBuff()
	return false
end

function invoker_expanse_buff2:IsBuff()
	return true
end

function invoker_expanse_buff2:IsHidden()
	return false
end

function invoker_expanse_buff2:IsPermanent()
	return false
end