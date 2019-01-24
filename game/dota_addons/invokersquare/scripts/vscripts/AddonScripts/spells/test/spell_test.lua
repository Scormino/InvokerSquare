spell_test = spell_test or class({})

require('AddonScripts/ModifierSync')
require('AddonScripts/SpellSystem')
LinkLuaModifier( "spell_test_modifier", "AddonScripts/spells/test/spell_test_modifier", LUA_MODIFIER_MOTION_NONE )


function spell_test:OnUpgrade()
	local eCaster = self:GetCaster()

	SpellSystem:ApplyBuff({
			eCaster = eCaster,
			eSourceAbility = self,
			sBuff = 'spell_test_modifier'
		}
	)
	--eCaster:AddNewModifier(eCaster, self, "spell_test_modifier", {})
end

function spell_test:OnSpellStart(keys)
	print('spell_test:OnSpellStart')

end

