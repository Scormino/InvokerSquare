invoker_expanse_buff3 = class({})

require("AddonScripts/spells/R/invoker_reconstruction")

function invoker_expanse_buff3:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
	return funcs
end

function invoker_expanse_buff3:GetModifierPreAttack_BonusDamage()
	local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetParent())
	return QWERSystemGetnConstBySpell(Q, W, E, R, "expanse", "nDamagePerSphere")
end
function invoker_expanse_buff3:OnCreated(data)
	CreateQWEParticle(self, 3, 3, data.nAnim)
end

function invoker_expanse_buff3:OnDestroy()
	RemoveQWEParticle(self)
end

function invoker_expanse_buff3:IsDeBuff()
	return false
end

function invoker_expanse_buff3:IsBuff()
	return true
end

function invoker_expanse_buff3:IsHidden()
	return false
end

function invoker_expanse_buff3:IsPermanent()
	return false
end