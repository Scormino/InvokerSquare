require('AddonScripts/SpellSystem')

forge_spirits_owner_link_modifier = forge_spirits_owner_link_modifier or class({})

function forge_spirits_owner_link_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
	}
end

function forge_spirits_owner_link_modifier:GetModifierMoveSpeed_Absolute()
	--local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetCaster())
	--return QWERSystemGetnConstBySpell(Q, W, E, R, "invoker_forge_spirits", "nMoveSpeed")
	return self:GetCaster():GetMoveSpeedModifier(self:GetCaster():GetBaseMoveSpeed())
end

function forge_spirits_owner_link_modifier:OnCreated()
	SpellSystem:BuffOnCreated(self)
end

function forge_spirits_owner_link_modifier:IsPurgable()
	return false
end

function forge_spirits_owner_link_modifier:IsHidden()
	return true
end