LinkLuaModifier( "forge_spirits_owner_link_modifier", "AddonScripts/spells/ForgeSpirit/forge_spirits_owner_link_modifier", LUA_MODIFIER_MOTION_NONE )

forge_spirits_owner_link = forge_spirits_owner_link or class({})

function forge_spirits_owner_link:OnUpgrade()
	local eForge = self:GetOwner()
	local eOwner = eForge:GetOwner() or eForge

	SpellSystem:ApplyBuff({
			eParent = eForge,
			eCaster = eOwner,
			eSourceAbility = self,
			sBuff = 'forge_spirits_owner_link_modifier',
		}
	)
	--eForge:AddNewModifier(eOwner, self, "forge_spirits_owner_link_modifier", {})
end

function forge_spirits_owner_link:IsPurgable()
	return false
end

function forge_spirits_owner_link:IsHidden()
	return true
end

